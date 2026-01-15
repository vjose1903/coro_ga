import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class PurchaseService {
  static final PurchaseService instance = PurchaseService._();
  PurchaseService._();

  final InAppPurchase _iap = InAppPurchase.instance;
  
  // ID del producto en Google Play / App Store
  static const String premiumProductId = 'pro_version';
  
  // IDs alternativos para testing
  static const Set<String> _productIds = {
    premiumProductId,
    'coro_games_premium',
  };

  StreamSubscription<List<PurchaseDetails>>? _subscription;
  List<ProductDetails> _products = [];
  Function(bool)? _onPurchaseComplete;

  bool _isAvailable = false;
  bool get isAvailable => _isAvailable;
  
  List<ProductDetails> get products => _products;

  Future<void> initialize({Function(bool)? onPurchaseComplete}) async {
    _onPurchaseComplete = onPurchaseComplete;
    
    _isAvailable = await _iap.isAvailable();
    if (!_isAvailable) {
      debugPrint('IAP no disponible');
      return;
    }

    // Escuchar actualizaciones de compras
    final purchaseUpdated = _iap.purchaseStream;
    _subscription = purchaseUpdated.listen(
      _onPurchaseUpdated,
      onDone: _onDone,
      onError: _onError,
    );

    await _loadProducts();
  }

  Future<void> _loadProducts() async {
    final response = await _iap.queryProductDetails(_productIds);
    
    if (response.notFoundIDs.isNotEmpty) {
      debugPrint('Productos no encontrados: ${response.notFoundIDs}');
    }
    
    _products = response.productDetails;
    debugPrint('Productos cargados: ${_products.length}');
  }

  void _onPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    for (final purchase in purchaseDetailsList) {
      _handlePurchase(purchase);
    }
  }

  Future<void> _handlePurchase(PurchaseDetails purchase) async {
    if (purchase.status == PurchaseStatus.pending) {
      debugPrint('Compra pendiente...');
      return;
    }

    if (purchase.status == PurchaseStatus.error) {
      debugPrint('Error en compra: ${purchase.error}');
      _onPurchaseComplete?.call(false);
      return;
    }

    if (purchase.status == PurchaseStatus.purchased ||
        purchase.status == PurchaseStatus.restored) {
      // Verificar la compra (en producción deberías verificar en tu servidor)
      final valid = await _verifyPurchase(purchase);
      if (valid) {
        debugPrint('Compra verificada: ${purchase.productID}');
        _onPurchaseComplete?.call(true);
      } else {
        debugPrint('Compra inválida');
        _onPurchaseComplete?.call(false);
      }
    }

    // Completar la transacción pendiente
    if (purchase.pendingCompletePurchase) {
      await _iap.completePurchase(purchase);
    }
  }

  Future<bool> _verifyPurchase(PurchaseDetails purchase) async {
    // En una app de producción, deberías verificar con tu backend
    // Por ahora, confiamos en la verificación local
    return purchase.status == PurchaseStatus.purchased ||
           purchase.status == PurchaseStatus.restored;
  }

  Future<bool> buyPremium() async {
    if (!_isAvailable) {
      debugPrint('IAP no disponible');
      return false;
    }

    if (_products.isEmpty) {
      await _loadProducts();
    }

    final product = _products.firstWhere(
      (p) => p.id == premiumProductId,
      orElse: () => _products.isNotEmpty ? _products.first : throw Exception('No hay productos'),
    );

    final purchaseParam = PurchaseParam(productDetails: product);
    
    try {
      // Non-consumable para compra única permanente
      return await _iap.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      debugPrint('Error al comprar: $e');
      return false;
    }
  }

  Future<bool> restorePurchases() async {
    if (!_isAvailable) return false;

    try {
      await _iap.restorePurchases();
      
      // Esperar un momento para que se procesen las compras restauradas
      await Future.delayed(const Duration(seconds: 2));
      
      // Verificar si hay compras activas
      // En iOS/Android, el stream de compras se actualiza con las restauraciones
      return false; // El estado real se maneja en _onPurchaseUpdated
    } catch (e) {
      debugPrint('Error restaurando compras: $e');
      return false;
    }
  }

  void _onDone() {
    _subscription?.cancel();
  }

  void _onError(dynamic error) {
    debugPrint('Error en IAP stream: $error');
  }

  void dispose() {
    _subscription?.cancel();
  }

  // Precio formateado del producto premium
  String get premiumPrice {
    if (_products.isEmpty) return '\$6.99'; // Precio por defecto
    final product = _products.firstWhere(
      (p) => p.id == premiumProductId,
      orElse: () => _products.first,
    );
    return product.price;
  }
}

