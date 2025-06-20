import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_sphere/core/enums/enums.dart';
import 'package:social_sphere/core/providers/storage_repository_provider.dart';
import 'package:social_sphere/core/utils.dart';
import 'package:social_sphere/features/auth/controller/auth_controller.dart';
import 'package:social_sphere/features/post/repository/post_repository.dart';
import 'package:social_sphere/features/user_profile/controller/user_profile_controller.dart';
import 'package:social_sphere/models/comment_model.dart';
import 'package:social_sphere/models/community_model.dart';
import 'package:social_sphere/models/post_model.dart';
import 'package:routemaster/routemaster.dart';
import 'package:uuid/uuid.dart';
import 'package:social_sphere/models/notification_model.dart';
import 'package:social_sphere/features/notification/repository/notification_repository.dart';

final postControllerProvider = StateNotifierProvider<PostController, bool>((
  ref,
) {
  final postRepository = ref.watch(postRepositoryProvider);
  final storageRepository = ref.watch(storageRepositoryProvider);
  return PostController(
    postRepository: postRepository,
    storageRepository: storageRepository,
    ref: ref,
  );
});

final userPostsProvider = StreamProvider.family((
  ref,
  List<Community> communities,
) {
  final postController = ref.watch(postControllerProvider.notifier);
  return postController.fetchUserPosts(communities);
});

final guestPostsProvider = StreamProvider((ref) {
  final postController = ref.watch(postControllerProvider.notifier);
  return postController.fetchGuestPosts();
});

final getPostByIdProvider = StreamProvider.family((ref, String postId) {
  final postController = ref.watch(postControllerProvider.notifier);
  return postController.getPostById(postId);
});

final getPostCommentsProvider = StreamProvider.family((ref, String postId) {
  final postController = ref.watch(postControllerProvider.notifier);
  return postController.fetchPostComments(postId);
});

class PostController extends StateNotifier<bool> {
  final PostRepository _postRepository;
  final Ref _ref;
  final StorageRepository _storageRepository;
  PostController({
    required PostRepository postRepository,
    required Ref ref,
    required StorageRepository storageRepository,
  }) : _postRepository = postRepository,
       _ref = ref,
       _storageRepository = storageRepository,
       super(false);

  // Add this new method to create notifications
  Future<void> _createNotificationsForPost(
    Post post,
    Community community,
  ) async {
    final notificationRepository = _ref.read(notificationRepositoryProvider);
    final user = _ref.read(userProvider)!;

    for (final memberId in community.members) {
      if (memberId == user.uid) continue; // Skip post author

      final notification = NotificationModel(
        
        type: NotificationType.post,
        id: const Uuid().v1(),
        userId: memberId,
        communityId: community.id,
        communityName: community.name,
        communityAvatar: community.avatar,
        postId: post.id,
        postTitle: post.title,
        authorName: post.username,
        createdAt: DateTime.now(),
        isRead: false,
        isAnonymous: post.isAnonymous,
      );

      final res = await notificationRepository.createNotification(notification);
      res.fold(
        (l) => debugPrint('Error creating notification: ${l.message}'),
        (r) => null,
      );
    }
  }

  // Updated shareTextPost with notifications
  void shareTextPost({
    required BuildContext context,
    required String title,
    required Community selectedCommunity,
    required String description,
    required bool isAnonymous,
  }) async {
    state = true;
    String postId = const Uuid().v1();
    final user = _ref.read(userProvider)!;

    final Post post = Post(
      isAnonymous: isAnonymous,
      id: postId,
      title: title,
      communityName: selectedCommunity.name,
      communityProfilePic: selectedCommunity.avatar,
      upvotes: [],
      downvotes: [],
      commentCount: 0,
      username: user.username,
      uid: user.uid,
      type: 'text',
      createdAt: DateTime.now(),
      awards: [],
      description: description,
    );

    final res = await _postRepository.addPost(post);
    _ref
        .read(userProfileControllerProvider.notifier)
        .updateUserKarma(UserKarma.textPost);
    state = false;
    res.fold((l) => showSnackBar(context, l.message), (r) async {
      await _createNotificationsForPost(post, selectedCommunity);
      showSnackBar2('Posted successfully!');
      Routemaster.of(context).pop();
    });
  }

  // Updated shareLinkPost with notifications
  void shareLinkPost({
    required BuildContext context,
    required String title,
    required Community selectedCommunity,
    required String link,
    required bool isAnonymous,
  }) async {
    state = true;
    String postId = const Uuid().v1();
    final user = _ref.read(userProvider)!;

    final Post post = Post(
      isAnonymous: isAnonymous,
      id: postId,
      title: title,
      communityName: selectedCommunity.name,
      communityProfilePic: selectedCommunity.avatar,
      upvotes: [],
      downvotes: [],
      commentCount: 0,
      username: user.username,
      uid: user.uid,
      type: 'link',
      createdAt: DateTime.now(),
      awards: [],
      link: link,
    );

    final res = await _postRepository.addPost(post);
    _ref
        .read(userProfileControllerProvider.notifier)
        .updateUserKarma(UserKarma.linkPost);
    state = false;
    res.fold((l) => showSnackBar(context, l.message), (r) async {
      await _createNotificationsForPost(post, selectedCommunity);
      showSnackBar(context, 'Posted successfully!');
      Routemaster.of(context).pop();
    });
  }

  // Updated shareImagePost with notifications
  // Add this new method to PostController
void shareImagePost({
  required BuildContext context,
  required String title,
  required Community selectedCommunity,
  required List<File>? files,
  required List<Uint8List>? webFiles,
  required bool isAnonymous,
}) async {
  state = true;
  String postId = const Uuid().v1();
  final user = _ref.read(userProvider)!;
  
  // Upload all images
  final List<String> imageUrls = [];
  
  try {
    if (files != null && files.isNotEmpty) {
      for (var file in files) {
        final imageRes = await _storageRepository.storeFile(
          path: 'posts/${selectedCommunity.name}',
          id: '${postId}_${files.indexOf(file)}',
          file: file, webFile: null,
        );
        imageRes.fold(
          (l) => throw l,
          (r) => imageUrls.add(r),
        );
      }
    } else if (webFiles != null && webFiles.isNotEmpty) {
      for (var webFile in webFiles) {
        final imageRes = await _storageRepository.storeFile(
          path: 'posts/${selectedCommunity.name}',
          id: '${postId}_${webFiles.indexOf(webFile)}',
          webFile: webFile, file: null,
        );
        imageRes.fold(
          (l) => throw l,
          (r) => imageUrls.add(r),
        );
      }
    }
    
    final Post post = Post(
      isAnonymous: isAnonymous,
      id: postId,
      title: title,
      communityName: selectedCommunity.name,
      communityProfilePic: selectedCommunity.avatar,
      upvotes: [],
      downvotes: [],
      commentCount: 0,
      username: user.username,
      uid: user.uid,
      type: 'image',
      createdAt: DateTime.now(),
      awards: [],
      mediaUrls: imageUrls,
    );

    final res = await _postRepository.addPost(post);
    _ref
        .read(userProfileControllerProvider.notifier)
        .updateUserKarma(UserKarma.imagePost);
    state = false;
    res.fold((l) => showSnackBar(context, l.message), (r) async {
      await _createNotificationsForPost(post, selectedCommunity);
      showSnackBar(context, 'Posted successfully!');
      Routemaster.of(context).pop();
    });
  } catch (e) {
    state = false;
    showSnackBar(context, e.toString());
  }
}



  // Add new method
  void shareVideoPost({
    required BuildContext context,
    required String title,
    required Community selectedCommunity,
    required File? file,
    required Uint8List? webFile,
    required bool isAnonymous,
  }) async {
    state = true;
    String postId = const Uuid().v1();
    final user = _ref.read(userProvider)!;

    final videoRes = await _storageRepository.storeFile(
      path: 'posts/${selectedCommunity.name}/videos',
      id: postId,
      file: file,
      webFile: webFile,
    );

    videoRes.fold((l) => showSnackBar(context, l.message), (r) async {
      final Post post = Post(
        isAnonymous: isAnonymous,
        id: postId,
        title: title,
        communityName: selectedCommunity.name,
        communityProfilePic: selectedCommunity.avatar,
        upvotes: [],
        downvotes: [],
        commentCount: 0,
        username: user.username,
        uid: user.uid,
        type: 'video',
        createdAt: DateTime.now(),
        awards: [],
        link: r, // Store video URL in existing link field
      );

      final res = await _postRepository.addPost(post);
      _ref
          .read(userProfileControllerProvider.notifier)
          .updateUserKarma(UserKarma.videoPost);
      state = false;
      res.fold((l) => showSnackBar(context, l.message), (r) async {
        await _createNotificationsForPost(post, selectedCommunity);
        showSnackBar(context, 'Video posted successfully!');
        Routemaster.of(context).pop();
      });
    });
  }

  Stream<List<Post>> fetchUserPosts(List<Community> communities) {
    if (communities.isNotEmpty) {
      return _postRepository.fetchUserPosts(communities);
    }
    return Stream.value([]);
  }

  Stream<List<Post>> fetchGuestPosts() {
    return _postRepository.fetchGuestPosts();
  }

  void deletePost(Post post, BuildContext context) async {
    final res = await _postRepository.deletePost(post);
    _ref
        .read(userProfileControllerProvider.notifier)
        .updateUserKarma(UserKarma.deletePost);
    res.fold(
      (l) => null,
      (r) => showSnackBar(context, 'Post Deleted successfully!'),
    );
  }

  void upvote(Post post) async {
    final uid = _ref.read(userProvider)!.uid;
    _postRepository.upvote(post, uid);
  }

  void downvote(Post post) async {
    final uid = _ref.read(userProvider)!.uid;
    _postRepository.downvote(post, uid);
  }

  Stream<Post> getPostById(String postId) {
    return _postRepository.getPostById(postId);
  }

  // void addComment({
  //   required BuildContext context,
  //   required String text,
  //   required Post post,
  //   String? parentCommentId, // Add this parameter
  // }) async {
  //   final user = _ref.read(userProvider)!;
  //   String commentId = const Uuid().v1();
  //   Comment comment = Comment(
  //     id: commentId,
  //     text: text,
  //     createdAt: DateTime.now(),
  //     postId: post.id,
  //     username: user.username,
  //     profilePic: user.profilePic,
  //     parentCommentId: parentCommentId, // Set parent ID
  //   );
  //   if (text.isEmpty) {
  //     showSnackBar(context, 'Comment cannot be empty');
  //     return;
  //   }
  //   final res = await _postRepository.addComment(comment);
  //   _ref
  //       .read(userProfileControllerProvider.notifier)
  //       .updateUserKarma(UserKarma.comment);
  //   res.fold((l) => showSnackBar(context, l.message), (r) => null);
  // }

  void addComment({
    required BuildContext context,
    required String text,
    required Post post,
    String? parentCommentId, // Add this parameter
  }) async {
    final user = _ref.read(userProvider)!;
    String commentId = const Uuid().v1();

    Comment comment = Comment(
      id: commentId,
      text: text,
      createdAt: DateTime.now(),
      postId: post.id,
      username: user.username,
      profilePic: user.profilePic,
      parentCommentId: parentCommentId, // Set parent ID
    );

    if (text.isEmpty) {
      showSnackBar(context, 'Comment cannot be empty');
      return;
    }

    final res = await _postRepository.addComment(comment);
    res.fold((l) => showSnackBar(context, l.message), (r) {
      _ref
          .read(userProfileControllerProvider.notifier)
          .updateUserKarma(UserKarma.comment);

      // Only show success for top-level comments
      if (parentCommentId == null) {
        showSnackBar(context, 'Comment added');
      }
    });
  }

  void awardPost({
    required Post post,
    required String award,
    required BuildContext context,
  }) async {
    final user = _ref.read(userProvider)!;

    final res = await _postRepository.awardPost(post, award, user.uid);

    res.fold((l) => showSnackBar(context, l.message), (r) {
      _ref
          .read(userProfileControllerProvider.notifier)
          .updateUserKarma(UserKarma.awardPost);
      _ref.read(userProvider.notifier).update((state) {
        state?.awards.remove(award);
        return state;
      });
      Routemaster.of(context).pop();
    });
  }

  Stream<List<Comment>> fetchPostComments(String postId) {
    return _postRepository.getCommentsOfPost(postId);
  }

  // New method for replies
  void addReply({
    required BuildContext context,
    required String text,
    required Comment parentComment,
  }) async {
    final user = _ref.read(userProvider)!;
    String commentId = const Uuid().v1();

    // Create reply comment
    Comment reply = Comment(
      id: commentId,
      text: text,
      createdAt: DateTime.now(),
      postId: parentComment.postId,
      username: user.username,
      profilePic: user.profilePic,
      parentCommentId: parentComment.id,
    );

    // Add reply to Firestore
    final commentRes = await _postRepository.addComment(reply);

    commentRes.fold((l) => showSnackBar(context, l.message), (r) async {
      // Update parent comment's replies list
      final updateRes = await _postRepository.addReplyToParent(
        parentComment.id,
        commentId,
      );

      updateRes.fold(
        (l) => showSnackBar(context, 'Failed to add reply'),
        (r) => showSnackBar(context, 'Reply added'),
      );
    });
  }

  // New method to fetch replies
  Stream<List<Comment>> getReplies(String commentId) {
    return _postRepository.getReplies(commentId);
  }
}
