import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_sphere/features/auth/controller/auth_controller.dart';
import 'package:social_sphere/features/chat/repository/chat_repository.dart';
import 'package:social_sphere/features/notification/repository/notification_repository.dart';
import 'package:social_sphere/models/chat_model.dart';
import 'package:social_sphere/models/notification_model.dart';

final unreadMessagesCountProvider =
    StreamProvider.family<int, (String, String)>(
      (ref, userIds) => ref
          .watch(chatRepositoryProvider)
          .getUnreadCount(userIds.$1, userIds.$2),
    );

final currentChatReceiverIdProvider = StateProvider<String?>((ref) => null);

final chatControllerProvider = StateNotifierProvider<ChatController, bool>((
  ref,
) {
  return ChatController(
    chatRepository: ref.watch(chatRepositoryProvider),
    notificationRepository: ref.watch(notificationRepositoryProvider),
    ref: ref,
  );
});

final chatMessagesProvider =
    StreamProvider.family<List<ChatModel>, (String, String)>(
      (ref, userIds) => ref
          .watch(chatControllerProvider.notifier)
          .getChatMessages(userIds.$1, userIds.$2),
    );

final recentChatsProvider = StreamProvider<List<ChatModel>>((ref) {
  final user = ref.watch(userProvider);
  return user != null
      ? ref.watch(chatControllerProvider.notifier).getRecentChats(user.uid)
      : const Stream.empty();
});

class ChatController extends StateNotifier<bool> {
  final ChatRepository _chatRepository;
  final NotificationRepository _notificationRepository;
  final Ref _ref;

  ChatController({
    required ChatRepository chatRepository,
    required NotificationRepository notificationRepository,
    required Ref ref,
  }) : _chatRepository = chatRepository,
       _notificationRepository = notificationRepository,
       _ref = ref,
       super(false);

  Future<void> sendMessage({
    required String text,
    required String receiverId,
    required BuildContext context,
  }) async {
    state = true;
    final user = _ref.read(userProvider)!;
    final messageId = DateTime.now().millisecondsSinceEpoch.toString();

    try {
      final message = ChatModel(
        messageId: messageId,
        senderId: user.uid,
        receiverId: receiverId,
        text: text,
        timestamp: DateTime.now(),
        isRead: false, // Always start as unread
        participants: [user.uid, receiverId],
      );

      await _chatRepository.sendMessage(message);

      if (receiverId != user.uid) {
        final notification = NotificationModel(
          id: 'chat_$messageId',
          userId: receiverId,
          type: NotificationType.chat,
          senderId: user.uid,
          senderName: user.username,
          messageText: text,
          createdAt: DateTime.now(),
          isRead: false,
          communityId: null,
          communityName: null,
          communityAvatar: null,
          postId: null,
          postTitle: null,
          authorName: null,
        );
        await _notificationRepository.createNotification(notification);
      }
    } catch (e) {
      showSnackBar(context, 'Failed to send message: ${e.toString()}');
    } finally {
      state = false;
    }
  }

  Future<void> markMessagesAsRead(String currentUserId, String senderId) async {
    try {
      final messages = await _chatRepository.getUnreadMessages(
        currentUserId,
        senderId,
      );
      final batch = FirebaseFirestore.instance.batch();

      for (final message in messages) {
        batch.update(_chatRepository.chatsCollection.doc(message.messageId), {
          'isRead': true,
        });
      }

      final notifications = await _notificationRepository
          .getUnreadChatNotifications(currentUserId, senderId);
      for (final notification in notifications) {
        await _notificationRepository.markAsRead(notification.id);
      }

      await batch.commit();
    } catch (e) {
      debugPrint('Error marking messages/notifications as read: $e');
      rethrow;
    }
  }

  Stream<List<ChatModel>> getChatMessages(String user1Id, String user2Id) {
    return _chatRepository.getChatStream(user1Id, user2Id).asyncMap((
      messages,
    ) async {
      final currentUser = _ref.read(userProvider);
      // Only mark as read if current user is the receiver
      if (currentUser != null && currentUser.uid == user2Id) {
        await markMessagesAsRead(user2Id, user1Id);
      }
      return messages;
    });
  }

  Stream<List<ChatModel>> getRecentChats(String userId) {
    return _chatRepository.getRecentChats(userId).asyncMap((chats) async {
      final uniqueChats = <String, ChatModel>{};
      for (final chat in chats) {
        final key = chat.participants..sort();
        if (!uniqueChats.containsKey(key.join('_')) ||
            chat.timestamp.isAfter(uniqueChats[key.join('_')]!.timestamp)) {
          uniqueChats[key.join('_')] = chat;
        }
      }
      return uniqueChats.values.toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    });
  }

  void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
