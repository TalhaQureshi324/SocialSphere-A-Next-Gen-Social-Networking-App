import 'package:any_link_preview/any_link_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_sphere/core/constants/constants.dart';
import 'package:social_sphere/features/auth/controller/auth_controller.dart';
import 'package:social_sphere/features/community/controller/community_controller.dart';
import 'package:social_sphere/features/post/controller/post_controller.dart';
import 'package:social_sphere/models/post_model.dart';
import 'package:social_sphere/theme/pallete.dart';
import 'package:routemaster/routemaster.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class PostCard extends ConsumerStatefulWidget {
  final Post post;
  const PostCard({super.key, required this.post});

  @override
  ConsumerState<PostCard> createState() => _PostCardState();
}

class _PostCardState extends ConsumerState<PostCard> {
  bool _isCardHovered = false;
  bool _isLikeHovered = false;
  bool _isDislikeHovered = false;
  bool _isCommentHovered = false;
  bool _isReactionHovered = false;
  late VideoPlayerController _videoController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    if (widget.post.type == 'video') {
      _initializeVideoPlayer();
    }
  }

  void _initializeVideoPlayer() {
    _videoController = VideoPlayerController.network(widget.post.link!)
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _chewieController = ChewieController(
              videoPlayerController: _videoController,
              autoPlay: false,
              looping: false,
              allowFullScreen: true,
              showControls: true,
              materialProgressColors: ChewieProgressColors(
                playedColor: Pallete.blueColor,
                handleColor: Pallete.blueColor,
              ),
            );
          });
        }
      });
  }

  @override
  void dispose() {
    if (widget.post.type == 'video') {
      _videoController.dispose();
      _chewieController?.dispose();
    }
    super.dispose();
  }

  void _deletePost() => ref.read(postControllerProvider.notifier).deletePost(widget.post, context);
  void _upvotePost() => ref.read(postControllerProvider.notifier).upvote(widget.post);
  void _downvotePost() => ref.read(postControllerProvider.notifier).downvote(widget.post);
  void _awardPost(String award) => ref.read(postControllerProvider.notifier).awardPost(post: widget.post, award: award, context: context);

  void _navigateToUser() => Routemaster.of(context).push('/u/${widget.post.uid}');
  void _navigateToCommunity() => Routemaster.of(context).push('/r/${widget.post.communityName}');
  void _navigateToComments() => Routemaster.of(context).push('/post/${widget.post.id}/comments');

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider)!;
    final isGuest = !user.isAuthenticated;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return MouseRegion(
      onEnter: (_) => setState(() => _isCardHovered = true),
      onExit: (_) => setState(() => _isCardHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: colorScheme.surfaceContainer,
          boxShadow: [
            if (_isCardHovered)
              BoxShadow(
                color: colorScheme.shadow.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
          border: Border.all(
            color: colorScheme.outlineVariant.withOpacity(0.3),
            width: 0.5,
          ),
        ),
        child: Column(
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  // Community Avatar with Gradient Border
                  GestureDetector(
                    onTap: _navigateToCommunity,
                    child: Container(
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
                        backgroundImage: NetworkImage(widget.post.communityProfilePic),
                        radius: 18,
                        backgroundColor: colorScheme.surface,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Community and User Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: _navigateToCommunity,
                          child: Text(
                            '${widget.post.communityName}',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        GestureDetector(
                          onTap: widget.post.isAnonymous ? null : _navigateToUser,
                          child: Text(
                            widget.post.isAnonymous
                                ? 'Posted anonymously'
                                : '${widget.post.username}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Delete Button (for post owner)
                  if (widget.post.uid == user.uid)
                    IconButton(
                      onPressed: _deletePost,
                      icon: const Icon(Icons.delete, size: 20),
                      color: Colors.red,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                ],
              ),
            ),

            // Awards Ribbon
            if (widget.post.awards.isNotEmpty) _buildAwardsRibbon(),

            // Content Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                border: Border.symmetric(
                  horizontal: BorderSide(
                    color: colorScheme.outlineVariant.withOpacity(0.2),
                    width: 0.5,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Post Title
                  Text(
                    widget.post.title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Content based on post type
                  if (widget.post.type == 'image') _buildImageContent(),
                  if (widget.post.type == 'video') _buildVideoContent(),
                  if (widget.post.type == 'link') _buildLinkContent(),
                  if (widget.post.type == 'text') _buildTextContent(),
                ],
              ),
            ),

            // Footer Actions
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Vote Buttons
                  Row(
                    children: [
                      _buildVoteButton(
                        isActive: widget.post.upvotes.contains(user.uid),
                        isHovered: _isLikeHovered,
                        icon: Icons.arrow_upward,
                        onPressed: isGuest ? null : _upvotePost,
                        count: widget.post.upvotes.length,
                        activeColor: Pallete.blueColor,
                        onHover: (hovering) => setState(() => _isLikeHovered = hovering),
                      ),
                      const SizedBox(width: 8),
                      _buildVoteButton(
                        isActive: widget.post.downvotes.contains(user.uid),
                        isHovered: _isDislikeHovered,
                        icon: Icons.arrow_downward,
                        onPressed: isGuest ? null : _downvotePost,
                        count: widget.post.downvotes.length,
                        activeColor: Pallete.redColor,
                        onHover: (hovering) => setState(() => _isDislikeHovered = hovering),
                      ),
                    ],
                  ),

                  // Comments Button
                  _buildActionButton(
                    icon: Icons.mode_comment_outlined,
                    count: widget.post.commentCount,
                    isHovered: _isCommentHovered,
                    onPressed: _navigateToComments,
                    onHover: (hovering) => setState(() => _isCommentHovered = hovering),
                  ),

                  // Mod Button (for mods)
                  ref.watch(getCommunityByNameProvider(widget.post.communityName)).when(
                    data: (community) {
                      if (community.mods.contains(user.uid)) {
                        return _buildModButton();
                      }
                      return const SizedBox();
                    },
                    error: (error, stackTrace) => const SizedBox(),
                    loading: () => const SizedBox(),
                  ),

                  // Reaction Button
                  _buildReactionButton(isGuest),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAwardsRibbon() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        border: Border.symmetric(
          horizontal: BorderSide(
            color: colorScheme.outlineVariant.withOpacity(0.2),
            width: 0.5,
          ),
        ),
      ),
      child: SizedBox(
        height: 28,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: widget.post.awards.length,
          itemBuilder: (context, index) {
            final award = widget.post.awards[index];
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Image.asset(
                Constants.awards[award]!,
                height: 25,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildImageContent() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.5,
        ),
        child: Image.network(
          widget.post.link!,
          fit: BoxFit.cover,
          width: double.infinity,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              height: 200,
              alignment: Alignment.center,
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                    : null,
                color: colorScheme.primary,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 200,
              color: colorScheme.surfaceContainerHighest,
              alignment: Alignment.center,
              child: Icon(Icons.broken_image, color: colorScheme.onSurfaceVariant),
            );
          },
        ),
      ),
    );
  }

  Widget _buildVideoContent() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_chewieController == null || !_videoController.value.isInitialized) {
      return Container(
        height: 200,
        color: colorScheme.surfaceContainerHighest,
        alignment: Alignment.center,
        child: CircularProgressIndicator(color: colorScheme.primary),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AspectRatio(
        aspectRatio: _videoController.value.aspectRatio,
        child: Chewie(controller: _chewieController!),
      ),
    );
  }

  Widget _buildLinkContent() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: AnyLinkPreview(
            displayDirection: UIDirection.uiDirectionHorizontal,
            link: widget.post.link!,
            backgroundColor: colorScheme.surface,
            bodyMaxLines: 3,
            bodyTextOverflow: TextOverflow.ellipsis,
            titleStyle: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextContent() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        widget.post.description!,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildVoteButton({
    required bool isActive,
    required bool isHovered,
    required IconData icon,
    required VoidCallback? onPressed,
    required int count,
    required Color activeColor,
    required Function(bool) onHover,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return MouseRegion(
      onEnter: (_) => onHover(true),
      onExit: (_) => onHover(false),
      child: Row(
        children: [
          IconButton(
            onPressed: onPressed,
            icon: Icon(icon, size: 20),
            style: IconButton.styleFrom(
              foregroundColor: isActive ? activeColor : colorScheme.onSurfaceVariant,
              backgroundColor: isActive
                  ? activeColor.withOpacity(0.1)
                  : isHovered
                  ? colorScheme.surfaceContainerHighest
                  : Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            splashRadius: 20,
          ),
          if (count > 0)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(
                '$count',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isActive ? activeColor : colorScheme.onSurfaceVariant,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required int count,
    required bool isHovered,
    required VoidCallback onPressed,
    required Function(bool) onHover,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return MouseRegion(
      onEnter: (_) => onHover(true),
      onExit: (_) => onHover(false),
      child: IconButton(
        onPressed: onPressed,
        icon: Row(
          children: [
            Icon(icon, size: 20),
            if (count > 0) ...[
              const SizedBox(width: 4),
              Text(
                '$count',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
        style: IconButton.styleFrom(
          foregroundColor: colorScheme.onSurfaceVariant,
          backgroundColor: isHovered
              ? colorScheme.surfaceContainerHighest
              : Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        splashRadius: 20,
      ),
    );
  }

  Widget _buildModButton() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Tooltip(
      message: 'Moderator Tools',
      child: IconButton(
        onPressed: _deletePost,
        icon: Stack(
          alignment: Alignment.center,
          children: [
            Icon(Icons.delete_forever , size: 20, color: colorScheme.onSurfaceVariant),
            Positioned(
              bottom: 0,
              right: 0,
              child: Icon(Icons.shield, size: 14, color: Pallete.redColor),
            ),
          ],
        ),
        style: IconButton.styleFrom(
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        splashRadius: 20,
      ),
    );
  }

  Widget _buildReactionButton(bool isGuest) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return MouseRegion(
      onEnter: (_) => setState(() => _isReactionHovered = true),
      onExit: (_) => setState(() => _isReactionHovered = false),
      child: IconButton(
        onPressed: isGuest
            ? null
            : () {
          showDialog(
            context: context,
            builder: (context) => Dialog(
              backgroundColor: colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Add Reaction',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: 300,
                      child: GridView.builder(
                        shrinkWrap: true,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                        ),
                        itemCount: ref.watch(userProvider)!.awards.length,
                        itemBuilder: (BuildContext context, int index) {
                          final award = ref.watch(userProvider)!.awards[index];
                          return GestureDetector(
                            onTap: () {
                              _awardPost(award);
                              Navigator.pop(context);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: colorScheme.surfaceVariant,
                              ),
                              child: Image.asset(
                                Constants.awards[award]!,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        icon: const Icon(Icons.emoji_emotions_outlined, size: 20),
        color: colorScheme.onSurfaceVariant,
        style: IconButton.styleFrom(
          backgroundColor: _isReactionHovered
              ? colorScheme.surfaceContainerHighest
              : Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        splashRadius: 20,
      ),
    );
  }
}