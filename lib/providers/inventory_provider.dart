import 'package:flutter/foundation.dart';
import '../models/inventory_movement_model.dart';
import '../services/inventory_service.dart';

class InventoryProvider with ChangeNotifier {
  final InventoryService _inventoryService = InventoryService();
  
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

  // Load all movements
  void loadMovements() {
    _isLoading = true;
    notifyListeners();

    _inventoryService.getAllMovements().listen(
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

  // Load active alerts
  void loadActiveAlerts() {
    _inventoryService.getActiveAlerts().listen(
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

  // Get movements by type
  Stream<List<InventoryMovement>> getMovementsByType(MovementType type) {
    return _inventoryService.getMovementsByType(type);
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

  // Get movement statistics
  Future<Map<String, dynamic>?> getMovementStats(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      return await _inventoryService.getMovementStats(startDate, endDate);
    } catch (e) {
      _errorMessage = 'Failed to get stats: $e';
      notifyListeners();
      return null;
    }
  }

  // Get all alerts stream
  Stream<List<StockAlert>> getAllAlerts() {
    return _inventoryService.getAllAlerts();
  }

  // Clear error
  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}