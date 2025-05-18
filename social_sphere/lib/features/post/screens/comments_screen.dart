import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_sphere/core/common/error_text.dart';
import 'package:social_sphere/core/common/loader.dart';
import 'package:social_sphere/core/common/post_card.dart';
import 'package:social_sphere/features/auth/controller/auth_controller.dart';
import 'package:social_sphere/features/post/controller/post_controller.dart';
import 'package:social_sphere/features/post/widgets/comment_card.dart';
import 'package:social_sphere/models/post_model.dart';

class CommentsScreen extends ConsumerStatefulWidget {
  final String postId;
  const CommentsScreen({super.key, required this.postId});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends ConsumerState<CommentsScreen> {
  final commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void addComment(Post post) {
    ref.read(postControllerProvider.notifier).addComment(
      context: context,
      text: commentController.text.trim(),
      post: post,
    );
    commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider)!;
    final isGuest = !user.isAuthenticated;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Comments'),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Post card with constrained height
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.4,
              ),
              child: SingleChildScrollView(
                controller: _scrollController,
                child: ref.watch(getPostByIdProvider(widget.postId)).when(
                  data: (post) => PostCard(post: post),
                  error: (error, _) => ErrorText(error: error.toString()),
                  loading: () => const Loader(),
                ),
              ),
            ),

            Divider(
              height: 1,
              color: colorScheme.outlineVariant.withOpacity(0.2),
            ),

            // Comment input section
            if (!isGuest)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  border: Border(
                    top: BorderSide(
                      color: colorScheme.outlineVariant.withOpacity(0.1),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(user.profilePic),
                      radius: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: TextField(
                          controller: commentController,
                          decoration: InputDecoration(
                            hintText: 'Add a comment...',
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                          onSubmitted: (val) {
                            ref.watch(getPostByIdProvider(widget.postId)).whenData(
                                  (post) => addComment(post),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colorScheme.primary,
                      ),
                      child: IconButton(
                        onPressed: () {
                          ref.watch(getPostByIdProvider(widget.postId)).whenData(
                                (post) => addComment(post),
                          );
                        },
                        icon: Icon(Icons.send, color: colorScheme.onPrimary),
                      ),
                    ),
                  ],
                ),
              ),

            // Comments list
            Expanded(
              child: Container(
                color: colorScheme.surface,
                child: ref.watch(getPostCommentsProvider(widget.postId)).when(
                  data: (comments) {
                    if (comments.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.mode_comment_outlined,
                                size: 48, color: colorScheme.onSurfaceVariant),
                            const SizedBox(height: 16),
                            Text(
                              'No comments yet',
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.only(top: 8, bottom: 80),
                      itemCount: comments.length,
                      separatorBuilder: (context, index) => Divider(
                        height: 1,
                        indent: 72,
                        color: colorScheme.outlineVariant.withOpacity(0.1),
                      ),
                      itemBuilder: (context, index) {
                        final comment = comments[index];
                        if (comment.parentCommentId != null) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: CommentCard(
                            comment: comment,
                            showFullThread: true,
                          ),
                        );
                      },
                    );
                  },
                  error: (error, _) => ErrorText(error: error.toString()),
                  loading: () => const Loader(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}