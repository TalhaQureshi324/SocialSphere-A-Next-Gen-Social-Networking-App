// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:social_sphere/core/common/error_text.dart';
// import 'package:social_sphere/core/common/loader.dart';
// import 'package:social_sphere/core/common/post_card.dart';
// import 'package:social_sphere/features/auth/controller/auth_controller.dart';
// import 'package:social_sphere/features/post/controller/post_controller.dart';
// import 'package:social_sphere/features/post/widgets/comment_card.dart';
// import 'package:social_sphere/models/post_model.dart';
// import 'package:social_sphere/theme/pallete.dart';

// class CommentsScreen extends ConsumerStatefulWidget {
//   final String postId;
//   const CommentsScreen({super.key, required this.postId});

//   @override
//   ConsumerState<ConsumerStatefulWidget> createState() => _CommentsScreenState();
// }

// class _CommentsScreenState extends ConsumerState<CommentsScreen> {
//   final commentController = TextEditingController();

//   @override
//   void dispose() {
//     super.dispose();
//     commentController.dispose();
//   }

//   void addComment(Post post) {
//     ref
//         .read(postControllerProvider.notifier)
//         .addComment(
//           context: context,
//           text: commentController.text.trim(),
//           post: post,
//         );
//     setState(() {
//       commentController.text = '';
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final user = ref.watch(userProvider)!;
//     final isGuest = !user.isAuthenticated;
//     final currentTheme = ref.watch(themeNotifierProvider);
//     final bool isDark = currentTheme.brightness == Brightness.dark;

//     return Scaffold(
//       appBar: AppBar(),
//       body: ref
//           .watch(getPostByIdProvider(widget.postId))
//           .when(
//             data: (data) {
//               return Column(
//                 children: [
//                   PostCard(post: data),
//                   if (!isGuest)
//                     Padding(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 12,
//                         vertical: 10,
//                       ),
//                       child: Material(
//                         elevation: 2,
//                         borderRadius: BorderRadius.circular(20),
//                         color: isDark ? const Color.fromARGB(255, 66, 66, 66) : Colors.white,
//                         child: Padding(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 12,
//                             vertical: 4,
//                           ),
//                           child: Row(

//                             children: [
//                               CircleAvatar(

//                                 backgroundImage: NetworkImage(user.profilePic),
//                                 radius: 16,
//                               ),
//                               const SizedBox(width: 10),
//                               Expanded(
//                                 child: TextField(
//                                   controller: commentController,
//                                   onSubmitted: (val) => addComment(data),
//                                   decoration: InputDecoration(
//                                     filled: true,
//                                     fillColor: isDark ? const Color.fromARGB(255, 66, 66, 66) : Colors.white,
//                                     hintText: 'Add a comment...',
//                                     border: InputBorder.none,
//                                   ),
//                                   style: Theme.of(context).textTheme.bodyMedium,
//                                 ),
//                               ),
//                               IconButton(
//                                 onPressed: () => addComment(data),
//                                 icon: const Icon(Icons.send_rounded),
//                                 color: Theme.of(context).colorScheme.primary,
//                                 splashRadius: 22,
//                                 tooltip: 'Send',
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ref
//                       .watch(getPostCommentsProvider(widget.postId))
//                       .when(
//                         data: (data) {
//                           return Expanded(
//                             child: ListView.builder(
//                               itemCount: data.length,
//                               itemBuilder: (BuildContext context, int index) {
//                                 final comment = data[index];
//                                 return CommentCard(comment: comment);
//                               },
//                             ),
//                           );
//                         },
//                         error: (error, stackTrace) {
//                           return ErrorText(error: error.toString());
//                         },
//                         loading: () => const Loader(),
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
import 'package:social_sphere/core/common/error_text.dart';
import 'package:social_sphere/core/common/loader.dart';
import 'package:social_sphere/core/common/post_card.dart';
import 'package:social_sphere/features/auth/controller/auth_controller.dart';
import 'package:social_sphere/features/post/controller/post_controller.dart';
import 'package:social_sphere/features/post/widgets/comment_card.dart';
import 'package:social_sphere/models/post_model.dart';
import 'package:social_sphere/theme/pallete.dart';

class CommentsScreen extends ConsumerStatefulWidget {
  final String postId;
  const CommentsScreen({super.key, required this.postId});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends ConsumerState<CommentsScreen> {
  final commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    super.dispose();
    commentController.dispose();
    _scrollController.dispose();
  }

  void addComment(Post post) {
    ref
        .read(postControllerProvider.notifier)
        .addComment(
          context: context,
          text: commentController.text.trim(),
          post: post,
        );
    setState(() {
      commentController.text = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider)!;
    final isGuest = !user.isAuthenticated;
    final currentTheme = ref.watch(themeNotifierProvider);
    final bool isDark = currentTheme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: ref
            .watch(getPostByIdProvider(widget.postId))
            .when(
              data: (post) {
                return Column(
                  children: [
                    // Post Card with constrained height
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.4,
                      ),
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        child: PostCard(post: post),
                      ),
                    ),

                    // Comment Input Section
                    if (!isGuest)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        child: Material(
                          elevation: 2,
                          borderRadius: BorderRadius.circular(20),
                          color:
                              isDark
                                  ? const Color.fromARGB(255, 66, 66, 66)
                                  : Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundImage: NetworkImage(
                                    user.profilePic,
                                  ),
                                  radius: 16,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: TextField(
                                    controller: commentController,
                                    onSubmitted: (val) => addComment(post),
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor:
                                          isDark
                                              ? const Color.fromARGB(
                                                255,
                                                66,
                                                66,
                                                66,
                                              )
                                              : Colors.white,
                                      hintText: 'Add a comment...',
                                      border: InputBorder.none,
                                    ),
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => addComment(post),
                                  icon: const Icon(Icons.send_rounded),
                                  color: Theme.of(context).colorScheme.primary,
                                  splashRadius: 22,
                                  tooltip: 'Send',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                    // Comments List
                    Expanded(
                      child: ref
                          .watch(getPostCommentsProvider(widget.postId))
                          .when(
                            data: (comments) {
                              return LayoutBuilder(
                                builder: (context, constraints) {
                                  return ListView.builder(
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    padding: const EdgeInsets.only(bottom: 80),
                                    itemCount: comments.length,
                                    itemBuilder: (
                                      BuildContext context,
                                      int index,
                                    ) {
                                      final comment = comments[index];
                                      return CommentCard(comment: comment);
                                    },
                                  );
                                },
                              );
                            },
                            error:
                                (error, stackTrace) =>
                                    ErrorText(error: error.toString()),
                            loading: () => const Loader(),
                          ),
                    ),
                  ],
                );
              },
              error: (error, stackTrace) => ErrorText(error: error.toString()),
              loading: () => const Loader(),
            ),
      ),
    );
  }
}
