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

  CollectionReference get _notifications => 
      _firestore.collection(FirebaseConstants.notificationsCollection);

  FutureVoid createNotification(NotificationModel notification) async {
    try {
      return right(
        _notifications.doc(notification.id).set(notification.toMap()),
      );
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<NotificationModel>> getUserNotifications(String userId) {
    return _notifications
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationModel.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }

  FutureVoid markAsRead(String notificationId) async {
    try {
      return right(
        _notifications.doc(notificationId).update({'isRead': true}),
      );
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}