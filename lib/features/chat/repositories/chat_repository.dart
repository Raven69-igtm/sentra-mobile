import 'package:sentra/core/network/api_client.dart';
import 'package:sentra/features/chat/models/chat_model.dart';
import 'package:dio/dio.dart';

class ChatRepository {
  final Dio dio = ApiClient.dio;

  Future<void> deleteConversation(int senderId, int receiverId) async {
    try {
      final response = await dio.delete('/chats/$senderId/$receiverId');
      if (response.statusCode != 200) {
        throw Exception('Gagal menghapus percakapan: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Gagal menghapus percakapan: $e');
    }
  }

  Future<List<Chat>> getChats(int userId) async {
    try {
      final response = await dio.get('/chats/$userId');
      List<dynamic> data = response.data;
      return data.map((chatJson) => Chat.fromJson(chatJson)).toList();
    } catch (e) {
      throw Exception('Failed to load chats: $e');
    }
  }

  Future<void> markAsRead(int chatId) async {
    try {
      await dio.put('/chats/$chatId/read');
    } catch (e) {
      throw Exception('Failed to mark as read: $e');
    }
  }

  Future<void> editMessage(int chatId, String newMessage) async {
    try {
      await dio.put('/chat/update/$chatId', data: {'message': newMessage});
    } catch (e) {
      throw Exception('Failed to edit message: $e');
    }
  }

  Future<void> deleteMessage(int chatId) async {
    try {
      await dio.delete('/chat/delete/$chatId');
    } catch (e) {
      throw Exception('Failed to delete message: $e');
    }
  }
}
