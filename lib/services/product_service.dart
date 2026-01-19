import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import '../models/product.dart';
import 'cloudinary_service.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CloudinaryService _cloudinaryService = CloudinaryService();
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

  // Read all products for a specific user
  Stream<List<Product>> getAllProducts(String userId) {
    return _firestore
        .collection(_collectionName)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Product.fromMap(doc.data());
      }).toList();
    });
  }

  // Read active products only for a specific user
  Stream<List<Product>> getActiveProducts(String userId) {
    return _firestore
        .collection(_collectionName)
        .where('userId', isEqualTo: userId)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Product.fromMap(doc.data());
      }).toList();
    });
  }

  // Read products by category for a specific user
  Stream<List<Product>> getProductsByCategory(String userId, String category) {
    return _firestore
        .collection(_collectionName)
        .where('userId', isEqualTo: userId)
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
      // Delete image from Cloudinary if exists
      if (imageUrl != null && imageUrl.isNotEmpty) {
        await deleteImageFromCloudinary(imageUrl);
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

  // Upload product image to Cloudinary
  Future<String> uploadProductImage(File imageFile, String productId) async {
    try {
      // Validate image
      if (!_cloudinaryService.isValidImage(imageFile)) {
        throw Exception('Invalid image file format');
      }

      // Check image size (max 5MB)
      double sizeMB = await _cloudinaryService.getImageSize(imageFile);
      if (sizeMB > 5) {
        throw Exception('Image size too large. Maximum 5MB allowed.');
      }

      // Upload to Cloudinary in 'products' folder
      String? imageUrl = await _cloudinaryService.uploadImageWithOptions(
        imageFile: imageFile,
        folder: 'bizmanager/products',
        maxWidth: 1920,
        maxHeight: 1080,
        quality: 85,
      );

      if (imageUrl == null) {
        throw Exception('Failed to upload image to Cloudinary');
      }

      return imageUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  // Delete image from Cloudinary
  Future<void> deleteImageFromCloudinary(String imageUrl) async {
    try {
      if (_cloudinaryService.isCloudinaryUrl(imageUrl)) {
        await _cloudinaryService.deleteImage(imageUrl);
      }
    } catch (e) {
      // Log error but don't throw - image deletion is not critical
      print('Failed to delete image from Cloudinary: $e');
    }
  }

  // Get optimized image URL for display
  String getOptimizedImageUrl(String originalUrl, {int? width, int? height}) {
    if (_cloudinaryService.isCloudinaryUrl(originalUrl)) {
      return _cloudinaryService.getOptimizedUrl(
        originalUrl,
        width: width,
        height: height,
        quality: 80,
      );
    }
    return originalUrl;
  }

  // Get thumbnail URL
  String getThumbnailUrl(String originalUrl, {int size = 200}) {
    if (_cloudinaryService.isCloudinaryUrl(originalUrl)) {
      return _cloudinaryService.getThumbnailUrl(originalUrl, size: size);
    }
    return originalUrl;
  }

  // Search products by name for a specific user
  Stream<List<Product>> searchProducts(String userId, String query) {
    return _firestore
        .collection(_collectionName)
        .where('userId', isEqualTo: userId)
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

  // Get low stock products for a specific user
  Stream<List<Product>> getLowStockProducts(String userId, int threshold) {
    return _firestore
        .collection(_collectionName)
        .where('userId', isEqualTo: userId)
        .where('isActive', isEqualTo: true)
        .where('stock', isLessThanOrEqualTo: threshold)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Product.fromMap(doc.data())).toList();
    });
  }
}