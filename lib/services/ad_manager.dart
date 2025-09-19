import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:utilimate/services/connectivity_service.dart';
import 'dart:developer' as developer;

class AdManager {
  static final AdManager _instance = AdManager._internal();
  factory AdManager() => _instance;

  AdManager._internal() {
    // Load the banner ad as soon as the manager is initialized.
    // The ad will be ready to be shown later when the UI requests it.
    _loadBannerAd();
  }

  // Test Ad Unit IDs
  static const String bannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  static const String interstitialAdUnitId =
      'ca-app-pub-3940256099942544/1033173712';
  static const String rewardedAdUnitId =
      'ca-app-pub-3940256099942544/5224354917';
  // Ad Unit IDs
  // static const String bannerAdUnitId = 'ca-app-pub-2416673076573660/1493290195';
  // static const String interstitialAdUnitId =
  //     'ca-app-pub-2416673076573660/4081878791';
  // static const String rewardedAdUnitId =
  //     'ca-app-pub-2416673076573660/5301808732';

  // Private fields to hold ad instances and their loading state
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;

  // Method to check for connectivity
  bool get _isOnline => ConnectivityService().isConnected;

  // Banner Ad: Loads the ad internally and sets a flag when it's ready.
  // This is a private method that the singleton calls upon creation.
  void _loadBannerAd() {
    if (!_isOnline) {
      developer.log('Not loading Banner Ad: No internet connection.');
      return;
    }

    _bannerAd = BannerAd(
      adUnitId: bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          developer.log('Banner ad loaded.');
          _isBannerAdLoaded = true;
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          developer.log('Banner ad failed to load: $error');
          _isBannerAdLoaded = false;
          ad.dispose();
        },
      ),
    );
    _bannerAd!.load();
  }

  // Public method to get the AdWidget for the UI.
  // Returns null if the ad is not yet loaded, which the UI should handle.
  AdWidget? getBannerAdWidget() {
    if (_isBannerAdLoaded && _bannerAd != null) {
      developer.log("Banner ad returned.");
      return AdWidget(ad: _bannerAd!);
    }
    return null;
  }

  // Interstitial Ad: Loads the ad and shows it at a specific moment
  void loadInterstitialAd() {
    if (!_isOnline) {
      developer.log('Not loading Interstitial Ad: No internet connection.');
      return;
    }

    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          _interstitialAd!.setImmersiveMode(true);
          _interstitialAd!.show();
        },
        onAdFailedToLoad: (LoadAdError error) {
          developer.log('InterstitialAd failed to load: $error');
          _interstitialAd = null;
        },
      ),
    );
  }

  // Rewarded Ad: Loads the ad and shows it, calling a reward function
  void loadAndShowRewardedAd(Function(RewardItem) onUserEarnedReward) {
    if (!_isOnline) {
      developer.log('Not loading Rewarded Ad: No internet connection.');
      return;
    }

    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          _rewardedAd = ad;
          _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (RewardedAd ad) {
              ad.dispose();
            },
            onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
              ad.dispose();
            },
          );
          _rewardedAd!.show(
            onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
              onUserEarnedReward(reward);
            },
          );
        },
        onAdFailedToLoad: (LoadAdError error) {
          developer.log('RewardedAd failed to load: $error');
          _rewardedAd = null;
        },
      ),
    );
  }

  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
  }
}
