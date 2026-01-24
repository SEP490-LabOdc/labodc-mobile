import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Shimmer loading widget for lists
class ListShimmer extends StatelessWidget {
  final int itemCount;
  final double itemHeight;
  final EdgeInsets? padding;

  const ListShimmer({
    super.key,
    this.itemCount = 5,
    this.itemHeight = 80,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView.builder(
      padding: padding ?? const EdgeInsets.all(16),
      itemCount: itemCount,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _ShimmerItem(height: itemHeight, isDark: isDark),
      ),
    );
  }
}

/// Shimmer loading widget for card grid
class CardGridShimmer extends StatelessWidget {
  final int itemCount;
  final double cardHeight;
  final int crossAxisCount;
  final EdgeInsets? padding;

  const CardGridShimmer({
    super.key,
    this.itemCount = 6,
    this.cardHeight = 200,
    this.crossAxisCount = 2,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GridView.builder(
      padding: padding ?? const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 1.0,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) =>
          _ShimmerItem(height: cardHeight, isDark: isDark),
    );
  }
}

/// Shimmer loading widget for detail screens
class DetailShimmer extends StatelessWidget {
  final EdgeInsets? padding;

  const DetailShimmer({super.key, this.padding});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: padding ?? const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header image placeholder
          _ShimmerBox(
            width: double.infinity,
            height: 200,
            isDark: isDark,
            borderRadius: 12,
          ),
          const SizedBox(height: 16),

          // Title
          _ShimmerBox(width: double.infinity, height: 24, isDark: isDark),
          const SizedBox(height: 12),

          // Subtitle
          _ShimmerBox(width: 200, height: 16, isDark: isDark),
          const SizedBox(height: 24),

          // Content blocks
          ...List.generate(
            3,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ShimmerBox(
                    width: double.infinity,
                    height: 14,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 8),
                  _ShimmerBox(
                    width: double.infinity,
                    height: 14,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 8),
                  _ShimmerBox(width: 150, height: 14, isDark: isDark),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Internal shimmer item widget
class _ShimmerItem extends StatelessWidget {
  final double height;
  final bool isDark;

  const _ShimmerItem({required this.height, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Shimmer.fromColors(
        baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
        highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

/// Internal shimmer box widget for detail screens
class _ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final bool isDark;
  final double borderRadius;

  const _ShimmerBox({
    required this.width,
    required this.height,
    required this.isDark,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}
