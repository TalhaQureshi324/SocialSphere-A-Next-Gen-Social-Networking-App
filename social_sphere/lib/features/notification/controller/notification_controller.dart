import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_sphere/core/utils.dart';
import 'package:social_sphere/features/auth/controller/auth_controller.dart';
import 'package:social_sphere/features/notification/repository/notification_repository.dart';

final notificationControllerProvider =
    StateNotifierProvider<NotificationController, bool>((ref) {
  return NotificationController(
    notificationRepository: ref.watch(notificationRepositoryProvider),
    ref: ref,
  );
});

// ... keep other providers the same ...

class NotificationController extends StateNotifier<bool> {
  final NotificationRepository _repository;
  final Ref _ref;

  NotificationController({
    required NotificationRepository notificationRepository,
    required Ref ref,
  }) : _repository = notificationRepository,
       _ref = ref,
       super(false);

  // Mark single notification as read
  Future<void> markAsRead(String notificationId, BuildContext context) async {
    state = true;
    final res = await _repository.markAsRead(notificationId);
    state = false;
    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) => null,
    );
  }

  // Mark all notifications as read
  Future<void> markAllAsRead(BuildContext context) async {
    state = true;
    final user = _ref.read(userProvider)!;
    final notifications = await _repository.getUserNotifications(user.uid).first;
    
    final batch = FirebaseFirestore.instance.batch();
    for (final notification in notifications.where((n) => !n.isRead)) {
      // Access through public getter
      batch.update(_repository.notifications.doc(notification.id), {'isRead': true});
    }
    
    try {
      await batch.commit();
    } catch (e) {
      showSnackBar(context, 'Error marking all as read');
    }
    state = false;
  }
}