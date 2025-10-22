import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../config/theme.dart';

class CachedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const CachedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    // Handle empty or invalid URLs
    if (imageUrl.isEmpty || !imageUrl.startsWith('http')) {
      return _buildPlaceholder();
    }

    // Calculate optimal cache sizes based on actual widget size
    // Use device pixel ratio for sharper images on high-DPI screens
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    final memWidth = width != null ? (width! * devicePixelRatio * 1.5).toInt() : null;
    final memHeight = height != null ? (height! * devicePixelRatio * 1.5).toInt() : null;
    
    // Disk cache limits based on image size - smaller for thumbnails
    final isSmallImage = (width ?? 0) < 100 || (height ?? 0) < 100;
    final diskCacheSize = isSmallImage ? 400 : 800;

    Widget imageWidget = CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => _buildShimmerPlaceholder(),
      errorWidget: (context, url, error) => _buildErrorPlaceholder(),
      memCacheWidth: memWidth,
      memCacheHeight: memHeight,
      maxWidthDiskCache: diskCacheSize,
      maxHeightDiskCache: diskCacheSize,
      // Add error handling for image decoding issues
      errorListener: (exception) {
        // Log the error for debugging (only in debug mode)
        if (const bool.fromEnvironment('dart.vm.product') == false) {
          print('CachedNetworkImage error: $exception');
        }
      },
      // Faster fade-in for better perceived performance
      fadeInDuration: const Duration(milliseconds: 200),
      fadeOutDuration: const Duration(milliseconds: 50),
    );

    if (borderRadius != null) {
      imageWidget = ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  Widget _buildShimmerPlaceholder() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        color: Colors.white,
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: AppTheme.backgroundColor,
      child: const Icon(
        Icons.coffee,
        color: AppTheme.textSecondary,
        size: 40,
      ),
    );
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: AppTheme.backgroundColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.coffee,
            color: AppTheme.textSecondary.withOpacity(0.5),
            size: 40,
          ),
          const SizedBox(height: 8),
          Text(
            'No image',
            style: TextStyle(
              color: AppTheme.textSecondary.withOpacity(0.5),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}