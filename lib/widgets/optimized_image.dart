import 'package:flutter/material.dart';
import '../services/cloudinary_service.dart';

class OptimizedImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final bool useThumbnail;
  final int thumbnailSize;

  const OptimizedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.useThumbnail = false,
    this.thumbnailSize = 200,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return errorWidget ?? _buildDefaultPlaceholder();
    }

    final cloudinaryService = CloudinaryService();
    String displayUrl = imageUrl!;

    // Get optimized URL if it's a Cloudinary image
    if (cloudinaryService.isCloudinaryUrl(imageUrl!)) {
      if (useThumbnail) {
        displayUrl = cloudinaryService.getThumbnailUrl(
          imageUrl!,
          size: thumbnailSize,
        );
      } else if (width != null || height != null) {
        displayUrl = cloudinaryService.getOptimizedUrl(
          imageUrl!,
          width: width?.toInt(),
          height: height?.toInt(),
        );
      }
    }

    return Image.network(
      displayUrl,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        
        return placeholder ??
            Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
      },
      errorBuilder: (context, error, stackTrace) {
        return errorWidget ?? _buildDefaultError();
      },
    );
  }

  Widget _buildDefaultPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      child: Center(
        child: Icon(
          Icons.image,
          size: 50,
          color: Colors.grey[400],
        ),
      ),
    );
  }

  Widget _buildDefaultError() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      child: Center(
        child: Icon(
          Icons.broken_image,
          size: 50,
          color: Colors.grey[400],
        ),
      ),
    );
  }
}

/// Cached Image Widget with better performance
class CachedOptimizedImage extends StatefulWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final bool useThumbnail;

  const CachedOptimizedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.useThumbnail = false,
  });

  @override
  State<CachedOptimizedImage> createState() => _CachedOptimizedImageState();
}

class _CachedOptimizedImageState extends State<CachedOptimizedImage> {
  @override
  Widget build(BuildContext context) {
    return OptimizedImage(
      imageUrl: widget.imageUrl,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      useThumbnail: widget.useThumbnail,
    );
  }
}