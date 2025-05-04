import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:social_sphere/core/constants/firebase_constants.dart';
import 'package:social_sphere/core/failure.dart';
import 'package:social_sphere/core/providers/firebase_providers.dart';
import 'package:social_sphere/core/type_defs.dart';
import 'package:social_sphere/models/notification_model.dart';

final notificationRepositoryProvider = Provider((ref) {
  return NotificationRepository(firestore: ref.watch(firestoreProvider));
});

class NotificationRepository {
  final FirebaseFirestore _firestore;
  NotificationRepository({required FirebaseFirestore firestore})
    : _firestore = firestore;

  // Public getter for notifications collection
  CollectionReference<Map<String, dynamic>> get notifications =>
      _firestore.collection(FirebaseConstants.notificationsCollection);

  // Create new notification
  FutureVoid createNotification(NotificationModel notification) async {
    try {
      return right(
        await notifications.doc(notification.id).set(notification.toMap()),
      );
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  // Get unread notifications count
  Stream<int> getUnreadCount(String userId) {
    return notifications
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Get user notifications
  Stream<List<NotificationModel>> getUserNotifications(String userId) {
    return notifications
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => NotificationModel.fromMap(
                    doc.data() as Map<String, dynamic>, // Explicit cast
                  ))
              .toList(),
        );
  }

  // Mark notification as read
  FutureVoid markAsRead(String notificationId) async {
    try {
      return right(
        await notifications.doc(notificationId).update({'isRead': true}),
      );
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  // Get unread chat notifications
  Future<List<NotificationModel>> getUnreadChatNotifications(
    String userId, 
    String senderId
  ) async {
    final query = await notifications
        .where('userId', isEqualTo: userId)
        .where('type', isEqualTo: NotificationType.chat.index)
        .where('senderId', isEqualTo: senderId)
        .where('isRead', isEqualTo: false)
        .get();
        
    return query.docs
        .map((doc) => NotificationModel.fromMap(
              doc.data() as Map<String, dynamic>, // Explicit cast
            ))
        .toList();
  }
}