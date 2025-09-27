// lib/shared/widgets/network_image_with_fallback.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../core/theme/app_colors.dart';


class NetworkImageWithFallback extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final String fallbackAsset; // e.g., 'assets/images/placeholder_image.png'
  final IconData? fallbackIcon; // Alternative to asset, e.g. Icons.image
  final Color? fallbackIconColor;
  final double? fallbackIconSize;
  final BorderRadius? borderRadius; // To clip the image

  const NetworkImageWithFallback({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.fallbackAsset = 'assets/images/logo.png', // Ensure this asset exists
    this.fallbackIcon,
    this.fallbackIconColor,
    this.fallbackIconSize,
    this.borderRadius,
  });

  Widget _buildErrorWidget() {
    Widget errorContent;
    if (fallbackIcon != null) {
      errorContent = Icon(
        fallbackIcon,
        size: fallbackIconSize ?? (width != null && height != null ? (width! < height! ? width! * 0.5 : height! * 0.5) : 40.0),
        color: fallbackIconColor ?? Colors.grey[400],
      );
    } else {
      errorContent = Image.asset(
        fallbackAsset,
        width: width,
        height: height,
        fit: fit,
        // Optional: Add error builder for the asset itself if it might fail
        // errorBuilder: (context, error, stackTrace) => Icon(Icons.broken_image, size: 40, color: Colors.grey[400]),
      );
    }

    return Container(
      width: width,
      height: height,
      color: Colors.grey[200], // A light background for the fallback
      alignment: Alignment.center,
      child: errorContent,
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[200], // A light background for the placeholder
      alignment: Alignment.center,
      child: const CircularProgressIndicator(strokeWidth: 2.0, valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),),
    );
  }


  @override
  Widget build(BuildContext context) {
    Widget imageWidget;
    if (imageUrl.isEmpty) {
      imageWidget = _buildErrorWidget();
    } else {
      imageWidget = CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) => _buildPlaceholder(),
        errorWidget: (context, url, error) => _buildErrorWidget(),
      );
    }

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }
    return imageWidget;
  }
}