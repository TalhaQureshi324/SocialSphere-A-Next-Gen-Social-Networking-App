// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:social_sphere/core/common/error_text.dart';
// import 'package:social_sphere/core/common/loader.dart';
// import 'package:social_sphere/core/common/post_card.dart';
// import 'package:social_sphere/features/auth/controller/auth_controller.dart';
// import 'package:social_sphere/features/user_profile/controller/user_profile_controller.dart';
// import 'package:social_sphere/theme/pallete.dart';
// import 'package:routemaster/routemaster.dart';

// class UserProfileScreen extends ConsumerWidget {
//   final String uid;
//   const UserProfileScreen({super.key, required this.uid});

//   void navigateToEditUser(BuildContext context) {
//     Routemaster.of(context).push('/edit-profile/$uid');
//   }

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final currentTheme = ref.watch(themeNotifierProvider);
//     final currentUser = ref.watch(userProvider)!;
//     final isCurrentUser = currentUser.uid == uid;

//     return Scaffold(
//       backgroundColor: currentTheme.scaffoldBackgroundColor,
//       body: ref
//           .watch(getUserDataProvider(uid))
//           .when(
//             data:
//                 (user) => CustomScrollView(
//                   slivers: [
//                     SliverAppBar(
//                       expandedHeight: 280,
//                       pinned: true,
//                       flexibleSpace: FlexibleSpaceBar(
//                         background: _ProfileHeader(
//                           user: user,
//                           isCurrentUser: isCurrentUser,
//                           onEditPressed: () => navigateToEditUser(context),
//                           theme: currentTheme,
//                         ),
//                       ),
//                     ),
//                     // SliverToBoxAdapter(
//                     //   child: _UserInfoSection(user: user, theme: currentTheme),
//                     // ),
//                     SliverPadding(
//                       padding: const EdgeInsets.only(top: 16),
//                       sliver: ref
//                           .watch(getUserPostsProvider(uid))
//                           .when(
//                             data:
//                                 (posts) => SliverList(
//                                   delegate: SliverChildBuilderDelegate((
//                                     context,
//                                     index,
//                                   ) {
//                                     return Padding(
//                                       padding: const EdgeInsets.symmetric(
//                                         horizontal: 16,
//                                         vertical: 8,
//                                       ),
//                                       child: PostCard(post: posts[index]),
//                                     );
//                                   }, childCount: posts.length),
//                                 ),
//                             error:
//                                 (error, stackTrace) => SliverToBoxAdapter(
//                                   child: ErrorText(error: error.toString()),
//                                 ),
//                             loading:
//                                 () => const SliverToBoxAdapter(child: Loader()),
//                           ),
//                     ),
//                   ],
//                 ),
//             error: (error, stackTrace) => ErrorText(error: error.toString()),
//             loading: () => const Loader(),
//           ),
//     );
//   }
// }

// class _ProfileHeader extends ConsumerWidget {
//   final dynamic user;
//   final bool isCurrentUser;
//   final VoidCallback onEditPressed;
//   final ThemeData theme;

//   const _ProfileHeader({
//     required this.user,
//     required this.isCurrentUser,
//     required this.onEditPressed,
//     required this.theme,
//   });

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final currentTheme = ref.watch(themeNotifierProvider);
//     final isDark = currentTheme.brightness == Brightness.dark;

//     return Stack(
//       children: [
//         // Banner Image
//         Container(
//           height: 200,
//           decoration: BoxDecoration(
//             image: DecorationImage(
//               image: NetworkImage(user.banner),
//               fit: BoxFit.cover,
//             ),
//           ),
//         ),

//         // Gradient Overlay
//         Container(
//           height: 200,
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.bottomCenter,
//               end: Alignment.topCenter,
//               colors: [Colors.black.withOpacity(0.7), Colors.transparent],
//             ),
//           ),
//         ),

//         // Profile Content
//         Positioned(
//           bottom: 0,
//           left: 0,
//           right: 0,
//           child: Padding(
//             padding: const EdgeInsets.all(16),
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.end,
//               children: [
//                 // Add this in your user profile header section

//                 // Profile Picture
//                 Container(
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     border: Border.all(
//                       color: currentTheme.scaffoldBackgroundColor,
//                       width: 3,
//                     ),
//                     boxShadow: [
//                       BoxShadow(
//                         color:
//                             isDark
//                                 ? const Color.fromARGB(255, 118, 114, 114)
//                                 : const Color.fromARGB(255, 78, 69, 69),
//                         blurRadius: 8,
//                         spreadRadius: 2,
//                       ),
//                     ],
//                   ),
//                   child: CircleAvatar(
//                     radius: 50,
//                     backgroundImage: NetworkImage(user.profilePic),
//                   ),
//                 ),

//                 const SizedBox(width: 16),

//                 // User Name and Actions
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         '${user.name}',
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                           color:
//                               isDark
//                                   ? Colors.white
//                                   : const Color.fromARGB(255, 10, 10, 10),
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         'browsing score ${user.karma}',
//                         style: TextStyle(
//                           fontSize: 14,
//                           color:
//                               isDark
//                                   ? Colors.white
//                                   : const Color.fromARGB(255, 10, 10, 10),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 if (!isCurrentUser)
//                   // In the _ProfileHeader widget's trailing section
//                   if (!isCurrentUser)
//                     IconButton(
//                       onPressed:
//                           () =>
//                               Routemaster.of(context).push('/chat/${user.uid}'),
//                       icon: const Icon(Icons.chat),
//                     ),

//                 // Edit Profile Button (only visible for current user)
//                 if (isCurrentUser)
//                   ElevatedButton(
//                     onPressed: onEditPressed,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.blue,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 20,
//                         vertical: 10,
//                       ),
//                     ),
//                     child: const Text(
//                       'Edit Profile',
//                       style: TextStyle(color: Colors.white),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

// // class _UserInfoSection extends ConsumerWidget {
// //   final dynamic user;
// //   final ThemeData theme;

// //   const _UserInfoSection({
// //     required this.user,
// //     required this.theme,
// //   });

// //   @override
// //   Widget build(BuildContext context, WidgetRef ref) {
// //     final currentTheme = ref.watch(themeNotifierProvider);
// //     final isDark = currentTheme.brightness == Brightness.dark;

// //     return Padding(
// //       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           const SizedBox(height: 16),
// //           // const Divider(height: 1),
// //           // const SizedBox(height: 16),

// //           // Stats Section
// //           // Row(
// //           //   mainAxisAlignment: MainAxisAlignment.spaceAround,
// //           //   children: [
// //           //     // _StatItem(
// //           //     //   value: user.karma.toString(),
// //           //     //   label: 'Karma',
// //           //     //   theme: currentTheme,
// //           //     // ),
// //           //   ],
// //           // ),
// //           // const SizedBox(height: 16),
// //           Divider(
// //             height: 1,
// //             color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }

// class _StatItem extends StatelessWidget {
//   final String value;
//   final String label;
//   final ThemeData theme;

//   const _StatItem({
//     required this.value,
//     required this.label,
//     required this.theme,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final isDark = theme.brightness == Brightness.dark;
//     return Column(
//       children: [
//         Text(
//           value,
//           style: TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//             color:
//                 isDark ? Colors.white : const Color.fromARGB(255, 10, 10, 10),
//           ),
//         ),
//         const SizedBox(height: 4),
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 12,
//             color:
//                 isDark ? Colors.white : const Color.fromARGB(255, 10, 10, 10),
//           ),
//         ),
//       ],
//     );
//   }
// }




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
          ? FloatingActionButton(
              backgroundColor: Pallete.blueColor,
              onPressed: () => Routemaster.of(context).push('/add-post'),
              child: const Icon(Icons.add, color: Colors.white),
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
                    // SliverToBoxAdapter(
                    //   child: _UserInfoSection(user: user, theme: currentTheme),
                    // ),
                    SliverPadding(
                      padding: const EdgeInsets.only(top: 16),
                      sliver: ref
                          .watch(getUserPostsProvider(uid))
                          .when(
                            data:
                                (posts) => SliverList(
                                  delegate: SliverChildBuilderDelegate((
                                    context,
                                    index,
                                  ) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      child: PostCard(post: posts[index]),
                                    );
                                  }, childCount: posts.length),
                                ),
                            error:
                                (error, stackTrace) => SliverToBoxAdapter(
                                  child: ErrorText(error: error.toString()),
                                ),
                            loading:
                                () => const SliverToBoxAdapter(child: Loader()),
                          ),
                    ),
                  ],
          // ... rest of the existing UserProfileScreen build method ...
          // (Keep all existing sliver app bar and content code unchanged)
        ),
        error: (error, stackTrace) => ErrorText(error: error.toString()),
        loading: () => const Loader(),
      ),
    );
  }
}

// Keep all existing _ProfileHeader and other helper classes unchanged



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
        // Banner Image
        Container(
          height: 200,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(user.banner),
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
                // Add this in your user profile header section

                // Profile Picture
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: currentTheme.scaffoldBackgroundColor,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color:
                            isDark
                                ? const Color.fromARGB(255, 118, 114, 114)
                                : const Color.fromARGB(255, 78, 69, 69),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(user.profilePic),
                  ),
                ),

                const SizedBox(width: 16),

                // User Name and Actions
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${user.name}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color:
                              isDark
                                  ? Colors.white
                                  : const Color.fromARGB(255, 10, 10, 10),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'browsing score ${user.karma}',
                        style: TextStyle(
                          fontSize: 14,
                          color:
                              isDark
                                  ? Colors.white
                                  : const Color.fromARGB(255, 10, 10, 10),
                        ),
                      ),
                    ],
                  ),
                ),

                if (!isCurrentUser)
                  // In the _ProfileHeader widget's trailing section
                  if (!isCurrentUser)
                    IconButton(
                      onPressed:
                          () =>
                              Routemaster.of(context).push('/chat/${user.uid}'),
                      icon: const Icon(Icons.chat),
                    ),

                // Edit Profile Button (only visible for current user)
                if (isCurrentUser)
                  ElevatedButton(
                    onPressed: onEditPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
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
            color:
                isDark ? Colors.white : const Color.fromARGB(255, 10, 10, 10),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color:
                isDark ? Colors.white : const Color.fromARGB(255, 10, 10, 10),
          ),
        ),
      ],
    );
  }
}

