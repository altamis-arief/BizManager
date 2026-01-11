class SalesTransaction {
  final String id;
  final String userId;
  final List<SalesItem> items;
  final double totalAmount;
  final double totalCost; // Add total cost
  final double discount;
  final double finalAmount;
  final String paymentMethod;
  final DateTime transactionDate;
  final String? notes;

  SalesTransaction({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.totalCost, // Add total cost
    this.discount = 0.0,
    required this.finalAmount,
    required this.paymentMethod,
    required this.transactionDate,
    this.notes,
  });

  // Calculate actual profit (revenue - cost)
  double get actualProfit {
    return finalAmount - totalCost;
  }

  // Calculate profit margin percentage
  double get profitMargin {
    if (finalAmount == 0) return 0;
    return (actualProfit / finalAmount) * 100;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'items': items.map((item) => item.toMap()).toList(),
      'totalAmount': totalAmount,
      'totalCost': totalCost, // Add total cost
      'discount': discount,
      'finalAmount': finalAmount,
      'paymentMethod': paymentMethod,
      'transactionDate': transactionDate.toIso8601String(),
      'notes': notes,
    };
  }

  factory SalesTransaction.fromMap(Map<String, dynamic> map) {
    return SalesTransaction(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      items: (map['items'] as List<dynamic>)
          .map((item) => SalesItem.fromMap(item as Map<String, dynamic>))
          .toList(),
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      totalCost: (map['totalCost'] ?? 0).toDouble(), // Add total cost
      discount: (map['discount'] ?? 0).toDouble(),
      finalAmount: (map['finalAmount'] ?? 0).toDouble(),
      paymentMethod: map['paymentMethod'] ?? '',
      transactionDate: DateTime.parse(map['transactionDate']),
      notes: map['notes'],
    );
  }

  SalesTransaction copyWith({
    String? id,
    String? userId,
    List<SalesItem>? items,
    double? totalAmount,
    double? totalCost,
    double? discount,
    double? finalAmount,
    String? paymentMethod,
    DateTime? transactionDate,
    String? notes,
  }) {
    return SalesTransaction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      totalCost: totalCost ?? this.totalCost,
      discount: discount ?? this.discount,
      finalAmount: finalAmount ?? this.finalAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      transactionDate: transactionDate ?? this.transactionDate,
      notes: notes ?? this.notes,
    );
  }
}

class SalesItem {
  final String productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double unitCost; // Add unit cost
  final double totalPrice;
  final double totalCost; // Add total cost

  SalesItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.unitCost, // Add unit cost
    required this.totalPrice,
    required this.totalCost, // Add total cost
  });

  // Calculate profit for this item
  double get profit {
    return totalPrice - totalCost;
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'unitCost': unitCost, // Add unit cost
      'totalPrice': totalPrice,
      'totalCost': totalCost, // Add total cost
    };
  }

  factory SalesItem.fromMap(Map<String, dynamic> map) {
    return SalesItem(
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      quantity: map['quantity'] ?? 0,
      unitPrice: (map['unitPrice'] ?? 0).toDouble(),
      unitCost: (map['unitCost'] ?? 0).toDouble(), // Add unit cost
      totalPrice: (map['totalPrice'] ?? 0).toDouble(),
      totalCost: (map['totalCost'] ?? 0).toDouble(), // Add total cost
    );
  }
}