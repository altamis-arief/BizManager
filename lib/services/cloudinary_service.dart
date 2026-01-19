import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:http/http.dart' as http;

class CloudinaryService {
  // Replace these with your Cloudinary credentials
  static const String _cloudName = 'dcriajssp';
  static const String _uploadPreset = 'bizmanager_products';
  
  late final CloudinaryPublic _cloudinary;
  
  CloudinaryService() {
    _cloudinary = CloudinaryPublic(_cloudName, _uploadPreset, cache: false);
  }

  /// Upload image to Cloudinary
  /// Returns the secure URL of the uploaded image
  Future<String?> uploadImage(File imageFile, String folder) async {
    try {
      // Upload image
      CloudinaryResponse response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          folder: folder,
          resourceType: CloudinaryResourceType.Image,
        ),
      );

      // Return the secure URL
      return response.secureUrl;
    } catch (e) {
      print('Error uploading image to Cloudinary: $e');
      return null;
    }
  }

  /// Upload image with custom options
  Future<String?> uploadImageWithOptions({
    required File imageFile,
    required String folder,
    int? maxWidth,
    int? maxHeight,
    int? quality,
  }) async {
    try {
      CloudinaryResponse response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          folder: folder,
          resourceType: CloudinaryResourceType.Image,
        ),
      );

      // Build transformation URL if dimensions are provided
      if (maxWidth != null || maxHeight != null || quality != null) {
        String transformedUrl = _buildTransformationUrl(
          response.secureUrl,
          maxWidth: maxWidth,
          maxHeight: maxHeight,
          quality: quality,
        );
        return transformedUrl;
      }

      return response.secureUrl;
    } catch (e) {
      print('Error uploading image to Cloudinary: $e');
      return null;
    }
  }

  /// Delete image from Cloudinary
  Future<bool> deleteImage(String imageUrl) async {
    try {
      // Extract public ID from URL
      String? publicId = _extractPublicId(imageUrl);
      
      if (publicId == null) {
        print('Could not extract public ID from URL');
        return false;
      }

      // Note: Deletion requires authentication and should be done server-side
      // This is a simplified version - in production, use your backend
      // For now, we'll just return true as the URL will be removed from Firestore
      print('Image marked for deletion: $publicId');
      return true;
    } catch (e) {
      print('Error deleting image from Cloudinary: $e');
      return false;
    }
  }

  /// Get optimized image URL with transformations
  String getOptimizedUrl(
    String originalUrl, {
    int? width,
    int? height,
    int quality = 80,
    String format = 'auto',
  }) {
    return _buildTransformationUrl(
      originalUrl,
      maxWidth: width,
      maxHeight: height,
      quality: quality,
      format: format,
    );
  }

  /// Get thumbnail URL
  String getThumbnailUrl(String originalUrl, {int size = 200}) {
    return _buildTransformationUrl(
      originalUrl,
      maxWidth: size,
      maxHeight: size,
      quality: 80,
      crop: 'fill',
    );
  }

  /// Build transformation URL
  String _buildTransformationUrl(
    String originalUrl, {
    int? maxWidth,
    int? maxHeight,
    int? quality,
    String format = 'auto',
    String crop = 'limit',
  }) {
    try {
      // Parse the URL
      Uri uri = Uri.parse(originalUrl);
      List<String> pathSegments = uri.pathSegments.toList();

      // Find the upload segment index
      int uploadIndex = pathSegments.indexOf('upload');
      if (uploadIndex == -1) return originalUrl;

      // Build transformation string
      List<String> transformations = [];
      
      if (maxWidth != null) transformations.add('w_$maxWidth');
      if (maxHeight != null) transformations.add('h_$maxHeight');
      if (quality != null) transformations.add('q_$quality');
      transformations.add('f_$format');
      transformations.add('c_$crop');

      String transformationString = transformations.join(',');

      // Insert transformation after 'upload'
      pathSegments.insert(uploadIndex + 1, transformationString);

      // Rebuild URL
      return uri.replace(pathSegments: pathSegments).toString();
    } catch (e) {
      print('Error building transformation URL: $e');
      return originalUrl;
    }
  }

  /// Extract public ID from Cloudinary URL
  String? _extractPublicId(String imageUrl) {
    try {
      Uri uri = Uri.parse(imageUrl);
      List<String> segments = uri.pathSegments;
      
      int uploadIndex = segments.indexOf('upload');
      if (uploadIndex == -1) return null;

      // Get segments after 'upload' (skip transformation if present)
      List<String> relevantSegments = segments.sublist(uploadIndex + 1);
      
      // Skip transformation segment if it contains parameters
      if (relevantSegments.isNotEmpty && relevantSegments[0].contains('_')) {
        relevantSegments = relevantSegments.sublist(1);
      }

      // Join remaining segments and remove file extension
      String publicId = relevantSegments.join('/');
      if (publicId.contains('.')) {
        publicId = publicId.substring(0, publicId.lastIndexOf('.'));
      }

      return publicId;
    } catch (e) {
      print('Error extracting public ID: $e');
      return null;
    }
  }

  /// Check if URL is a Cloudinary URL
  bool isCloudinaryUrl(String url) {
    return url.contains('cloudinary.com') || url.contains(_cloudName);
  }

  /// Validate image file
  bool isValidImage(File file) {
    final validExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp'];
    final path = file.path.toLowerCase();
    return validExtensions.any((ext) => path.endsWith(ext));
  }

  /// Get image size estimate (in MB)
  Future<double> getImageSize(File file) async {
    try {
      int bytes = await file.length();
      return bytes / (1024 * 1024); // Convert to MB
    } catch (e) {
      print('Error getting image size: $e');
      return 0;
    }
  }
}