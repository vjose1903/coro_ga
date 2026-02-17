import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  ConnectivityService._();

  static final ConnectivityService instance = ConnectivityService._();

  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _statusController =
      StreamController<bool>.broadcast();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  Stream<bool> get statusStream => _statusController.stream;

  Future<void> initialize() async {
    _subscription ??= _connectivity.onConnectivityChanged.listen((_) async {
      final hasInternet = await hasInternetConnection();
      _statusController.add(hasInternet);
    });
    final hasInternet = await hasInternetConnection();
    _statusController.add(hasInternet);
  }

  Future<bool> hasInternetConnection() async {
    final results = await _connectivity.checkConnectivity();
    if (results.isEmpty ||
        (results.length == 1 && results.first == ConnectivityResult.none)) {
      return false;
    }
    return _canReachInternet();
  }

  Future<bool> _canReachInternet() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    _statusController.close();
  }
}
