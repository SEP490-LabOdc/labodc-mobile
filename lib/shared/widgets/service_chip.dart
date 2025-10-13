import 'package:flutter/material.dart';

class ServiceChip extends StatelessWidget {
  final String name;
  final String color;
  final bool small;

  const ServiceChip({
    super.key,
    required this.name,
    required this.color,
    this.small = false,
  });

  /// Phân tích chuỗi hex màu thành đối tượng Color.
  /// Hỗ trợ các định dạng: "RRGGBB", "#RRGGBB", "AARRGGBB", "#AARRGGBB".
  Color _parseColor(String hexColorString) {
    if (hexColorString.isEmpty) {
      return Colors.grey.shade400; // Màu xám nhạt nếu chuỗi rỗng
    }

    String hex = hexColorString.toUpperCase().replaceAll("#", "");
    if (hex.length == 3) { // Hỗ trợ định dạng rút gọn RGB -> RRGGBB
      hex = "${hex[0]}${hex[0]}${hex[1]}${hex[1]}${hex[2]}${hex[2]}";
    }
    if (hex.length == 6) {
      hex = "FF$hex"; // Thêm Alpha nếu chỉ có RGB (FF = opaque)
    }

    if (hex.length == 8) { // AARRGGBB
      try {
        return Color(int.parse("0x$hex"));
      } catch (e) {
        return Colors.grey.shade600; // Màu xám đậm hơn nếu lỗi parse
      }
    }

    return Colors.grey; // Màu xám mặc định nếu định dạng không hợp lệ
  }

  /// Xác định màu chữ dựa trên độ sáng của màu nền để đảm bảo độ tương phản.
  Color _getTextColorForBackground(Color backgroundColor, Brightness brightness) {
    if (backgroundColor.computeLuminance() > 0.6) {
      return brightness == Brightness.dark ? Colors.white70 : Colors.black87; // Điều chỉnh theo brightness
    }
    return brightness == Brightness.dark ? Colors.white : Colors.black54;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color chipColor = _parseColor(color); // `color` là chuỗi hex từ constructor
    final textColor = _getTextColorForBackground(chipColor, theme.brightness);

    return Chip(
      backgroundColor: chipColor, // QUAN TRỌNG: Sử dụng màu đã parse
      label: Text(
        name,
        style: TextStyle(
          color: textColor,
          fontSize: small ? 10.5 : 12.5, // Kích thước chữ có thể điều chỉnh
          fontWeight: FontWeight.w500,
        ),
        overflow: TextOverflow.ellipsis,
      ),
      padding: small
          ? const EdgeInsets.symmetric(horizontal: 7.0, vertical: 2.5)
          : const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      side: BorderSide.none, // Bỏ viền mặc định của Chip
      elevation: 0.5, // Thêm chút bóng đổ nhẹ
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(small ? 6 : 8), // Bo góc chip
      ),
    );
  }
}