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
    if (amount == null || amount == 0) return '0 VND';

    try {
      return NumberFormat.currency(
        locale: 'vi_VN',
        symbol: 'VND',
        decimalDigits: 0,
      ).format(amount);
    } catch (e) {
      // fallback nếu lỗi formatter
      final number = amount.toStringAsFixed(0);
      return "$number đ";
    }
  }

  // --- PROJECT STATUS ---

  static Color getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return Colors.orange;
      case 'UPDATE_REQUIRED':
        return Colors.deepOrange;
      case 'REJECTED':
        return Colors.red;
      case 'PLANNING':
        return Colors.purple;
      case 'ON_GOING':
        return Colors.blue;
      case 'CLOSED':
        return Colors.grey;
      case 'COMPLETE':
      case 'COMPLETED':
        return Colors.green;
      case 'PAUSED':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  static String translateStatus(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return 'Đang chờ';
      case 'UPDATE_REQUIRED':
        return 'Yêu cầu cập nhật';
      case 'REJECTED':
        return 'Đã từ chối';
      case 'PLANNING':
        return 'Đang lập kế hoạch';
      case 'ON_GOING':
        return 'Đang thực hiện';
      case 'CLOSED':
        return 'Đã đóng';
      case 'COMPLETE':
      case 'COMPLETED':
        return 'Đã hoàn thành';
      case 'PAUSED':
        return 'Tạm dừng';
      default:
        return status;
    }
  }

  // --- MILESTONE STATUS ---

  static Color getMilestoneStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return Colors.orange; // Đang chờ
      case 'PENDING_START':
        return Colors.amber.shade700; // Chờ bắt đầu - Màu vàng đậm
      case 'UPDATE_REQUIRED':
        return Colors.red; // Yêu cầu cập nhật - Màu đỏ cảnh báo
      case 'ON_GOING':
        return Colors.blue; // Đang thực hiện - Màu xanh dương
      case 'COMPLETED':
        return Colors.green; // Đã hoàn thành - Màu xanh lá
      case 'PAID':
        return Colors.purple; // Đã thanh toán - Màu tím
      default:
        return Colors.grey;
    }
  }

  static String translateMilestoneStatus(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return 'Đang chờ';
      case 'PENDING_START':
        return 'Chờ bắt đầu';
      case 'UPDATE_REQUIRED':
        return 'Yêu cầu cập nhật';
      case 'ON_GOING':
        return 'Đang thực hiện';
      case 'COMPLETED':
        return 'Đã hoàn thành';
      case 'PAID':
        return 'Đã thanh toán';
      default:
        return status;
    }
  }

  // --- REPORT STATUS ---

  static Color getReportStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'SUBMITTED':
        return Colors.orange; // Đã nộp (Chờ review)
      case 'UNDER_REVIEW':
        return Colors.amber.shade700; // Đang xem xét
      case 'APPROVED':
        return Colors.green; // Đã duyệt
      case 'REJECTED':
        return Colors.red; // Từ chối / Yêu cầu sửa lại
      case 'FINAL':
        return Colors.blue; // Đã chốt / Đã gửi khách hàng
      default:
        return Colors.grey;
    }
  }

  static String translateReportStatus(String status) {
    switch (status.toUpperCase()) {
      case 'SUBMITTED':
        return 'Đã nộp';
      case 'UNDER_REVIEW':
        return 'Đang xem xét';
      case 'APPROVED':
        return 'Đã duyệt';
      case 'REJECTED':
        return 'Từ chối';
      case 'FINAL':
        return 'Đã gửi khách hàng';
      default:
        return status;
    }
  }


  //My APPLICATION STATUS
  static Color getApplicationStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return Colors.orange;
      case 'APPROVED':
        return Colors.green;
      case 'REJECTED':
        return Colors.red;
      case 'CANCELED':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  static String translateApplicationStatus(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return 'Đang chờ duyệt';
      case 'APPROVED':
        return 'Đã chấp nhận';
      case 'REJECTED':
        return 'Đã từ chối';
      case 'CANCELED':
        return 'Đã hủy';
      default:
        return status;
    }
  }
}