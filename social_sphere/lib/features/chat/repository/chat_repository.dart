import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:social_sphere/core/constants/firebase_constants.dart';
import 'package:social_sphere/core/failure.dart';
import 'package:social_sphere/core/providers/firebase_providers.dart';
import 'package:social_sphere/core/type_defs.dart';
import 'package:social_sphere/models/chat_model.dart';

final chatRepositoryProvider = Provider((ref) {
  return ChatRepository(firestore: ref.watch(firestoreProvider));
});

class ChatRepository {
  final FirebaseFirestore _firestore;
  ChatRepository({required FirebaseFirestore firestore})
    : _firestore = firestore;

  CollectionReference get _chats =>
      _firestore.collection(FirebaseConstants.chatsCollection);

  FutureVoid sendMessage(ChatModel message) async {
    try {
      return right(await _chats.doc(message.messageId).set(message.toMap()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<ChatModel>> getChatStream(String user1Id, String user2Id) {
    return _chats
        .where('participants', arrayContainsAny: [user1Id, user2Id])
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map(
          (event) =>
              event.docs
                  .map(
                    (doc) =>
                        ChatModel.fromMap(doc.data() as Map<String, dynamic>),
                  )
                  .toList(),
        );
  }

  Stream<List<ChatModel>> getRecentChats(String userId) {
    return _chats
        .where('participants', arrayContains: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (event) =>
              event.docs
                  .map(
                    (doc) =>
                        ChatModel.fromMap(doc.data() as Map<String, dynamic>),
                  )
                  .toList(),
        );
  }

  FutureVoid markAsRead(String messageId) async {
    try {
      return right(await _chats.doc(messageId).update({'isRead': true}));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Future<List<ChatModel>> getUnreadMessages(
    String currentUserId,
    String senderId,
  ) async {
    final query =
        await _chats
            .where('senderId', isEqualTo: senderId)
            .where('receiverId', isEqualTo: currentUserId)
            .where('isRead', isEqualTo: false)
            .get();

    return query.docs
        .map((doc) => ChatModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Stream<int> getUnreadCount(String currentUserId, String otherUserId) {
    return _chats
        .where('senderId', isEqualTo: otherUserId)
        .where('receiverId', isEqualTo: currentUserId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  CollectionReference get chatsCollection =>
      _firestore.collection(FirebaseConstants.chatsCollection);
}
