// // features/post/screens/post_screen.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:social_sphere/core/common/error_text.dart';
// import 'package:social_sphere/core/common/loader.dart';
// import 'package:social_sphere/core/common/post_card.dart';
// import 'package:social_sphere/features/auth/controller/auth_controller.dart';
// import 'package:social_sphere/features/community/controller/community_controller.dart';
// import 'package:social_sphere/features/post/controller/post_controller.dart';
// import 'package:social_sphere/models/post_model.dart';

// class PostScreen extends ConsumerWidget {
//   final String postId;
//   const PostScreen({super.key, required this.postId});

//   void deletePost(WidgetRef ref, BuildContext context, Post post) {
//     ref.read(postControllerProvider.notifier).deletePost(post, context);
//     Navigator.pop(context);
//   }

//   void confirmDelete(WidgetRef ref, BuildContext context, Post post) {
//     showDialog(
//       context: context,
//       builder:
//           (context) => AlertDialog(
//             title: const Text('Delete Post'),
//             content: const Text('Are you sure you want to delete this post?'),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: const Text('Cancel'),
//               ),
//               TextButton(
//                 onPressed: () => deletePost(ref, context, post),
//                 child: const Text(
//                   'Delete',
//                   style: TextStyle(color: Colors.red),
//                 ),
//               ),
//             ],
//           ),
//     );
//   }

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final user = ref.watch(userProvider)!;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Post'),
//         actions: [
//           // Admin delete button (will only show if user has permissions)
//           ref
//               .watch(getPostByIdProvider(postId))
//               .when(
//                 data:
//                     (post) => ref
//                         .watch(getCommunityByNameProvider(post.communityName))
//                         .when(
//                           data: (community) {
//                             if (community.mods.contains(user.uid)) {
//                               return IconButton(
//                                 icon: const Icon(Icons.delete),
//                                 onPressed:
//                                     () => confirmDelete(ref, context, post),
//                               );
//                             }
//                             return const SizedBox();
//                           },
//                           error: (e, s) => const SizedBox(),
//                           loading: () => const SizedBox(),
//                         ),
//                 error: (e, s) => const SizedBox(),
//                 loading: () => const SizedBox(),
//               ),
//         ],
//       ),
//       body: ref
//           .watch(getPostByIdProvider(postId))
//           .when(
//             data: (post) {
//               return SingleChildScrollView(
//                 child: Column(
//                   children: [
//                     PostCard(post: post),
//                     const SizedBox(height: 16),
//                     // Add comments section here if needed
//                     // You can use your existing CommentsScreen components
//                   ],
//                 ),
//               );
//             },
//             error: (error, stackTrace) => ErrorText(error: error.toString()),
//             loading: () => const Loader(),
//           ),
//     );
//   }
// }
