// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:routemaster/routemaster.dart';
// import 'package:social_sphere/core/common/error_text.dart';
// import 'package:social_sphere/core/common/loader.dart';
// import 'package:social_sphere/core/common/post_card.dart';
// import 'package:social_sphere/features/auth/controller/auth_controller.dart';
// import 'package:social_sphere/features/community/controller/community_controller.dart';
// import 'package:social_sphere/models/community_model.dart';
// import 'package:social_sphere/theme/pallete.dart';

// class CommunityScreen extends ConsumerWidget {
//   final String name;
//   const CommunityScreen({super.key, required this.name});

//   void navigateToModTools(BuildContext context) {
//     Routemaster.of(context).push('/mod-tools/$name');
//   }

//   void joinCommunity(WidgetRef ref, Community community, BuildContext context) {
//     ref
//         .read(communityControllerProvider.notifier)
//         .joinCommunity(community, context);
//   }

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final user = ref.watch(userProvider)!;
//     final isGuest = !user.isAuthenticated;

//     return Scaffold(
//       //backgroundColor: Pallete.backgroundColor,
//       body: ref
//           .watch(getCommunityByNameProvider(name))
//           .when(
//             data: (community) {
//               return CustomScrollView(
//                 slivers: [
//                   SliverAppBar(
//                     expandedHeight: 180,
//                     pinned: true,
//                     //backgroundColor: Pallete.backgroundColor,
//                     flexibleSpace: FlexibleSpaceBar(
//                       background: Stack(
//                         fit: StackFit.expand,
//                         children: [
//                           Image.network(community.banner, fit: BoxFit.cover),
//                           Container(color: Colors.black.withOpacity(0.5)),
//                           Align(
//                             alignment: Alignment.bottomLeft,
//                             child: Padding(
//                               padding: const EdgeInsets.all(16),
//                               child: Row(
//                                 children: [
//                                   CircleAvatar(
//                                     backgroundImage: NetworkImage(
//                                       community.avatar,
//                                     ),
//                                     radius: 30,
//                                   ),
//                                   const SizedBox(width: 12),
//                                   Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     mainAxisSize: MainAxisSize.min,
//                                     children: [
//                                       Text(
//                                         '${community.name}',
//                                         style: const TextStyle(
//                                           fontSize: 22,
//                                           color: Colors.white,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                                       Text(
//                                         '${community.members.length} members',
//                                         style: const TextStyle(
//                                           color: Colors.white70,
//                                           fontSize: 14,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   SliverToBoxAdapter(
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 16.0,
//                         vertical: 12,
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           if (!isGuest)
//                             community.mods.contains(user.uid)
//                                 ? ElevatedButton.icon(
//                                   onPressed: () => navigateToModTools(context),
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: Pallete.blueColor,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(30),
//                                     ),
//                                     padding: const EdgeInsets.symmetric(
//                                       horizontal: 20,
//                                       vertical: 10,
//                                     ),
//                                   ),
//                                   icon: const Icon(Icons.shield),
//                                   label: const Text('Admin Settings'),
//                                 )
//                                 : ElevatedButton.icon(
//                                   onPressed:
//                                       () => joinCommunity(
//                                         ref,
//                                         community,
//                                         context,
//                                       ),
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor:
//                                         community.members.contains(user.uid)
//                                             ? Pallete.greyColor
//                                             : Pallete.blueColor,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(30),
//                                     ),
//                                     padding: const EdgeInsets.symmetric(
//                                       horizontal: 20,
//                                       vertical: 10,
//                                     ),
//                                   ),
//                                   icon: Icon(
//                                     community.members.contains(user.uid)
//                                         ? Icons.check
//                                         : Icons.add,
//                                   ),
//                                   label: Text(
//                                     community.members.contains(user.uid)
//                                         ? 'Joined'
//                                         : 'Join',
//                                   ),
//                                 ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   ref
//                       .watch(getCommunityPostsProvider(name))
//                       .when(
//                         data: (posts) {
//                           if (posts.isEmpty) {
//                             return SliverToBoxAdapter(
//                               child: Center(
//                                 child: Padding(
//                                   padding: const EdgeInsets.all(30.0),
//                                   child: Text(
//                                     "No posts yet. Be the first to post!",
//                                     style:
//                                         Theme.of(context).textTheme.bodyLarge,
//                                   ),
//                                 ),
//                               ),
//                             );
//                           }
//                           return SliverList(
//                             delegate: SliverChildBuilderDelegate(
//                               (context, index) => PostCard(post: posts[index]),
//                               childCount: posts.length,
//                             ),
//                           );
//                         },
//                         error:
//                             (error, stackTrace) => SliverToBoxAdapter(
//                               child: ErrorText(error: error.toString()),
//                             ),
//                         loading:
//                             () => const SliverToBoxAdapter(child: Loader()),
//                       ),
//                 ],
//               );
//             },
//             error: (error, stackTrace) => ErrorText(error: error.toString()),
//             loading: () => const Loader(),
//           ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:social_sphere/core/common/error_text.dart';
import 'package:social_sphere/core/common/loader.dart';
import 'package:social_sphere/core/common/post_card.dart';
import 'package:social_sphere/features/auth/controller/auth_controller.dart';
import 'package:social_sphere/features/community/controller/community_controller.dart';
import 'package:social_sphere/models/community_model.dart';
import 'package:social_sphere/theme/pallete.dart';

class CommunityScreen extends ConsumerWidget {
  final String name;
  const CommunityScreen({super.key, required this.name});

  void navigateToModTools(BuildContext context) {
    Routemaster.of(context).push('/mod-tools/$name');
  }

  void joinCommunity(WidgetRef ref, Community community, BuildContext context) {
    ref
        .read(communityControllerProvider.notifier)
        .joinCommunity(community, context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider)!;
    final isGuest = !user.isAuthenticated;

    return Scaffold(
      floatingActionButton: ref
          .watch(getCommunityByNameProvider(name))
          .when(
            data: (community) {
              if (!isGuest && community.members.contains(user.uid)) {
                return FloatingActionButton(
                  backgroundColor: Pallete.blueColor,
                  onPressed: () => Routemaster.of(context).push('/add-post'),
                  child: const Icon(Icons.add, color: Colors.white),
                );
              }
              return null;
            },
            error: (error, stackTrace) => null,
            loading: () => null,
          ),
      body: ref
          .watch(getCommunityByNameProvider(name))
          .when(
            data: (community) {
              return CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: 180,
                    pinned: true,
                    //backgroundColor: Pallete.backgroundColor,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(community.banner, fit: BoxFit.cover),
                          Container(color: Colors.black.withOpacity(0.5)),
                          Align(
                            alignment: Alignment.bottomLeft,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundImage: NetworkImage(
                                      community.avatar,
                                    ),
                                    radius: 30,
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '${community.name}',
                                        style: const TextStyle(
                                          fontSize: 22,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '${community.members.length} members',
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 12,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (!isGuest)
                            community.mods.contains(user.uid)
                                ? ElevatedButton.icon(
                                  onPressed: () => navigateToModTools(context),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Pallete.blueColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 10,
                                    ),
                                  ),
                                  icon: const Icon(Icons.shield),
                                  label: const Text('Admin Settings'),
                                )
                                : ElevatedButton.icon(
                                  onPressed:
                                      () => joinCommunity(
                                        ref,
                                        community,
                                        context,
                                      ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        community.members.contains(user.uid)
                                            ? Pallete.greyColor
                                            : Pallete.blueColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 10,
                                    ),
                                  ),
                                  icon: Icon(
                                    community.members.contains(user.uid)
                                        ? Icons.check
                                        : Icons.add,
                                  ),
                                  label: Text(
                                    community.members.contains(user.uid)
                                        ? 'Joined'
                                        : 'Join',
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ),
                  ref
                      .watch(getCommunityPostsProvider(name))
                      .when(
                        data: (posts) {
                          if (posts.isEmpty) {
                            return SliverToBoxAdapter(
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(30.0),
                                  child: Text(
                                    "No posts yet. Be the first to post!",
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
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
                        error:
                            (error, stackTrace) => SliverToBoxAdapter(
                              child: ErrorText(error: error.toString()),
                            ),
                        loading:
                            () => const SliverToBoxAdapter(child: Loader()),
                      ),
                ],
                // ... rest of the existing CommunityScreen build method ...
                // (Keep all existing sliver app bar and content code unchanged)
              );
            },
            error: (error, stackTrace) => ErrorText(error: error.toString()),
            loading: () => const Loader(),
          ),
    );
  }
}
