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

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
  bool _isMarkingAll = false;

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeNotifierProvider);
    final colorScheme = theme.colorScheme;
    final unreadCount = ref.watch(unreadNotificationsCountProvider).value ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: colorScheme.surface,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        surfaceTintColor: Colors.transparent,
        actions: [
          if (unreadCount > 0)
            _isMarkingAll
                ? Padding(
              padding: const EdgeInsets.only(right: 16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colorScheme.primary,
                ),
              ),
            )
                : IconButton(
              icon: Badge(
                label: unreadCount > 9
                    ? const Text('9+')
                    : Text(unreadCount.toString()),
                backgroundColor: colorScheme.primary,
                textColor: colorScheme.onPrimary,
                child: Icon(
                  Icons.mark_email_read_outlined,
                  color: colorScheme.onSurfaceVariant,
                  size: 26,
                ),
              ),
              onPressed: () async {
                setState(() => _isMarkingAll = true);
                await ref
                    .read(notificationControllerProvider.notifier)
                    .markAllAsRead(context);
                setState(() => _isMarkingAll = false);
              },
              tooltip: 'Mark all as read',
            ),
        ],
      ),
      body: Container(
        color: colorScheme.surfaceContainerLowest,
        child: ref.watch(userNotificationsProvider).when(
          data: (notifications) => _NotificationListView(
            notifications: notifications,
            unreadCount: unreadCount,
            colorScheme: colorScheme,
          ),
          error: (error, _) => ErrorText(error: error.toString()),
          loading: () => const Loader(),
        ),
      ),
    );
  }
}

class _NotificationListView extends ConsumerWidget {
  final List<NotificationModel> notifications;
  final int unreadCount;
  final ColorScheme colorScheme;

  const _NotificationListView({
    required this.notifications,
    required this.unreadCount,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    if (notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.notifications_off_rounded,
              size: 64,
              color: colorScheme.onSurfaceVariant.withOpacity(0.4),
            ),
            const SizedBox(height: 24),
            Text(
              'No notifications yet',
              style: theme.textTheme.titleLarge?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'When you receive notifications, they will appear here',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: colorScheme.primary,
      backgroundColor: colorScheme.surface,
      onRefresh: () async {
        // Add refresh logic if needed
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          if (unreadCount > 0)
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.05),
                  border: Border(
                    bottom: BorderSide(
                      color: colorScheme.primary.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.circle,
                      size: 10,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$unreadCount Unread',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                final notification = notifications[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => _handleNotificationTap(context, notification),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: !notification.isRead
                            ? colorScheme.primaryContainer.withOpacity(0.08)
                            : colorScheme.surfaceContainerLow,
                        border: Border.all(
                          color: !notification.isRead
                              ? colorScheme.primary.withOpacity(0.2)
                              : colorScheme.outlineVariant.withOpacity(0.1),
                        ),
                      ),
                      child: Stack(
                        children: [
                          NotificationCard(
                            notification: notification,
                            isUnread: !notification.isRead,
                          ),
                          if (!notification.isRead)
                            Positioned(
                              top: 0,
                              right: 0,
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              childCount: notifications.length,
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 16),
          ),
        ],
      ),
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