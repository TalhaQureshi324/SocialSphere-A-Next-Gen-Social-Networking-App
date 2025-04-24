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

  @override
  void dispose() {
    _refreshController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    final user = ref.read(userProvider)!;
    if (user.isAuthenticated) {
      await ref.refresh(userCommunitiesProvider.future);
      final communities = ref.read(userCommunitiesProvider).value ?? [];
      await ref.refresh(userPostsProvider(communities).future);
    } else {
      await ref.refresh(guestPostsProvider.future);
    }
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = ref.watch(themeNotifierProvider);
    final user = ref.watch(userProvider)!;
    final isGuest = !user.isAuthenticated;

    return Scaffold(
      backgroundColor: currentTheme.scaffoldBackgroundColor,
      body: SafeArea(child: _buildFeedContent(isGuest, currentTheme)),
    );
  }

  Widget _buildFeedContent(bool isGuest, ThemeData theme) {
    return isGuest ? _buildGuestFeed(theme) : _buildUserFeed(theme);
  }

  Widget _buildUserFeed(ThemeData theme) {
    return ref
        .watch(userCommunitiesProvider)
        .when(
          data: (communities) {
            return ref
                .watch(userPostsProvider(communities))
                .when(
                  data: (posts) {
                    if (posts.isEmpty) {
                      return _buildEmptyFeed(theme);
                    }
                    return SmartRefresher(
                      controller: _refreshController,
                      onRefresh: _onRefresh,
                      enablePullDown: true,
                      header: ClassicHeader(
                        completeIcon: Icon(
                          Icons.check,
                          color: theme.primaryColor,
                        ),
                        idleIcon: Icon(
                          Icons.arrow_downward,
                          color: theme.primaryColor,
                        ),
                        textStyle: TextStyle(
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                      child: ListView.separated(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(12),
                        itemCount: posts.length,
                        separatorBuilder:
                            (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          return PostCard(post: posts[index]);
                        },
                      ),
                    );
                  },
                  error:
                      (error, stackTrace) => ErrorText(error: error.toString()),
                  loading: () => const Loader(),
                );
          },
          error: (error, stackTrace) => ErrorText(error: error.toString()),
          loading: () => const Loader(),
        );
  }

  Widget _buildGuestFeed(ThemeData theme) {
    return ref
        .watch(guestPostsProvider)
        .when(
          data: (posts) {
            if (posts.isEmpty) {
              return _buildEmptyFeed(theme);
            }
            return SmartRefresher(
              controller: _refreshController,
              onRefresh: _onRefresh,
              enablePullDown: true,
              header: ClassicHeader(
                completeIcon: Icon(Icons.check, color: theme.primaryColor),
                idleIcon: Icon(Icons.arrow_downward, color: theme.primaryColor),
                textStyle: TextStyle(color: theme.textTheme.bodyLarge?.color),
              ),
              child: ListView.separated(
                controller: _scrollController,
                padding: const EdgeInsets.all(12),
                itemCount: posts.length,
                separatorBuilder:
                    (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return PostCard(post: posts[index]);
                },
              ),
            );
          },
          error: (error, stackTrace) => ErrorText(error: error.toString()),
          loading: () => const Loader(),
        );
  }

  Widget _buildEmptyFeed(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.feed_outlined,
            size: 60,
            color: theme.iconTheme.color?.withOpacity(0.5),
          ),
          const SizedBox(height: 20),
          Text(
            'No posts yet',
            style: TextStyle(
              fontSize: 20,
              color: theme.textTheme.bodyLarge?.color?.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Join some groups or refresh to see posts',
            style: TextStyle(
              fontSize: 14,
              color: theme.textTheme.bodyLarge?.color?.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _onRefresh,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text('Refresh', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
