import 'package:sentra/fitur/authentikasi/data/provider/userprovider.dart';
import 'package:sentra/fitur/chat/data/repositories/chatrepository.dart';
import 'package:sentra/fitur/chat/screen/views/chat.dart';
import 'package:sentra/fitur/dashboard/screen/views/homescreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sentra/core/network/api_client.dart';
import 'package:shimmer/shimmer.dart';

class VChatUser {
  final String name;
  final String lastMessage;
  final String time;
  final bool isOnline;
  final int userId;

  VChatUser({
    required this.name,
    required this.lastMessage,
    required this.time,
    required this.isOnline,
    required this.userId,
  });
}

class RoomChat extends StatefulWidget {
  @override
  _RoomChatState createState() => _RoomChatState();
}

class _RoomChatState extends State<RoomChat> {
  final ChatRepository _repository = ChatRepository();
  List<VChatUser> users = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    try {
      final userId = Provider.of<UserProvider>(context, listen: false).idAkun;
      print('Fetching conversations for userId: $userId');
      final response = await _repository.dio.get(
        'https://${ApiClient.baseUrl}/api/conversations/$userId',
      );
      print('API response: ${response.data}');
      final data = response.data is List ? response.data : [];
      setState(() {
        users =
            data
                .map((user) {
                  print('Parsing user: $user');
                  return VChatUser(
                    name: user['name'] ?? 'Unknown',
                    lastMessage: user['last_message'] ?? '',
                    time: user['time'] ?? '',
                    isOnline: user['is_online'] == 1,
                    userId: user['user_id'] ?? 0,
                  );
                })
                .toList()
                .cast<VChatUser>();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load conversations: $e';
      });
      print('Error fetching users: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('RoomChat Admin'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () =>Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()),
              ),
        ),
      ),
      body:
          isLoading
              ? _buildShimmerEffect() 
              : errorMessage != null
              ? Center(
                child: Text(errorMessage!, style: TextStyle(color: Colors.red)),
              )
              : users.isEmpty
              ? Center(
                child: Text(
                  'Belum ada percakapan',
                  style: TextStyle(color: Colors.grey),
                ),
              )
              : ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return ListTile(
                    leading: Stack(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.grey.shade300,
                          child: Icon(
                            Icons.account_circle_rounded,
                            size: 50,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        if (user.isOnline)
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    title: Text(
                      user.name,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1, 
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(user.lastMessage,
                    overflow: TextOverflow.ellipsis,
                      maxLines: 1, ),
                    trailing: Text(
                      user.time,
                      style: TextStyle(color: Colors.grey),
                    ),
                    onTap: () {
                      print(
                        'Navigating to ChatKonsultasiScreen with receiverId: ${user.userId} and  receiverName: ${user.name}',
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  ChatKonsultasiScreen(receiverId: user.userId,receiverName: user.name,),
                        ),
                      );
                    },
                  );
                },
              ),
    );
  }
  Widget _buildShimmerEffect() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        itemCount: 6,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 16,
                        color: Colors.white,
                      ),
                      SizedBox(height: 8),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.5,
                        height: 14,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
                Container(width: 50, height: 14, color: Colors.white),
              ],
            ),
          );
        },
      ),
    );
  }
}
