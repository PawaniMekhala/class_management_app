class NoticeModel {
  final int id;
  final String type;
  final String message;
  final int count;

  const NoticeModel({
    required this.id,
    required this.type,
    required this.message,
    required this.count,
  });

  // Convert API JSON into a NoticeModel
  factory NoticeModel.fromJson(Map<String, dynamic> json) {
    return NoticeModel(
      id: json['id'] as int,
      type: json['type'] as String,
      message: json['message'] as String,
      count: json['count'] as int,
    );
  }
}
