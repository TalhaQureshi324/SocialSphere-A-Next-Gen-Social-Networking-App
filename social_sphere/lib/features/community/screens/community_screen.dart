import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:social_sphere/core/common/error_text.dart';
import 'package:social_sphere/core/common/loader.dart';
import 'package:social_sphere/core/common/post_card.dart';
import 'package:social_sphere/features/auth/controller/auth_controller.dart';
import 'package:social_sphere/features/community/controller/community_controller.dart';
import 'package:social_sphere/models/community_model.dart';

class CommunityScreen extends ConsumerWidget {
  final String name;
  const CommunityScreen({super.key, required this.name});

  void _navigateToModTools(BuildContext context) {
    Routemaster.of(context).push('/mod-tools/$name');
  }

  void _joinCommunity(WidgetRef ref, Community community, BuildContext context) {
    ref.read(communityControllerProvider.notifier).joinCommunity(community, context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider)!;
    final isGuest = !user.isAuthenticated;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      floatingActionButton: ref.watch(getCommunityByNameProvider(name)).when(
        data: (community) {
          if (!isGuest && community.members.contains(user.uid)) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.shade400,
                    Colors.purple.shade600,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: FloatingActionButton(
                backgroundColor: Colors.transparent,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                onPressed: () => Routemaster.of(context).push('/add-post'),
                child: const Icon(Icons.add, color: Colors.white, size: 28),
              ),
            );
          }
          return null;
        },
        error: (error, stackTrace) => null,
        loading: () => null,
      ),
      body: ref.watch(getCommunityByNameProvider(name)).when(
        data: (community) {
          return CustomScrollView(
            slivers: [
              // Community Header Section
              SliverAppBar(
                expandedHeight: 220,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.pin,
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Banner Image with Gradient Overlay
                      Image.network(
                        community.banner,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: isDark ? Colors.grey.shade900 : Colors.grey.shade200,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withOpacity(0.7),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),

                      // Community Info
                      Positioned(
                        bottom: 16,
                        left: 16,
                        right: 16,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // Community Avatar
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.blue.shade400,
                                    Colors.purple.shade600,
                                  ],
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(3.0),
                                child: CircleAvatar(
                                  backgroundImage: NetworkImage(community.avatar),
                                  radius: 30,
                                  backgroundColor: theme.scaffoldBackgroundColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),

                            // Community Name and Members
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${community.name}',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${community.members.length} ${community.members.length == 1 ? 'member' : 'members'}',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Community Actions Section
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    children: [
                      if (!isGuest)
                        community.mods.contains(user.uid)
                            ? _buildActionButton(
                          icon: Icons.admin_panel_settings,
                          label: 'Admin Settings',
                          onPressed: () => _navigateToModTools(context),
                          isActive: true,
                        )
                            : _buildActionButton(
                          icon: community.members.contains(user.uid)
                              ? Icons.check
                              : Icons.add,
                          label: community.members.contains(user.uid)
                              ? 'Joined'
                              : 'Join',
                          onPressed: () => _joinCommunity(ref, community, context),
                          isActive: community.members.contains(user.uid),
                        ),
                    ],
                  ),
                ),
              ),

              // Community Posts Section
              ref.watch(getCommunityPostsProvider(name)).when(
                data: (posts) {
                  if (posts.isEmpty) {
                    return SliverPadding(
                      padding: const EdgeInsets.only(top: 80),
                      sliver: SliverToBoxAdapter(
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.forum_outlined,
                                size: 48,
                                color: theme.textTheme.bodyLarge?.color?.withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "No posts yet",
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Be the first to share something!",
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                                ),
                              ),
                              const SizedBox(height: 24),
                              if (!isGuest && community.members.contains(user.uid))
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.blue.shade400,
                                        Colors.purple.shade600,
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    onPressed: () => Routemaster.of(context).push('/add-post'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 12,
                                      ),
                                    ),
                                    child: const Text(
                                      'Create Post',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) => PostCard(post: posts[index]),
                      childCount: posts.length,
                    ),
                  );
                },
                error: (error, stackTrace) => SliverToBoxAdapter(
                  child: ErrorText(error: error.toString()),
                ),
                loading: () => const SliverToBoxAdapter(child: Loader()),
              ),
            ],
          );
        },
        error: (error, stackTrace) => ErrorText(error: error.toString()),
        loading: () => const Loader(),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool isActive = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: isActive
            ? LinearGradient(
          colors: [
            Colors.blue.shade400,
            Colors.purple.shade600,
          ],
        )
            : null,
        border: !isActive
            ? Border.all(
          color: Colors.blue.shade400,
          width: 1.5,
        )
            : null,
        boxShadow: isActive
            ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ]
            : null,
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: isActive ? Colors.white : Colors.blue.shade400,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
        icon: Icon(icon, size: 18),
        label: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}