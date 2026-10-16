class AppNotificationModel {
  final int id;
  final int instituteId;
  final String title;
  final String message;
  final String type;
  final DateTime createdAt;
  bool isRead;

  AppNotificationModel({
    required this.id,
    required this.instituteId,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    this.isRead = false,
  });

  // Convert backend JSON into a notification object.
  factory AppNotificationModel.fromJson(Map<String, dynamic> json) {
    return AppNotificationModel(
      id: json['id'] as int,
      instituteId: json['institute_id'] as int,
      title: json['title'] as String,
      message: json['message'] as String,
      type: json['type'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      isRead: json['is_read'] as bool? ?? false,
    );
  }
}
