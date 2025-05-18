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
  final bool showFullThread;

  const CommentCard({
    super.key,
    required this.comment,
    this.isReply = false,
    this.showFullThread = true,
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
    final repliesAsync = showFullThread ? ref.watch(getRepliesProvider(comment.id)) : null;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Responsive(
      child: Container(
        margin: EdgeInsets.only(
          left: isReply ? 32.0 : 12,
          right: 12,
          top: 4,
          bottom: 4,
        ),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.outlineVariant.withOpacity(0.2),
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
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              timeAgo,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
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
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface,
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
                          color: colorScheme.onSurfaceVariant,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      if (comment.replies.isNotEmpty)
                        Text(
                          '${comment.replies.length} ${comment.replies.length == 1 ? 'reply' : 'replies'}',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.primary,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            if (showFullThread && comment.replies.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 8, bottom: 8),
                child: repliesAsync!.when(
                  data: (replies) => Column(
                    children: [
                      for (final reply in replies.take(2))
                        CommentCard(
                          comment: reply,
                          isReply: true,
                          showFullThread: false,
                        ),
                      if (replies.length > 2)
                        TextButton(
                          onPressed: () => _navigateToReplyScreen(context),
                          child: Text(
                            'View all ${replies.length} replies',
                            style: TextStyle(
                              color: colorScheme.primary,
                              fontSize: 12,
                            ),
                          ),
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