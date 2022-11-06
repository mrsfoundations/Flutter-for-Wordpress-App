import 'dart:io';

import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdState {
  Future<InitializationStatus> initialization;

  AdState(this.initialization);

  String get bannerAdUnitId => "ca-app-pub-7721979264176834/5076605237";

  String get interstitialAd => "ca-app-pub-7721979264176834/9798448873";
}