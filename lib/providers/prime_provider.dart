import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrimeProvider extends ChangeNotifier {
  static const String _primeKey = 'is_prime_member';
  // The Product ID must match exactly what you will create in Google Play Console
  static const String _productId = 'winit_prime_no_ads';

  bool _isPrime = false;
  bool get isPrime => _isPrime;

  final InAppPurchase _iap = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  List<ProductDetails> _products = [];
  List<ProductDetails> get products => _products;

  bool _isAvailable = false;
  bool get isAvailable => _isAvailable;

  String? _statusMessage;
  String? get statusMessage => _statusMessage;

  PrimeProvider() {
    _loadPrimeStatus();
    _initializeIAP();
  }

  Future<void> _loadPrimeStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isPrime = prefs.getBool(_primeKey) ?? false;
    notifyListeners();
  }

  Future<void> _initializeIAP() async {
    _isAvailable = await _iap.isAvailable();
    if (!_isAvailable) {
      _statusMessage = "Store not available";
      notifyListeners();
      return;
    }

    // Listen to purchase updates
    final purchaseUpdated = _iap.purchaseStream;
    _subscription = purchaseUpdated.listen((purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription.cancel();
    }, onError: (error) {
      // handle error here.
      _statusMessage = "Store Error: $error";
      notifyListeners();
    });

    // Load products
    await _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      const Set<String> _kIds = <String>{_productId};
      final ProductDetailsResponse response = await _iap.queryProductDetails(_kIds);
      if (response.notFoundIDs.isNotEmpty) {
        _statusMessage = "ID not found in Play Store: $_productId";
        print('Product ID not found: ${response.notFoundIDs}');
      } else if (response.productDetails.isEmpty) {
        _statusMessage = "No products found (check Play Console configuration)";
      }
      _products = response.productDetails;
      notifyListeners();
    } catch (e) {
      _statusMessage = "Error loading products: $e";
      notifyListeners();
    }
  }

  Future<void> buyPrime() async {
    if (_products.isEmpty) {
      // Try reloading
      await _loadProducts();
      if (_products.isEmpty) {
        _statusMessage = "Product not found in store";
        notifyListeners();
        return;
      }
    }

    final ProductDetails productDetails = _products.firstWhere((p) => p.id == _productId);
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: productDetails);
    
    // For non-consumables (One-time purchase)
    _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  Future<void> restorePurchases() async {
    await _iap.restorePurchases();
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        // Show pending UI if needed
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          _statusMessage = "Purchase Error: ${purchaseDetails.error?.message}";
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
                   purchaseDetails.status == PurchaseStatus.restored) {
          
          await _verifyPurchase(purchaseDetails);
        }
        
        if (purchaseDetails.pendingCompletePurchase) {
          await _iap.completePurchase(purchaseDetails);
        }
        notifyListeners();
      }
    });
  }

  Future<void> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    // In a real backend app, you verify the receipt with your server here.
    // For this app, we trust Google Play's success response.
    if (purchaseDetails.productID == _productId) {
      await enablePrime();
      _statusMessage = null; 
    }
  }

  Future<void> enablePrime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_primeKey, true);
    _isPrime = true;
    notifyListeners();
  }

  Future<void> disablePrime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_primeKey, false);
    _isPrime = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
