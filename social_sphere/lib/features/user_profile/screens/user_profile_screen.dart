import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_sphere/core/common/error_text.dart';
import 'package:social_sphere/core/common/loader.dart';
import 'package:social_sphere/core/common/post_card.dart';
import 'package:social_sphere/features/auth/controller/auth_controller.dart';
import 'package:social_sphere/features/user_profile/controller/user_profile_controller.dart';
import 'package:social_sphere/theme/pallete.dart';
import 'package:routemaster/routemaster.dart';

class UserProfileScreen extends ConsumerWidget {
  final String uid;
  const UserProfileScreen({super.key, required this.uid});

  void navigateToEditUser(BuildContext context) {
    Routemaster.of(context).push('/edit-profile/$uid');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeNotifierProvider);
    final currentUser = ref.watch(userProvider)!;
    final isCurrentUser = currentUser.uid == uid;

    return Scaffold(
      floatingActionButton: isCurrentUser
          ? Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              Colors.blue.shade400,
              Colors.purple.shade600,
            ],
          ),
        ),
        child: FloatingActionButton(
          backgroundColor: Colors.transparent,
          elevation: 0,
          mini: false,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          onPressed: () => Routemaster.of(context).push('/add-post'),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      )
          : null,

      backgroundColor: currentTheme.scaffoldBackgroundColor,
      body: ref.watch(getUserDataProvider(uid)).when(
        data: (user) => CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 280,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: _ProfileHeader(
                  user: user,
                  isCurrentUser: isCurrentUser,
                  onEditPressed: () => navigateToEditUser(context),
                  theme: currentTheme,
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.only(top: 16),
              sliver: ref.watch(getUserPostsProvider(uid)).when(
                data: (posts) => SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: PostCard(post: posts[index]),
                      );
                    },
                    childCount: posts.length,
                  ),
                ),
                error: (error, stackTrace) => SliverToBoxAdapter(
                  child: ErrorText(error: error.toString()),
                ),
                loading: () => const SliverToBoxAdapter(
                  child: Loader(),
                ),
              ),
            ),
          ],
        ),
        error: (error, stackTrace) => ErrorText(error: error.toString()),
        loading: () => const Loader(),
      ),
    );
  }
}

class _ProfileHeader extends ConsumerWidget {
  final dynamic user;
  final bool isCurrentUser;
  final VoidCallback onEditPressed;
  final ThemeData theme;

  const _ProfileHeader({
    required this.user,
    required this.isCurrentUser,
    required this.onEditPressed,
    required this.theme,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeNotifierProvider);
    final isDark = currentTheme.brightness == Brightness.dark;

    return Stack(
      children: [
        // Banner Image with fallback
        Container(
          height: 200,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(user.banner ?? 'https://example.com/default_banner.jpg'),
              fit: BoxFit.cover,
            ),
          ),
        ),

        // Gradient Overlay
        Container(
          height: 200,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [Colors.black.withOpacity(0.7), Colors.transparent],
            ),
          ),
        ),

        // Profile Content
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Profile Picture with fallback
                Container(
                  padding: const EdgeInsets.all(3.0),
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
                    radius: 50,
                    backgroundImage: NetworkImage(user.profilePic ?? 'https://example.com/default_avatar.jpg'),
                  ),
                ),
                const SizedBox(width: 16),

                // User Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name ?? 'Anonymous',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Karma: ${user.karma ?? 0}',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),

                // Actions
                if (!isCurrentUser)
                  IconButton(
                    onPressed: () => Routemaster.of(context).push('/chat/${user.uid}'),
                    icon: Icon(
                      Icons.chat,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),

                if (isCurrentUser)
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        colors: [
                          Colors.blue.shade400,
                          Colors.purple.shade600,
                        ],
                      ),
                    ),
                    child: ElevatedButton(
                      onPressed: onEditPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                      ),
                      child: const Text(
                        'Edit Profile',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final ThemeData theme;

  const _StatItem({
    required this.value,
    required this.label,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = theme.brightness == Brightness.dark;
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.white70 : Colors.black87,
          ),
        ),
      ],
    );
  }
}