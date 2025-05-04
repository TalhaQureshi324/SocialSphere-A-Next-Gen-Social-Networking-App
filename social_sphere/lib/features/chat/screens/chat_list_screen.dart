import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_sphere/core/common/loader.dart';
import 'package:social_sphere/features/auth/controller/auth_controller.dart';
import 'package:social_sphere/features/chat/controller/chat_controller.dart';
import 'package:social_sphere/models/chat_model.dart';
import 'package:social_sphere/models/user_model.dart';
import 'package:routemaster/routemaster.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(userProvider)!;
    final chatsAsync = ref.watch(recentChatsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Chats')),
      body: chatsAsync.when(
        data: (chats) {
          if (chats.isEmpty) {
            return const Center(child: Text('No chats yet!'));
          }

          final uniqueChats = _getUniqueConversations(chats, currentUser.uid);

          return ListView.builder(
            itemCount: uniqueChats.length,
            itemBuilder: (context, index) {
              final chat = uniqueChats[index];
              final participants =
                  chat.participants
                      .where((id) => id != currentUser.uid)
                      .toList();
              final otherUserId =
                  participants.isNotEmpty ? participants.first : '';

              return ref
                  .watch(getUserDataProvider(otherUserId))
                  .when(
                    data:
                        (otherUser) => _ChatListItem(
                          chat: chat,
                          otherUser: otherUser,
                          currentUserId: currentUser.uid,
                        ),
                    error: (error, _) => Text('Error: $error'),
                    loading: () => const Loader(),
                  );
            },
          );
        },
        error: (error, _) => Text('Error: $error'),
        loading: () => const Loader(),
      ),
    );
  }

  List<ChatModel> _getUniqueConversations(
    List<ChatModel> chats,
    String userId,
  ) {
    final Map<String, ChatModel> uniqueChats = {};

    for (final chat in chats) {
      final others =
          chat.participants.where((id) => id != userId).toList()..sort();
      final key = others.join('_');

      final existing = uniqueChats[key];
      if (existing == null || chat.timestamp.isAfter(existing.timestamp)) {
        uniqueChats[key] = chat;
      }
    }

    return uniqueChats.values.toList();
  }
}

class _ChatListItem extends ConsumerWidget {
  final ChatModel chat;
  final UserModel otherUser;
  final String currentUserId;

  const _ChatListItem({
    required this.chat,
    required this.otherUser,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCountAsync = ref.watch(
      unreadMessagesCountProvider((currentUserId, otherUser.uid)),
    );

    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(otherUser.profilePic),
      ),
      title: Text(otherUser.username),
      subtitle: Text(
        chat.text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight:
              unreadCountAsync.valueOrNull != null &&
                      unreadCountAsync.value! > 0
                  ? FontWeight.bold
                  : FontWeight.normal,
        ),
      ),
      trailing: unreadCountAsync.when(
        data:
            (count) =>
                count > 0
                    ? Badge(
                      label: Text(count.toString()),
                      backgroundColor: Colors.blue,
                    )
                    : Text(
                      timeAgo(chat.timestamp),
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
        loading: () => const SizedBox(),
        error: (_, __) => const SizedBox(),
      ),
      onTap: () {
        ref
            .read(chatControllerProvider.notifier)
            .markMessagesAsRead(currentUserId, otherUser.uid);
        Routemaster.of(context).push('/chat/${otherUser.uid}');
      },
    );
  }

  String timeAgo(DateTime date) {
    final difference = DateTime.now().difference(date);
    if (difference.inDays > 365) return '${(difference.inDays / 365).floor()}y';
    if (difference.inDays > 30) return '${(difference.inDays / 30).floor()}mo';
    if (difference.inDays > 0) return '${difference.inDays}d';
    if (difference.inHours > 0) return '${difference.inHours}h';
    if (difference.inMinutes > 0) return '${difference.inMinutes}m';
    return 'Just now';
  }
}
