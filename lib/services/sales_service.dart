import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/sale_transaction_model.dart';

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

  // Get all sales transactions for a specific user
  Stream<List<SalesTransaction>> getAllSalesTransactions(String userId) {
    return _firestore
        .collection(_salesCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('transactionDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => SalesTransaction.fromMap(doc.data()))
          .toList();
    });
  }

  // Get sales transactions by date range for a specific user
  Stream<List<SalesTransaction>> getSalesTransactionsByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) {
    return _firestore
        .collection(_salesCollection)
        .where('userId', isEqualTo: userId)
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

  // Get today's sales for a specific user
  Stream<List<SalesTransaction>> getTodaySales(String userId) {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);
    
    return getSalesTransactionsByDateRange(userId, startOfDay, endOfDay);
  }

  // Calculate sales statistics for a specific user with profit tracking
  Future<Map<String, dynamic>> getSalesStats(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final snapshot = await _firestore
          .collection(_salesCollection)
          .where('userId', isEqualTo: userId)
          .where('transactionDate', 
            isGreaterThanOrEqualTo: startDate.toIso8601String())
          .where('transactionDate', 
            isLessThanOrEqualTo: endDate.toIso8601String())
          .get();

      double totalRevenue = 0;
      double totalCost = 0;
      double totalDiscount = 0;
      int totalTransactions = snapshot.docs.length;
      int totalItemsSold = 0;
      Map<String, int> paymentMethods = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        totalRevenue += (data['finalAmount'] ?? 0).toDouble();
        totalCost += (data['totalCost'] ?? 0).toDouble();
        totalDiscount += (data['discount'] ?? 0).toDouble();
        
        final items = data['items'] as List<dynamic>;
        for (var item in items) {
          totalItemsSold += (item['quantity'] ?? 0) as int;
        }

        final method = data['paymentMethod'] ?? 'Unknown';
        paymentMethods[method] = (paymentMethods[method] ?? 0) + 1;
      }

      final actualProfit = totalRevenue - totalCost;
      final profitMargin = totalRevenue > 0 ? (actualProfit / totalRevenue) * 100 : 0;

      return {
        'totalRevenue': totalRevenue,
        'totalCost': totalCost,
        'actualProfit': actualProfit,
        'profitMargin': profitMargin,
        'totalDiscount': totalDiscount,
        'totalTransactions': totalTransactions,
        'totalItemsSold': totalItemsSold,
        'averageTransactionValue': 
          totalTransactions > 0 ? totalRevenue / totalTransactions : 0,
        'averageProfit':
          totalTransactions > 0 ? actualProfit / totalTransactions : 0,
        'paymentMethods': paymentMethods,
      };
    } catch (e) {
      throw Exception('Failed to calculate sales stats: $e');
    }
  }

  // Get top selling products for a specific user with profit data
  Future<List<Map<String, dynamic>>> getTopSellingProducts(
    String userId,
    DateTime startDate,
    DateTime endDate,
    {int limit = 10}
  ) async {
    try {
      final snapshot = await _firestore
          .collection(_salesCollection)
          .where('userId', isEqualTo: userId)
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
          final totalCost = (item['totalCost'] ?? 0).toDouble();
          final profit = totalPrice - totalCost;

          if (productSales.containsKey(productId)) {
            productSales[productId]!['quantity'] += quantity;
            productSales[productId]!['revenue'] += totalPrice;
            productSales[productId]!['cost'] += totalCost;
            productSales[productId]!['profit'] += profit;
          } else {
            productSales[productId] = {
              'productId': productId,
              'productName': productName,
              'quantity': quantity,
              'revenue': totalPrice,
              'cost': totalCost,
              'profit': profit,
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