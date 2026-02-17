import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class PurchaseService {
  PurchaseService._();
  static final PurchaseService instance = PurchaseService._();

  final InAppPurchase _iap = InAppPurchase.instance;

  // ID del producto
  static const String premiumProductId = 'pro_version';

  static const Set<String> _productIds = {
    premiumProductId,
  };

  StreamSubscription<List<PurchaseDetails>>? _subscription;
  List<ProductDetails> _products = [];

  bool _isAvailable = false;
  bool _restoredPurchaseFound = false;
  void Function(bool success)? _onPurchaseComplete;

  bool get isAvailable => _isAvailable;
  List<ProductDetails> get products => _products;

  /// Inicializar IAP
  Future<void> initialize({void Function(bool success)? onPurchaseComplete}) async {
    _onPurchaseComplete = onPurchaseComplete;
    _isAvailable = await _iap.isAvailable();
    if (!_isAvailable) {
      debugPrint('IAP no disponible');
      return;
    }

    _subscription = _iap.purchaseStream.listen(
      _onPurchaseUpdated,
      onDone: _onDone,
      onError: _onError,
    );

    await _loadProducts();
  }

  /// Cargar productos
  Future<void> _loadProducts() async {
    final response = await _iap.queryProductDetails(_productIds);

    if (response.notFoundIDs.isNotEmpty) {
      debugPrint('Productos no encontrados: ${response.notFoundIDs}');
    }

    _products = response.productDetails;
    debugPrint('Productos cargados: ${_products.length}');
  }

  /// COMPRA (SOLO COMPRA)
  Future<bool> buyPremium() async {
    if (!_isAvailable) return false;

    if (_products.isEmpty) {
      await _loadProducts();
    }

    final product = _products.firstWhere(
      (p) => p.id == premiumProductId,
      orElse: () => throw Exception('Producto no encontrado'),
    );

    final purchaseParam = PurchaseParam(productDetails: product);

    try {
      await _iap.buyNonConsumable(purchaseParam: purchaseParam);
      return true;
    } catch (e) {
      debugPrint('Error al comprar: $e');
      return false;
    }
  }

  /// RESTAURAR (SOLO RESTAURAR)
  Future<bool> restorePurchases() async {
    if (!_isAvailable) return false;

    _restoredPurchaseFound = false;

    await _iap.restorePurchases();

    await Future.delayed(const Duration(seconds: 3));

    return _restoredPurchaseFound;
  }

  /// Listener de compras
  void _onPurchaseUpdated(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased || purchase.status == PurchaseStatus.restored) {
        if (purchase.productID == premiumProductId) {
          _restoredPurchaseFound = true;
          _onPurchaseComplete?.call(true);
        }
      }

      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
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

  /// Precio formateado
  String get premiumPrice {
    if (_products.isEmpty) return '\$6.99';
    return _products.first.price;
  }
}
