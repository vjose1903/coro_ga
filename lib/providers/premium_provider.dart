import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:game_score/services/purchase_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PremiumProvider extends ChangeNotifier {
  // 🔧 FLAG DE PRUEBAS: Cambiar a true para simular versión premium (solo funciona en debug)
  static const bool _kTestPremium = false;

  bool _isPremium = false;
  bool _isLoading = true;

  bool get isPremium => (kDebugMode && _kTestPremium) || _isPremium;
  bool get isLoading => _isLoading;

  // Límites para versión FREE
  static const int freeMaxPlayers = 3;
  static const int freeMaxGames = 2;
  static const int freeMaxPredefinedGames = 2;
  static const int freeMaxHistory = 10;

  PremiumProvider() {
    _loadPremiumStatus();
  }

  Future<void> _loadPremiumStatus() async {
    _isLoading = true;
    notifyListeners();

    // 1. Verificar cache local primero (rápido)
    final prefs = await SharedPreferences.getInstance();
    _isPremium = prefs.getBool('isPremium') ?? false;

    // 2. Si no es premium en cache, verificar con la tienda
    if (!_isPremium) {
      _isPremium = await PurchaseService.instance.restorePurchases();
      if (_isPremium) {
        await prefs.setBool('isPremium', true);
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> checkAndRestorePurchases() async {
    _isLoading = true;
    notifyListeners();

    _isPremium = await PurchaseService.instance.restorePurchases();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isPremium', _isPremium);

    _isLoading = false;
    notifyListeners();
  }

  void setPremium(bool value) async {
    _isPremium = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isPremium', value);
    notifyListeners();
  }

  // Verificadores de límites
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
    if (isPremium) return -1; // Sin límite
    return freeMaxHistory;
  }

  bool get showAds => !isPremium;
}

