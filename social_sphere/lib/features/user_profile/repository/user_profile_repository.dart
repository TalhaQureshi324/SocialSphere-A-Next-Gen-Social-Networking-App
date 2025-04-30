import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:social_sphere/core/constants/firebase_constants.dart';
import 'package:social_sphere/core/failure.dart';
import 'package:social_sphere/core/type_defs.dart';
import 'package:social_sphere/models/post_model.dart';
import 'package:social_sphere/models/user_model.dart';

import '../../../core/providers/firebase_providers.dart';

final userProfileRepositoryProvider = Provider((ref) {
  return UserProfileRepository(firestore: ref.watch(firestoreProvider));
});

class UserProfileRepository {
  final FirebaseFirestore _firestore;
  UserProfileRepository({required FirebaseFirestore firestore})
    : _firestore = firestore;

  CollectionReference get _users =>
      _firestore.collection(FirebaseConstants.usersCollection);
  CollectionReference get _posts =>
      _firestore.collection(FirebaseConstants.postsCollection);

  FutureVoid editProfile(UserModel user) async {
    try {
      return right(_users.doc(user.uid).update(user.toMap()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<Post>> getUserPosts(String uid) {
    return _posts
        .where('uid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (event) =>
              event.docs
                  .map((e) => Post.fromMap(e.data() as Map<String, dynamic>))
                  .toList(),
        );
  }

  FutureVoid updateUserKarma(UserModel user) async {
    try {
      return right(_users.doc(user.uid).update({'karma': user.karma}));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<UserModel>> searchUser(String query) {
    return _users
        .where('username', isGreaterThanOrEqualTo: query)
        .where('username', isLessThan: query + 'z')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map(
                    (doc) =>
                        UserModel.fromMap(doc.data() as Map<String, dynamic>),
                  )
                  .toList(),
        );
  }

  Future<List<UserModel>> getUserByUsername(String username) async {
    try {
      final querySnapshot =
          await _firestore
              .collection('users')
              .where('username', isEqualTo: username)
              .get();

      return querySnapshot.docs
          .map((doc) => UserModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> updateUsernameInPosts({
    required String uid,
    required String newUsername,
  }) async {
    final postsRef = _firestore.collection('posts');
    final querySnapshot = await postsRef.where('uid', isEqualTo: uid).get();

    for (final doc in querySnapshot.docs) {
      await doc.reference.update({'username': newUsername});
    }
  }

  Future<void> updateUsernameInComments({
    required String oldusername,
    required String newUsername,
  }) async {
    final commentsRef = _firestore.collection('comments');
    final querySnapshot =
        await commentsRef.where('username', isEqualTo: oldusername).get();

    for (final doc in querySnapshot.docs) {
      await doc.reference.update({'username': newUsername});
    }
  }

  Future<void> updateUsernameInLikes({
    required String uid,
    required String newUsername,
  }) async {
    final likesRef = _firestore.collection('likes');
    final querySnapshot = await likesRef.where('uid', isEqualTo: uid).get();

    for (final doc in querySnapshot.docs) {
      await doc.reference.update({'username': newUsername});
    }
  }

  //   Future<void> updateUsernameInPosts({
  //   required String uid,
  //   required String newUsername,
  // }) async {
  //   try {
  //     final postsRef = _firestore.collection('posts');
  //     final querySnapshot = await postsRef.where('uid', isEqualTo: uid).get();

  //     final totalDocs = querySnapshot.docs.length;
  //     const batchLimit = 500;
  //     int processed = 0;

  //     while (processed < totalDocs) {
  //       final batch = _firestore.batch();

  //       final docsBatch = querySnapshot.docs.skip(processed).take(batchLimit);
  //       for (final doc in docsBatch) {
  //         batch.update(doc.reference, {'username': newUsername});
  //       }

  //       await batch.commit(); // If this fails, it throws an exception
  //       processed += batchLimit;
  //     }
  //   } catch (e) {
  //     debugPrint('Failed to update usernames in posts: $e');
  //     // Optionally, showSnackBar or retry logic can be added here
  //   }
  // }
}
