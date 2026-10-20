import '../../models/app_notification_model.dart';

class NotificationService {
  // Temporary in-memory data for UI testing.
  final List<AppNotificationModel> _notifications = [
    AppNotificationModel(
      id: 1,
      instituteId: 1,
      title: 'Leave request — Prasad Wijesinghe',
      message:
          'Prasad Wijesinghe asks for leave 21 Oct–21 Oct '
          '(Exam paper marking panel). 1 class affected.',
      type: 'leave_request',
      createdAt: DateTime(2026, 10, 4, 21, 49),
    ),
    AppNotificationModel(
      id: 2,
      instituteId: 1,
      title: 'Missing tutes — 2027 A/L Combined Maths (Theory)',
      message:
          'Prasad Wijesinghe reports missing tutes in '
          '2027 A/L Combined Maths (Theory).',
      type: 'missing_tutes',
      createdAt: DateTime(2026, 10, 4, 20, 30),
    ),
  ];

  Future<List<AppNotificationModel>> getNotifications(int instituteId) async {
    // TO DO: API INTEGRATION
    // GET /api/institutes/{instituteId}/notifications

    await Future.delayed(const Duration(milliseconds: 300));

    return _notifications
        .where((notification) => notification.instituteId == instituteId)
        .toList();
  }

  Future<void> markAllAsRead(int instituteId) async {
    // TO DO: API INTEGRATION
    // PATCH /api/institutes/{instituteId}/notifications/read-all
    //
    // Only update local data after the API confirms success.

    await Future.delayed(const Duration(milliseconds: 200));

    for (final notification in _notifications) {
      if (notification.instituteId == instituteId) {
        notification.isRead = true;
      }
    }
  }

  Future<void> markAsRead(int instituteId, int notificationId) async {
    // TO DO: API INTEGRATION
    // PATCH /api/institutes/{instituteId}/notifications/{notificationId}/read

    await Future.delayed(const Duration(milliseconds: 200));

    for (final notification in _notifications) {
      if (notification.instituteId == instituteId &&
          notification.id == notificationId) {
        notification.isRead = true;
      }
    }
  }
}
