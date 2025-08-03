import 'dart:async';
import 'package:sentra/core/network/api_client.dart';
import 'package:sentra/fitur/chat/data/models/chatmodel.dart';
import 'package:sentra/fitur/chat/data/repositories/chatrepository.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';

class ChatController extends ChangeNotifier {
  final ChatRepository _repository = ChatRepository();
  List<Chat> _chats = [];
  WebSocketChannel? _channel;
  final Map<int, bool> _typingStatusMap = {};

  List<Chat> get chats => _chats;
  bool isUserTyping(int userId) => _typingStatusMap[userId] ?? false;

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
    try {
      print(
        'Attempting to connect to WebSocket: ws://${ApiClient.baseUrl}:8123 for userId: $userId',
      );
      _channel = WebSocketChannel.connect(
        Uri.parse('ws://13.250.111.64:3001'),
      );
      print('WebSocket connected for userId: $userId');
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
          print('WebSocket error for userId $userId: $error');
          Future.delayed(Duration(seconds: 5), () => connectToChat(userId));
        },
        onDone: () {
          print('WebSocket connection closed for userId $userId');
          Future.delayed(Duration(seconds: 5), () => connectToChat(userId));
        },
      );
    } catch (e) {
      print('Error connecting to WebSocket for userId $userId: $e');
      Future.delayed(Duration(seconds: 5), () => connectToChat(userId));
    }
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
        // Cek apakah ada pesan sementara yang cocok
        final index = _chats.indexWhere(
          (c) =>
              c.isTemporary &&
              c.message == chat.message &&
              c.senderId == chat.senderId &&
              c.receiverId == chat.receiverId,
        );
        if (index != -1) {
          // Ganti pesan sementara dengan pesan dari server
          _chats[index] = chat;
          print('Replaced temporary chat with server chat: ${chat.message}');
        } else if (!_chats.any((c) => c.idChat == chat.idChat)) {
          // Tambahkan hanya jika idChat belum ada
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
      } else {
        print('Unknown message type: ${data['type']}');
      }
    } catch (e) {
      print('Error parsing message: $e');
    }
  }

  void sendMessage(int senderId, int receiverId, String message) {
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
      );
      _chats.add(localChat);
      notifyListeners();
      final chat = {
        'type': 'send_message',
        'sender_id': senderId,
        'receiver_id': receiverId,
        'message': message,
      };
      print('Sending message to WebSocket: $chat');
      if (_channel == null) {
        print('Error: WebSocket channel is null');
        return;
      }
      try {
        _channel!.sink.add(jsonEncode(chat));
        print('Message sent successfully to WebSocket');
      } catch (e) {
        print('Error sending message to WebSocket: $e');
      }
    } else {
      print('Message is empty, not sending');
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
    _channel?.sink.close();
  }
}
