import 'dart:io';

import 'package:RomaStore/utils/constants.dart';

String? getBannerAdUnitId() {
  if (Platform.isIOS) {
    return bannerIdForIos;
  } else if (Platform.isAndroid) {
    return bannerIdForAndroid;
  }
  return null;
}

String? getInterstitialAdUnitId() {
  if (Platform.isIOS) {
    return interstitialIdForIos;
  } else if (Platform.isAndroid) {
    return InterstitialIdForAndroid;
  }
  return null;
}
