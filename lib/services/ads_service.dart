import 'package:spectrum_chase/constants.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';

class AdsService {
  /// functions ///

  void loadAds() {
    createRewardedAd(placementId: 'Rewarded_Android', doneFunction: (){});
    // createRewardedAd(placementId: 'Rewarded_Android2', doneFunction: (){});
    // createRewardedAd(placementId: 'Rewarded_Android3', doneFunction: (){});
    createRewardedAd(placementId: 'Rewarded_Android4', doneFunction: (){});
    createBannerAd();
    createInterstitialAd();
  }

  void createBannerAd() {
    UnityAds.load(
      placementId: 'Banner_Android',
      onComplete: (placementId) {
        print('Load Complete $placementId');
      },
      onFailed: (placementId, error, message) {
        createBannerAd();
      },
    );
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

  void createRewardedAd({
    required String placementId,
    required Function doneFunction,
  }) {
    // Constants.adsLoading = true;
    UnityAds.load(
      placementId: '$placementId',
      onComplete: (placementId) {
        print('Load Complete $placementId');
        UnityAds.showVideoAd(
          placementId: '$placementId',
          onStart: (placementId) {},
          onClick: (placementId) {},
          onSkipped: (placementId) {},
          onComplete: (placementId) {
            doneFunction();
          },
          onFailed: (placementId, error, message) {
            print('Failed to show: $message');
            Future.delayed(Duration(seconds: 3),(){
              createRewardedAd(placementId: placementId, doneFunction: doneFunction);
            });
          },
        );
      },
      onFailed: (placementId, error, message) {
        print('Failed to load: $message');
        Future.delayed(Duration(seconds: 3),(){
          createRewardedAd(placementId: placementId, doneFunction: doneFunction);
        });
      },
    );
  }
}
