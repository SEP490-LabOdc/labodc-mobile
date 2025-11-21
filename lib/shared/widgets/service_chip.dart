import 'package:flutter/material.dart';

class ServiceChip extends StatelessWidget {
  final String name;
  final String color; // vẫn giữ param nhưng không dùng làm nền
  final bool small;

  const ServiceChip({
    super.key,
    required this.name,
    required this.color,
    this.small = false,
  });

  Color _parseColor(String hexColorString) {
    if (hexColorString.isEmpty) {
      return Colors.grey.shade400;
    }

    String hex = hexColorString.toUpperCase().replaceAll("#", "");
    if (hex.length == 3) {
      hex = "${hex[0]}${hex[0]}${hex[1]}${hex[1]}${hex[2]}${hex[2]}";
    }
    if (hex.length == 6) {
      hex = "FF$hex";
    }

    if (hex.length == 8) {
      try {
        return Color(int.parse("0x$hex"));
      } catch (e) {
        return Colors.grey.shade600;
      }
    }

    return Colors.grey;
  }

  Color _getTextColorForBackground(Color backgroundColor, Brightness brightness) {
    if (backgroundColor.computeLuminance() > 0.6) {
      return brightness == Brightness.dark ? Colors.white70 : Colors.black87;
    }
    return brightness == Brightness.dark ? Colors.white : Colors.black54;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Bỏ màu nền — dùng nền trong suốt và viền nhẹ theo theme
    final Color borderColor = theme.dividerColor.withOpacity(0.12);
    final Color textColor = theme.colorScheme.onSurface;

    return Chip(
      backgroundColor: Colors.transparent, // Không dùng màu nền
      label: Text(
        name,
        style: TextStyle(
          color: textColor,
          fontSize: small ? 10.5 : 12.5,
          fontWeight: FontWeight.w500,
        ),
        overflow: TextOverflow.ellipsis,
      ),
      padding: small
          ? const EdgeInsets.symmetric(horizontal: 7.0, vertical: 2.5)
          : const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      side: BorderSide(color: borderColor),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(small ? 6 : 8),
      ),
    );
  }
}