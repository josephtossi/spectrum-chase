import 'package:unity_ads_plugin/unity_ads_plugin.dart';

class AdsService {
  /// functions ///

  void loadAds() {
    createInterstitialAd();
    createRewardedAd(doneFunction: () {}, loadAd: false);
  }

  void createInterstitialAd() {
    UnityAds.load(
      placementId: 'Interstitial_Android',
      onComplete: (placementId) {
        print('Load Complete $placementId');
      },
      onFailed: (placementId, error, message) {
        createInterstitialAd();
      },
    );
  }

  void showInterstitialAd() {
    UnityAds.showVideoAd(
      placementId: 'Interstitial_Android',
      onStart: (placementId) {
        createInterstitialAd();
      },
      onClick: (placementId) {
        createInterstitialAd();
      },
      onSkipped: (placementId) {
        createInterstitialAd();
      },
      onComplete: (placementId) {
        createInterstitialAd();
      },
      onFailed: (placementId, error, message) =>
          print('Video Ad $placementId failed: $error $message'),
    );
  }

  void createRewardedAd({required Function doneFunction, required loadAd}) {
    UnityAds.load(
      placementId: 'Rewarded_Android4',
      onComplete: (placementId) {
        print('Load Complete $placementId');
        if (loadAd) {
          UnityAds.showVideoAd(
            placementId: 'Rewarded_Android4',
            onStart: (placementId) {},
            onClick: (placementId) {},
            onSkipped: (placementId) {},
            onComplete: (placementId) {
              doneFunction();
            },
            onFailed: (placementId, error, message) {
              print('Failed to show: $message');
            },
          );
        }
      },
      onFailed: (placementId, error, message) {
        print('Failed to load: $message');
      },
    );
  }
}
