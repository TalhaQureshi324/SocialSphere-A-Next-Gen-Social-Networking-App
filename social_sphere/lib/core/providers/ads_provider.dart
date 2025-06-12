import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_sphere/core/ads/ads_controller.dart';

final adsControllerProvider = Provider<AdsController>((ref) {
  final controller = AdsController();
  ref.onDispose(() => controller.dispose());
  return controller;
});