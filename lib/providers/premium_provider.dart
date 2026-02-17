import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/purchase_service.dart';

class PremiumProvider extends ChangeNotifier {
  PremiumProvider() {
    _loadPremiumStatus();
  }
  bool _isPremium = false;
  bool _isLoading = true;
  bool _simulatePremium = false; // solo debug

  bool get isPremium => (kDebugMode && _simulatePremium) || _isPremium;
  bool get simulatePremium => kDebugMode ? _simulatePremium : false;
  bool get isLoading => _isLoading;

  // Límites versión FREE
  static const int freeMaxPlayers = 3;
  static const int freeMaxGames = 2;
  static const int freeMaxPredefinedGames = 2;
  static const int freeMaxHistory = 10;

  /// Cargar estado premium
  Future<void> _loadPremiumStatus() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    _isPremium = prefs.getBool('isPremium') ?? false;

    _isLoading = false;
    notifyListeners();
  }

  /// Restaurar manual (botón explícito)
  Future<void> restorePurchases() async {
    _isLoading = true;
    notifyListeners();

    final restored = await PurchaseService.instance.restorePurchases();
    _isPremium = restored;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isPremium', restored);

    _isLoading = false;
    notifyListeners();
  }

  /// Alias de restauración para UI (mantiene la separación de flujo)
  Future<void> checkAndRestorePurchases() async {
    await restorePurchases();
  }

  void setPremium(bool value) async {
    _isPremium = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isPremium', value);
    notifyListeners();
  }

  // DEBUG
  void setSimulatePremium(bool value) {
    if (!kDebugMode) return;
    _simulatePremium = value;
    notifyListeners();
  }

  // Validadores
  bool canAddPlayer(int currentPlayers) {
    if (isPremium) return true;
    return currentPlayers < freeMaxPlayers;
  }

  bool canCreateGame(int currentGames) {
    if (isPremium) return true;
    return currentGames < freeMaxGames;
  }

  bool canCreatePredefinedGame(int currentPredefined) {
    if (isPremium) return true;
    return currentPredefined < freeMaxPredefinedGames;
  }

  int getHistoryLimit() {
    if (isPremium) return -1;
    return freeMaxHistory;
  }

  bool get showAds => !isPremium;
}
