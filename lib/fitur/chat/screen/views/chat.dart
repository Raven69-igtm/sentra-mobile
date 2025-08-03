import 'dart:async';
import 'package:sentra/fitur/authentikasi/data/provider/userprovider.dart';
import 'package:sentra/fitur/chat/data/controllers/chatcontroller.dart';
import 'package:sentra/fitur/chat/data/models/chatmodel.dart';
import 'package:sentra/fitur/chat/screen/views/roomchat.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sentra/fitur/dashboard/screen/views/homescreen.dart';

class ChatKonsultasiScreen extends StatefulWidget {
  final int receiverId;
  final String receiverName;

  ChatKonsultasiScreen({required this.receiverId, required this.receiverName});

  @override
  _ChatKonsultasiScreenState createState() => _ChatKonsultasiScreenState();
}

class _ChatKonsultasiScreenState extends State<ChatKonsultasiScreen> {
  final TextEditingController _controller = TextEditingController();
  int? _idUser;
  final Map<int, bool> _expandedStateMap = {};
  final Map<int, int> _visibleLinesMap = {};
  final int _initialVisibleLines = 10;
  final int _lineIncrement = 10;
  final ScrollController _scrollController = ScrollController();
  Timer? _typingTimer;

  @override
  void initState() {
    super.initState();
    _idUser = Provider.of<UserProvider>(context, listen: false).idAkun;
    print('User ID: $_idUser, Receiver ID: ${widget.receiverId}');
    final chatController = Provider.of<ChatController>(context, listen: false);
    chatController.connectToChat(_idUser!);
    chatController.fetchChats(_idUser!);
    _controller.addListener(() {
      final text = _controller.text;
      _typingTimer?.cancel();
      _typingTimer = Timer(Duration(milliseconds: 500), () {
        chatController.emitTypingStatus(
          senderId: _idUser!,
          receiverId: widget.receiverId,
          isTyping: text.isNotEmpty,
        );
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      chatController.chats
          .where((chat) => chat.receiverId == _idUser && !chat.isRead)
          .forEach((chat) {
            chatController.markAsRead(chat.idChat);
          });
    });
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    Provider.of<ChatController>(context, listen: false).closeConnection();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final message = _controller.text;
    if (message.isNotEmpty) {
      Provider.of<ChatController>(
        context,
        listen: false,
      ).sendMessage(_idUser!, widget.receiverId, message);
      _controller.clear();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            0.0,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  Widget _buildMessage(Chat chat) {
    bool isAdmin = chat.senderId != _idUser;
    final isExpanded = _expandedStateMap[chat.idChat] ?? false;
    final visibleLines = _visibleLinesMap[chat.idChat] ?? _initialVisibleLines;

    return Align(
      alignment: isAdmin ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4),
        child: Column(
          crossAxisAlignment:
              isAdmin ? CrossAxisAlignment.start : CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment:
                  isAdmin ? MainAxisAlignment.start : MainAxisAlignment.end,
              children: [
                if (isAdmin) ...[
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.blue,
                    child: Icon(Icons.person, color: Colors.white, size: 16),
                  ),
                  SizedBox(width: 8),
                ],
                Flexible(
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:
                          !isAdmin && chat.isTemporary
                              ? Colors.green.shade100.withOpacity(0.7)
                              : !isAdmin
                              ? Colors.green.shade100
                              : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final textSpan = TextSpan(
                              text: chat.message,
                              style: TextStyle(color: Colors.black),
                            );

                            final textPainter = TextPainter(
                              text: textSpan,
                              maxLines: null,
                              textDirection: TextDirection.ltr,
                            )..layout(maxWidth: constraints.maxWidth);

                            final totalLines =
                                textPainter.computeLineMetrics().length;
                            final needsExpansion =
                                totalLines > _initialVisibleLines;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    if (isExpanded) {
                                      setState(() {
                                        _expandedStateMap[chat.idChat] = false;
                                        _visibleLinesMap[chat.idChat] =
                                            _initialVisibleLines;
                                      });
                                    }
                                  },
                                  child: Text(
                                    chat.message,
                                    style: TextStyle(color: Colors.black),
                                    maxLines: isExpanded ? null : visibleLines,
                                    overflow:
                                        isExpanded
                                            ? TextOverflow.visible
                                            : TextOverflow.ellipsis,
                                  ),
                                ),
                                if (needsExpansion && !isExpanded)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            if (visibleLines < totalLines) {
                                              // Tambahkan baris yang ditampilkan
                                              final newVisibleLines =
                                                  visibleLines + _lineIncrement;
                                              _visibleLinesMap[chat.idChat] =
                                                  newVisibleLines > totalLines
                                                      ? totalLines
                                                      : newVisibleLines;
                                            } else {
                                              // Jika sudah mencapai akhir, expand semua
                                              _expandedStateMap[chat.idChat] =
                                                  true;
                                            }
                                          });
                                        },
                                        child: Text(
                                          visibleLines < totalLines
                                              ? 'Baca selengkapnya'
                                              : 'Tampilkan semua',
                                          style: TextStyle(
                                            color: Colors.blue,
                                            fontSize: 12,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                        ),
                                      ),
                                      if (visibleLines > _initialVisibleLines)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 8.0,
                                          ),
                                          child: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                _visibleLinesMap[chat.idChat] =
                                                    _initialVisibleLines;
                                              });
                                            },
                                            child: Text(
                                              'Ringkas Kembali',
                                              style: TextStyle(
                                                color: Colors.blue,
                                                fontSize: 12,
                                                decoration:
                                                    TextDecoration.underline,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                if (isExpanded)
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _expandedStateMap[chat.idChat] = false;
                                        _visibleLinesMap[chat.idChat] =
                                            _initialVisibleLines;
                                      });
                                    },
                                    child: Text(
                                      'Sembunyikan',
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontSize: 12,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                if (!isAdmin) ...[
                  SizedBox(width: 8),
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.green,
                    child: Icon(Icons.person, color: Colors.white, size: 16),
                  ),
                ],
              ],
            ),
            SizedBox(height: 4),
            Padding(
              padding: EdgeInsets.only(
                right: isAdmin ? 0 : 36,
                left: isAdmin ? 36 : 0,
              ),
              child: Text(
                chat.sentAt,
                style: TextStyle(color: Colors.white60, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "Type a message",
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send, color: Colors.green),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String? role = Provider.of<UserProvider>(context, listen: false).role;
    final chatController = Provider.of<ChatController>(context);
    print('Building UI with ${chatController.chats.length} chats');
    print(
      'isUserTyping(${widget.receiverId}): ${chatController.isUserTyping(widget.receiverId)}',
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0.0,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Color(0xFF3E3650),
      appBar: AppBar(
        backgroundColor: Color(0xFF3E3650),
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.receiverName,
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            if (chatController.isUserTyping(widget.receiverId))
              Text(
                "Sedang mengetik...",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            print(role);
            if (role == 'user') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                       (context) => HomeScreen()
                ),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RoomChat()),
              );
            }
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child:
                  chatController.chats.isEmpty
                      ? Center(
                        child: Text(
                          'No chats available',
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                      : Builder(
                        builder: (context) {
                          final filteredChats =
                              chatController.chats.asMap().entries.where((
                                entry,
                              ) {
                                final chat = entry.value;
                                return (chat.senderId == _idUser &&
                                        chat.receiverId == widget.receiverId) ||
                                    (chat.senderId == widget.receiverId &&
                                        chat.receiverId == _idUser);
                              }).toList();
                          if (filteredChats.isEmpty) {
                            return Center(
                              child: Text(
                                'No chats with this user',
                                style: TextStyle(color: Colors.white),
                              ),
                            );
                          }
                          return ListView.builder(
                            controller: _scrollController,
                            reverse: true,
                            itemCount: chatController.chats.length,
                            itemBuilder: (context, index) {
                              final chat =
                                  chatController.chats[chatController
                                          .chats
                                          .length -
                                      1 -
                                      index];
                              print(
                                'Chat: sender=${chat.senderId}, receiver=${chat.receiverId}, user=$_idUser, target=${widget.receiverId}, isTemporary=${chat.isTemporary}',
                              );
                              if ((chat.senderId == _idUser &&
                                      chat.receiverId == widget.receiverId) ||
                                  (chat.senderId == widget.receiverId &&
                                      chat.receiverId == _idUser)) {
                                print('Displaying chat: ${chat.message}');
                                return _buildMessage(chat);
                              } else {
                                print('Chat filtered out: ${chat.message}');
                              }
                              return SizedBox.shrink();
                            },
                          );
                        },
                      ),
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }
}
