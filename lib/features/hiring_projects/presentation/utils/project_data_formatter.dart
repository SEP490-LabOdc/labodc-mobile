// File: lib/features/hiring_projects/presentation/utils/project_data_formatter.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProjectDataFormatter {
  // Private constructor để ngăn chặn khởi tạo
  ProjectDataFormatter._();

  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  static String formatCurrency(BuildContext context, double? amount) {
    if (amount == null || amount == 0) return 'Thỏa thuận';
    final theme = Theme.of(context);

    // Format theo USD như JSON mẫu (5800 -> $5,800)
    // Nếu muốn VND, đổi locale thành 'vi_VN' và symbol thành 'đ'
    try {
      return NumberFormat.currency(
        locale: 'en_US',
        symbol: '\$',
        decimalDigits: 0,
      ).format(amount);
    } catch (e) {
      return '\$${amount.toStringAsFixed(0)}';
    }
  }

  static Color getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
      case 'ĐANG CHỜ':
        return Colors.orange;
      case 'ACTIVE':
      case 'HOẠT ĐỘNG':
        return Colors.green;
      case 'COMPLETED':
      case 'HOÀN THÀNH':
        return Colors.blue;
      case 'CANCELLED':
      case 'ĐÃ HỦY':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  static String translateStatus(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING': return 'Đang chờ';
      case 'ACTIVE': return 'Hoạt động';
      case 'COMPLETED': return 'Hoàn thành';
      case 'CANCELLED': return 'Đã hủy';
      default: return status;
    }
  }
}