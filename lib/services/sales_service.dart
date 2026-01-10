import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/sale_transaction_model.dart';
import '../models/product.dart';

class SalesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _salesCollection = 'sales_transactions';

  // Create a new sales transaction
  Future<String> createSalesTransaction(SalesTransaction transaction) async {
    try {
      final docRef = await _firestore
          .collection(_salesCollection)
          .add(transaction.toMap());
      
      await docRef.update({'id': docRef.id});
      
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create sales transaction: $e');
    }
  }

  // Get all sales transactions
  Stream<List<SalesTransaction>> getAllSalesTransactions() {
    return _firestore
        .collection(_salesCollection)
        .orderBy('transactionDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => SalesTransaction.fromMap(doc.data()))
          .toList();
    });
  }

  // Get sales transactions by date range
  Stream<List<SalesTransaction>> getSalesTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) {
    return _firestore
        .collection(_salesCollection)
        .where('transactionDate', 
          isGreaterThanOrEqualTo: startDate.toIso8601String())
        .where('transactionDate', 
          isLessThanOrEqualTo: endDate.toIso8601String())
        .orderBy('transactionDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => SalesTransaction.fromMap(doc.data()))
          .toList();
    });
  }

  // Get sales transaction by ID
  Future<SalesTransaction?> getSalesTransactionById(String id) async {
    try {
      final doc = await _firestore
          .collection(_salesCollection)
          .doc(id)
          .get();
      
      if (doc.exists) {
        return SalesTransaction.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get sales transaction: $e');
    }
  }

  // Get today's sales
  Stream<List<SalesTransaction>> getTodaySales() {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);
    
    return getSalesTransactionsByDateRange(startOfDay, endOfDay);
  }

  // Calculate sales statistics
  Future<Map<String, dynamic>> getSalesStats(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final snapshot = await _firestore
          .collection(_salesCollection)
          .where('transactionDate', 
            isGreaterThanOrEqualTo: startDate.toIso8601String())
          .where('transactionDate', 
            isLessThanOrEqualTo: endDate.toIso8601String())
          .get();

      double totalRevenue = 0;
      double totalDiscount = 0;
      int totalTransactions = snapshot.docs.length;
      int totalItemsSold = 0;
      Map<String, int> paymentMethods = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        totalRevenue += (data['finalAmount'] ?? 0).toDouble();
        totalDiscount += (data['discount'] ?? 0).toDouble();
        
        final items = data['items'] as List<dynamic>;
        for (var item in items) {
          totalItemsSold += (item['quantity'] ?? 0) as int;
        }

        final method = data['paymentMethod'] ?? 'Unknown';
        paymentMethods[method] = (paymentMethods[method] ?? 0) + 1;
      }

      return {
        'totalRevenue': totalRevenue,
        'totalDiscount': totalDiscount,
        'totalTransactions': totalTransactions,
        'totalItemsSold': totalItemsSold,
        'averageTransactionValue': 
          totalTransactions > 0 ? totalRevenue / totalTransactions : 0,
        'paymentMethods': paymentMethods,
      };
    } catch (e) {
      throw Exception('Failed to calculate sales stats: $e');
    }
  }

  // Get top selling products
  Future<List<Map<String, dynamic>>> getTopSellingProducts(
    DateTime startDate,
    DateTime endDate,
    {int limit = 10}
  ) async {
    try {
      final snapshot = await _firestore
          .collection(_salesCollection)
          .where('transactionDate', 
            isGreaterThanOrEqualTo: startDate.toIso8601String())
          .where('transactionDate', 
            isLessThanOrEqualTo: endDate.toIso8601String())
          .get();

      Map<String, Map<String, dynamic>> productSales = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final items = data['items'] as List<dynamic>;
        
        for (var item in items) {
          final productId = item['productId'];
          final productName = item['productName'];
          final quantity = item['quantity'] as int;
          final totalPrice = (item['totalPrice'] ?? 0).toDouble();

          if (productSales.containsKey(productId)) {
            productSales[productId]!['quantity'] += quantity;
            productSales[productId]!['revenue'] += totalPrice;
          } else {
            productSales[productId] = {
              'productId': productId,
              'productName': productName,
              'quantity': quantity,
              'revenue': totalPrice,
            };
          }
        }
      }

      List<Map<String, dynamic>> topProducts = productSales.values.toList();
      topProducts.sort((a, b) => b['quantity'].compareTo(a['quantity']));
      
      return topProducts.take(limit).toList();
    } catch (e) {
      throw Exception('Failed to get top selling products: $e');
    }
  }

  // Delete sales transaction
  Future<void> deleteSalesTransaction(String id) async {
    try {
      await _firestore.collection(_salesCollection).doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete sales transaction: $e');
    }
  }
}