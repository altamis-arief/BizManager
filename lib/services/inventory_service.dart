import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/inventory_movement_model.dart';

class InventoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _movementsCollection = 'inventory_movements';
  final String _alertsCollection = 'stock_alerts';

  // Record inventory movement
  Future<String> recordMovement(InventoryMovement movement) async {
    try {
      final docRef = await _firestore
          .collection(_movementsCollection)
          .add(movement.toMap());
      
      await docRef.update({'id': docRef.id});
      
      // Check if we need to create a stock alert
      await _checkAndCreateStockAlert(
        movement.productId,
        movement.productName,
        movement.newStock,
        movement.userId,
      );
      
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to record movement: $e');
    }
  }

  // Get all movements for a product
  Stream<List<InventoryMovement>> getProductMovements(String productId) {
    return _firestore
        .collection(_movementsCollection)
        .where('productId', isEqualTo: productId)
        .orderBy('movementDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => InventoryMovement.fromMap(doc.data()))
          .toList();
    });
  }

  // Get all movements for a specific user
  Stream<List<InventoryMovement>> getAllMovements(String userId) {
    return _firestore
        .collection(_movementsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('movementDate', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => InventoryMovement.fromMap(doc.data()))
          .toList();
    });
  }

  // Get movements by type for a specific user
  Stream<List<InventoryMovement>> getMovementsByType(String userId, MovementType type) {
    return _firestore
        .collection(_movementsCollection)
        .where('userId', isEqualTo: userId)
        .where('movementType', isEqualTo: type.toString().split('.').last)
        .orderBy('movementDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => InventoryMovement.fromMap(doc.data()))
          .toList();
    });
  }

  // Get movements by date range for a specific user
  Stream<List<InventoryMovement>> getMovementsByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) {
    return _firestore
        .collection(_movementsCollection)
        .where('userId', isEqualTo: userId)
        .where('movementDate', isGreaterThanOrEqualTo: startDate.toIso8601String())
        .where('movementDate', isLessThanOrEqualTo: endDate.toIso8601String())
        .orderBy('movementDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => InventoryMovement.fromMap(doc.data()))
          .toList();
    });
  }

  // Check and create stock alert
  Future<void> _checkAndCreateStockAlert(
    String productId,
    String productName,
    int currentStock,
    String userId,
  ) async {
    const int threshold = 10;
    
    if (currentStock <= threshold) {
      // Check if an unresolved alert already exists
      final existingAlerts = await _firestore
          .collection(_alertsCollection)
          .where('productId', isEqualTo: productId)
          .where('userId', isEqualTo: userId)
          .where('isResolved', isEqualTo: false)
          .get();

      if (existingAlerts.docs.isEmpty) {
        // Create new alert
        final alert = StockAlert(
          id: '',
          productId: productId,
          productName: productName,
          currentStock: currentStock,
          threshold: threshold,
          alertDate: DateTime.now(),
        );

        final alertMap = alert.toMap();
        alertMap['userId'] = userId; // Add userId to alert

        final docRef = await _firestore
            .collection(_alertsCollection)
            .add(alertMap);
        
        await docRef.update({'id': docRef.id});
      } else {
        // Update existing alert with new stock level
        await existingAlerts.docs.first.reference.update({
          'currentStock': currentStock,
          'alertDate': DateTime.now().toIso8601String(),
        });
      }
    } else {
      // Resolve any existing alerts for this product
      final existingAlerts = await _firestore
          .collection(_alertsCollection)
          .where('productId', isEqualTo: productId)
          .where('userId', isEqualTo: userId)
          .where('isResolved', isEqualTo: false)
          .get();

      for (var doc in existingAlerts.docs) {
        await doc.reference.update({'isResolved': true});
      }
    }
  }

  // Get active stock alerts for a specific user
  Stream<List<StockAlert>> getActiveAlerts(String userId) {
    return _firestore
        .collection(_alertsCollection)
        .where('userId', isEqualTo: userId)
        .where('isResolved', isEqualTo: false)
        .orderBy('alertDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => StockAlert.fromMap(doc.data()))
          .toList();
    });
  }

  // Get all stock alerts for a specific user
  Stream<List<StockAlert>> getAllAlerts(String userId) {
    return _firestore
        .collection(_alertsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('alertDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => StockAlert.fromMap(doc.data()))
          .toList();
    });
  }

  // Resolve stock alert
  Future<void> resolveAlert(String alertId) async {
    try {
      await _firestore
          .collection(_alertsCollection)
          .doc(alertId)
          .update({'isResolved': true});
    } catch (e) {
      throw Exception('Failed to resolve alert: $e');
    }
  }

  // Delete movement (for corrections)
  Future<void> deleteMovement(String movementId) async {
    try {
      await _firestore
          .collection(_movementsCollection)
          .doc(movementId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete movement: $e');
    }
  }

  // Get movement statistics for a specific user
  Future<Map<String, dynamic>> getMovementStats(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final movements = await _firestore
          .collection(_movementsCollection)
          .where('userId', isEqualTo: userId)
          .where('movementDate', isGreaterThanOrEqualTo: startDate.toIso8601String())
          .where('movementDate', isLessThanOrEqualTo: endDate.toIso8601String())
          .get();

      int stockIn = 0;
      int stockOut = 0;
      int adjustments = 0;
      int sales = 0;
      int returns = 0;

      for (var doc in movements.docs) {
        final data = doc.data();
        final type = data['movementType'];
        final quantity = data['quantity'] as int;

        switch (type) {
          case 'stockIn':
            stockIn += quantity;
            break;
          case 'stockOut':
            stockOut += quantity;
            break;
          case 'adjustment':
            adjustments += quantity.abs();
            break;
          case 'sale':
            sales += quantity;
            break;
          case 'return_':
            returns += quantity;
            break;
        }
      }

      return {
        'totalMovements': movements.docs.length,
        'stockIn': stockIn,
        'stockOut': stockOut,
        'adjustments': adjustments,
        'sales': sales,
        'returns': returns,
      };
    } catch (e) {
      throw Exception('Failed to get movement stats: $e');
    }
  }
}