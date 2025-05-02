// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:social_sphere/core/common/error_text.dart';
// import 'package:social_sphere/core/common/loader.dart';
// import 'package:social_sphere/core/providers/comment_provider.dart';
// import 'package:social_sphere/features/post/screens/reply_screen.dart';
// import 'package:social_sphere/models/comment_model.dart';
// import 'package:social_sphere/responsive/responsive.dart';
// import 'package:timeago/timeago.dart' as timeago;

// class CommentCard extends ConsumerWidget {
//   final Comment comment;
//   const CommentCard({super.key, required this.comment});

//   void _navigateToReplyScreen(BuildContext context) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => ReplyScreen(
//           parentComment: comment,
//           postId: comment.postId,
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final timeAgo = timeago.format(comment.createdAt);
//     final repliesAsync = ref.watch(getRepliesProvider(comment.id));
//     final currentTheme = Theme.of(context);
//     final bool isDark = currentTheme.brightness == Brightness.dark;

//     return Responsive(
//       child: Container(
//         margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//         padding: const EdgeInsets.all(14),
//         decoration: BoxDecoration(
//           color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(
//             color: currentTheme.dividerColor.withOpacity(0.2),
//           ),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 CircleAvatar(
//                   backgroundImage: NetworkImage(comment.profilePic),
//                   radius: 20,
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         comment.username,
//                         style: currentTheme.textTheme.titleSmall?.copyWith(
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                       const SizedBox(height: 2),
//                       Text(
//                         timeAgo,
//                         style: currentTheme.textTheme.bodySmall?.copyWith(
//                           color: isDark ? Colors.grey.shade100 : Colors.grey.shade900,
//                           fontSize: 12,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 10),
//             Padding(
//               padding: const EdgeInsets.only(left: 4),
//               child: Text(
//                 comment.text,
//                 style: currentTheme.textTheme.bodyMedium,
//               ),
//             ),
//             const SizedBox(height: 12),
//             Row(
//               children: [
//                 IconButton(
//                   onPressed: () => _navigateToReplyScreen(context),
//                   icon: const Icon(Icons.reply_outlined, size: 20),
//                   color: isDark ? Colors.grey.shade100 : Colors.grey.shade900,
//                   splashRadius: 20,
//                 ),
//                 if (comment.replies.isNotEmpty)
//                   Text(
//                     '${comment.replies.length} ${comment.replies.length == 1 ? 'reply' : 'replies'}',
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: currentTheme.colorScheme.primary,
//                     ),
//                   ),
//               ],
//             ),
//             repliesAsync.when(
//               data: (replies) => Column(
//                 children: [
//                   for (final reply in replies.take(2))
//                     Padding(
//                       padding: const EdgeInsets.only(left: 16.0, top: 8),
//                       child: CommentCard(comment: reply),
//                     ),
//                   if (replies.length > 2)
//                     TextButton(
//                       onPressed: () => _navigateToReplyScreen(context),
//                       child: Text(
//                         'View all ${replies.length} replies',
//                         style: TextStyle(
//                           color: currentTheme.colorScheme.primary,
//                         ),
//                       ),
//                     ),
//                 ],
//               ),
//               error: (error, _) => ErrorText(error: error.toString()),
//               loading: () => const Padding(
//                 padding: EdgeInsets.symmetric(vertical: 8.0),
//                 child: Loader(),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:social_sphere/core/common/error_text.dart';
// import 'package:social_sphere/core/common/loader.dart';
// import 'package:social_sphere/core/providers/comment_provider.dart';
// import 'package:social_sphere/features/post/screens/reply_screen.dart';
// import 'package:social_sphere/models/comment_model.dart';
// import 'package:social_sphere/responsive/responsive.dart';
// import 'package:timeago/timeago.dart' as timeago;

// class CommentCard extends ConsumerWidget {
//   final Comment comment;
//   final bool isReply;
//   const CommentCard({super.key, required this.comment, this.isReply = false});

//   void _navigateToReplyScreen(BuildContext context) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder:
//             (context) =>
//                 ReplyScreen(parentComment: comment, postId: comment.postId),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final timeAgo = timeago.format(comment.createdAt);
//     final repliesAsync = ref.watch(getRepliesProvider(comment.id));
//     final currentTheme = Theme.of(context);
//     final bool isDark = currentTheme.brightness == Brightness.dark;

//     return Responsive(
//       child: Container(
//         margin: EdgeInsets.only(
//           left: isReply ? 24.0 : 12,
//           right: 12,
//           top: 4,
//           bottom: 4,
//         ),
//         decoration: BoxDecoration(
//           color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(
//             color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
//             width: 0.5,
//           ),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(12),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       CircleAvatar(
//                         backgroundImage: NetworkImage(comment.profilePic),
//                         radius: 16,
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               comment.username,
//                               style: currentTheme.textTheme.bodyMedium
//                                   ?.copyWith(fontWeight: FontWeight.w600),
//                             ),
//                             Text(
//                               timeAgo,
//                               style: currentTheme.textTheme.bodySmall?.copyWith(
//                                 color:
//                                     isDark
//                                         ? Colors.grey.shade400
//                                         : Colors.grey.shade600,
//                                 fontSize: 12,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     comment.text,
//                     style: currentTheme.textTheme.bodyMedium?.copyWith(
//                       color:
//                           isDark ? Colors.grey.shade100 : Colors.grey.shade900,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Row(
//                     children: [
//                       IconButton(
//                         onPressed: () => _navigateToReplyScreen(context),
//                         icon: Icon(
//                           Icons.reply_outlined,
//                           size: 18,
//                           color:
//                               isDark
//                                   ? Colors.grey.shade400
//                                   : Colors.grey.shade600,
//                         ),
//                         padding: EdgeInsets.zero,
//                         constraints: const BoxConstraints(),
//                       ),
//                       if (comment.replies.isNotEmpty)
//                         Text(
//                           '${comment.replies.length} ${comment.replies.length == 1 ? 'reply' : 'replies'}',
//                           style: TextStyle(
//                             fontSize: 12,
//                             color:
//                                 isDark
//                                     ? Colors.grey.shade400
//                                     : Colors.grey.shade600,
//                           ),
//                         ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             if (comment.replies.isNotEmpty)
//               Padding(
//                 padding: const EdgeInsets.only(left: 16, right: 8, bottom: 8),
//                 child: repliesAsync.when(
//                   data:
//                       (replies) => Column(
//                         children: [
//                           for (final reply in replies.take(2))
//                             CommentCard(comment: reply, isReply: true),
//                           if (replies.length > 2)
//                             TextButton(
//                               onPressed: () => _navigateToReplyScreen(context),
//                               child: Text(
//                                 'View all ${replies.length} replies',
//                                 style: TextStyle(
//                                   color: currentTheme.colorScheme.primary,
//                                   fontSize: 12,
//                                 ),
//                               ),
//                             ),
//                         ],
//                       ),
//                   error: (error, _) => ErrorText(error: error.toString()),
//                   loading:
//                       () => const Padding(
//                         padding: EdgeInsets.symmetric(vertical: 8),
//                         child: Loader(),
//                       ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_sphere/core/common/error_text.dart';
import 'package:social_sphere/core/common/loader.dart';
import 'package:social_sphere/core/providers/comment_provider.dart';
import 'package:social_sphere/features/post/screens/reply_screen.dart';
import 'package:social_sphere/models/comment_model.dart';
import 'package:social_sphere/responsive/responsive.dart';
import 'package:timeago/timeago.dart' as timeago;

class CommentCard extends ConsumerWidget {
  final Comment comment;
  final bool isReply;
  const CommentCard({
    super.key,
    required this.comment,
    this.isReply = false,
  });

  void _navigateToReplyScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReplyScreen(
          parentComment: comment,
          postId: comment.postId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timeAgo = timeago.format(comment.createdAt);
    final repliesAsync = ref.watch(getRepliesProvider(comment.id));
    final currentTheme = Theme.of(context);
    final bool isDark = currentTheme.brightness == Brightness.dark;

    return Responsive(
      child: Container(
        margin: EdgeInsets.only(
          left: isReply ? 32.0 : 12,
          right: 12,
          top: 4,
          bottom: 4,
        ),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
            width: 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(comment.profilePic),
                        radius: 16,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              comment.username,
                              style: currentTheme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              timeAgo,
                              style: currentTheme.textTheme.bodySmall?.copyWith(
                                color: isDark 
                                    ? Colors.grey.shade400 
                                    : Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    comment.text,
                    style: currentTheme.textTheme.bodyMedium?.copyWith(
                      color: isDark ? Colors.grey.shade100 : Colors.grey.shade900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => _navigateToReplyScreen(context),
                        icon: Icon(
                          Icons.reply_outlined,
                          size: 18,
                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      if (comment.replies.isNotEmpty)
                        Text(
                          '${comment.replies.length} ${comment.replies.length == 1 ? 'reply' : 'replies'}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            if (comment.replies.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 8, bottom: 8),
                child: repliesAsync.when(
                  data: (replies) => Column(
                    children: [
                      for (final reply in replies)
                        CommentCard(
                          comment: reply,
                          isReply: true,
                        ),
                    ],
                  ),
                  error: (error, _) => ErrorText(error: error.toString()),
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Loader(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}