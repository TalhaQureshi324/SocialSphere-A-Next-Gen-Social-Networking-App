import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_sphere/core/common/error_text.dart';
import 'package:social_sphere/core/common/loader.dart';
import 'package:social_sphere/core/common/post_card.dart';
import 'package:social_sphere/features/auth/controller/auth_controller.dart';
import 'package:social_sphere/features/community/controller/community_controller.dart';
import 'package:social_sphere/features/post/controller/post_controller.dart';
import 'package:social_sphere/theme/pallete.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  final RefreshController _refreshController = RefreshController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    try {
      final user = ref.read(userProvider)!;
      if (user.isAuthenticated) {
        await ref.refresh(userCommunitiesProvider.future);
        final communities = ref.read(userCommunitiesProvider).value ?? [];
        await ref.refresh(userPostsProvider(communities).future);
      } else {
        await ref.refresh(guestPostsProvider.future);
      }
      _refreshController.refreshCompleted();
    } catch (e) {
      _refreshController.refreshFailed();
    }
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent &&
        !_isLoadingMore) {
      _loadMorePosts();
    }
  }

  Future<void> _loadMorePosts() async {
    if (_isLoadingMore) return;

    setState(() => _isLoadingMore = true);
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    setState(() => _isLoadingMore = false);
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = ref.watch(themeNotifierProvider);
    final user = ref.watch(userProvider)!;
    final isGuest = !user.isAuthenticated;

    return Scaffold(
      backgroundColor: currentTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshConfiguration(
          headerBuilder: () => ClassicHeader(
            completeIcon: Icon(Icons.check, color: currentTheme.primaryColor),
            idleIcon: Icon(Icons.arrow_downward, color: currentTheme.primaryColor),
          ),
          child: SmartRefresher(
            controller: _refreshController,
            onRefresh: _onRefresh,
            enablePullDown: true,
            header: ClassicHeader(
              completeIcon: Icon(Icons.check, color: currentTheme.primaryColor),
              idleIcon: Icon(Icons.arrow_downward, color: currentTheme.primaryColor),
            ),
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                      padding: const EdgeInsets.only(top: 8, left: 16, right: 16),
                      child: Center(
                          child: Text(
                            'Your Feed',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).textTheme.titleLarge?.color ?? Colors.black, // Use a fallback color
                            ),
                          ),
                      ),
                  ),
                ),
                _buildFeedContent(isGuest, currentTheme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeedContent(bool isGuest, ThemeData theme) {
    if (isGuest) {
      return _buildGuestFeed(theme);
    }
    return _buildUserFeed(theme);
  }

  Widget _buildUserFeed(ThemeData theme) {
    return ref.watch(userCommunitiesProvider).when(
      loading: () => const SliverFillRemaining(child: Loader()),
      error: (error, stackTrace) => SliverToBoxAdapter(
        child: ErrorText(error: error.toString()),
      ),
      data: (communities) {
        return ref.watch(userPostsProvider(communities)).when(
          loading: () => const SliverFillRemaining(child: Loader()),
          error: (error, stackTrace) => SliverToBoxAdapter(
            child: ErrorText(error: error.toString()),
          ),
          data: (posts) {
            if (posts.isEmpty) {
              return SliverFillRemaining(child: _buildEmptyFeed(theme));
            }
            return SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  if (index == posts.length) {
                    return _buildLoadMoreIndicator();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: PostCard(post: posts[index]),
                  );
                },
                childCount: posts.length + 1,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildGuestFeed(ThemeData theme) {
    return ref.watch(guestPostsProvider).when(
      loading: () => const SliverFillRemaining(child: Loader()),
      error: (error, stackTrace) => SliverToBoxAdapter(
        child: ErrorText(error: error.toString()),
      ),
      data: (posts) {
        if (posts.isEmpty) {
          return SliverFillRemaining(child: _buildEmptyFeed(theme));
        }
        return SliverList(
          delegate: SliverChildBuilderDelegate(
                (context, index) {
              if (index == posts.length) {
                return _buildLoadMoreIndicator();
              }
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: PostCard(post: posts[index]),
              );
            },
            childCount: posts.length + 1,
          ),
        );
      },
    );
  }

  Widget _buildEmptyFeed(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.feed_outlined,
            size: 80,
            color: theme.iconTheme.color?.withOpacity(0.3),
          ),
          const SizedBox(height: 24),
          Text(
            'Your feed is empty',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: theme.textTheme.titleLarge?.color?.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Join communities to see posts in your feed, or refresh to check for new content',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: theme.textTheme.bodyLarge?.color?.withOpacity(0.6),
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _onRefresh,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              elevation: 0,
            ),
            child: Text(
              'Refresh Feed',
              style: TextStyle(
                color: theme.colorScheme.onPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: _isLoadingMore
            ? const CircularProgressIndicator()
            : const SizedBox.shrink(),
      ),
    );
  }
}