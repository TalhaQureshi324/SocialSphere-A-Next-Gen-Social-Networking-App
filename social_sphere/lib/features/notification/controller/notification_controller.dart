// features/notification/controller/notification_controller.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_sphere/core/utils.dart';
import 'package:social_sphere/features/auth/controller/auth_controller.dart';
import 'package:social_sphere/models/notification_model.dart';
import 'package:social_sphere/features/notification/repository/notification_repository.dart';

final notificationControllerProvider =
    StateNotifierProvider<NotificationController, bool>((ref) {
      return NotificationController(
        notificationRepository: ref.watch(notificationRepositoryProvider),
        ref: ref,
      );
    });

final userNotificationsProvider = StreamProvider((ref) {
  final user = ref.watch(userProvider);
  if (user == null) return Stream.value([]);
  return ref
      .watch(notificationControllerProvider.notifier)
      .getUserNotifications(user.uid);
});

class NotificationController extends StateNotifier<bool> {
  final NotificationRepository _notificationRepository;
  final Ref _ref;
  NotificationController({
    required NotificationRepository notificationRepository,
    required Ref ref,
  }) : _notificationRepository = notificationRepository,
       _ref = ref,
       super(false); // Loading state

  Stream<List<NotificationModel>> getUserNotifications(String userId) {
    return _notificationRepository.getUserNotifications(userId);
  }

  void markAsRead(String notificationId, BuildContext context) async {
    state = true;
    final res = await _notificationRepository.markAsRead(notificationId);
    state = false;
    res.fold((l) => showSnackBar(context, l.message), (r) => null);
  }
}
