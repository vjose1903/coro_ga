import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:upgrader/upgrader.dart';

class VersionService {
  VersionService._();
  static final VersionService instance = VersionService._();

  String? _currentVersion;
  String? _storeVersion;
  String? _storeUrl;
  bool _hasChecked = false;
  bool _updateAvailable = false;

  bool get updateAvailable => _updateAvailable;
  String? get storeUrl => _storeUrl;
  String? get currentVersion => _currentVersion;
  String? get storeVersion => _storeVersion;

  Future<bool> checkForUpdate() async {
    if (_hasChecked) return _updateAvailable;

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      _currentVersion = packageInfo.version;

      final upgrader = Upgrader(
        debugLogging: kDebugMode,
        storeController: UpgraderStoreController(
          onAndroid: () => UpgraderPlayStore(),
          oniOS: () => UpgraderAppStore(),
        ),
      );

      await upgrader.initialize();

      // Obtener información del store
      final state = upgrader.state;
      _storeVersion = state.versionInfo?.appStoreVersion?.toString();
      _storeUrl = state.versionInfo?.appStoreListingURL;

      if (_storeVersion != null && _currentVersion != null) {
        _updateAvailable = _isNewerVersion(_storeVersion!, _currentVersion!);
      }

      _hasChecked = true;
      return _updateAvailable;
    } catch (e) {
      debugPrint('Error checking for update: $e');
      _hasChecked = true;
      return false;
    }
  }

  bool _isNewerVersion(String storeVersion, String currentVersion) {
    final storeParts = storeVersion.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final currentParts = currentVersion.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    // Asegurar que ambas listas tengan la misma longitud
    while (storeParts.length < 3) storeParts.add(0);
    while (currentParts.length < 3) currentParts.add(0);

    for (int i = 0; i < 3; i++) {
      if (storeParts[i] > currentParts[i]) return true;
      if (storeParts[i] < currentParts[i]) return false;
    }

    return false;
  }

  String getStoreUrl() {
    if (_storeUrl != null) return _storeUrl!;
    
    if (Platform.isAndroid) {
      return 'https://play.google.com/store/apps/details?id=com.inSpot.coro_games';
    } else if (Platform.isIOS) {
      return 'https://apps.apple.com/app/coro-games/id6478162656';
    }
    return '';
  }

  void reset() {
    _hasChecked = false;
    _updateAvailable = false;
    _storeVersion = null;
    _storeUrl = null;
  }
}

