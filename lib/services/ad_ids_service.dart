import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_remote_config/firebase_remote_config.dart';

import '../helpers/ad_helper.dart';

class AdIdsService {
  AdIdsService._();

  static final AdIdsService instance = AdIdsService._();
  static final StreamController<void> _idsUpdatedController = StreamController<void>.broadcast();
  static bool _isReady = false;

  static Stream<void> get idsUpdatedStream => _idsUpdatedController.stream;
  static bool get isReady => _isReady;

  static const Map<String, String> _defaultAndroidIds = {
    'AD_BANNER_HOME': '',
    'AD_BANNER_PARTIDA': '',
    'AD_BANNER_PUNTUACION': '',
    'AD_BANNER_AGREGAR_JUGADOR': '',
    'AD_BANNER_EDITAR_ENTIDAD': '',
    'AD_INTERSTITIAL': '',
    'AD_REWARDED_REVANCHA': '',
  };

  static const Map<String, String> _defaultIosIds = {
    'AD_IOS_BANNER_HOME': '',
    'AD_IOS_BANNER_PARTIDA': '',
    'AD_IOS_BANNER_PUNTUACION': '',
    'AD_IOS_BANNER_AGREGAR_JUGADOR': '',
    'AD_IOS_BANNER_EDITAR_ENTIDAD': '',
    'AD_IOS_INTERSTITIAL': '',
    'AD_IOS_REWARDED_REVANCHA': '',
  };

  Future<void> initialize() async {
    final remoteConfig = FirebaseRemoteConfig.instance;

    await remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 10),
      minimumFetchInterval: const Duration(minutes: 20),
    ));

    await remoteConfig.setDefaults({
      'AD_ANDROID_IDS': jsonEncode(_defaultAndroidIds),
      'AD_IOS_IDS': jsonEncode(_defaultIosIds),
    });

    try {
      await remoteConfig.fetchAndActivate();
    } catch (_) {
      // Keep defaults if fetch fails.
    }

    final configKey = Platform.isIOS ? 'AD_IOS_IDS' : 'AD_ANDROID_IDS';
    final raw = remoteConfig.getString(configKey);
    final ids = _parseIds(raw);
    AdHelper.setRemoteIds(ids);
    _isReady = _allIdsPresent(ids);
    _idsUpdatedController.add(null);
  }

  Map<String, dynamic> _parseIds(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) {
        return decoded.map((key, value) => MapEntry(key.toString(), value));
      }
    } catch (_) {}
    return Platform.isIOS ? Map<String, dynamic>.from(_defaultIosIds) : Map<String, dynamic>.from(_defaultAndroidIds);
  }

  bool _allIdsPresent(Map<String, dynamic> ids) {
    if (Platform.isIOS) {
      for (final key in _defaultIosIds.keys) {
        final value = ids[key]?.toString() ?? '';
        if (value.isEmpty) return false;
      }
      return true;
    }
    for (final key in _defaultAndroidIds.keys) {
      final value = ids[key]?.toString() ?? '';
      if (value.isEmpty) return false;
    }
    return true;
  }
}
