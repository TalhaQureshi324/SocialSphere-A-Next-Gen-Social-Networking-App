import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_sphere/core/common/loader.dart';
import 'package:social_sphere/features/auth/controller/auth_controller.dart';
import 'package:social_sphere/features/chat/controller/chat_controller.dart';
import 'package:social_sphere/models/chat_model.dart';
import 'package:social_sphere/models/user_model.dart';
import 'package:routemaster/routemaster.dart';
import 'package:social_sphere/theme/pallete.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeNotifierProvider);
    final isDark = currentTheme.brightness == Brightness.dark;
    final currentUser = ref.watch(userProvider)!;
    final chatsAsync = ref.watch(recentChatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Messages',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        elevation: 0,
      ),
      body: chatsAsync.when(
        data: (chats) {
          if (chats.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.forum_outlined,
                    size: 48,
                    color: currentTheme.iconTheme.color?.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No conversations yet',
                    style: currentTheme.textTheme.titleMedium?.copyWith(
                      color: currentTheme.textTheme.titleMedium?.color?.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            );
          }

          final uniqueChats = _getUniqueConversations(chats, currentUser.uid);

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: uniqueChats.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: currentTheme.dividerColor.withOpacity(0.1),
              indent: 72,
            ),
            itemBuilder: (context, index) {
              final chat = uniqueChats[index];
              final participants =
              chat.participants.where((id) => id != currentUser.uid).toList();
              final otherUserId = participants.isNotEmpty ? participants.first : '';

              return ref.watch(getUserDataProvider(otherUserId)).when(
                data: (otherUser) => _ChatListItem(
                  chat: chat,
                  otherUser: otherUser,
                  currentUserId: currentUser.uid,
                  theme: currentTheme,
                ),
                error: (error, _) => ListTile(
                  title: Text('Error loading user'),
                  subtitle: Text('Tap to retry'),
                  onTap: () => ref.refresh(getUserDataProvider(otherUserId)),
                ),
                loading: () => const ListTile(
                  leading: CircleAvatar(),
                  title: Text('Loading...'),
                ),
              );
            },
          );
        },
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Failed to load chats',
                style: currentTheme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => ref.refresh(recentChatsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        loading: () => const Loader(),
      ),
    );
  }

  List<ChatModel> _getUniqueConversations(List<ChatModel> chats, String userId) {
    final Map<String, ChatModel> uniqueChats = {};

    for (final chat in chats) {
      final others = chat.participants.where((id) => id != userId).toList()..sort();
      final key = others.join('_');

      final existing = uniqueChats[key];
      if (existing == null || chat.timestamp.isAfter(existing.timestamp)) {
        uniqueChats[key] = chat;
      }
    }

    return uniqueChats.values.toList()..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }
}

class _ChatListItem extends ConsumerWidget {
  final ChatModel chat;
  final UserModel otherUser;
  final String currentUserId;
  final ThemeData theme;

  const _ChatListItem({
    required this.chat,
    required this.otherUser,
    required this.currentUserId,
    required this.theme,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCountAsync = ref.watch(
      unreadMessagesCountProvider((currentUserId, otherUser.uid)),
    );
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: () {
        ref.read(chatControllerProvider.notifier)
            .markMessagesAsRead(currentUserId, otherUser.uid);
        Routemaster.of(context).push('/chat/${otherUser.uid}');
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Avatar with gradient border
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.shade400,
                    Colors.purple.shade600,
                  ],
                ),
              ),
              child: CircleAvatar(
                radius: 24,
                backgroundImage: NetworkImage(otherUser.profilePic),
              ),
            ),
            const SizedBox(width: 16),

            // Chat content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        otherUser.username,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: unreadCountAsync.valueOrNull != null &&
                              unreadCountAsync.value! > 0
                              ? FontWeight.bold
                              : FontWeight.w600,
                        ),
                      ),
                      Text(
                        _formatTime(chat.timestamp),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          chat.text,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: unreadCountAsync.valueOrNull != null &&
                                unreadCountAsync.value! > 0
                                ? theme.textTheme.bodyMedium?.color
                                : theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                            fontWeight: unreadCountAsync.valueOrNull != null &&
                                unreadCountAsync.value! > 0
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (unreadCountAsync.valueOrNull != null &&
                          unreadCountAsync.value! > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Pallete.blueColor,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            unreadCountAsync.value!.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateDay = DateTime(date.year, date.month, date.day);

    if (dateDay == today) {
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (dateDay == yesterday) {
      return 'Yesterday';
    } else if (now.difference(date).inDays < 7) {
      return _weekdays[date.weekday]!;
    } else {
      return '${date.day}/${date.month}/${date.year.toString().substring(2)}';
    }
  }

  static const Map<int, String> _weekdays = {
    1: 'Mon',
    2: 'Tue',
    3: 'Wed',
    4: 'Thu',
    5: 'Fri',
    6: 'Sat',
    7: 'Sun',
  };
}