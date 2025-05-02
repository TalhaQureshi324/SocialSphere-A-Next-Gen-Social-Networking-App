

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_sphere/features/post/controller/post_controller.dart';
import 'package:social_sphere/models/comment_model.dart';

final getRepliesProvider = StreamProvider.family<List<Comment>, String>((ref, commentId) {
  return ref.watch(postControllerProvider.notifier).getReplies(commentId);
});