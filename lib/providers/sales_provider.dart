import 'package:flutter/foundation.dart';
import '../models/sale_transaction_model.dart';
import '../models/product.dart';
import '../models/inventory_movement_model.dart';
import '../services/sales_service.dart';
import '../services/product_service.dart';
import '../services/inventory_service.dart';
import '../services/auth_service.dart';

class SalesProvider with ChangeNotifier {
  final SalesService _salesService = SalesService();
  final ProductService _productService = ProductService();
  final InventoryService _inventoryService = InventoryService();
  final AuthService _authService = AuthService();

  List<SalesTransaction> _transactions = [];
  List<SalesItem> _cartItems = [];
  bool _isLoading = false;
  String _errorMessage = '';
  double _discount = 0.0;
  String _selectedPaymentMethod = 'Cash';

  // Getters
  List<SalesTransaction> get transactions => _transactions;
  List<SalesItem> get cartItems => _cartItems;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  double get discount => _discount;
  String get selectedPaymentMethod => _selectedPaymentMethod;

  double get subtotal {
    return _cartItems.fold(0, (sum, item) => sum + item.totalPrice);
  }

  double get total {
    return subtotal - _discount;
  }

  int get totalItems {
    return _cartItems.fold(0, (sum, item) => sum + item.quantity);
  }

  // Payment methods
  final List<String> paymentMethods = [
    'Cash',
    'Card',
    'E-Wallet',
    'Bank Transfer',
  ];

  // Load all transactions
  void loadTransactions() {
    _isLoading = true;
    notifyListeners();

    _salesService.getAllSalesTransactions().listen(
      (transactionList) {
        _transactions = transactionList;
        _isLoading = false;
        _errorMessage = '';
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = 'Failed to load transactions: $error';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // Add item to cart
Future<bool> addToCart(Product product, int quantity) async {
  if (quantity <= 0) {
    _errorMessage = 'Quantity must be greater than 0';
    notifyListeners();
    return false;
  }

  if (quantity > product.stock) {
    _errorMessage = 'Insufficient stock. Available: ${product.stock}';
    notifyListeners();
    return false;
  }

  // Check if product already in cart
  final existingIndex = _cartItems.indexWhere(
    (item) => item.productId == product.id
  );

  if (existingIndex != -1) {
    // Update quantity
    final newQuantity = _cartItems[existingIndex].quantity + quantity;
    
    if (newQuantity > product.stock) {
      _errorMessage = 'Total quantity exceeds stock. Available: ${product.stock}';
      notifyListeners();
      return false;
    }

    _cartItems[existingIndex] = SalesItem(
      productId: product.id,
      productName: product.name,
      quantity: newQuantity,
      unitPrice: product.price,
      unitCost: product.cost, // Add unit cost
      totalPrice: product.price * newQuantity,
      totalCost: product.cost * newQuantity, // Add total cost
    );
  } else {
    // Add new item
    _cartItems.add(SalesItem(
      productId: product.id,
      productName: product.name,
      quantity: quantity,
      unitPrice: product.price,
      unitCost: product.cost, // Add unit cost
      totalPrice: product.price * quantity,
      totalCost: product.cost * quantity, // Add total cost
    ));
  }

  _errorMessage = '';
  notifyListeners();
  return true;
}

  // Update cart item quantity
bool updateCartItemQuantity(String productId, int newQuantity) {
  final index = _cartItems.indexWhere((item) => item.productId == productId);
  
  if (index == -1) return false;

  if (newQuantity <= 0) {
    _cartItems.removeAt(index);
  } else {
    final item = _cartItems[index];
    _cartItems[index] = SalesItem(
      productId: item.productId,
      productName: item.productName,
      quantity: newQuantity,
      unitPrice: item.unitPrice,
      unitCost: item.unitCost, // Preserve unit cost
      totalPrice: item.unitPrice * newQuantity,
      totalCost: item.unitCost * newQuantity, // Update total cost
    );
  }

  notifyListeners();
  return true;
}

// Add getter for total cost
double get totalCost {
  return _cartItems.fold(0, (sum, item) => sum + item.totalCost);
}

// Add getter for expected profit
double get expectedProfit {
  return subtotal - totalCost;
}


  // Remove item from cart
  void removeFromCart(String productId) {
    _cartItems.removeWhere((item) => item.productId == productId);
    notifyListeners();
  }

  // Clear cart
  void clearCart() {
    _cartItems.clear();
    _discount = 0.0;
    _selectedPaymentMethod = 'Cash';
    notifyListeners();
  }

  // Set discount
  void setDiscount(double value) {
    _discount = value;
    notifyListeners();
  }

  // Set payment method
  void setPaymentMethod(String method) {
    _selectedPaymentMethod = method;
    notifyListeners();
  }

  // Process sale
Future<bool> processSale({String? notes}) async {
  if (_cartItems.isEmpty) {
    _errorMessage = 'Cart is empty';
    notifyListeners();
    return false;
  }

  final userId = _authService.currentUser?.uid;
  if (userId == null) {
    _errorMessage = 'User not authenticated';
    notifyListeners();
    return false;
  }

  try {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    // Create sales transaction with cost tracking
    final transaction = SalesTransaction(
      id: '',
      userId: userId,
      items: _cartItems,
      totalAmount: subtotal,
      totalCost: totalCost, // Add total cost
      discount: _discount,
      finalAmount: total,
      paymentMethod: _selectedPaymentMethod,
      transactionDate: DateTime.now(),
      notes: notes,
    );

    final transactionId = await _salesService.createSalesTransaction(transaction);

    // Update stock levels and record inventory movements
    for (var item in _cartItems) {
      final product = await _productService.getProductById(item.productId);
      
      if (product != null) {
        final newStock = product.stock - item.quantity;
        await _productService.updateStock(item.productId, newStock);

        // Record inventory movement
        final movement = InventoryMovement(
          id: '',
          productId: item.productId,
          productName: item.productName,
          movementType: MovementType.sale,
          quantity: item.quantity,
          previousStock: product.stock,
          newStock: newStock,
          userId: userId,
          movementDate: DateTime.now(),
          notes: 'Sale transaction',
          referenceId: transactionId,
        );

        await _inventoryService.recordMovement(movement);
      }
    }

    // Clear cart after successful sale
    clearCart();

    _isLoading = false;
    notifyListeners();
    return true;
  } catch (e) {
    _errorMessage = 'Failed to process sale: $e';
    _isLoading = false;
    notifyListeners();
    return false;
  }
}

  // Get sales statistics
  Future<Map<String, dynamic>?> getSalesStats(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      return await _salesService.getSalesStats(startDate, endDate);
    } catch (e) {
      _errorMessage = 'Failed to get sales stats: $e';
      notifyListeners();
      return null;
    }
  }

  // Get top selling products
  Future<List<Map<String, dynamic>>> getTopSellingProducts(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      return await _salesService.getTopSellingProducts(startDate, endDate);
    } catch (e) {
      _errorMessage = 'Failed to get top selling products: $e';
      notifyListeners();
      return [];
    }
  }

  // Get today's sales stream
  Stream<List<SalesTransaction>> getTodaySales() {
    return _salesService.getTodaySales();
  }

  // Get sales by date range stream
  Stream<List<SalesTransaction>> getSalesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) {
    return _salesService.getSalesTransactionsByDateRange(startDate, endDate);
  }

  // Clear error
  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}