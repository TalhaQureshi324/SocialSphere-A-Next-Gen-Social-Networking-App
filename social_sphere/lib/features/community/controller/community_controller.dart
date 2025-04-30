import 'package:flutter/material.dart';
import 'package:social_sphere/core/failure.dart';
import 'package:social_sphere/core/providers/storage_repository_provider.dart';
import 'package:social_sphere/features/community/repository/community_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_sphere/models/community_model.dart';
import 'package:social_sphere/core/constants/constants.dart';
import 'package:social_sphere/features/auth/controller/auth_controller.dart';
import 'package:routemaster/routemaster.dart';
import 'package:social_sphere/core/utils.dart';
import 'dart:io';
import 'package:fpdart/fpdart.dart';
import 'package:social_sphere/models/post_model.dart';
import 'dart:typed_data';

final userCommunitiesProvider = StreamProvider((ref) {
  final communityController = ref.watch(communityControllerProvider.notifier);
  return communityController.getUserCommunities();
});

final communityControllerProvider =
    StateNotifierProvider<CommunityController, bool>((ref) {
      final communityRepository = ref.watch(communityRepositoryProvider);
      final storageRepository = ref.watch(storageRepositoryProvider);
      return CommunityController(
        communityRepository: communityRepository,
        storageRepository: storageRepository,
        ref: ref,
      );
    });

final getCommunityByNameProvider = StreamProvider.family((ref, String name) {
  return ref
      .watch(communityControllerProvider.notifier)
      .getCommunityByName(name);
});

final searchCommunityProvider = StreamProvider.family((ref, String query) {
  return ref.watch(communityControllerProvider.notifier).searchCommunity(query);
});

final getCommunityPostsProvider = StreamProvider.family((ref, String name) {
  return ref.read(communityControllerProvider.notifier).getCommunityPosts(name);
});

class CommunityController extends StateNotifier<bool> {
  final CommunityRepository _communityRepository;
  final Ref _ref;

  final StorageRepository _storageRepository;

  CommunityController({
    required communityRepository,
    required Ref ref,
    required storageRepository,
  }) : _storageRepository = storageRepository,
       _communityRepository = communityRepository,
       _ref = ref,
       super(false);

  void createCommunity(String name, BuildContext context) async {
    state = true;
    final uid = _ref.read(userProvider)?.uid ?? '';
    Community community = Community(
      id: name,
      name: name,
      banner: Constants.bannerDefault,
      avatar: Constants.avatarDefault,
      members: [uid],
      mods: [uid],
    );
    if (name.isEmpty || name.contains(" ")) {
      showSnackBar(context, "Please enter a valid group name without spaces");
      state = false;
      return;
    }

    final res = await _communityRepository.createCommunity(community);
    state = false;
    res.fold(
      (l) {
        showSnackBar(context, l.message);
      },
      (r) {
        showSnackBar(context, "Group created successfully!!!");
        Routemaster.of(context).pop();
      },
    );
  }

  void joinCommunity(Community community, BuildContext context) async {
    final user = _ref.read(userProvider)!;

    Either<Failure, void> res;

    if (community.members.contains(user.uid)) {
      res = await _communityRepository.leaveCommunity(user.uid, community.name);
    } else {
      res = await _communityRepository.joinCommunity(user.uid, community.name);
    }

    res.fold(
      (l) {
        showSnackBar(context, l.message);
      },
      (r) {
        if (community.members.contains(user.uid)) {
          showSnackBar(context, "Group Left ${community.name} successfully");
        } else {
          showSnackBar(context, "Group Joined ${community.name} successfully");
        }
      },
    );
  }

  Stream<List<Community>> getUserCommunities() {
    final uid = _ref.read(userProvider)!.uid;
    return _communityRepository.getUserCommunities(uid);
  }

  Stream<Community> getCommunityByName(String name) {
    return _communityRepository.getCommunityByName(name);
  }

  void editCommunity({
    required File? profileFile,
    required File? bannerFile,
    required Uint8List? profileWebFile,
    required Uint8List? bannerWebFile,
    required BuildContext context,
    required Community community,
  }) async {
    state = true;
    if (profileFile != null) {
      final res = await _storageRepository.storeFile(
        path: 'communities/profile',
        id: community.name,
        file: profileFile,
        webFile: profileWebFile,
      );
      res.fold(
        (l) {
          showSnackBar(context, l.message);
        },
        (r) {
          community = community.copyWith(avatar: r);
        },
      );
    }

    if (bannerFile != null) {
      final res = await _storageRepository.storeFile(
        path: 'communities/banner',
        id: community.name,
        file: bannerFile,
        webFile: bannerWebFile,
      );
      res.fold(
        (l) {
          showSnackBar(context, l.message);
        },
        (r) {
          community = community.copyWith(banner: r);
        },
      );
    }
    final res = await _communityRepository.editCommunity(community);
    state = false;

    res.fold(
      (l) {
        showSnackBar(context, l.message);
      },
      (r) {
        showSnackBar(context, "Group edited successfully!!!");
        Routemaster.of(context).pop();
      },
    );
  }

  Stream<List<Community>> searchCommunity(String query) {
    return _communityRepository.searchCommunity(query);
  }

  void addMods(
    String communityName,
    List<String> uids,
    BuildContext context,
  ) async {
    final res = await _communityRepository.addMods(communityName, uids);
    res.fold(
      (l) {
        showSnackBar(context, l.message);
      },
      (r) {
        showSnackBar(context, "Admin added successfully!!!");
        Routemaster.of(context).pop();
      },
    );
  }

  Stream<List<Post>> getCommunityPosts(String name) {
    return _communityRepository.getCommunityPosts(name);
  }
}
