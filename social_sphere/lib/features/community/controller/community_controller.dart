import 'package:flutter/material.dart';
import 'package:social_sphere/features/community/repository/community_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_sphere/models/community_model.dart';
import 'package:social_sphere/core/constants/constants.dart';
import 'package:social_sphere/core/providers/firebase_providers.dart';
import 'package:social_sphere/features/auth/controller/auth_controller.dart';
import 'package:routemaster/routemaster.dart';
import 'package:social_sphere/core/utils.dart';

final communityControllerProvider =
    StateNotifierProvider<CommunityController, bool>((ref) {
      final communityRepository = ref.watch(
        communityRepositoryProvider,
      );
      return CommunityController(
        communityRepository: communityRepository,
        ref: ref,
      );
    });

class CommunityController extends StateNotifier<bool> {
  final CommunityRepository _communityRepository;
  final Ref _ref;
  CommunityController({required communityRepository, required Ref ref})
    : _communityRepository = communityRepository,
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

    final res = await _communityRepository.createCommunity(community);
    state = false;
    res.fold(
      (l) {
        showSnackBar(context, l.message);
      },
      (r) {
        showSnackBar(context, "Community created successfully!!!");
        Routemaster.of(context).pop();
      },
    );
  }
}
