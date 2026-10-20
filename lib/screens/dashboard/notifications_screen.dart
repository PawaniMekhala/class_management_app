import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/notification_provider.dart';
import '../../widgets/cards/notification_card.dart';
import '../../widgets/common/app_bottom_nav_bar.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();

    return Scaffold(
      backgroundColor: AppColors.authBackground,

      appBar: AppBar(
        backgroundColor: AppColors.authBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.authHeading),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.authHeading,
          ),
        ),
        actions: [
          TextButton(
            onPressed: provider.unreadCount == 0 || provider.isUpdating
                ? null
                : () => provider.markAllAsRead(),
            child: const Text('Mark all read', style: TextStyle(fontSize: 11)),
          ),
        ],
      ),

      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.errorMessage != null && provider.notifications.isEmpty
          ? Center(child: Text(provider.errorMessage!))
          : provider.notifications.isEmpty
          ? const Center(child: Text('No notifications yet'))
          : ListView.separated(
              itemCount: provider.notifications.length,
              separatorBuilder: (_, _) =>
                  const Divider(height: 1, color: AppColors.authFieldBorder),
              itemBuilder: (context, index) {
                final notification = provider.notifications[index];

                return NotificationCard(
                  key: ValueKey(notification.id),
                  notification: notification,
                  onTap: () async {
                    await provider.markAsRead(notification.id);

                    // TO DO: Navigate to the relevant screen
                    // based on notification.type.
                  },
                );
              },
            ),

      bottomNavigationBar: AppBottomNavBar(
        selectedIndex: 0,
        onTabSelected: (index) {
          if (index == 0) {
            Navigator.pop(context);
          }

          // Modules and Profile will be connected later.
        },
      ),
    );
  }
}
