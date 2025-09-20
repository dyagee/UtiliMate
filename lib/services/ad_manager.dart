import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:utilimate/services/connectivity_service.dart';
import 'dart:developer' as developer;

class AdManager {
  static final AdManager _instance = AdManager._internal();
  factory AdManager() => _instance;

  AdManager._internal() {
    // Load the two banner ads and other ad types upon creation.
    _loadBannerAd();
    _loadFileBrowserBannerAd();
  }

  // Test Ad Unit IDs
  // static const String bannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  // static const String interstitialAdUnitId =
  //     'ca-app-pub-3940256099942544/1033173712';
  // static const String rewardedAdUnitId =
  //     'ca-app-pub-3940256099942544/5224354917';

  // Ad Unit IDs
  static const String bannerAdUnitId = 'ca-app-pub-2416673076573660/1493290195';
  static const String interstitialAdUnitId =
      'ca-app-pub-2416673076573660/4081878791';
  static const String rewardedAdUnitId =
      'ca-app-pub-2416673076573660/5301808732';

  // Private fields to hold ad instances and their loading state
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;

  // New private fields for the dedicated file browser banner ad
  BannerAd? _fileBrowserBannerAd;
  bool _isFileBrowserBannerAdLoaded = false;

  // Method to check for connectivity
  bool get _isOnline => ConnectivityService().isConnected;

  // Public method to get the AdWidget for the standard banner.
  AdWidget? getBannerAdWidget() {
    if (_isBannerAdLoaded && _bannerAd != null) {
      developer.log("Standard banner ad returned.");
      return AdWidget(ad: _bannerAd!);
    }
    return null;
  }

  // Public method to get the AdWidget for the file browser banner.
  AdWidget? getFileBrowserBannerAdWidget() {
    if (_isFileBrowserBannerAdLoaded && _fileBrowserBannerAd != null) {
      developer.log("File Browser banner ad returned.");
      return AdWidget(ad: _fileBrowserBannerAd!);
    }
    return null;
  }

  // Private method to load the standard banner ad.
  void _loadBannerAd() {
    if (!_isOnline) {
      developer.log('Not loading standard Banner Ad: No internet connection.');
      return;
    }
    _bannerAd = BannerAd(
      adUnitId: bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          developer.log('Standard banner ad loaded.');
          _isBannerAdLoaded = true;
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          developer.log('Standard banner ad failed to load: $error');
          _isBannerAdLoaded = false;
          ad.dispose();
        },
      ),
    );
    _bannerAd!.load();
  }

  // Private method to load the dedicated file browser banner ad.
  void _loadFileBrowserBannerAd() {
    if (!_isOnline) {
      developer.log(
        'Not loading File Browser Banner Ad: No internet connection.',
      );
      return;
    }
    _fileBrowserBannerAd = BannerAd(
      adUnitId: bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          developer.log('File Browser banner ad loaded.');
          _isFileBrowserBannerAdLoaded = true;
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          developer.log('File Browser banner ad failed to load: $error');
          _isFileBrowserBannerAdLoaded = false;
          ad.dispose();
        },
      ),
    );
    _fileBrowserBannerAd!.load();
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
    _fileBrowserBannerAd?.dispose();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
  }
}
