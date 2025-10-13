import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

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

  Widget _buildErrorWidget(BuildContext context) {
    final theme = Theme.of(context);
    Widget errorContent;
    if (fallbackIcon != null) {
      errorContent = Icon(
        fallbackIcon,
        size: fallbackIconSize ?? (width != null && height != null ? (width! < height! ? width! * 0.5 : height! * 0.5) : 40.0),
        color: fallbackIconColor ?? theme.colorScheme.onSurfaceVariant,
      );
    } else {
      errorContent = Image.asset(
        fallbackAsset,
        width: width,
        height: height,
        fit: fit,
      );
    }

    return Container(
      width: width,
      height: height,
      color: theme.colorScheme.surfaceVariant, // Thay bằng màu từ theme
      alignment: Alignment.center,
      child: errorContent,
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: width,
      height: height,
      color: theme.colorScheme.surfaceVariant, // Thay bằng màu từ theme
      alignment: Alignment.center,
      child: CircularProgressIndicator(
        strokeWidth: 2.0,
        valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Widget imageWidget;
    if (imageUrl.isEmpty) {
      imageWidget = _buildErrorWidget(context);
    } else {
      imageWidget = CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) => _buildPlaceholder(context),
        errorWidget: (context, url, error) => _buildErrorWidget(context),
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