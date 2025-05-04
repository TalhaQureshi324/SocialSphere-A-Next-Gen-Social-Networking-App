import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_sphere/core/common/loader.dart';
import 'package:social_sphere/features/auth/controller/auth_controller.dart';
import 'package:social_sphere/features/chat/controller/chat_controller.dart';
import 'package:social_sphere/models/chat_model.dart';

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
    final currentUser = ref.watch(userProvider)!;
    final chatAsync = ref.watch(
      chatMessagesProvider((currentUser.uid, widget.receiverId)),
    );
    final otherUserAsync = ref.watch(getUserDataProvider(widget.receiverId));

    return Scaffold(
      appBar: AppBar(
        title: otherUserAsync.when(
          data:
              (user) => Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(user.profilePic),
                    radius: 16,
                  ),
                  const SizedBox(width: 12),
                  Text(user.username),
                ],
              ),
          error: (error, _) => const Text('Error loading user'),
          loading: () => const Loader(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: chatAsync.when(
              data: (messages) {
                if (messages.isEmpty) {
                  return const Center(child: Text('Start a conversation!'));
                }
                WidgetsBinding.instance.addPostFrameCallback(
                  (_) => _scrollToBottom(),
                );
                return ListView.builder(
                  controller: _scrollController,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderId == currentUser.uid;
                    return _ChatBubble(message: message, isMe: isMe);
                  },
                );
              },
              error: (error, _) => Center(child: Text('Error: $error')),
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
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final ChatModel message;
  final bool isMe;

  const _ChatBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color:
              isMe
                  ? (message.isRead ? Colors.blue[100] : Colors.blue[200])
                  : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(message.text, style: const TextStyle(fontSize: 16, color: Colors.black)),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${message.timestamp.hour.toString().padLeft(2, '0')}:'
                  '${message.timestamp.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                ),
                if (isMe)
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Icon(
                      message.isRead ? Icons.done_all : Icons.done,
                      size: 12,
                      color:
                          message.isRead
                              ? const Color.fromARGB(255, 218, 132, 3)
                              : const Color.fromARGB(255, 43, 53, 44),
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

  const _MessageInput({required this.messageController, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: messageController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onSubmitted: (_) => onSend(),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: Colors.blue,
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
