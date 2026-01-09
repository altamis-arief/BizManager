import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../models/product.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final String _collectionName = 'products';

  // Create a new product
  Future<String> createProduct(Product product) async {
    try {
      final docRef = await _firestore.collection(_collectionName).add(product.toMap());
      
      // Update the product with its Firestore ID
      await docRef.update({'id': docRef.id});
      
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create product: $e');
    }
  }

  // Read all products
  Stream<List<Product>> getAllProducts() {
    return _firestore
        .collection(_collectionName)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Product.fromMap(doc.data());
      }).toList();
    });
  }

  // Read active products only
  Stream<List<Product>> getActiveProducts() {
    return _firestore
        .collection(_collectionName)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Product.fromMap(doc.data());
      }).toList();
    });
  }

  // Read products by category
  Stream<List<Product>> getProductsByCategory(String category) {
    return _firestore
        .collection(_collectionName)
        .where('category', isEqualTo: category)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Product.fromMap(doc.data());
      }).toList();
    });
  }

  // Read a single product by ID
  Future<Product?> getProductById(String id) async {
    try {
      final doc = await _firestore.collection(_collectionName).doc(id).get();
      if (doc.exists) {
        return Product.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get product: $e');
    }
  }

  // Update a product
  Future<void> updateProduct(Product product) async {
    try {
      await _firestore.collection(_collectionName).doc(product.id).update(
        product.copyWith(updatedAt: DateTime.now()).toMap(),
      );
    } catch (e) {
      throw Exception('Failed to update product: $e');
    }
  }

  // Delete a product (soft delete)
  Future<void> deleteProduct(String id) async {
    try {
      await _firestore.collection(_collectionName).doc(id).update({
        'isActive': false,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to delete product: $e');
    }
  }

  // Permanently delete a product
  Future<void> permanentlyDeleteProduct(String id, String? imageUrl) async {
    try {
      // Delete image from storage if exists
      if (imageUrl != null && imageUrl.isNotEmpty) {
        await deleteImageFromStorage(imageUrl);
      }
      
      // Delete document from Firestore
      await _firestore.collection(_collectionName).doc(id).delete();
    } catch (e) {
      throw Exception('Failed to permanently delete product: $e');
    }
  }

  // Update stock
  Future<void> updateStock(String id, int newStock) async {
    try {
      await _firestore.collection(_collectionName).doc(id).update({
        'stock': newStock,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to update stock: $e');
    }
  }

  // Upload product image to Firebase Storage
  Future<String> uploadProductImage(File imageFile, String productId) async {
    try {
      final ref = _storage.ref().child('products/$productId/${DateTime.now().millisecondsSinceEpoch}.jpg');
      final uploadTask = await ref.putFile(imageFile);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  // Delete image from Firebase Storage
  Future<void> deleteImageFromStorage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      // Ignore error if image doesn't exist
      print('Failed to delete image: $e');
    }
  }

  // Search products by name
  Stream<List<Product>> searchProducts(String query) {
    return _firestore
        .collection(_collectionName)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      final products = snapshot.docs.map((doc) => Product.fromMap(doc.data())).toList();
      
      // Filter by name containing query (case insensitive)
      return products.where((product) {
        return product.name.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  // Get low stock products
  Stream<List<Product>> getLowStockProducts(int threshold) {
    return _firestore
        .collection(_collectionName)
        .where('isActive', isEqualTo: true)
        .where('stock', isLessThanOrEqualTo: threshold)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Product.fromMap(doc.data())).toList();
    });
  }
}