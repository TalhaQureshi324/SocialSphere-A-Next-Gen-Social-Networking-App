// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:social_sphere/core/common/error_text.dart';
// import 'package:social_sphere/core/common/loader.dart';
// import 'package:social_sphere/core/providers/comment_provider.dart';
// import 'package:social_sphere/features/post/controller/post_controller.dart';
// import 'package:social_sphere/features/post/widgets/comment_card.dart';
// import 'package:social_sphere/models/comment_model.dart';

// class ReplyScreen extends ConsumerStatefulWidget {
//   final Comment parentComment;
//   final String postId;
//   const ReplyScreen({
//     super.key,
//     required this.parentComment,
//     required this.postId,
//   });

//   @override
//   ConsumerState<ConsumerStatefulWidget> createState() => _ReplyScreenState();
// }

// class _ReplyScreenState extends ConsumerState<ReplyScreen> {
//   final TextEditingController _replyController = TextEditingController();

//   void _postReply() {
//     if (_replyController.text.trim().isNotEmpty) {
//       ref.read(postControllerProvider.notifier).addReply(
//             context: context,
//             text: _replyController.text.trim(),
//             parentComment: widget.parentComment,
//           );
//       _replyController.clear();
//     }
//   }

//   @override
//   void dispose() {
//     _replyController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Replies'),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView(
//               children: [
//                 CommentCard(comment: widget.parentComment),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                   child: Text(
//                     'Replies',
//                     style: Theme.of(context).textTheme.titleLarge,
//                   ),
//                 ),
//                 ref.watch(getRepliesProvider(widget.parentComment.id)).when(
//                   data: (replies) => Column(
//                     children: replies
//                         .map((reply) => CommentCard(key: Key(reply.id), comment: reply))
//                         .toList(),
//                   ),
//                   error: (error, _) => ErrorText(error: error.toString()),
//                   loading: () => const Loader(),
//                 ),
//               ],
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(12.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _replyController,
//                     decoration: InputDecoration(
//                       hintText: 'Write a reply...',
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       contentPadding: const EdgeInsets.symmetric(
//                         horizontal: 16,
//                         vertical: 12,
//                       ),
//                     ),
//                     onSubmitted: (_) => _postReply(),
//                   ),
//                 ),
//                 IconButton(
//                   onPressed: _postReply,
//                   icon: const Icon(Icons.send),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_sphere/core/common/error_text.dart';
import 'package:social_sphere/core/common/loader.dart';
import 'package:social_sphere/core/providers/comment_provider.dart';
import 'package:social_sphere/features/post/controller/post_controller.dart';
import 'package:social_sphere/features/post/widgets/comment_card.dart';
import 'package:social_sphere/models/comment_model.dart';

class ReplyScreen extends ConsumerStatefulWidget {
  final Comment parentComment;
  final String postId;
  const ReplyScreen({
    super.key,
    required this.parentComment,
    required this.postId,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ReplyScreenState();
}

class _ReplyScreenState extends ConsumerState<ReplyScreen> {
  final TextEditingController _replyController = TextEditingController();

  void _postReply() {
    if (_replyController.text.trim().isNotEmpty) {
      ref
          .read(postControllerProvider.notifier)
          .addReply(
            context: context,
            text: _replyController.text.trim(),
            parentComment: widget.parentComment,
          );
      _replyController.clear();
    }
  }

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = Theme.of(context);
    final bool isDark = currentTheme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Thread'), elevation: 0),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 80),
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: CommentCard(comment: widget.parentComment),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Text(
                    'Replies',
                    style: currentTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ref
                    .watch(getRepliesProvider(widget.parentComment.id))
                    .when(
                      data:
                          (replies) => ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: replies.length,
                            itemBuilder: (context, index) {
                              final reply = replies[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                child: CommentCard(
                                  comment: reply,
                                  isReply: true,
                                ),
                              );
                            },
                          ),
                      error: (error, _) => ErrorText(error: error.toString()),
                      loading: () => const Loader(),
                    ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade900 : Colors.white,
              border: Border(
                top: BorderSide(
                  color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                ),
              ),
            ),
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _replyController,
                    decoration: InputDecoration(
                      hintText: 'Write a reply...',
                      filled: true,
                      fillColor:
                          isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (_) => _postReply(),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: currentTheme.colorScheme.primary,
                  child: IconButton(
                    onPressed: _postReply,
                    icon: const Icon(Icons.send),
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
