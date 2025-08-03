class NotificationModel {
  final String id;
  final String title;
  final String date;
  final String message;

  NotificationModel({
    required this.id,
    required this.title,
    required this.date,
    required this.message,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'date': date,
    'message': message,
  };

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      title: json['title'],
      date: json['date'],
      message: json['message'],
    );
  }
}
