import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_sphere/core/common/loader.dart';
import 'package:social_sphere/features/auth/controller/auth_controller.dart';
import 'package:social_sphere/features/chat/controller/chat_controller.dart';
import 'package:social_sphere/models/chat_model.dart';
import 'package:social_sphere/theme/pallete.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String receiverId;
  const ChatScreen({super.key, required this.receiverId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      safeUpdateReceiverId();
      _markMessagesAsRead();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(currentChatReceiverIdProvider.notifier).state = null;
    });
    super.dispose();
  }

  void safeUpdateReceiverId() {
    try {
      ref.read(currentChatReceiverIdProvider.notifier).state =
          widget.receiverId;
    } catch (e) {
      debugPrint('Error updating chat state: ${e.toString()}');
    }
  }

  void _markMessagesAsRead() {
    final currentUser = ref.read(userProvider)!;
    ref
        .read(chatControllerProvider.notifier)
        .markMessagesAsRead(currentUser.uid, widget.receiverId);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = ref.watch(themeNotifierProvider);
    final isDark = currentTheme.brightness == Brightness.dark;
    final currentUser = ref.watch(userProvider)!;
    final chatAsync = ref.watch(
      chatMessagesProvider((currentUser.uid, widget.receiverId)),
    );
    final otherUserAsync = ref.watch(getUserDataProvider(widget.receiverId));

    return Scaffold(
      appBar: AppBar(
        title: otherUserAsync.when(
          data: (user) => Row(
            children: [
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
                  radius: 16,
                  backgroundImage: NetworkImage(user.profilePic),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                user.username,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: currentTheme.textTheme.titleLarge?.color,
                ),
              ),
            ],
          ),
          error: (error, _) => Text(
            'Error',
            style: TextStyle(color: currentTheme.textTheme.titleLarge?.color),
          ),
          loading: () => const Loader(),
        ),
        centerTitle: false,
        elevation: 0,
        iconTheme: IconThemeData(color: currentTheme.iconTheme.color),
      ),
      body: Column(
        children: [
          Expanded(
            child: chatAsync.when(
              data: (messages) {
                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 48,
                          color: currentTheme.iconTheme.color?.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Start a conversation!',
                          style: currentTheme.textTheme.titleMedium?.copyWith(
                            color: currentTheme.textTheme.titleMedium?.color
                                ?.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                WidgetsBinding.instance.addPostFrameCallback(
                      (_) => _scrollToBottom(),
                );
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderId == currentUser.uid;
                    return _ChatBubble(
                      message: message,
                      isMe: isMe,
                      theme: currentTheme,
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
                      'Failed to load messages',
                      style: currentTheme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => ref.refresh(
                        chatMessagesProvider((currentUser.uid, widget.receiverId)),
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              loading: () => const Loader(),
            ),
          ),
          _MessageInput(
            messageController: _messageController,
            onSend: () {
              if (_messageController.text.trim().isEmpty) return;
              ref
                  .read(chatControllerProvider.notifier)
                  .sendMessage(
                text: _messageController.text,
                receiverId: widget.receiverId,
                context: context,
              );
              _messageController.clear();
            },
            theme: currentTheme,
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final ChatModel message;
  final bool isMe;
  final ThemeData theme;

  const _ChatBubble({
    required this.message,
    required this.isMe,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = theme.brightness == Brightness.dark;
    final bubbleColor = isMe
        ? (message.isRead ? Colors.blue.shade400 : Colors.blue.shade500)
        : (isDark ? Colors.grey.shade800 : Colors.grey.shade200);

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        constraints: const BoxConstraints(maxWidth: 300),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: isMe ? const Radius.circular(20) : Radius.zero,
            bottomRight: isMe ? Radius.zero : const Radius.circular(20),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: TextStyle(
                fontSize: 16,
                color: isMe ? Colors.white : theme.textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${message.timestamp.hour.toString().padLeft(2, '0')}:'
                      '${message.timestamp.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    fontSize: 10,
                    color: isMe
                        ? Colors.white.withOpacity(0.7)
                        : theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                  ),
                ),
                if (isMe)
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Icon(
                      message.isRead ? Icons.done_all : Icons.done,
                      size: 12,
                      color: isMe
                          ? Colors.white.withOpacity(0.7)
                          : theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageInput extends StatelessWidget {
  final TextEditingController messageController;
  final VoidCallback onSend;
  final ThemeData theme;

  const _MessageInput({
    required this.messageController,
    required this.onSend,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
        border: Border(
          top: BorderSide(
            color: theme.dividerColor.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: messageController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                filled: true,
                fillColor: isDark ? Colors.grey.shade800 : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onSubmitted: (_) => onSend(),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Colors.blue.shade400,
                  Colors.purple.shade600,
                ],
              ),
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: onSend,
            ),
          ),
        ],
      ),
    );
  }
}