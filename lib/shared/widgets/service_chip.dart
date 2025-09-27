import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

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
    // Thêm dòng print để debug (xóa hoặc comment lại khi deploy)
    // print("ServiceChip: Parsing color '$hexColorString' for service '$name'");

    if (hexColorString.isEmpty) {
      // print("ServiceChip: Empty hex string, returning grey.");
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
        final Color parsed = Color(int.parse("0x$hex"));
        // print("ServiceChip: Parsed '$hexColorString' to $parsed");
        return parsed;
      } catch (e) {
        // print("ServiceChip: Error parsing hex '$hexColorString': $e. Returning grey.");
        return Colors.grey.shade600; // Màu xám đậm hơn nếu lỗi parse
      }
    }

    // print("ServiceChip: Invalid hex length for '$hexColorString', returning grey.");
    return Colors.grey; // Màu xám mặc định nếu định dạng không hợp lệ
  }

  /// Xác định màu chữ dựa trên độ sáng của màu nền để đảm bảo độ tương phản.
  Color _getTextColorForBackground(Color backgroundColor) {
    // Tính toán độ sáng của màu. Giá trị từ 0 (đen) đến 1 (trắng).
    // Ngưỡng 0.5 thường được sử dụng để phân biệt màu sáng và tối.
    // Một số người dùng ngưỡng 0.6 hoặc 0.7 cho kết quả tốt hơn.
    if (backgroundColor.computeLuminance() > 0.6) {
      return AppColors.textPrimary; // Chữ tối trên nền sáng
    }
    return AppColors.softWhite; // Chữ trắng trên nền tối
  }

  @override
  Widget build(BuildContext context) {
    final Color chipColor = _parseColor(color); // `color` là chuỗi hex từ constructor
    final Color textColor = _getTextColorForBackground(chipColor);

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