import 'package:flutter/foundation.dart';
import '../models/inventory_movement_model.dart';
import '../services/inventory_service.dart';
import '../services/auth_service.dart';

class InventoryProvider with ChangeNotifier {
  final InventoryService _inventoryService = InventoryService();
  final AuthService _authService = AuthService();
  
  List<InventoryMovement> _movements = [];
  List<StockAlert> _activeAlerts = [];
  bool _isLoading = false;
  String _errorMessage = '';

  // Getters
  List<InventoryMovement> get movements => _movements;
  List<StockAlert> get activeAlerts => _activeAlerts;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  int get alertCount => _activeAlerts.length;

  // Load all movements for current user
  void loadMovements() {
    final userId = _authService.currentUser?.uid;
    if (userId == null) {
      _errorMessage = 'User not authenticated';
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    _inventoryService.getAllMovements(userId).listen(
      (movementList) {
        _movements = movementList;
        _isLoading = false;
        _errorMessage = '';
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = 'Failed to load movements: $error';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // Load active alerts for current user
  void loadActiveAlerts() {
    final userId = _authService.currentUser?.uid;
    if (userId == null) {
      _errorMessage = 'User not authenticated';
      notifyListeners();
      return;
    }

    _inventoryService.getActiveAlerts(userId).listen(
      (alertList) {
        _activeAlerts = alertList;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = 'Failed to load alerts: $error';
        notifyListeners();
      },
    );
  }

  // Record inventory movement
  Future<bool> recordMovement({
    required String productId,
    required String productName,
    required MovementType movementType,
    required int quantity,
    required int previousStock,
    required int newStock,
    required String userId,
    String? notes,
    String? referenceId,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();

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

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to record movement: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Get movements for a specific product
  Stream<List<InventoryMovement>> getProductMovements(String productId) {
    return _inventoryService.getProductMovements(productId);
  }

  // Get movements by type for current user
  Stream<List<InventoryMovement>> getMovementsByType(MovementType type) {
    final userId = _authService.currentUser?.uid;
    if (userId == null) {
      return Stream.value([]);
    }
    return _inventoryService.getMovementsByType(userId, type);
  }

  // Resolve alert
  Future<bool> resolveAlert(String alertId) async {
    try {
      await _inventoryService.resolveAlert(alertId);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to resolve alert: $e';
      notifyListeners();
      return false;
    }
  }

  // Get movement statistics for current user
  Future<Map<String, dynamic>?> getMovementStats(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final userId = _authService.currentUser?.uid;
    if (userId == null) {
      _errorMessage = 'User not authenticated';
      notifyListeners();
      return null;
    }

    try {
      return await _inventoryService.getMovementStats(userId, startDate, endDate);
    } catch (e) {
      _errorMessage = 'Failed to get stats: $e';
      notifyListeners();
      return null;
    }
  }

  // Get all alerts stream for current user
  Stream<List<StockAlert>> getAllAlerts() {
    final userId = _authService.currentUser?.uid;
    if (userId == null) {
      return Stream.value([]);
    }
    return _inventoryService.getAllAlerts(userId);
  }

  // Clear error
  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}