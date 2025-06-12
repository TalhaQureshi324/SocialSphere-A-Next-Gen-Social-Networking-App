import 'dart:async';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdsController {
  static final AdsController _instance = AdsController._internal();
  factory AdsController() => _instance;
  AdsController._internal();

  bool _isInitialized = false;

  /// Initialize Google Mobile Ads SDK
  Future<void> initialize() async {
    if (_isInitialized) return;
    await MobileAds.instance.initialize();
    _isInitialized = true;
  }

  InterstitialAd? _interstitialAd;

  /// Create and return a fresh banner ad instance
  Future<BannerAd> createBannerAd() async {
    await initialize();

    final banner = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111', // ✅ Test Banner Ad Unit
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdFailedToLoad: (ad, error) {
          ad.dispose(); // Always dispose failed ads
        },
      ),
    );

    await banner.load();
    return banner;
  }

  /// Load a single interstitial ad
  Future<InterstitialAd> loadInterstitialAd() async {
    await initialize();
    final completer = Completer<InterstitialAd>();

    InterstitialAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/1033173712', // ✅ Test Interstitial Ad Unit
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _interstitialAd = null;
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _interstitialAd = null;
            },
          );
          _interstitialAd = ad;
          completer.complete(ad);
        },
        onAdFailedToLoad: (error) {
          completer.completeError(error);
        },
      ),
    );

    return completer.future;
  }

  /// Dispose interstitial ad if exists
  void dispose() {
    _interstitialAd?.dispose();
  }
}
