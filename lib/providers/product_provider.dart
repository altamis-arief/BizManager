import 'package:flutter/foundation.dart';
import 'dart:io';
import '../models/product.dart';
import '../models/inventory_movement_model.dart';
import '../services/product_service.dart';
import '../services/inventory_service.dart';
import '../services/auth_service.dart';

class ProductProvider with ChangeNotifier {
  final ProductService _productService = ProductService();
  final InventoryService _inventoryService = InventoryService();
  final AuthService _authService = AuthService();
  
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = false;
  String _errorMessage = '';
  String _selectedCategory = 'All';
  String _searchQuery = '';

  // Getters
  List<Product> get products => _filteredProducts;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  // Categories list
  final List<String> categories = [
    'All',
    'Electronics',
    'Clothing',
    'Food & Beverages',
    'Books',
    'Home & Garden',
    'Sports',
    'Toys',
    'Health & Beauty',
    'Automotive',
    'Others',
  ];

  // Initialize and load products
  void loadProducts() {
    _isLoading = true;
    notifyListeners();

    _productService.getActiveProducts().listen(
      (productList) {
        _products = productList;
        _applyFilters();
        _isLoading = false;
        _errorMessage = '';
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = 'Failed to load products: $error';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // Apply category and search filters
  void _applyFilters() {
    _filteredProducts = _products.where((product) {
      final matchesCategory = _selectedCategory == 'All' || product.category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty || 
          product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          product.description.toLowerCase().contains(_searchQuery.toLowerCase());
      
      return matchesCategory && matchesSearch;
    }).toList();
  }

  // Set category filter
  void setCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  // Set search query
  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  // Create product
  Future<bool> createProduct({
    required String name,
    required String description,
    required double price,
    required int stock,
    required String category,
    File? imageFile,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();

      String? imageUrl;
      
      // Create product first to get ID
      final tempProduct = Product(
        id: '',
        name: name,
        description: description,
        price: price,
        stock: stock,
        category: category,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final productId = await _productService.createProduct(tempProduct);

      // Upload image if provided
      if (imageFile != null) {
        imageUrl = await _productService.uploadProductImage(imageFile, productId);
        
        // Update product with image URL
        final updatedProduct = tempProduct.copyWith(
          id: productId,
          imageUrl: imageUrl,
        );
        await _productService.updateProduct(updatedProduct);
      }

      // Record initial stock as inventory movement
      if (stock > 0) {
        await _recordInventoryMovement(
          productId: productId,
          productName: name,
          movementType: MovementType.stockIn,
          quantity: stock,
          previousStock: 0,
          newStock: stock,
          notes: 'Initial stock on product creation',
        );
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to create product: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update product
  Future<bool> updateProduct({
    required String id,
    required String name,
    required String description,
    required double price,
    required int stock,
    required String category,
    String? existingImageUrl,
    File? newImageFile,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();

      String? imageUrl = existingImageUrl;

      // Upload new image if provided
      if (newImageFile != null) {
        // Delete old image if exists
        if (existingImageUrl != null && existingImageUrl.isNotEmpty) {
          await _productService.deleteImageFromStorage(existingImageUrl);
        }
        
        imageUrl = await _productService.uploadProductImage(newImageFile, id);
      }

      final product = Product(
        id: id,
        name: name,
        description: description,
        price: price,
        stock: stock,
        category: category,
        imageUrl: imageUrl,
        createdAt: DateTime.now(), // Will be preserved from original
        updatedAt: DateTime.now(),
      );

      await _productService.updateProduct(product);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update product: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Delete product
  Future<bool> deleteProduct(String id) async {
    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();

      await _productService.deleteProduct(id);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete product: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update stock with automatic inventory tracking
  Future<bool> updateStock(String id, int newStock) async {
    try {
      // Get current product to know previous stock
      final product = await _productService.getProductById(id);
      if (product == null) {
        _errorMessage = 'Product not found';
        notifyListeners();
        return false;
      }

      final previousStock = product.stock;
      final difference = newStock - previousStock;

      // Update the stock
      await _productService.updateStock(id, newStock);

      // Determine movement type and record inventory movement
      MovementType movementType;
      if (difference > 0) {
        movementType = MovementType.stockIn;
      } else if (difference < 0) {
        movementType = MovementType.stockOut;
      } else {
        return true; // No change, no need to record
      }

      await _recordInventoryMovement(
        productId: id,
        productName: product.name,
        movementType: movementType,
        quantity: difference.abs(),
        previousStock: previousStock,
        newStock: newStock,
        notes: 'Manual stock adjustment',
      );

      return true;
    } catch (e) {
      _errorMessage = 'Failed to update stock: $e';
      notifyListeners();
      return false;
    }
  }

  // Record inventory movement helper
  Future<void> _recordInventoryMovement({
    required String productId,
    required String productName,
    required MovementType movementType,
    required int quantity,
    required int previousStock,
    required int newStock,
    String? notes,
    String? referenceId,
  }) async {
    final userId = _authService.currentUser?.uid ?? 'unknown';

    final movement = InventoryMovement(
      id: '',
      productId: productId,
      productName: productName,
      movementType: movementType,
      quantity: quantity,
      previousStock: previousStock,
      newStock: newStock,
      userId: userId,
      movementDate: DateTime.now(),
      notes: notes,
      referenceId: referenceId,
    );

    await _inventoryService.recordMovement(movement);
  }

  // Get product by ID
  Future<Product?> getProductById(String id) async {
    try {
      return await _productService.getProductById(id);
    } catch (e) {
      _errorMessage = 'Failed to get product: $e';
      notifyListeners();
      return null;
    }
  }

  // Get low stock products
  List<Product> getLowStockProducts(int threshold) {
    return _products.where((product) => product.stock <= threshold).toList();
  }

  // Clear error message
  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}