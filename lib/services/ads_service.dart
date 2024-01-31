import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdsService {
  /// todo enable ads //
  /// variables ///
  int maxFailedLoadAttempts = 3;
  static const AdRequest request = AdRequest(
    keywords: <String>['foo', 'bar'],
    contentUrl: 'http://foo.com/bar.html',
    nonPersonalizedAds: true,
  );
  InterstitialAd? _interstitialAd;
  int _numInterstitialLoadAttempts = 0;
  RewardedAd? _rewardedAd;
  int _numRewardedLoadAttempts = 0;

  /// functions ///
  void createInterstitialAd() {
    InterstitialAd.load(
        adUnitId: Platform.isAndroid
            ? 'ca-app-pub-6797834730215290/4585896045'
            : 'ca-app-pub-6797834730215290/4585896045',
        request: request,
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            print('$ad loaded');
            _interstitialAd = ad;
            _numInterstitialLoadAttempts = 0;
            _interstitialAd!.setImmersiveMode(true);
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('InterstitialAd failed to load: $error.');
            _numInterstitialLoadAttempts += 1;
            _interstitialAd = null;
            if (_numInterstitialLoadAttempts < maxFailedLoadAttempts) {
              createInterstitialAd();
            }
          },
        ));
  }

  void showInterstitialAd() {
    // if (_interstitialAd == null) {
    //   print('Warning: attempt to show interstitial before loaded.');
    //   return;
    // }
    // _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
    //   onAdShowedFullScreenContent: (InterstitialAd ad) =>
    //       print('ad onAdShowedFullScreenContent.'),
    //   onAdDismissedFullScreenContent: (InterstitialAd ad) {
    //     print('$ad onAdDismissedFullScreenContent.');
    //     ad.dispose();
    //     createInterstitialAd();
    //   },
    //   onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
    //     print('$ad onAdFailedToShowFullScreenContent: $error');
    //     ad.dispose();
    //     createInterstitialAd();
    //   },
    // );
    // _interstitialAd!.show();
    // _interstitialAd = null;
  }

  void createRewardedAd() {
    RewardedAd.load(
        adUnitId: Platform.isAndroid
            ? 'ca-app-pub-6797834730215290/2919830279'
            : 'ca-app-pub-6797834730215290/2919830279',
        request: request,
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (RewardedAd ad) {
            print('$ad loaded.');
            _rewardedAd = ad;
            _numRewardedLoadAttempts = 0;
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('RewardedAd failed to load: $error');
            _rewardedAd = null;
            _numRewardedLoadAttempts += 1;
            if (_numRewardedLoadAttempts < maxFailedLoadAttempts) {
              createRewardedAd();
            }
          },
        ));
  }

  void showRewardedAd({required Function doneFunction}) {
    // if (_rewardedAd == null) {
    //   print('Warning: attempt to show rewarded before loaded.');
    //   return;
    // }
    // _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
    //   onAdShowedFullScreenContent: (RewardedAd ad) =>
    //       print('ad onAdShowedFullScreenContent.'),
    //   onAdDismissedFullScreenContent: (RewardedAd ad) {
    //     print('$ad onAdDismissedFullScreenContent.');
    //     ad.dispose();
    //     createRewardedAd();
    //     print('done function');
    //     doneFunction();
    //   },
    //   onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
    //     print('$ad onAdFailedToShowFullScreenContent: $error');
    //     ad.dispose();
    //     createRewardedAd();
    //   },
    //   onAdWillDismissFullScreenContent: (RewardedAd ad) {},
    // );
    //
    // _rewardedAd!.setImmersiveMode(true);
    // _rewardedAd!.show(
    //     onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
    //   print('$ad with reward $RewardItem(${reward.amount}, ${reward.type})');
    // });
    // _rewardedAd = null;
  }
}
