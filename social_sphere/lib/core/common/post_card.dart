import 'package:any_link_preview/any_link_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_sphere/core/constants/constants.dart';
import 'package:social_sphere/features/auth/controller/auth_controller.dart';
import 'package:social_sphere/features/community/controller/community_controller.dart';
import 'package:social_sphere/features/post/controller/post_controller.dart';
import 'package:social_sphere/models/post_model.dart';
import 'package:social_sphere/responsive/responsive.dart';
import 'package:social_sphere/theme/pallete.dart';
import 'package:routemaster/routemaster.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

// class PostCard extends ConsumerWidget {
//   final Post post;
//   const PostCard({super.key, required this.post});

//   void deletePost(WidgetRef ref, BuildContext context) async {
//     ref.read(postControllerProvider.notifier).deletePost(post, context);
//   }

//   void upvotePost(WidgetRef ref) async {
//     ref.read(postControllerProvider.notifier).upvote(post);
//   }

//   void downvotePost(WidgetRef ref) async {
//     ref.read(postControllerProvider.notifier).downvote(post);
//   }

//   void awardPost(WidgetRef ref, String award, BuildContext context) async {
//     ref
//         .read(postControllerProvider.notifier)
//         .awardPost(post: post, award: award, context: context);
//   }

//   void navigateToUser(BuildContext context) {
//     Routemaster.of(context).push('/u/${post.uid}');
//   }

//   void navigateToCommunity(BuildContext context) {
//     Routemaster.of(context).push('/r/${post.communityName}');
//   }

//   void navigateToComments(BuildContext context) {
//     Routemaster.of(context).push('/post/${post.id}/comments');
//   }

//   // ... (keep all existing methods unchanged)

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final isTypeImage = post.type == 'image';
//     final isTypeText = post.type == 'text';
//     final isTypeLink = post.type == 'link';
//     final user = ref.watch(userProvider)!;
//     final isGuest = !user.isAuthenticated;
//     final currentTheme = ref.watch(themeNotifierProvider);

//     final bool isDark = currentTheme.brightness == Brightness.dark;

//     return Responsive(
//       child: Card(
//         elevation: 1,
//         margin: const EdgeInsets.symmetric(vertical: 8),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//           side: BorderSide(
//             color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
//             width: 1,
//           ),
//         ),
//         color: currentTheme.cardColor,
//         child: Column(
//           children: [
//             // Header section
//             Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color:
//                     isDark
//                         ? Colors.grey.shade900.withOpacity(0.6)
//                         : Colors.grey.shade50,
//                 borderRadius: const BorderRadius.vertical(
//                   top: Radius.circular(12),
//                 ),
//               ),
//               child: Row(
//                 children: [
//                   GestureDetector(
//                     onTap: () => navigateToCommunity(context),
//                     child: CircleAvatar(
//                       backgroundImage: NetworkImage(post.communityProfilePic),
//                       // backgroundImage: NetworkImage(community.avatar),
//                       radius: 18,
//                       backgroundColor: currentTheme.scaffoldBackgroundColor,
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         GestureDetector(
//                           onTap: () => navigateToCommunity(context),
//                           child: Text(
//                             '${post.communityName}',
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                               color: currentTheme.textTheme.bodyLarge?.color,
//                             ),
//                           ),
//                         ),
//                         GestureDetector(
//                           onTap: () => navigateToUser(context),
//                           child: Text(
//                             'Posted by ${post.username}',
//                             style: TextStyle(
//                               fontSize: 12,
//                               color:
//                                   isDark
//                                       ? Colors.grey.shade400
//                                       : Colors.grey.shade600,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   if (post.uid == user.uid)
//                     IconButton(
//                       onPressed: () => deletePost(ref, context),
//                       icon: Icon(
//                         Icons.delete,
//                         color: Pallete.redColor,
//                         size: 22,
//                       ),
//                       padding: EdgeInsets.zero,
//                       constraints: const BoxConstraints(),
//                     ),
//                 ],
//               ),
//             ),

//             // Awards ribbon
//             if (post.awards.isNotEmpty)
//               Container(
//                 padding: const EdgeInsets.symmetric(
//                   vertical: 4,
//                   horizontal: 12,
//                 ),
//                 color:
//                     isDark
//                         ? Colors.grey.shade900.withOpacity(0.6)
//                         : Colors.grey.shade200,
//                 child: SizedBox(
//                   height: 28,
//                   child: ListView.builder(
//                     scrollDirection: Axis.horizontal,
//                     itemCount: post.awards.length,
//                     itemBuilder: (BuildContext context, int index) {
//                       final award = post.awards[index];
//                       return Padding(
//                         padding: const EdgeInsets.only(right: 4),
//                         child: Image.asset(
//                           Constants.awards[award]!,
//                           height: 25,
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ),

//             // Post content
//             Container(
//               width: double.infinity, // ⬅️ Force full width
//               color:
//                   isDark
//                       ? Colors.grey.shade900.withOpacity(0.6)
//                       : Colors.grey.shade200,
//               child: Padding(
//                 padding: const EdgeInsets.all(12),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       post.title,
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.w600,
//                         color: currentTheme.textTheme.titleLarge?.color,
//                       ),
//                     ),
//                     const SizedBox(height: 8),

//                     if (isTypeImage)
//                       ClipRRect(
//                         borderRadius: BorderRadius.circular(8),
//                         child: Image.network(
//                           post.link!,
//                           fit: BoxFit.cover,
//                           width: double.infinity,
//                           height: MediaQuery.of(context).size.height * 0.35,
//                         ),
//                       ),

//                     if (isTypeLink)
//                       Padding(
//                         padding: const EdgeInsets.only(top: 8),
//                         child: ClipRRect(
//                           borderRadius: BorderRadius.circular(8),
//                           child: Container(
//                             decoration: BoxDecoration(
//                               border: Border.all(
//                                 color:
//                                     isDark
//                                         ? Colors.grey.shade800
//                                         : Colors.grey.shade200,
//                               ),
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             child: AnyLinkPreview(
//                               displayDirection:
//                                   UIDirection.uiDirectionHorizontal,
//                               link: post.link!,
//                               backgroundColor: currentTheme.colorScheme.surface,
//                               bodyMaxLines: 3,
//                               bodyTextOverflow: TextOverflow.ellipsis,
//                               titleStyle: TextStyle(
//                                 color: currentTheme.textTheme.bodyLarge?.color,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),

//                     if (isTypeText)
//                       Padding(
//                         padding: const EdgeInsets.only(top: 8),
//                         child: LayoutBuilder(
//                           builder: (context, constraints) {
//                             return ConstrainedBox(
//                               constraints: BoxConstraints(
//                                 maxWidth: constraints.maxWidth,
//                               ),
//                               child: Text(
//                                 post.description!,
//                                 textAlign: TextAlign.start,
//                                 softWrap: true,
//                                 overflow: TextOverflow.visible,
//                                 style: TextStyle(
//                                   color:
//                                       isDark
//                                           ? Colors.grey.shade300
//                                           : Colors.grey.shade700,
//                                   fontSize: 15,
//                                   height: 1.4,

//                                 ),
//                               ),
//                             );
//                           },
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//             ),

//             // Footer actions
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//               decoration: BoxDecoration(
//                 color:
//                     isDark
//                         ? Colors.grey.shade900.withOpacity(0.4)
//                         : Colors.grey.shade50,
//                 borderRadius: const BorderRadius.vertical(
//                   bottom: Radius.circular(12),
//                 ),
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   // Like/Dislike section (YouTube-style)
//                   Row(
//                     children: [
//                       // Like button
//                       Container(
//                         decoration: BoxDecoration(
//                           color:
//                               post.upvotes.contains(user.uid)
//                                   ? (isDark
//                                       ? Colors.blue.shade900
//                                       : Colors.blue.shade50)
//                                   : Colors.transparent,
//                           borderRadius: BorderRadius.circular(20),
//                           border: Border.all(
//                             color:
//                                 isDark
//                                     ? Colors.grey.shade700
//                                     : Colors.grey.shade300,
//                           ),
//                         ),
//                         child: Row(
//                           children: [
//                             IconButton(
//                               onPressed: isGuest ? null : () => upvotePost(ref),
//                               icon: Icon(
//                                 Icons.thumb_up_alt_outlined,
//                                 size: 20,
//                                 color:
//                                     post.upvotes.contains(user.uid)
//                                         ? Pallete.blueColor
//                                         : currentTheme.iconTheme.color,
//                               ),
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 8,
//                               ),
//                             ),
//                             Padding(
//                               padding: const EdgeInsets.only(right: 8),
//                               child: Text(
//                                 '${post.upvotes.length}',
//                                 style: TextStyle(
//                                   fontSize: 14,
//                                   color:
//                                       post.upvotes.contains(user.uid)
//                                           ? Pallete.blueColor
//                                           : currentTheme
//                                               .textTheme
//                                               .bodyLarge
//                                               ?.color,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),

//                       const SizedBox(width: 8),

//                       // Dislike button
//                       Container(
//                         decoration: BoxDecoration(
//                           color:
//                               post.downvotes.contains(user.uid)
//                                   ? (isDark
//                                       ? Colors.red.shade900
//                                       : Colors.red.shade50)
//                                   : Colors.transparent,
//                           borderRadius: BorderRadius.circular(20),
//                           border: Border.all(
//                             color:
//                                 isDark
//                                     ? Colors.grey.shade700
//                                     : Colors.grey.shade300,
//                           ),
//                         ),
//                         child: IconButton(
//                           onPressed: isGuest ? null : () => downvotePost(ref),
//                           icon: Icon(
//                             Icons.thumb_down_alt_outlined,
//                             size: 20,
//                             color:
//                                 post.downvotes.contains(user.uid)
//                                     ? Pallete.redColor
//                                     : currentTheme.iconTheme.color,
//                           ),
//                           padding: const EdgeInsets.symmetric(horizontal: 8),
//                         ),
//                       ),
//                     ],
//                   ),

//                   // Comments
//                   Row(
//                     children: [
//                       IconButton(
//                         onPressed: () => navigateToComments(context),
//                         icon: Icon(
//                           Icons.comment_outlined,
//                           size: 20,
//                           color: currentTheme.iconTheme.color,
//                         ),
//                       ),
//                       Text(
//                         '${post.commentCount}',
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: currentTheme.textTheme.bodyLarge?.color,
//                         ),
//                       ),
//                     ],
//                   ),

//                   // Mod actions
//                   ref
//                       .watch(getCommunityByNameProvider(post.communityName))
//                       .when(
//                         data: (data) {
//                           if (data.mods.contains(user.uid)) {
//                             return IconButton(
//                               onPressed: () => deletePost(ref, context),
//                               icon: Stack(
//                                 alignment: Alignment.center,
//                                 children: [
//                                   Icon(
//                                     Icons.delete,
//                                     size: 28,
//                                     color: Colors.grey[800],
//                                   ),
//                                   Positioned(
//                                     bottom: 0,
//                                     right: 0,
//                                     child: Icon(
//                                       Icons.shield,
//                                       size: 12,
//                                       color: const Color.fromARGB(
//                                         255,
//                                         220,
//                                         15,
//                                         0,
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               tooltip: 'Admin Panel',
//                             );

//                             // icon: Icon(
//                             //   Icons.security,
//                             //   size: 20,
//                             //   color: currentTheme.iconTheme.color,
//                             // ),
//                             //);
//                           }
//                           return const SizedBox();
//                         },
//                         error: (error, stackTrace) => const SizedBox(),
//                         loading: () => const SizedBox(),
//                       ),

//                   // Reaction button (replaces award)
//                   Container(
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(20),
//                       border: Border.all(
//                         color:
//                             isDark
//                                 ? Colors.grey.shade700
//                                 : Colors.grey.shade300,
//                       ),
//                     ),
//                     child: IconButton(
//                       onPressed:
//                           isGuest
//                               ? null
//                               : () {
//                                 // showDialog(
//                                 //   context: context,
//                                 //   builder:
//                                 //       (context) => Dialog(
//                                 //         backgroundColor: currentTheme.cardColor,
//                                 //         shape: RoundedRectangleBorder(
//                                 //           borderRadius: BorderRadius.circular(
//                                 //             16,
//                                 //           ),
//                                 //         ),
//                                 //         child: Padding(
//                                 //           padding: const EdgeInsets.all(20),
//                                 //           child: Column(
//                                 //             mainAxisSize: MainAxisSize.min,
//                                 //             children: [
//                                 //               Text(
//                                 //                 'Add Reaction',
//                                 //                 style: TextStyle(
//                                 //                   fontSize: 18,
//                                 //                   fontWeight: FontWeight.bold,
//                                 //                   color:
//                                 //                       currentTheme
//                                 //                           .textTheme
//                                 //                           .titleLarge
//                                 //                           ?.color,
//                                 //                 ),
//                                 //               ),
//                                 //               const SizedBox(height: 16),
//                                 //               GridView.builder(
//                                 //                 shrinkWrap: true,
//                                 //                 gridDelegate:
//                                 //                     const SliverGridDelegateWithFixedCrossAxisCount(
//                                 //                       crossAxisCount: 4,
//                                 //                       mainAxisSpacing: 8,
//                                 //                       crossAxisSpacing: 8,
//                                 //                     ),
//                                 //                 itemCount: user.awards.length,
//                                 //                 itemBuilder: (
//                                 //                   BuildContext context,
//                                 //                   int index,
//                                 //                 ) {
//                                 //                   final award =
//                                 //                       user.awards[index];
//                                 //                   return GestureDetector(
//                                 //                     onTap:
//                                 //                         () => awardPost(
//                                 //                           ref,
//                                 //                           award,
//                                 //                           context,
//                                 //                         ),
//                                 //                     child: Container(
//                                 //                       padding:
//                                 //                           const EdgeInsets.all(
//                                 //                             8,
//                                 //                           ),
//                                 //                       decoration: BoxDecoration(
//                                 //                         borderRadius:
//                                 //                             BorderRadius.circular(
//                                 //                               8,
//                                 //                             ),
//                                 //                         color:
//                                 //                             isDark
//                                 //                                 ? Colors
//                                 //                                     .grey
//                                 //                                     .shade800
//                                 //                                 : Colors
//                                 //                                     .grey
//                                 //                                     .shade100,
//                                 //                       ),
//                                 //                       child: Image.asset(
//                                 //                         Constants
//                                 //                             .awards[award]!,
//                                 //                       ),
//                                 //                     ),
//                                 //                   );
//                                 //                 },
//                                 //               ),
//                                 //             ],
//                                 //           ),
//                                 //         ),
//                                 //       ),
//                                 //);
//                               },
//                       icon: Icon(
//                         Icons.emoji_emotions_outlined,
//                         size: 20,
//                         color: currentTheme.iconTheme.color,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

class PostCard extends ConsumerWidget {
  final Post post;
  const PostCard({super.key, required this.post});

  void deletePost(WidgetRef ref, BuildContext context) async {
    ref.read(postControllerProvider.notifier).deletePost(post, context);
  }

  void upvotePost(WidgetRef ref) async {
    ref.read(postControllerProvider.notifier).upvote(post);
  }

  void downvotePost(WidgetRef ref) async {
    ref.read(postControllerProvider.notifier).downvote(post);
  }

  void awardPost(WidgetRef ref, String award, BuildContext context) async {
    ref
        .read(postControllerProvider.notifier)
        .awardPost(post: post, award: award, context: context);
  }

  void navigateToUser(BuildContext context) {
    Routemaster.of(context).push('/u/${post.uid}');
  }

  void navigateToCommunity(BuildContext context) {
    Routemaster.of(context).push('/r/${post.communityName}');
  }

  void navigateToComments(BuildContext context) {
    Routemaster.of(context).push('/post/${post.id}/comments');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider)!;
    final isGuest = !user.isAuthenticated;
    final currentTheme = ref.watch(themeNotifierProvider);
    final bool isDark = currentTheme.brightness == Brightness.dark;

    final communityAsyncValue = ref.watch(
      getCommunityByNameProvider(post.communityName),
    );

    return communityAsyncValue.when(
      data: (community) {
        return Responsive(
          child: Card(
            elevation: 1,
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                width: 1,
              ),
            ),
            color: currentTheme.cardColor,
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color:
                        isDark
                            ? Colors.grey.shade900.withOpacity(0.6)
                            : Colors.grey.shade50,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => navigateToCommunity(context),
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(community.avatar),
                          radius: 18,
                          backgroundColor: currentTheme.scaffoldBackgroundColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () => navigateToCommunity(context),
                              child: Text(
                                community.name,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      currentTheme.textTheme.bodyLarge?.color,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => navigateToUser(context),
                              child: Text(
                                'Posted by ${post.username}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color:
                                      isDark
                                          ? Colors.grey.shade400
                                          : Colors.grey.shade600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (post.uid == user.uid)
                        IconButton(
                          onPressed: () => deletePost(ref, context),
                          icon: Icon(
                            Icons.delete,
                            color: Pallete.redColor,
                            size: 22,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                    ],
                  ),
                ),

                // Awards
                if (post.awards.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 12,
                    ),
                    color:
                        isDark
                            ? Colors.grey.shade900.withOpacity(0.6)
                            : Colors.grey.shade200,
                    child: SizedBox(
                      height: 28,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: post.awards.length,
                        itemBuilder: (context, index) {
                          final award = post.awards[index];
                          return Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Image.asset(
                              Constants.awards[award]!,
                              height: 25,
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                // Post Content
                Container(
                  width: double.infinity,
                  color:
                      isDark
                          ? Colors.grey.shade900.withOpacity(0.6)
                          : Colors.grey.shade200,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: currentTheme.textTheme.titleLarge?.color,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (post.type == 'image')
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              post.link!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: MediaQuery.of(context).size.height * 0.35,
                            ),
                          ),
                        if (post.type == 'video')
                          _VideoPlayerWidget(videoUrl: post.link!),

                        if (post.type == 'link')
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color:
                                        isDark
                                            ? Colors.grey.shade800
                                            : Colors.grey.shade200,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: AnyLinkPreview(
                                  displayDirection:
                                      UIDirection.uiDirectionHorizontal,
                                  link: post.link!,
                                  backgroundColor:
                                      currentTheme.colorScheme.surface,
                                  bodyMaxLines: 3,
                                  bodyTextOverflow: TextOverflow.ellipsis,
                                  titleStyle: TextStyle(
                                    color:
                                        currentTheme.textTheme.bodyLarge?.color,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        if (post.type == 'text')
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              post.description!,
                              style: TextStyle(
                                color:
                                    isDark
                                        ? Colors.grey.shade300
                                        : Colors.grey.shade700,
                                fontSize: 15,
                                height: 1.4,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // Footer Actions
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isDark
                            ? Colors.grey.shade900.withOpacity(0.4)
                            : Colors.grey.shade50,
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Like/Dislike buttons
                      Row(
                        children: [
                          _buildVoteButton(
                            isDark: isDark,
                            voted: post.upvotes.contains(user.uid),
                            icon: Icons.thumb_up_alt_outlined,
                            onPressed: isGuest ? null : () => upvotePost(ref),
                            voteCount: post.upvotes.length,
                            votedColor: Pallete.blueColor,
                            context: context,
                          ),
                          const SizedBox(width: 8),
                          _buildVoteButton(
                            isDark: isDark,
                            voted: post.downvotes.contains(user.uid),
                            icon: Icons.thumb_down_alt_outlined,
                            onPressed: isGuest ? null : () => downvotePost(ref),
                            voteCount: 0,
                            votedColor: Pallete.redColor,
                            context: context,
                          ),
                        ],
                      ),

                      // Comments
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => navigateToComments(context),
                            icon: Icon(
                              Icons.comment_outlined,
                              size: 20,
                              color: currentTheme.iconTheme.color,
                            ),
                          ),
                          Text(
                            '${post.commentCount}',
                            style: TextStyle(
                              fontSize: 14,
                              color: currentTheme.textTheme.bodyLarge?.color,
                            ),
                          ),
                        ],
                      ),

                      // Admin Button (only for mods)
                      if (community.mods.contains(user.uid))
                        IconButton(
                          onPressed: () => deletePost(ref, context),
                          icon: Stack(
                            alignment: Alignment.center,
                            children: [
                              Icon(
                                Icons.delete,
                                size: 28,
                                color: Colors.grey[800],
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Icon(
                                  Icons.shield,
                                  size: 12,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                          tooltip: 'Admin Panel',
                        ),

                      // Reaction Button
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color:
                                isDark
                                    ? Colors.grey.shade700
                                    : Colors.grey.shade300,
                          ),
                        ),
                        child: IconButton(
                          onPressed:
                              isGuest
                                  ? null
                                  : () {
                                    showDialog(
                                      context: context,
                                      builder:
                                          (context) => Dialog(
                                            backgroundColor:
                                                currentTheme.cardColor,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(20),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    'Add Reaction',
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          currentTheme
                                                              .textTheme
                                                              .titleLarge
                                                              ?.color,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 16),
                                                  GridView.builder(
                                                    shrinkWrap: true,
                                                    gridDelegate:
                                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                                          crossAxisCount: 4,
                                                          mainAxisSpacing: 8,
                                                          crossAxisSpacing: 8,
                                                        ),
                                                    itemCount:
                                                        user.awards.length,
                                                    itemBuilder: (
                                                      BuildContext context,
                                                      int index,
                                                    ) {
                                                      final award =
                                                          user.awards[index];
                                                      return GestureDetector(
                                                        onTap:
                                                            () => awardPost(
                                                              ref,
                                                              award,
                                                              context,
                                                            ),
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets.all(
                                                                8,
                                                              ),
                                                          decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  8,
                                                                ),
                                                            color:
                                                                isDark
                                                                    ? Colors
                                                                        .grey
                                                                        .shade800
                                                                    : Colors
                                                                        .grey
                                                                        .shade100,
                                                          ),
                                                          child: Image.asset(
                                                            Constants
                                                                .awards[award]!,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                    );
                                  },
                          icon: Icon(
                            Icons.emoji_emotions_outlined,
                            size: 20,
                            color: currentTheme.iconTheme.color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
      error: (error, _) => const SizedBox(),
      loading: () => const SizedBox(),
    );
  }

  Widget _buildVoteButton({
    required bool isDark,
    required bool voted,
    required IconData icon,
    required VoidCallback? onPressed,
    required int voteCount,
    required Color votedColor,
    required BuildContext context,
  }) {
    final currentTheme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color:
            voted
                ? (isDark
                    ? votedColor.withOpacity(0.2)
                    : votedColor.withOpacity(0.1))
                : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onPressed,
            icon: Icon(
              icon,
              size: 20,
              color: voted ? votedColor : currentTheme.iconTheme.color,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
          if (voteCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(
                '$voteCount',
                style: TextStyle(
                  fontSize: 14,
                  color:
                      voted
                          ? votedColor
                          : currentTheme.textTheme.bodyLarge?.color,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  const _VideoPlayerWidget({required this.videoUrl});

  @override
  State<_VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<_VideoPlayerWidget> {
  late VideoPlayerController _videoController;
  late ChewieController _chewieController;

  @override
  void initState() {
    super.initState();
    _videoController = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {});
      });

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
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: AspectRatio(
        aspectRatio: _videoController.value.aspectRatio,
        child: Chewie(controller: _chewieController),
      ),
    );
  }

  @override
  void dispose() {
    _videoController.dispose();
    _chewieController.dispose();
    super.dispose();
  }
}
