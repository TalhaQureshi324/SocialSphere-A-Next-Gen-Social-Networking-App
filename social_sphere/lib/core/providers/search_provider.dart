// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:tuple/tuple.dart';
// import 'package:social_sphere/features/community/controller/community_controller.dart';
// import 'package:social_sphere/features/user_profile/controller/user_profile_controller.dart';
// import 'package:social_sphere/models/community_model.dart';
// import 'package:social_sphere/models/user_model.dart';

// final searchCommunityAndUsersProvider = FutureProvider.family
//   .autoDispose<Tuple2<List<Community>, List<UserModel>>, String>((ref, query) async {
//   if (query.isEmpty) {
//     return Tuple2([], []);
//   }
  
//   final communities = await ref.read(communityControllerProvider.notifier).searchCommunity(query);
//   final users = await ref.read(userProfileControllerProvider.notifier).searchUser(query);
  
//   return Tuple2(communities, users);
// });