import 'dart:io';

import 'package:game_score/widgets/widgets.dart';

class AdHelper {
  static String getTestingId(String tipo) {
    if (tipo == "banner") {
      return 'ca-app-pub-3940256099942544/6300978111';
    } else if (tipo == "completo") {
      return 'ca-app-pub-3940256099942544/1033173712';
    } else {
      return '';
    }
  }

  static String getBannerAdUnitId(AdLocation location) {
    String id = '';
    if (Platform.isAndroid) {
      switch (location) {
        case AdLocation.partida:
          id = 'ca-app-pub-7138392349989063/9555188441';
          break;
        case AdLocation.puntuacion:
          id = 'ca-app-pub-7138392349989063/7103983607';
          break;
        case AdLocation.agregarJugador:
          id = 'ca-app-pub-7138392349989063/8717320319';
          break;
        case AdLocation.editarEntidad:
          id = 'ca-app-pub-7138392349989063/5628122544';
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
  //     return 'ca-app-pub-7138392349989063/3081850257';
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
