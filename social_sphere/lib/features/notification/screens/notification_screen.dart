import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:social_sphere/core/common/error_text.dart';
import 'package:social_sphere/core/common/loader.dart';
import 'package:social_sphere/core/common/notification_card.dart';
import 'package:social_sphere/features/auth/controller/auth_controller.dart';
import 'package:social_sphere/features/notification/controller/notification_controller.dart';
import 'package:social_sphere/features/notification/repository/notification_repository.dart';
import 'package:social_sphere/models/notification_model.dart';
import 'package:social_sphere/theme/pallete.dart';

// Add these provider definitions if missing
final userNotificationsProvider = StreamProvider((ref) {
  final user = ref.watch(userProvider);
  return user != null 
      ? ref.watch(notificationRepositoryProvider).getUserNotifications(user.uid)
      : const Stream.empty();
});

final unreadNotificationsCountProvider = StreamProvider((ref) {
  final user = ref.watch(userProvider);
  return user != null
      ? ref.watch(notificationRepositoryProvider).getUnreadCount(user.uid)
      : const Stream.empty();
});

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeNotifierProvider);
    final unreadCount = ref.watch(unreadNotificationsCountProvider).value ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: true,
        actions: [
          if (unreadCount > 0)
            IconButton(
              icon: const Icon(Icons.mark_as_unread),
              onPressed: () => ref.read(notificationControllerProvider.notifier)
                .markAllAsRead(context),
              tooltip: 'Mark all as read',
            ),
        ],
      ),
      body: ref.watch(userNotificationsProvider).when(
            data: (notifications) => _buildNotificationList(notifications, currentTheme),
            error: (error, _) => ErrorText(error: error.toString()),
            loading: () => const Loader(),
          ),
    );
  }

  Widget _buildNotificationList(List<NotificationModel> notifications, ThemeData theme) {
    if (notifications.isEmpty) {
      return Center(
        child: Text(
          'No notifications yet!',
          style: TextStyle(color: theme.textTheme.bodyMedium?.color),
        ),
      );
    }
    
    return ListView.builder(
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return GestureDetector(
          onTap: () => _handleNotificationTap(context, notification),
          child: NotificationCard(
            notification: notification,
            isUnread: !notification.isRead,
          ),
        );
      },
    );
  }

  void _handleNotificationTap(BuildContext context, NotificationModel notification) {
    final ref = ProviderScope.containerOf(context);
    if (!notification.isRead) {
      ref.read(notificationControllerProvider.notifier)
        .markAsRead(notification.id, context);
    }
    
    if (notification.type == NotificationType.chat) {
      Routemaster.of(context).push('/chat/${notification.senderId}');
    } else {
      Routemaster.of(context).push('/post/${notification.postId}/comments');
    }
  }
}