import 'package:flutter/painting.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class ImageCacheManager {
  // Custom cache manager with optimized settings
  static CacheManager? _customCacheManager;
  
  static CacheManager get customCacheManager {
    _customCacheManager ??= CacheManager(
      Config(
        'optimized_image_cache',
        stalePeriod: const Duration(days: 7), // Cache images for 7 days
        maxNrOfCacheObjects: 200, // Limit number of cached images
        repo: JsonCacheInfoRepository(databaseName: 'optimized_image_cache'),
        fileService: HttpFileService(),
      ),
    );
    return _customCacheManager!;
  }

  /// Clear the entire image cache
  static Future<void> clearCache() async {
    try {
      await DefaultCacheManager().emptyCache();
      await customCacheManager.emptyCache();
      // Also clear the image cache from memory
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();
    } catch (e) {
      print('Error clearing image cache: $e');
    }
  }

  /// Clear a specific image from cache
  static Future<void> evictImage(String imageUrl) async {
    try {
      await CachedNetworkImage.evictFromCache(imageUrl);
      await customCacheManager.removeFile(imageUrl);
    } catch (e) {
      print('Error evicting image from cache: $e');
    }
  }
  
  /// Get current memory cache info
  static String getCacheInfo() {
    try {
      final cache = PaintingBinding.instance.imageCache;
      return 'Current: ${cache.currentSize} images, ${(cache.currentSizeBytes / (1024 * 1024)).toStringAsFixed(1)}MB / Max: ${cache.maximumSize} images, ${(cache.maximumSizeBytes / (1024 * 1024)).toStringAsFixed(0)}MB';
    } catch (e) {
      return 'Unable to get cache info';
    }
  }
  
  /// Optimize image cache on app start
  static Future<void> optimizeCache() async {
    try {
      // Clear old images that are no longer needed
      final cache = PaintingBinding.instance.imageCache;
      
      // Set optimal cache size based on device memory
      // Default is 1000 images and 100MB, we reduce it for better memory management
      cache.maximumSize = 500; // Reduce from default 1000
      cache.maximumSizeBytes = 50 * 1024 * 1024; // 50MB instead of 100MB
      
      print('Image cache optimized: max ${cache.maximumSize} images, ${cache.maximumSizeBytes ~/ (1024 * 1024)}MB');
    } catch (e) {
      print('Error optimizing cache: $e');
    }
  }
}