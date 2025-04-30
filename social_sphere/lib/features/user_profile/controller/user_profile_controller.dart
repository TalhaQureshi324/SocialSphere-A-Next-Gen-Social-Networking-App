import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_sphere/core/enums/enums.dart';
import 'package:social_sphere/core/providers/storage_repository_provider.dart';
import 'package:social_sphere/core/utils.dart';
import 'package:social_sphere/features/auth/controller/auth_controller.dart';
import 'package:social_sphere/features/user_profile/repository/user_profile_repository.dart';
import 'package:social_sphere/models/post_model.dart';
import 'package:social_sphere/models/user_model.dart';
import 'package:routemaster/routemaster.dart';

final userProfileControllerProvider =
    StateNotifierProvider<UserProfileController, bool>((ref) {
      final userProfileRepository = ref.watch(userProfileRepositoryProvider);
      final storageRepository = ref.watch(storageRepositoryProvider);
      return UserProfileController(
        userProfileRepository: userProfileRepository,
        storageRepository: storageRepository,
        ref: ref,
      );
    });

final getUserPostsProvider = StreamProvider.family((ref, String uid) {
  return ref.read(userProfileControllerProvider.notifier).getUserPosts(uid);
});

final searchUserProvider = StreamProvider.family((ref, String query) {
  return ref.watch(userProfileControllerProvider.notifier).searchUser(query);
});

class UserProfileController extends StateNotifier<bool> {
  final UserProfileRepository _userProfileRepository;
  final Ref _ref;
  final StorageRepository _storageRepository;
  UserProfileController({
    required UserProfileRepository userProfileRepository,
    required Ref ref,
    required StorageRepository storageRepository,
  }) : _userProfileRepository = userProfileRepository,
       _ref = ref,
       _storageRepository = storageRepository,
       super(false);

  //   void editCommunity({
  //     required File? profileFile,
  //     required File? bannerFile,
  //     required Uint8List? profileWebFile,
  //     required Uint8List? bannerWebFile,
  //     required BuildContext context,
  //     required String name,
  //     required String username,
  //   }) async {
  //     state = true;
  //     UserModel user = _ref.read(userProvider)!;

  //     if (profileFile != null || profileWebFile != null) {
  //       final res = await _storageRepository.storeFile(
  //         path: 'users/profile',
  //         id: user.uid,
  //         file: profileFile,
  //         webFile: profileWebFile,
  //       );
  //       res.fold(
  //         (l) => showSnackBar(context, l.message),
  //         (r) => user = user.copyWith(profilePic: r),
  //       );
  //     }

  //     if (bannerFile != null || bannerWebFile != null) {
  //       final res = await _storageRepository.storeFile(
  //         path: 'users/banner',
  //         id: user.uid,
  //         file: bannerFile,
  //         webFile: bannerWebFile,
  //       );
  //       res.fold(
  //         (l) => showSnackBar(context, l.message),
  //         (r) => user = user.copyWith(banner: r),
  //       );
  //     }
  //     if (username != user.username) {
  //       if(username.contains(' '))
  //       {
  //         showSnackBar(context, 'Username cannot contain spaces');
  //         state = false;
  //         return;
  //       }
  //   final existingUsers = await _userProfileRepository.getUserByUsername(username);
  //   if (existingUsers.isNotEmpty) {
  //     showSnackBar(context, 'Username is already taken');
  //     state = false;
  //     return;
  //   }
  // }

  //     user = user.copyWith(name: name, username: username);
  //     final res = await _userProfileRepository.editProfile(user);
  //     state = false;
  //     res.fold(
  //       (l) => showSnackBar(context, l.message),
  //       (r) {
  //         _ref.read(userProvider.notifier).update((state) => user);
  //         Routemaster.of(context).pop();
  //       },
  //     );
  //   }

  // void editCommunity({
  //   required File? profileFile,
  //   required File? bannerFile,
  //   required Uint8List? profileWebFile,
  //   required Uint8List? bannerWebFile,
  //   required BuildContext context,
  //   required String name,
  //   required String username,
  // }) async {
  //   state = true;
  //   UserModel user = _ref.read(userProvider)!;

  //   if (profileFile != null || profileWebFile != null) {
  //     final res = await _storageRepository.storeFile(
  //       path: 'users/profile',
  //       id: user.uid,
  //       file: profileFile,
  //       webFile: profileWebFile,
  //     );
  //     res.fold(
  //       (l) => showSnackBar(context, l.message),
  //       (r) => user = user.copyWith(profilePic: r),
  //     );
  //   }

  //   if (bannerFile != null || bannerWebFile != null) {
  //     final res = await _storageRepository.storeFile(
  //       path: 'users/banner',
  //       id: user.uid,
  //       file: bannerFile,
  //       webFile: bannerWebFile,
  //     );
  //     res.fold(
  //       (l) => showSnackBar(context, l.message),
  //       (r) => user = user.copyWith(banner: r),
  //     );
  //   }

  //   if (username != user.username) {
  //     if (username.contains(' ')) {
  //       showSnackBar(context, 'Username cannot contain spaces');
  //       state = false;
  //       return;
  //     }

  //     final existingUsers = await _userProfileRepository.getUserByUsername(username);
  //     if (existingUsers.isNotEmpty) {
  //       showSnackBar(context, 'Username is already taken');
  //       state = false;
  //       return;
  //     }
  //   }

  //   final oldUsername = user.username;
  //   user = user.copyWith(name: name, username: username);
  //   final res = await _userProfileRepository.editProfile(user);

  //   state = false;
  //   res.fold(
  //     (l) => showSnackBar(context, l.message),
  //     (r) async {
  //       // ✅ Update all posts with the new username
  //       if (username != oldUsername) {
  //         await _userProfileRepository.updateUsernameInPosts(
  //           uid: user.uid,
  //           newUsername: username,
  //         );
  //       }

  //       _ref.read(userProvider.notifier).update((state) => user);
  //       Routemaster.of(context).pop();
  //     },
  //   );
  // }

  void editCommunity({
    required File? profileFile,
    required File? bannerFile,
    required Uint8List? profileWebFile,
    required Uint8List? bannerWebFile,
    required BuildContext context,
    required String name,
    required String username,
  }) async {
    state = true;
    UserModel user = _ref.read(userProvider)!;

    if (profileFile != null || profileWebFile != null) {
      final res = await _storageRepository.storeFile(
        path: 'users/profile',
        id: user.uid,
        file: profileFile,
        webFile: profileWebFile,
      );
      res.fold(
        (l) {
          if (context.mounted) showSnackBar(context, l.message);
        },
        (r) {
          user = user.copyWith(profilePic: r);
        },
      );
    }

    if (bannerFile != null || bannerWebFile != null) {
      final res = await _storageRepository.storeFile(
        path: 'users/banner',
        id: user.uid,
        file: bannerFile,
        webFile: bannerWebFile,
      );
      res.fold(
        (l) {
          if (context.mounted) showSnackBar(context, l.message);
        },
        (r) {
          user = user.copyWith(banner: r);
        },
      );
    }

    // Username validation
    if (username != user.username) {
      if (username.contains(' ') || username.isEmpty) {
        if (context.mounted)
          showSnackBar(context, 'Please enter a valid username without spaces');
        state = false;
        return;
      }

      final existingUsers = await _userProfileRepository.getUserByUsername(
        username,
      );
      if (existingUsers.isNotEmpty) {
        if (context.mounted) showSnackBar(context, 'Username is already taken');
        state = false;
        return;
      }
    }
    if (name.isEmpty) {
      if (context.mounted) showSnackBar(context, 'Please enter a valid name');
      state = false;
      return;
    }
    final oldUsername = user.username;
    user = user.copyWith(name: name, username: username);

    final res = await _userProfileRepository.editProfile(user);
    state = false;

    res.fold(
      (l) {
        if (context.mounted) showSnackBar(context, l.message);
      },
      (r) async {
        // 🔄 Update username in all posts if changed
        if (username != oldUsername) {
          await _userProfileRepository.updateUsernameInPosts(
            uid: user.uid,
            newUsername: username,
          );
          await _userProfileRepository.updateUsernameInComments(
            oldusername: oldUsername,
            newUsername: username,
          );
        }

        _ref.read(userProvider.notifier).update((state) => user);
        if (context.mounted) Routemaster.of(context).pop();
      },
    );
  }

  Stream<List<Post>> getUserPosts(String uid) {
    return _userProfileRepository.getUserPosts(uid);
  }

  void updateUserKarma(UserKarma karma) async {
    UserModel user = _ref.read(userProvider)!;
    user = user.copyWith(karma: user.karma + karma.karma);

    final res = await _userProfileRepository.updateUserKarma(user);
    res.fold(
      (l) => null,
      (r) => _ref.read(userProvider.notifier).update((state) => user),
    );
  }

  Stream<List<UserModel>> searchUser(String query) {
    return _userProfileRepository.searchUser(query);
  }
}
