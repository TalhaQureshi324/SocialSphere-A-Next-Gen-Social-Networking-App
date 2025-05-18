import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_sphere/core/common/error_text.dart';
import 'package:social_sphere/core/common/loader.dart';
import 'package:social_sphere/core/providers/comment_provider.dart';
import 'package:social_sphere/features/post/controller/post_controller.dart';
import 'package:social_sphere/features/post/widgets/comment_card.dart';
import 'package:social_sphere/models/comment_model.dart';












import '../../auth/controller/auth_controller.dart';
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
  final ScrollController _scrollController = ScrollController();

  void _postReply() {
    if (_replyController.text.trim().isNotEmpty) {
      ref.read(postControllerProvider.notifier).addReply(
        context: context,
        text: _replyController.text.trim(),
        parentComment: widget.parentComment,
      );
      _replyController.clear();
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
  }

  @override
  void dispose() {
    _replyController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final user = ref.watch(userProvider)!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thread'),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverToBoxAdapter(
                    child: CommentCard(
                      comment: widget.parentComment,
                      isReply: false, // Main comment is not a reply
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Divider(
                    height: 1,
                    color: colorScheme.outlineVariant.withOpacity(0.2),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      'Replies',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
                ref.watch(getRepliesProvider(widget.parentComment.id)).when(
                  data: (replies) {
                    if (replies.isEmpty) {
                      return SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.mode_comment_outlined,
                                size: 48,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No replies yet',
                                style: TextStyle(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                            (context, index) {
                          final reply = replies[index];
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                            child: CommentCard(
                              comment: reply,
                              isReply: true, // These are replies
                            ),
                          );
                        },
                        childCount: replies.length,
                      ),
                    );
                  },
                  error: (error, _) => SliverToBoxAdapter(
                    child: ErrorText(error: error.toString()),
                  ),
                  loading: () => const SliverToBoxAdapter(
                    child: Loader(),
                  ),
                ),
              ],
            ),
          ),
          // Reply input section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
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
                      controller: _replyController,
                      decoration: InputDecoration(
                        hintText: 'Write a reply...',
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      onSubmitted: (_) => _postReply(),
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
                    onPressed: _postReply,
                    icon: Icon(Icons.send, color: colorScheme.onPrimary),
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