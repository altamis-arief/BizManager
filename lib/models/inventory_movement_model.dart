enum MovementType {
  stockIn,
  stockOut,
  adjustment,
  sale,
  return_,
}

class InventoryMovement {
  final String id;
  final String productId;
  final String productName;
  final MovementType movementType;
  final int quantity;
  final int previousStock;
  final int newStock;
  final String userId;
  final DateTime movementDate;
  final String? notes;
  final String? referenceId; // Reference to sale or other transaction

  InventoryMovement({
    required this.id,
    required this.productId,
    required this.productName,
    required this.movementType,
    required this.quantity,
    required this.previousStock,
    required this.newStock,
    required this.userId,
    required this.movementDate,
    this.notes,
    this.referenceId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'movementType': movementType.toString().split('.').last,
      'quantity': quantity,
      'previousStock': previousStock,
      'newStock': newStock,
      'userId': userId,
      'movementDate': movementDate.toIso8601String(),
      'notes': notes,
      'referenceId': referenceId,
    };
  }

  factory InventoryMovement.fromMap(Map<String, dynamic> map) {
    return InventoryMovement(
      id: map['id'] ?? '',
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      movementType: MovementType.values.firstWhere(
        (e) => e.toString().split('.').last == map['movementType'],
        orElse: () => MovementType.adjustment,
      ),
      quantity: map['quantity'] ?? 0,
      previousStock: map['previousStock'] ?? 0,
      newStock: map['newStock'] ?? 0,
      userId: map['userId'] ?? '',
      movementDate: DateTime.parse(map['movementDate']),
      notes: map['notes'],
      referenceId: map['referenceId'],
    );
  }

  String get movementTypeLabel {
    switch (movementType) {
      case MovementType.stockIn:
        return 'Stock In';
      case MovementType.stockOut:
        return 'Stock Out';
      case MovementType.adjustment:
        return 'Adjustment';
      case MovementType.sale:
        return 'Sale';
      case MovementType.return_:
        return 'Return';
    }
  }
}

class StockAlert {
  final String id;
  final String productId;
  final String productName;
  final int currentStock;
  final int threshold;
  final DateTime alertDate;
  final bool isResolved;

  StockAlert({
    required this.id,
    required this.productId,
    required this.productName,
    required this.currentStock,
    required this.threshold,
    required this.alertDate,
    this.isResolved = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'currentStock': currentStock,
      'threshold': threshold,
      'alertDate': alertDate.toIso8601String(),
      'isResolved': isResolved,
    };
  }

  factory StockAlert.fromMap(Map<String, dynamic> map) {
    return StockAlert(
      id: map['id'] ?? '',
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      currentStock: map['currentStock'] ?? 0,
      threshold: map['threshold'] ?? 0,
      alertDate: DateTime.parse(map['alertDate']),
      isResolved: map['isResolved'] ?? false,
    );
  }
}