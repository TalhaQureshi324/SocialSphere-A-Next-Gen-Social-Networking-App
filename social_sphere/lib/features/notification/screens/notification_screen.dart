import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_sphere/core/common/error_text.dart';
import 'package:social_sphere/core/common/loader.dart';
import 'package:social_sphere/core/common/notification_card.dart';
import 'package:social_sphere/theme/pallete.dart';
import 'package:routemaster/routemaster.dart';
import 'package:social_sphere/features/notification/controller/notification_controller.dart';

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  void markAsRead(WidgetRef ref, String notificationId, BuildContext context) {
    ref
        .read(notificationControllerProvider.notifier)
        .markAsRead(notificationId, context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications'), centerTitle: true),
      body: ref
          .watch(userNotificationsProvider)
          .when(
            data: (notifications) {
              if (notifications.isEmpty) {
                return Center(
                  child: Text(
                    'No notifications yet!',
                    style: TextStyle(
                      color: currentTheme.textTheme.bodyMedium?.color,
                    ),
                  ),
                );
              }
              return ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  return GestureDetector(
                    onTap: () {
                      // Navigate to the post using the correct route
                      // Routemaster.of(
                      //   context,
                      // ).push('/post/${notification.postId}');
                      Routemaster.of(context).push('/post/${notification.postId}/comments');
                      if (!notification.isRead) {
                        markAsRead(ref, notification.id, context);
                      }
                    },
                    child: NotificationCard(
                      notification: notification,
                      isUnread: !notification.isRead,
                    ),
                  );
                },
              );
            },
            error: (error, stackTrace) => ErrorText(error: error.toString()),
            loading: () => const Loader(),
          ),
    );
  }
}
