import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

class VersionService {
  VersionService._();
  static final VersionService instance = VersionService._();

  String? _currentVersion;
  String? _storeVersion;
  String? _storeUrl;
  bool _hasChecked = false;
  bool _updateAvailable = false;

  // App IDs
  static const String _androidPackageId = 'com.inSpot.coro_games';
  static const String _iosAppId = '6757870526';

  bool get updateAvailable => _updateAvailable;
  String? get storeUrl => _storeUrl;
  String? get currentVersion => _currentVersion;
  String? get storeVersion => _storeVersion;

  Future<bool> checkForUpdate() async {
    if (_hasChecked) return _updateAvailable;

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      _currentVersion = packageInfo.version;

      if (Platform.isAndroid) {
        await _checkPlayStore();
      } else if (Platform.isIOS) {
        await _checkAppStore();
      }

      debugPrint('VersionService: current=$_currentVersion, store=$_storeVersion, url=$_storeUrl');

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

  Future<void> _checkAppStore() async {
    try {
      final url = Uri.parse('https://itunes.apple.com/lookup?id=$_iosAppId&country=us');
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);

      final request = await client.getUrl(url);
      final response = await request.close();

      if (response.statusCode == 200) {
        final body = await response.transform(utf8.decoder).join();
        final json = jsonDecode(body);

        if (json['resultCount'] > 0) {
          final result = json['results'][0];
          _storeVersion = result['version'];
          _storeUrl = result['trackViewUrl'];
        }
      }
      client.close();
    } catch (e) {
      debugPrint('Error checking App Store: $e');
    }
  }

  Future<void> _checkPlayStore() async {
    try {
      // Para Android, consultamos la página de Play Store y extraemos la versión
      final url = Uri.parse('https://play.google.com/store/apps/details?id=$_androidPackageId&hl=en&gl=US');
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);

      final request = await client.getUrl(url);
      request.headers.set('User-Agent', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36');
      final response = await request.close();

      if (response.statusCode == 200) {
        final body = await response.transform(utf8.decoder).join();

        // Múltiples patrones para extraer la versión de Play Store
        final patterns = [
          RegExp(r'\[\[\["(\d+\.\d+\.?\d*)"\]\]'),
          RegExp(r'"softwareVersion"[^"]*"(\d+\.\d+\.?\d*)"'),
          RegExp(r'Current Version[^>]*>(\d+\.\d+\.?\d*)<'),
          RegExp(r'\["(\d+\.\d+\.?\d*)"\],"ANDROID"'),
        ];

        for (final pattern in patterns) {
          final match = pattern.firstMatch(body);
          if (match != null) {
            _storeVersion = match.group(1);
            debugPrint('VersionService: Play Store version found with pattern: ${pattern.pattern}');
            break;
          }
        }

        _storeUrl = 'https://play.google.com/store/apps/details?id=$_androidPackageId';
      }
      client.close();
    } catch (e) {
      debugPrint('Error checking Play Store: $e');
    }
  }

  bool _isNewerVersion(String storeVersion, String currentVersion) {
    final storeParts = storeVersion.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final currentParts = currentVersion.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    // Asegurar que ambas listas tengan la misma longitud
    while (storeParts.length < 3) {
      storeParts.add(0);
    }
    while (currentParts.length < 3) {
      currentParts.add(0);
    }

    for (int i = 0; i < 3; i++) {
      if (storeParts[i] > currentParts[i]) return true;
      if (storeParts[i] < currentParts[i]) return false;
    }

    return false;
  }

  String getStoreUrl() {
    if (_storeUrl != null) return _storeUrl!;

    if (Platform.isAndroid) {
      return 'https://play.google.com/store/apps/details?id=$_androidPackageId';
    } else if (Platform.isIOS) {
      return 'https://apps.apple.com/app/coro-games/id$_iosAppId';
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
