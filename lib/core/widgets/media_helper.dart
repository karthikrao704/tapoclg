import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:tapovana_mobile_app/core/widgets/failed_image_cache.dart';
import 'package:tapovana_mobile_app/core/config/api_config.dart';

/// Helper utility to resolve and build images/videos from the API.
class MediaHelper {
  MediaHelper._();

  /// Resolves any relative URL (starting with `/uploads/` or `/`) to the production backend host.
  static String resolveMediaUrl(String? url) {
    if (url == null || url.isEmpty) return '';

    // Convert http:// to https:// to prevent Android/iOS cleartext traffic blocks
    if (url.startsWith('http://')) {
      url = url.replaceFirst('http://', 'https://');
    }

    if (url.startsWith('/uploads/') || url.startsWith('/')) {
      final backendUrl = ApiConfig.authProfileBackendUrl;
      final prefix = url.startsWith('/') ? '' : '/';
      return "$backendUrl$prefix$url";
    }
    return url;
  }

  /// Builds a responsive Image widget handling Base64 strings, relative server paths, and standard network/fallback images.
  static Widget buildServiceImage(
    String? url, {
    BoxFit fit = BoxFit.cover,
    double? width,
    double? height,
    Widget? fallbackWidget,
  }) {
    final fallback = fallbackWidget ?? Image.network(
      'https://placehold.co/600x400?text=No+Image',
      fit: fit,
      width: width,
      height: height,
    );

    if (url == null || url.isEmpty) {
      return fallback;
    }

    if (FailedImageCache.isFailed(url)) {
      return fallback;
    }

    // Scenario A: It's a Base64 string
    if (url.startsWith('data:image') || (!url.startsWith('http') && !url.startsWith('/uploads/') && !url.startsWith('/') && url.length > 100)) {
      try {
        final base64String = url.contains(',') ? url.split(',').last : url;
        return Image.memory(
          base64Decode(base64String.trim()),
          fit: fit,
          width: width,
          height: height,
          errorBuilder: (_, __, ___) {
            FailedImageCache.markFailed(url);
            return fallback;
          },
        );
      } catch (e) {
        debugPrint('❌ MediaHelper: Error decoding base64 image: $e');
        return fallback;
      }
    }

    // Scenario B: It's a local file path or standard URL
    final resolvedUrl = resolveMediaUrl(url);
    return Image.network(
      resolvedUrl,
      fit: fit,
      width: width,
      height: height,
      errorBuilder: (context, error, stackTrace) {
        FailedImageCache.markFailed(url);
        return fallback;
      },
    );
  }
}
