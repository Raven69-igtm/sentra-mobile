import 'dart:async';
import 'package:sentra/core/network/api_client.dart';
import 'package:sentra/features/chat/models/chat_model.dart';
import 'package:sentra/features/chat/repositories/chat_repository.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';

class ChatController extends ChangeNotifier {
  final ChatRepository _repository = ChatRepository();
  List<Chat> _chats = [];
  WebSocketChannel? _channel;
  bool _wsReady = false;
  bool _shouldReconnect = true;
  final Map<int, bool> _typingStatusMap = {};
  Chat? _repliedToChat;

  List<Chat> get chats => _chats;
  bool isUserTyping(int userId) => _typingStatusMap[userId] ?? false;
  Chat? get repliedToChat => _repliedToChat;

  void setRepliedToChat(Chat? chat) {
    _repliedToChat = chat;
    notifyListeners();
  }

  void clearRepliedToChat() {
    _repliedToChat = null;
    notifyListeners();
  }

  void emitTypingStatus({
    required int senderId,
    required int receiverId,
    required bool isTyping,
  }) {
    if (_channel == null) {
      print('Error: WebSocket channel is null');
      return;
    }
    try {
      final typingData = {
        'type': 'typing',
        'senderId': senderId,
        'receiverId': receiverId,
        'isTyping': isTyping,
      };
      print('Sending typing status: $typingData');
      _channel!.sink.add(jsonEncode(typingData));
      print('Typing status sent successfully');
    } catch (e) {
      print('Error sending typing status: $e');
    }
  }

  void connectToChat(int userId) {
    _shouldReconnect = true;
    try {
      print('Attempting to connect to WebSocket: ${ApiClient.wsUrl} for userId: $userId');
      _channel = WebSocketChannel.connect(Uri.parse(ApiClient.wsUrl));
      _wsReady = false;
      _channel!.ready.then(
        (_) {
          _wsReady = true;
          print('WebSocket connected for userId: $userId');
        },
        onError: (error) {
          _wsReady = false;
          print('WebSocket connection failed for userId $userId: $error');
        },
      );
      _channel!.sink.add(
        jsonEncode({
          'type': 'register',
          'user_id': userId.toString(),
          'user_type': 'user',
        }),
      );
      print('Registration sent for userId: $userId');
      _channel!.stream.listen(
        (message) {
          _onNewMessage(message);
        },
        onError: (error) {
          _wsReady = false;
          print('WebSocket error for userId $userId: $error');
          if (_shouldReconnect) {
            Future.delayed(Duration(seconds: 5), () => connectToChat(userId));
          }
        },
        onDone: () {
          _wsReady = false;
          print('WebSocket connection closed for userId $userId');
          if (_shouldReconnect) {
            Future.delayed(Duration(seconds: 5), () => connectToChat(userId));
          }
        },
      );
    } catch (e) {
      _wsReady = false;
      print('Error connecting to WebSocket for userId $userId: $e');
      if (_shouldReconnect) {
        Future.delayed(Duration(seconds: 5), () => connectToChat(userId));
      }
    }
  }

  void markDeletedLocally(int chatId) {
    final i = chats.indexWhere((c) => c.idChat == chatId);
    if (i == -1) return;
    final c = chats[i];
    chats[i] = Chat(
      idChat: c.idChat,
      senderId: c.senderId,
      receiverId: c.receiverId,
      message: '[deleted]',
      sentAt: c.sentAt,
      isRead: c.isRead,
      isNotified: c.isNotified,
      isTemporary: c.isTemporary,
    );
    notifyListeners();
  }

  Future<void> fetchChats(int userId) async {
    try {
      _chats = await _repository.getChats(userId);
      print('Fetched ${_chats.length} chats for userId $userId');
      for (var chat in _chats) {
        print(
          'Chat: sender=${chat.senderId}, receiver=${chat.receiverId}, message=${chat.message}, isTemporary=${chat.isTemporary}',
        );
      }
      notifyListeners();
    } catch (e) {
      print('Error fetching chats: $e');
    }
  }

  void _onNewMessage(dynamic message) {
    try {
      print('Received message: $message');
      final data = jsonDecode(message);
      if (data['type'] == 'new_message') {
        final chat = Chat.fromJson(data);
        final index = _chats.indexWhere(
          (c) =>
              c.isTemporary &&
              c.message == chat.message &&
              c.senderId == chat.senderId &&
              c.receiverId == chat.receiverId &&
              c.repliedToId == chat.repliedToId,
        );
        if (index != -1) {
          final existing = _chats[index];
          final updatedChat = Chat(
            idChat: chat.idChat,
            senderId: chat.senderId,
            receiverId: chat.receiverId,
            message: chat.message,
            sentAt: chat.sentAt,
            isRead: chat.isRead,
            isNotified: chat.isNotified,
            repliedToId: chat.repliedToId ?? existing.repliedToId,
            isTemporary: false,
          );

          _chats[index] = updatedChat;
          print('Replaced temporary chat with server chat: ${chat.message}');
        } else if (!_chats.any((c) => c.idChat == chat.idChat)) {
          _chats.add(chat);
          print('New chat added: ${chat.message}');
        } else {
          print('Chat already exists, skipping: ${chat.message}');
        }
        notifyListeners();
      } else if (data['type'] == 'typing') {
        final senderId = int.parse(data['senderId'].toString());
        final isTyping = data['isTyping'] == true;
        print('Received typing status: senderId=$senderId, isTyping=$isTyping');
        _typingStatusMap[senderId] = isTyping;
        if (isTyping) {
          Future.delayed(Duration(seconds: 5), () {
            if (_typingStatusMap[senderId] == true) {
              _typingStatusMap[senderId] = false;
              notifyListeners();
            }
          });
        }
        notifyListeners();
      } else if (data['type'] == 'message_edited') {
        final chatId = data['chat_id'];
        final index = _chats.indexWhere((c) => c.idChat == chatId);
        if (index != -1) {
          final updatedChat = Chat(
            idChat: chatId,
            senderId: _chats[index].senderId,
            receiverId: _chats[index].receiverId,
            message: data['new_message'],
            sentAt: data['sent_at'],
            isRead: _chats[index].isRead,
            isNotified: _chats[index].isNotified,
            isTemporary: false,
            repliedToId: _chats[index].repliedToId,
          );
          _chats[index] = updatedChat;
          print('Updated chat locally: ${updatedChat.message}');
          notifyListeners();
        }
      } else if (data['type'] == 'message_deleted') {
        final chatId = data['chat_id'];
        _chats.removeWhere((c) => c.idChat == chatId);
        print('Deleted chat with id: $chatId');
        notifyListeners();
      }
    } catch (e) {
      print('Error parsing message: $e');
    }
  }

  void sendMessage(
    int senderId,
    int receiverId,
    String message, {
    int? repliedToId,
  }) {
    if (message.isNotEmpty) {
      final localChat = Chat(
        idChat: DateTime.now().millisecondsSinceEpoch,
        senderId: senderId,
        receiverId: receiverId,
        message: message,
        sentAt: DateTime.now().toIso8601String(),
        isRead: false,
        isNotified: true,
        isTemporary: true,
        repliedToId: repliedToId,
      );
      _chats.add(localChat);
      notifyListeners();
      // Pesan selalu dikirim lewat REST API agar backend memakai identitas
      // dari token, bukan sender_id yang dikirim aplikasi.
      _sendMessageHttp(senderId, receiverId, message, repliedToId);
    } else {
      print('Message is empty, not sending');
    }
  }

  Future<void> _sendMessageHttp(
    int senderId,
    int receiverId,
    String message,
    int? repliedToId,
  ) async {
    try {
      await _repository.sendMessage(
        receiverId: receiverId,
        message: message,
        repliedToId: repliedToId,
      );
      print('HTTP POST chat berhasil');
      // Sinkronkan dengan server agar pesan sementara mendapat id_chat asli.
      await fetchChats(senderId);
    } catch (e) {
      print('HTTP POST chat gagal: $e');
    }
  }

  Future<void> editMessage(
    int chatId,
    String newMessage,
    int senderId,
    int receiverId,
  ) async {
    if (newMessage.isEmpty) {
      print('Edited message is empty, not sending');
      return;
    }
    try {
      await _repository.editMessage(chatId, newMessage);
      await fetchChats(senderId);
    } catch (e) {
      print('Gagal mengubah pesan: $e');
    }
  }

  Future<void> deleteMessage(int chatId, int senderId) async {
    try {
      await _repository.deleteMessage(chatId);
      await fetchChats(senderId);
    } catch (e) {
      print('Gagal menghapus pesan: $e');
    }
  }

  Future<void> markAsRead(int chatId) async {
    try {
      await _repository.markAsRead(chatId);
      final chat = _chats.firstWhere((chat) => chat.idChat == chatId);
      chat.isRead = true;
      notifyListeners();
    } catch (e) {
      print('Error marking as read: $e');
    }
  }

  void closeConnection() {
    _shouldReconnect = false;
    _wsReady = false;
    _channel?.sink.close();
    _channel = null;
  }

  /// Membersihkan state chat saat logout / ganti akun.
  void reset() {
    closeConnection();
    _chats = [];
    _typingStatusMap.clear();
    _repliedToChat = null;
    notifyListeners();
  }
}
