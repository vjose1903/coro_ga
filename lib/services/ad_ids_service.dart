import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import '../helpers/ad_helper.dart';
import '../shared_preferences/preferences.dart';

class AdIdsService {
  AdIdsService._();

  static final AdIdsService instance = AdIdsService._();
  static final StreamController<void> _idsUpdatedController = StreamController<void>.broadcast();
  static bool _isReady = false;
  static bool _isInitializing = false;
  static Timer? _retryTimer;
  static int _retryCount = 0;
  static DateTime? _lastRetryLogAt;
  static const Duration _logCooldown = Duration(minutes: 4);
  static const Duration _baseRetryDelay = Duration(seconds: 3);
  static const Duration _maxRetryDelay = Duration(minutes: 1);

  static Stream<void> get idsUpdatedStream => _idsUpdatedController.stream;
  static bool get isReady => _isReady;

  static bool _isInitialized = false;
  static bool get isInitialized => _isInitialized;

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
    if (_isInitializing) return;
    _isInitializing = true;
    final remoteConfig = FirebaseRemoteConfig.instance;
    final cachedIds = _loadCachedIds();
    final baseIds = cachedIds ?? _platformDefaults();
    FirebaseCrashlytics.instance.log('AdIdsService.initialize: start');

    await remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 4),
      minimumFetchInterval: const Duration(hours: 1),
    ));

    await remoteConfig.setDefaults({
      'AD_ANDROID_IDS': jsonEncode(Platform.isIOS ? _defaultAndroidIds : baseIds),
      'AD_IOS_IDS': jsonEncode(Platform.isIOS ? baseIds : _defaultIosIds),
    });

    try {
      await remoteConfig.fetchAndActivate();
    } catch (_) {
      // Keep defaults if fetch fails.
      FirebaseCrashlytics.instance.log('AdIdsService.initialize: fetchAndActivate failed');
    }

    final configKey = Platform.isIOS ? 'AD_IOS_IDS' : 'AD_ANDROID_IDS';
    final raw = remoteConfig.getString(configKey);
    final parsed = _tryParseIds(raw);
    final ids = _mergeIds(baseIds, parsed);
    AdHelper.setRemoteIds(ids);
    _isReady = _allIdsPresent(ids);
    _cacheIds(ids);
    _logStatus(ids: ids, parsed: parsed, cachedIds: cachedIds);
    _isInitialized = true;
    _idsUpdatedController.add(null);
    _isInitializing = false;
    if (!_isReady) {
      _scheduleRetry();
    } else {
      _resetRetry();
    }
  }

  Map<String, dynamic> _platformDefaults() {
    return Platform.isIOS ? Map<String, dynamic>.from(_defaultIosIds) : Map<String, dynamic>.from(_defaultAndroidIds);
  }

  Map<String, dynamic>? _tryParseIds(String raw) {
    if (raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is Map) {
        final mapped = decoded.map((key, value) => MapEntry(key.toString(), value));
        return mapped;
      }
    } catch (_) {}
    return null;
  }

  Map<String, dynamic>? _loadCachedIds() {
    final raw = Platform.isIOS ? Preferences.cachedIosAdIds : Preferences.cachedAndroidAdIds;
    final parsed = _tryParseIds(raw);
    if (parsed == null) return null;
    return _allIdsPresent(parsed) ? parsed : null;
  }

  void _cacheIds(Map<String, dynamic> ids) {
    if (!_allIdsPresent(ids)) return;
    final raw = jsonEncode(ids);
    if (Platform.isIOS) {
      Preferences.cachedIosAdIds = raw;
    } else {
      Preferences.cachedAndroidAdIds = raw;
    }
  }

  Map<String, dynamic> _mergeIds(Map<String, dynamic> base, Map<String, dynamic>? incoming) {
    final merged = Map<String, dynamic>.from(base);
    if (incoming == null) return merged;
    final expected = _expectedKeys();
    for (final entry in incoming.entries) {
      if (!expected.contains(entry.key)) continue;
      final value = entry.value.toString();
      if (value.isNotEmpty) {
        merged[entry.key] = value;
      }
    }
    return merged;
  }

  Set<String> _expectedKeys() {
    return Platform.isIOS ? _defaultIosIds.keys.toSet() : _defaultAndroidIds.keys.toSet();
  }

  void _logStatus({
    required Map<String, dynamic> ids,
    required Map<String, dynamic>? parsed,
    required Map<String, dynamic>? cachedIds,
  }) {
    final source = parsed != null ? 'remote' : (cachedIds != null ? 'cache' : 'defaults');
    FirebaseCrashlytics.instance.setCustomKey('ad_ids_source', source);
    FirebaseCrashlytics.instance.setCustomKey('ad_ids_ready', _isReady);
    FirebaseCrashlytics.instance.log(
      'AdIdsService.initialize: source=$source ready=$_isReady',
    );
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

  void _scheduleRetry() {
    if (_isInitializing) return;
    if (_retryTimer != null) return;
    final delay = _nextRetryDelay();
    _logRetryThrottled(
      'AdIdsService: scheduling retry in ${delay.inSeconds}s (attempt $_retryCount)',
    );
    _retryTimer = Timer(delay, () {
      _retryTimer = null;
      if (_isReady) {
        _resetRetry();
        return;
      }
      initialize();
    });
  }

  Duration _nextRetryDelay() {
    _retryCount = (_retryCount + 1).clamp(1, 8);
    final multiplier = 1.6 * (_retryCount - 1);
    final baseMs = _baseRetryDelay.inMilliseconds;
    var delayMs = (baseMs * (1 + multiplier)).round();
    if (delayMs > _maxRetryDelay.inMilliseconds) {
      delayMs = _maxRetryDelay.inMilliseconds;
    }
    final jitterMs = DateTime.now().microsecondsSinceEpoch % 1500;
    return Duration(milliseconds: delayMs + jitterMs);
  }

  void _resetRetry() {
    _retryTimer?.cancel();
    _retryTimer = null;
    _retryCount = 0;
  }

  void _logRetryThrottled(String message) {
    final now = DateTime.now();
    if (_lastRetryLogAt != null && now.difference(_lastRetryLogAt!) < _logCooldown) {
      return;
    }
    _lastRetryLogAt = now;
    FirebaseCrashlytics.instance.log(message);
  }
}
