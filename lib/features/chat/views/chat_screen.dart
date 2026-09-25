import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sentra/features/auth/controllers/user_provider.dart';
import 'package:sentra/features/chat/controllers/chat_controller.dart';
import 'package:sentra/features/chat/models/chat_model.dart';
import 'package:sentra/features/chat/views/room_chat_screen.dart';
import 'package:sentra/features/dashboard/views/home_screen.dart';
import 'package:sentra/core/utils/app_colors.dart';
import 'package:sentra/core/utils/custom_snackbar.dart';

class ChatKonsultasiScreen extends StatefulWidget {
  final int receiverId;
  final String receiverName;

  const ChatKonsultasiScreen({
    super.key,
    required this.receiverId,
    required this.receiverName,
  });

  @override
  _ChatKonsultasiScreenState createState() => _ChatKonsultasiScreenState();
}

class TypingBubble extends StatefulWidget {
  const TypingBubble({super.key});

  @override
  State<TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<TypingBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _dot1;
  late final Animation<double> _dot2;
  late final Animation<double> _dot3;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _dot1 = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
    );
    _dot2 = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 0.8, curve: Curves.easeInOut),
    );
    _dot3 = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.4, 1.0, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _dot(Animation<double> animation) {
    return ScaleTransition(
      scale: Tween(begin: 0.6, end: 1.0).animate(animation),
      child: Container(
        width: 6,
        height: 6,
        margin: const EdgeInsets.symmetric(horizontal: 3),
        decoration: BoxDecoration(
          color: Colors.grey.shade600,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const CircleAvatar(
            radius: 14,
            backgroundColor: Colors.blue,
            child: Icon(Icons.person, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(14),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [_dot(_dot1), _dot(_dot2), _dot(_dot3)],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatKonsultasiScreenState extends State<ChatKonsultasiScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final Map<int, bool> _expandedStateMap = {};
  final Map<int, int> _visibleLinesMap = {};
  final int _initialVisibleLines = 10;
  final int _lineIncrement = 10;
  Timer? _typingTimer;
  int? _idUser;
  bool _hasWelcomeMessage = false;

  @override
  void initState() {
    super.initState();
    _idUser = Provider.of<UserProvider>(context, listen: false).idAkun;

    final chatController = Provider.of<ChatController>(context, listen: false);
    if (_idUser != null) {
      chatController.connectToChat(_idUser!);
      chatController.fetchChats(_idUser!);
    }

    _controller.addListener(() {
      final text = _controller.text;
      _typingTimer?.cancel();
      _typingTimer = Timer(const Duration(milliseconds: 500), () {
        if (_idUser != null) {
          chatController.emitTypingStatus(
            senderId: _idUser!,
            receiverId: widget.receiverId,
            isTyping: text.isNotEmpty,
          );
        }
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_idUser != null) {
        chatController.chats
            .where((chat) => chat.receiverId == _idUser && !chat.isRead)
            .forEach((chat) {
              chatController.markAsRead(chat.idChat);
            });
      }
    });
  }

  void _checkAndShowWelcomeMessage(List<Chat> conversationChats) {
    if (conversationChats.isEmpty && !_hasWelcomeMessage) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _hasWelcomeMessage = true;
          });
        }
      });
    }
  }

  Chat _createWelcomeMessage() {
    return Chat(
      idChat: -1,
      senderId: widget.receiverId,
      receiverId: _idUser ?? 0,
      message:
          "Selamat datang di layanan konsultasi kami! 👋\n\nKami dari tim konsultan profesional siap membantu dan menemani Anda dalam proses konsultasi. Silakan ceritakan keluhan atau pertanyaan yang ingin Anda konsultasikan.\n\nKami akan memberikan pelayanan terbaik untuk Anda.",
      sentAt: "Pesan Otomatis",
      isRead: true,
      isNotified: false,
      isTemporary: false,
      isWelcomeMessage: true,
    );
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
    final message = _controller.text.trim();
    if (message.isNotEmpty && _idUser != null) {
      final chatController = Provider.of<ChatController>(
        context,
        listen: false,
      );
      chatController.sendMessage(
        _idUser!,
        widget.receiverId,
        message,
        repliedToId: chatController.repliedToChat?.idChat,
      );
      _controller.clear();
      chatController.clearRepliedToChat();
      if (_hasWelcomeMessage) {
        setState(() {
          _hasWelcomeMessage = false;
        });
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            0.0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  void _showChatOptions(BuildContext context, Chat chat) {
    // Don't show options for welcome message
    if (chat.idChat == -1) return;

    final chatController = Provider.of<ChatController>(context, listen: false);
    final bool isOwnMessage = chat.senderId == _idUser;
    final bool isDeletedMsg = _isDeletedMessage(chat.message);

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.reply, color: Warna.backgroundIjo),
                title: const Text(
                  'Balas',
                  style: TextStyle(
                    fontFamily: "Mulish",
                    fontWeight: FontWeight.normal,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  chatController.setRepliedToChat(chat);
                },
              ),
              if (isOwnMessage && !isDeletedMsg) ...[
                ListTile(
                  leading: Icon(Icons.edit, color: Warna.backgroundBiru),
                  title: const Text(
                    'Edit',
                    style: TextStyle(
                      fontFamily: "Mulish",
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _showEditMessageDialog(context, chat);
                  },
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text(
                    'Hapus',
                    style: TextStyle(
                      fontFamily: "Mulish",
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    chatController.deleteMessage(chat.idChat, _idUser!);
                    chatController.markDeletedLocally(chat.idChat);
                  },
                ),
              ],
              const Divider(height: 0),
              ListTile(
                leading: const Icon(Icons.cancel, color: Colors.grey),
                title: const Text(
                  'Batal',
                  style: TextStyle(
                    fontFamily: "Mulish",
                    fontWeight: FontWeight.normal,
                  ),
                ),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditMessageDialog(BuildContext context, Chat chat) {
    final TextEditingController editController = TextEditingController(
      text: chat.message,
    );

    showDialog(
      context: context,
      barrierDismissible: false, // Mencegah dismiss dengan tap di luar
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 10,
          contentPadding: const EdgeInsets.all(24),
          title: Row(
            children: [
              Icon(
                Icons.edit_rounded,
                color: Warna.backgroundIjoDark,
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Edit Pesan',
                style: TextStyle(
                  fontFamily: 'Mulish',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          content: Container(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: editController,
                  maxLines: 4,
                  minLines: 2,
                  textCapitalization: TextCapitalization.sentences,
                  style: const TextStyle(
                    fontFamily: 'Mulish',
                    fontSize: 16,
                    height: 1.4,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Edit pesan Anda...',
                    hintStyle: TextStyle(
                      color: Colors.grey[500],
                      fontFamily: 'Mulish',
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.grey[300]!,
                        width: 1.5,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.grey[300]!,
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Warna.backgroundIjoDark,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tekan Simpan untuk menyimpan perubahan',
                  style: TextStyle(
                    fontFamily: 'Mulish',
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
          actions: [
            Container(
              width: double.maxFinite,
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            color: Colors.grey[300]!,
                            width: 1.5,
                          ),
                        ),
                        backgroundColor: Colors.white,
                      ),
                      child: Text(
                        'Batal',
                        style: TextStyle(
                          fontFamily: 'Mulish',
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (editController.text.trim().isNotEmpty) {
                          Provider.of<ChatController>(
                            context,
                            listen: false,
                          ).editMessage(
                            chat.idChat,
                            editController.text.trim(),
                            _idUser!,
                            widget.receiverId,
                          );
                          Navigator.pop(context);

                          CustomSnackbar.show(
                            'Pesan berhasil diedit',
                            warna: Warna.backgroundIjoDark,
                          );
                        } else {
                          CustomSnackbar.show(
                            'Pesan tidak boleh kosong',
                            warna: Colors.orange[600],
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Warna.backgroundIjoDark,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 2,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.save_rounded, size: 18),
                          const SizedBox(width: 8),
                          const Text(
                            'Simpan',
                            style: TextStyle(
                              fontFamily: 'Mulish',
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMessage(Chat chat) {
    final bool isAdmin = chat.senderId != _idUser;
    final bool isExpanded = _expandedStateMap[chat.idChat] ?? false;
    final int visibleLines =
        _visibleLinesMap[chat.idChat] ?? _initialVisibleLines;
    final bool isWelcomeMessage = chat.idChat == -1;

    final chatController = Provider.of<ChatController>(context, listen: false);

    String content = chat.message;
    bool isEdited = false;
    if (content.trim().endsWith('[edited]')) {
      isEdited = true;
      content = content.replaceAll(RegExp(r'\s*\[edited\]$'), '').trim();
    }
    final bool isDeletedMsg = _isDeletedMessage(content);
    if (isDeletedMsg) {
      content = 'Pesan ini telah dihapus';
    }

    final repliedChat =
        chat.repliedToId != null
            ? chatController.chats.firstWhere(
              (c) => c.idChat == chat.repliedToId,
              orElse:
                  () => Chat(
                    idChat: 0,
                    senderId: 0,
                    receiverId: 0,
                    message: 'Pesan tidak ditemukan',
                    sentAt: '',
                    isRead: false,
                    isNotified: false,
                    isTemporary: false,
                  ),
            )
            : null;

    return GestureDetector(
      onLongPress: () => _showChatOptions(context, chat),
      child: Align(
        alignment: isAdmin ? Alignment.centerLeft : Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            crossAxisAlignment:
                isAdmin ? CrossAxisAlignment.start : CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment:
                    isAdmin ? MainAxisAlignment.start : MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (isAdmin) ...[
                    CircleAvatar(
                      radius: 14,
                      backgroundColor:
                          isWelcomeMessage ? Colors.green : Colors.blue,
                      child: Icon(
                        isWelcomeMessage ? Icons.support_agent : Icons.person,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.75,
                      ),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient:
                            (!isAdmin && !isDeletedMsg)
                                ? LinearGradient(
                                  colors:
                                      chat.isTemporary
                                          ? [
                                            Warna.backgroundIjo.withOpacity(
                                              0.7,
                                            ),
                                            Warna.backgroundIjo.withOpacity(
                                              0.55,
                                            ),
                                          ]
                                          : [
                                            Warna.backgroundIjo,
                                            Warna.backgroundIjo.withOpacity(
                                              0.85,
                                            ),
                                          ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                                : null,
                        color:
                            isDeletedMsg
                                ? Colors.grey.shade200
                                : (isAdmin
                                    ? (isWelcomeMessage
                                        ? Colors.green.shade50
                                        : Colors.white)
                                    : null),
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(14),
                          topRight: const Radius.circular(14),
                          bottomLeft: Radius.circular(isAdmin ? 4 : 14),
                          bottomRight: Radius.circular(isAdmin ? 14 : 4),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border:
                            isWelcomeMessage
                                ? Border.all(
                                  color: Colors.green.shade200,
                                  width: 1,
                                )
                                : null,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Welcome message badge
                          if (isWelcomeMessage) ...[
                            Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.green.shade300,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.auto_awesome,
                                    size: 12,
                                    color: Colors.green.shade700,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Pesan Otomatis',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.green.shade700,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: "Mulish",
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          if (repliedChat != null &&
                              repliedChat.idChat != 0) ...[
                            Container(
                              padding: const EdgeInsets.all(8),
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color:
                                    isAdmin
                                        ? Colors.grey.shade100
                                        : Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border(
                                  left: BorderSide(
                                    color:
                                        isAdmin
                                            ? Warna.backgroundIjoDark
                                            : Colors.white70,
                                    width: 3,
                                  ),
                                ),
                              ),
                              child: Text(
                                _isDeletedMessage(repliedChat!.message)
                                    ? 'Pesan ini telah dihapus'
                                    : repliedChat!.message,
                                style: TextStyle(
                                  color:
                                      isAdmin ? Colors.black54 : Colors.white70,
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                  fontFamily: "Mulish",
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                          if (isDeletedMsg)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.delete_outline,
                                  size: 16,
                                  color:
                                      isAdmin
                                          ? Colors.grey.shade600
                                          : Colors.white70,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  content,
                                  style: TextStyle(
                                    color:
                                        isAdmin
                                            ? Colors.grey.shade700
                                            : Colors.white,
                                    fontStyle: FontStyle.italic,
                                    fontFamily: "Mulish",
                                  ),
                                ),
                              ],
                            )
                          else
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final textSpan = TextSpan(
                                  text: content,
                                  style: TextStyle(
                                    color:
                                        isAdmin
                                            ? (isWelcomeMessage
                                                ? Colors.green.shade800
                                                : Colors.black)
                                            : Colors.white,
                                    fontFamily: "Mulish",
                                    fontWeight:
                                        isWelcomeMessage
                                            ? FontWeight.w500
                                            : FontWeight.normal,
                                  ),
                                );
                                final textPainter = TextPainter(
                                  text: textSpan,
                                  maxLines: null,
                                  textDirection: TextDirection.ltr,
                                )..layout(maxWidth: constraints.maxWidth);

                                final int totalLines =
                                    textPainter.computeLineMetrics().length;
                                final bool needsExpansion =
                                    totalLines > _initialVisibleLines;

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        if (isExpanded) {
                                          setState(() {
                                            _expandedStateMap[chat.idChat] =
                                                false;
                                            _visibleLinesMap[chat.idChat] =
                                                _initialVisibleLines;
                                          });
                                        }
                                      },
                                      child: Text(
                                        content,
                                        style: TextStyle(
                                          color:
                                              isAdmin
                                                  ? (isWelcomeMessage
                                                      ? Colors.green.shade800
                                                      : Colors.black)
                                                  : Colors.white,
                                          fontFamily: "Mulish",
                                          fontWeight:
                                              isWelcomeMessage
                                                  ? FontWeight.w500
                                                  : FontWeight.normal,
                                        ),
                                        maxLines:
                                            isExpanded ? null : visibleLines,
                                        overflow:
                                            isExpanded
                                                ? TextOverflow.visible
                                                : TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (isEdited)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(
                                          '• diedit',
                                          style: TextStyle(
                                            color:
                                                isAdmin
                                                    ? Colors.grey.shade600
                                                    : Colors.white70,
                                            fontSize: 10,
                                            fontStyle: FontStyle.italic,
                                            fontFamily: "Mulish",
                                          ),
                                          textAlign: TextAlign.end,
                                        ),
                                      ),
                                    if (needsExpansion && !isExpanded)
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                if (visibleLines < totalLines) {
                                                  final int newVisibleLines =
                                                      visibleLines +
                                                      _lineIncrement;
                                                  _visibleLinesMap[chat
                                                          .idChat] =
                                                      newVisibleLines >
                                                              totalLines
                                                          ? totalLines
                                                          : newVisibleLines;
                                                } else {
                                                  _expandedStateMap[chat
                                                          .idChat] =
                                                      true;
                                                }
                                              });
                                            },
                                            child: const Text(
                                              'Baca selengkapnya',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                decoration:
                                                    TextDecoration.underline,
                                              ),
                                            ),
                                          ),
                                          if (visibleLines >
                                              _initialVisibleLines)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                left: 8.0,
                                              ),
                                              child: GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    _visibleLinesMap[chat
                                                            .idChat] =
                                                        _initialVisibleLines;
                                                  });
                                                },
                                                child: const Text(
                                                  'Ringkas Kembali',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                    decoration:
                                                        TextDecoration
                                                            .underline,
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
                                            _expandedStateMap[chat.idChat] =
                                                false;
                                            _visibleLinesMap[chat.idChat] =
                                                _initialVisibleLines;
                                          });
                                        },
                                        child: const Text(
                                          'Sembunyikan',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            decoration:
                                                TextDecoration.underline,
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
                    const SizedBox(width: 8),
                    const CircleAvatar(
                      radius: 14,
                      backgroundColor: Warna.backgroundIjo,
                      child: Icon(Icons.person, color: Colors.white, size: 16),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              Padding(
                padding: EdgeInsets.only(
                  right: isAdmin ? 0 : 36,
                  left: isAdmin ? 36 : 0,
                ),
                child: Text(
                  chat.sentAt,
                  style: TextStyle(
                    color: isAdmin ? Colors.blueGrey : Colors.blueGrey,
                    fontSize: 11,
                    fontStyle:
                        isWelcomeMessage ? FontStyle.italic : FontStyle.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isDeletedMessage(String message) {
    final t = message.trim().toLowerCase();
    final norm = t.replaceAll(RegExp(r'[^a-z0-9 ]'), '');
    return t.isEmpty ||
        t.contains('pesan ini telah dihapus') ||
        t.contains('pesan telah dihapus') ||
        t.contains('pesan dihapus') ||
        norm.contains('message was deleted') ||
        norm.contains('message deleted') ||
        RegExp(
          r'\[deleted\]|\(deleted\)|<deleted>',
          caseSensitive: false,
        ).hasMatch(message);
  }

  Widget _buildMessageInput() {
    final chatController = Provider.of<ChatController>(context);
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (chatController.repliedToChat != null)
              Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        'Membalas: ${chatController.repliedToChat!.message}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 16),
                      onPressed: chatController.clearRepliedToChat,
                    ),
                  ],
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    minLines: 1,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: "Ketik pesan",
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(color: Colors.transparent),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(color: Colors.transparent),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: Warna.backgroundIjo),
                      ),
                      hintStyle: const TextStyle(
                        color: Colors.grey,
                        fontFamily: 'Mulish',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Warna.backgroundIjo, Warna.backgroundIjoDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ChatController chatController) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Warna.backgroundIjoDark, Warna.backgroundIjo],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      title: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Colors.white24,
            child: Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.receiverName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: 'Mulish',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
      centerTitle: false,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        onPressed: () {
          final String? role =
              Provider.of<UserProvider>(context, listen: false).role;
          if (role == 'user') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RoomChat()),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatController = Provider.of<ChatController>(context);

    final conversationChats =
        chatController.chats.where((chat) {
          return (chat.senderId == _idUser &&
                  chat.receiverId == widget.receiverId) ||
              (chat.senderId == widget.receiverId &&
                  chat.receiverId == _idUser);
        }).toList();

    // Check if we should show welcome message after data is loaded
    _checkAndShowWelcomeMessage(conversationChats);

    // Create combined list with welcome message if needed
    List<Chat> displayChats = [];
    if (_hasWelcomeMessage && conversationChats.isEmpty) {
      displayChats.add(_createWelcomeMessage());
    }
    displayChats.addAll(conversationChats);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(chatController),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/image/bg_chat.jpg', fit: BoxFit.cover),
          ),
          Column(
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    top: kToolbarHeight + MediaQuery.of(context).padding.top,
                    left: 16.0,
                    right: 16.0,
                    bottom: 16.0,
                  ),
                  child: Builder(
                    builder: (_) {
                      final isTyping = chatController.isUserTyping(
                        widget.receiverId,
                      );
                      final totalItems =
                          displayChats.length + (isTyping ? 1 : 0);

                      if (totalItems == 0) {
                        return const Center(
                          child: Text(
                            'Tidak ada pesan',
                            style: TextStyle(color: Colors.white),
                          ),
                        );
                      }

                      return ListView.builder(
                        controller: _scrollController,
                        reverse: true,
                        itemCount: totalItems,
                        itemBuilder: (context, index) {
                          if (index == 0 && isTyping) {
                            return const Padding(
                              padding: EdgeInsets.only(bottom: 6),
                              child: TypingBubble(),
                            );
                          }
                          final adjustedIndex = isTyping ? index - 1 : index;
                          final chat =
                              displayChats[displayChats.length -
                                  1 -
                                  adjustedIndex];
                          return _buildMessage(chat);
                        },
                      );
                    },
                  ),
                ),
              ),
              _buildMessageInput(),
            ],
          ),
        ],
      ),
    );
  }
}
