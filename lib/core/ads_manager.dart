// import 'package:google_mobile_ads/google_mobile_ads.dart';

// class AdsManager {
//   static String get bannerAdUnitId =>
//       'ca-app-pub-3940256099942544/6300978111'; // Test Ad Unit ID

//   static BannerAd createBannerAd(Function(Ad) onAdLoaded) {
//     return BannerAd(
//       adUnitId: bannerAdUnitId,
//       size: AdSize.banner,
//       request: const AdRequest(),
//       listener: BannerAdListener(
//         onAdLoaded: (ad) => onAdLoaded(ad),
//         onAdFailedToLoad: (ad, error) => ad.dispose(),
//       ),
//     );
//   }
// }
