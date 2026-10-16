import 'package:flutter/material.dart';

import '../core/services/notification_service.dart';
import '../models/app_notification_model.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _service = NotificationService();

  List<AppNotificationModel> notifications = [];
  bool isLoading = false;
  bool isUpdating = false;
  String? errorMessage;

  int? _instituteId;

  int get unreadCount =>
      notifications.where((notification) => !notification.isRead).length;

  Future<void> loadNotifications(int instituteId) async {
    _instituteId = instituteId;
    isLoading = true;
    errorMessage = null;
    notifications = [];
    notifyListeners();

    try {
      notifications = await _service.getNotifications(instituteId);
    } catch (error) {
      errorMessage = 'Failed to load notifications.';
      debugPrint('Notification error: $error');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAllAsRead() async {
    if (_instituteId == null || isUpdating) return;

    isUpdating = true;
    notifyListeners();

    try {
      await _service.markAllAsRead(_instituteId!);

      for (final notification in notifications) {
        notification.isRead = true;
      }

      errorMessage = null;
    } catch (error) {
      errorMessage = 'Failed to mark notifications as read.';
    } finally {
      isUpdating = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(int notificationId) async {
    if (_instituteId == null) return;

    try {
      await _service.markAsRead(_instituteId!, notificationId);

      for (final notification in notifications) {
        if (notification.id == notificationId) {
          notification.isRead = true;
          break;
        }
      }

      notifyListeners();
    } catch (error) {
      errorMessage = 'Failed to update notification.';
      notifyListeners();
    }
  }
}
