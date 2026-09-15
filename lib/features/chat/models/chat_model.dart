class Chat {
  final int idChat;
  final int senderId;
  final int receiverId;
  final String message;
  final String sentAt;
  late final bool isRead;
  final bool isNotified;
  final bool isTemporary;
  final bool? isWelcomeMessage;
  final int? repliedToId;

  Chat({
    required this.idChat,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.sentAt,
    required this.isRead,
    required this.isNotified,
    required this.isTemporary,
    this.repliedToId,
    this.isWelcomeMessage,

  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      idChat: json['id_chat'],
      senderId: json['sender_id'],
      receiverId: json['receiver_id'],
      message: json['message'],
      repliedToId: json['replied_to_id'],
      sentAt: json['sent_at'],
      isRead: json['is_read'] == 1,
      isNotified: json['is_notified'] == 1,
      isTemporary: false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_chat': idChat,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'message': message,
      'sent_at': sentAt,
      'is_read': isRead ? 1 : 0,
      'is_notified': isNotified ? 1 : 0,
      'is_temporary': isTemporary ? 1 : 0,
      'replied_to_id': repliedToId,
    };
  }
}
