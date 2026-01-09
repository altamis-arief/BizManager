class SalesTransaction {
  final String id;
  final String userId;
  final List<SalesItem> items;
  final double totalAmount;
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
    this.discount = 0.0,
    required this.finalAmount,
    required this.paymentMethod,
    required this.transactionDate,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'items': items.map((item) => item.toMap()).toList(),
      'totalAmount': totalAmount,
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
  final double totalPrice;

  SalesItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
    };
  }

  factory SalesItem.fromMap(Map<String, dynamic> map) {
    return SalesItem(
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      quantity: map['quantity'] ?? 0,
      unitPrice: (map['unitPrice'] ?? 0).toDouble(),
      totalPrice: (map['totalPrice'] ?? 0).toDouble(),
    );
  }
}