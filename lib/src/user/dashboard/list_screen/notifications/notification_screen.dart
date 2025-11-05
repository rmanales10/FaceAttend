import 'package:app_attend/src/user/dashboard/list_screen/notifications/notification_controller.dart';
import 'package:app_attend/src/widgets/color_constant.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NotificationController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: blue),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Notifications',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: blue,
          ),
        ),
        actions: [
          Obx(() {
            if (controller.unreadCount.value > 0) {
              return TextButton(
                onPressed: () => controller.markAllAsRead(),
                child: Text(
                  'Mark all read',
                  style: TextStyle(
                    color: blue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }
            return SizedBox.shrink();
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(color: blue),
          );
        }

        if (controller.notifications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.notifications_none,
                  size: 80,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 16),
                Text(
                  'No notifications',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'You\'re all caught up!',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.notifications.length,
          itemBuilder: (context, index) {
            final notification = controller.notifications[index];
            return _buildNotificationCard(notification, controller);
          },
        );
      }),
    );
  }

  Widget _buildNotificationCard(
      AppNotification notification, NotificationController controller) {
    Color cardColor =
        notification.isRead ? Colors.white : blue.withOpacity(0.05);

    Color borderColor =
        notification.isRead ? Colors.grey[200]! : blue.withOpacity(0.3);

    IconData iconData = _getIconForType(notification.type);
    Color iconColor = _getColorForType(notification.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (!notification.isRead) {
              controller.markAsRead(notification.id);
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    iconData,
                    color: iconColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: notification.isRead
                                    ? FontWeight.w500
                                    : FontWeight.bold,
                                color: blue,
                              ),
                            ),
                          ),
                          if (!notification.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: blue,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        notification.message,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatDate(notification.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    color: Colors.grey[400],
                    size: 20,
                  ),
                  onPressed: () =>
                      controller.deleteNotification(notification.id),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'attendance':
        return Icons.check_circle;
      case 'reminder':
        return Icons.alarm;
      case 'system':
        return Icons.info;
      case 'warning':
        return Icons.warning;
      default:
        return Icons.notifications;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'attendance':
        return Colors.green;
      case 'reminder':
        return Colors.orange;
      case 'system':
        return blue;
      case 'warning':
        return Colors.red;
      default:
        return blue;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d, yyyy').format(date);
    }
  }
}
