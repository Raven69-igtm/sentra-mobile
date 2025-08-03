import 'package:sentra/core/network/api_client.dart';
import 'package:sentra/fitur/chat/data/models/chatmodel.dart';
import 'package:dio/dio.dart';

class ChatRepository {
  final Dio dio = Dio();
  final String baseUrl = 'https://${ApiClient.baseUrl}/api';

  ChatRepository() {
    dio.options.headers['Accept'] = 'application/json';
  }

  Future<List<Chat>> getChats(int userId) async {
    try {
      final response = await dio.get('$baseUrl/chats/$userId');
      List<dynamic> data = response.data;
      return data.map((chatJson) => Chat.fromJson(chatJson)).toList();
    } catch (e) {
      throw Exception('Failed to load chats: $e');
    }
  }

  Future<void> markAsRead(int chatId) async {
    try {
      await dio.put('$baseUrl/chats/$chatId/read');
    } catch (e) {
      throw Exception('Failed to mark as read: $e');
    }
  }
}
