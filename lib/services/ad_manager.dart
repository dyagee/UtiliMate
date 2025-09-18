// lib/services/ad_manager.dart

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:utilimate/services/connectivity_service.dart';
import 'dart:developer' as developer;

class AdManager {
  static final AdManager _instance = AdManager._internal();
  factory AdManager() => _instance;
  AdManager._internal();

  // Ad Unit IDs
  static const String bannerAdUnitId = 'ca-app-pub-2416673076573660/1493290195';
  static const String interstitialAdUnitId =
      'ca-app-pub-2416673076573660/4081878791';
  static const String rewardedAdUnitId =
      'ca-app-pub-2416673076573660/5301808732';

  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;

  // Method to check for connectivity
  bool get _isOnline => ConnectivityService().isConnected;

  // Banner Ad: Returns the AdWidget if a connection is available
  AdWidget? createBannerAdWidget() {
    if (_isOnline) {
      final bannerAd = BannerAd(
        adUnitId: bannerAdUnitId,
        request: const AdRequest(),
        size: AdSize.banner,
        listener: BannerAdListener(
          onAdLoaded: (ad) => developer.log('BannerAd loaded.'),
          onAdFailedToLoad: (ad, err) {
            developer.log('BannerAd failed to load: $err');
            ad.dispose();
          },
        ),
      );
      bannerAd.load();
      return AdWidget(ad: bannerAd);
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
  // CORRECTED CODE BELOW
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
          // CORRECTED: Pass the callback with the correct signature
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
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
  }
}
