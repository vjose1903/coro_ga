import 'dart:io';

import 'package:game_score/widgets/widgets.dart';

class AdHelper {
  static String get testing {
    return 'ca-app-pub-3940256099942544/6300978111';
  }

  static String getBannerAdUnitId(AdLocation location) {
    String id = '';
    if (Platform.isAndroid) {
      switch (location) {
        case AdLocation.partida:
          id = 'ca-app-pub-4324407503643964/8520147255';
          break;
        case AdLocation.puntuacion:
          id = 'ca-app-pub-4324407503643964/3158911880';
          break;
        case AdLocation.agregarJugador:
          id = 'ca-app-pub-4324407503643964/3785597846';
          break;
        case AdLocation.editarEntidad:
          id = 'ca-app-pub-4324407503643964/7034577710';
          break;
        default:
      }
    } else if (Platform.isIOS) {
      return '<YOUR_IOS_BANNER_AD_UNIT_ID>';
    } else {
      throw UnsupportedError('Unsupported platform');
    }

    return id;
  }

  // static String get interstitialAdUnitId {
  //   if (Platform.isAndroid) {
  //     return '<YOUR_ANDROID_INTERSTITIAL_AD_UNIT_ID>';
  //   } else if (Platform.isIOS) {
  //     return '<YOUR_IOS_INTERSTITIAL_AD_UNIT_ID>';
  //   } else {
  //     throw UnsupportedError('Unsupported platform');
  //   }
  // }

  // static String get rewardedAdUnitId {
  //   if (Platform.isAndroid) {
  //     return '<YOUR_ANDROID_REWARDED_AD_UNIT_ID>';
  //   } else if (Platform.isIOS) {
  //     return '<YOUR_IOS_REWARDED_AD_UNIT_ID>';
  //   } else {
  //     throw UnsupportedError('Unsupported platform');
  //   }
  // }
}
