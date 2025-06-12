import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:social_sphere/core/common/error_text.dart';
import 'package:social_sphere/core/common/loader.dart';
import 'package:social_sphere/core/common/post_card.dart';
import 'package:social_sphere/core/providers/ads_provider.dart';
import 'package:social_sphere/features/auth/controller/auth_controller.dart';
import 'package:social_sphere/features/community/controller/community_controller.dart';
import 'package:social_sphere/features/post/controller/post_controller.dart';
import 'package:social_sphere/models/post_model.dart';
import 'package:social_sphere/theme/pallete.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  final RefreshController _refreshController = RefreshController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  static const _adFrequency = 5;

  // Maintain unique BannerAds per index
  final Map<int, BannerAd> _bannerAds = {};
  final Set<int> _loadedAdIndexes = {};

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

    // Dispose all BannerAds
    for (final ad in _bannerAds.values) {
      ad.dispose();
    }
    super.dispose();
  }

  Future<void> _loadBannerAd(int index) async {
    if (_loadedAdIndexes.contains(index)) return;

    final adsController = ref.read(adsControllerProvider);
    try {
      final bannerAd = await adsController.createBannerAd();
      setState(() {
        _bannerAds[index] = bannerAd;
        _loadedAdIndexes.add(index);
      });
    } catch (e) {
      debugPrint('Error loading banner ad at $index: $e');
    }
  }

  Future<void> _onRefresh() async {
    try {
      final user = ref.read(userProvider)!;
      if (user.isAuthenticated) {
        await ref.refresh(userCommunitiesProvider.future);
        final comms = ref.read(userCommunitiesProvider).value ?? [];
        await ref.refresh(userPostsProvider(comms).future);
      } else {
        await ref.refresh(guestPostsProvider.future);
      }
      _refreshController.refreshCompleted();
    } catch (e) {
      _refreshController.refreshFailed();
    }
  }

  void _scrollListener() {
    if (_scrollController.position.atEdge &&
        _scrollController.position.pixels != 0 &&
        !_isLoadingMore) {
      _loadMorePosts();
    }
  }

  Future<void> _loadMorePosts() async {
    setState(() => _isLoadingMore = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoadingMore = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeNotifierProvider);
    final user = ref.watch(userProvider)!;
    final isGuest = !user.isAuthenticated;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshConfiguration(
          headerBuilder: () => ClassicHeader(
            completeIcon: Icon(Icons.check, color: theme.primaryColor),
            idleIcon: Icon(Icons.arrow_downward, color: theme.primaryColor),
          ),
          child: SmartRefresher(
            controller: _refreshController,
            onRefresh: _onRefresh,
            enablePullDown: true,
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: Text(
                      'Your Feed',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.titleLarge?.color,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                isGuest ? _buildGuestFeed(theme) : _buildUserFeed(theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserFeed(ThemeData theme) {
    return ref.watch(userCommunitiesProvider).when(
      loading: () => const SliverFillRemaining(child: Loader()),
      error: (e, _) => SliverToBoxAdapter(child: ErrorText(error: e.toString())),
      data: (comms) => ref.watch(userPostsProvider(comms)).when(
        loading: () => const SliverFillRemaining(child: Loader()),
        error: (e, _) => SliverToBoxAdapter(child: ErrorText(error: e.toString())),
        data: (posts) => _buildPostSliver(posts),
      ),
    );
  }

  Widget _buildGuestFeed(ThemeData theme) {
    return ref.watch(guestPostsProvider).when(
      loading: () => const SliverFillRemaining(child: Loader()),
      error: (e, _) => SliverToBoxAdapter(child: ErrorText(error: e.toString())),
      data: (posts) => _buildPostSliver(posts),
    );
  }

  Widget _buildPostSliver(List<Post> posts) {
    if (posts.isEmpty) {
      return SliverFillRemaining(child: _buildEmptyFeed());
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index == posts.length) return _buildLoadMoreIndicator();

          // Show Banner after every _adFrequency posts
          if (index > 0 && index % _adFrequency == 0) {
            if (!_loadedAdIndexes.contains(index)) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _loadBannerAd(index);
              });
            }

            final bannerAd = _bannerAds[index];
            return Column(
              children: [
                if (bannerAd != null)
                  SizedBox(
                    width: bannerAd.size.width.toDouble(),
                    height: bannerAd.size.height.toDouble(),
                    child: AdWidget(ad: bannerAd),
                  )
                else
                  SizedBox(
                    height: AdSize.banner.height.toDouble(),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                const SizedBox(height: 8),
                _buildPostCard(posts[index]),
              ],
            );
          }

          return _buildPostCard(posts[index]);
        },
        childCount: posts.length + 1,
      ),
    );
  }

  Widget _buildPostCard(Post post) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: PostCard(post: post),
    );
  }

  Widget _buildEmptyFeed() {
    final theme = ref.watch(themeNotifierProvider);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.feed_outlined, size: 80, color: theme.iconTheme.color?.withOpacity(0.3)),
          const SizedBox(height: 24),
          Text('Your feed is empty',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: theme.textTheme.titleLarge?.color?.withOpacity(0.8))
          ),
          const SizedBox(height: 16),
          Text(
            'Join communities or pull to refresh to load posts.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: theme.textTheme.bodyLarge?.color?.withOpacity(0.6)),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _onRefresh,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              elevation: 0,
            ),
            child: Text('Refresh', style: TextStyle(fontSize: 16, color: theme.colorScheme.onPrimary)),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(child: _isLoadingMore ? const CircularProgressIndicator() : const SizedBox.shrink()),
    );
  }
}
