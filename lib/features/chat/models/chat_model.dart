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
      idChat: json['id_chat'] is int
          ? json['id_chat']
          : int.tryParse((json['id_chat'] ?? json['id'] ?? json['chat_id'])?.toString() ?? '') ?? 0,
      senderId: json['sender_id'] is int
          ? json['sender_id']
          : int.tryParse((json['sender_id'] ?? json['senderId'])?.toString() ?? '') ?? 0,
      receiverId: json['receiver_id'] is int
          ? json['receiver_id']
          : int.tryParse((json['receiver_id'] ?? json['receiverId'])?.toString() ?? '') ?? 0,
      message: (json['message'] ?? json['pesan'])?.toString() ?? '',
      repliedToId: (json['replied_to_id'] ?? json['repliedToId']) != null
          ? ((json['replied_to_id'] ?? json['repliedToId']) is int
              ? (json['replied_to_id'] ?? json['repliedToId'])
              : int.tryParse((json['replied_to_id'] ?? json['repliedToId'])?.toString() ?? ''))
          : null,
      sentAt: (json['sent_at'] ?? json['created_at'] ?? json['time'])?.toString() ?? '',
      isRead: json['is_read'] == 1 || json['is_read'] == true || json['is_read'] == '1',
      isNotified: json['is_notified'] == 1 || json['is_notified'] == true || json['is_notified'] == '1',
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
