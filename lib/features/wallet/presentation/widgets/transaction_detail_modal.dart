import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/transaction_detail_model.dart';

class TransactionDetailModal extends StatelessWidget {
  final TransactionDetailModel transaction;

  const TransactionDetailModal({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    final isIncome = transaction.direction == 'CREDIT';

    // Logic hiển thị trạng thái
    final statusColor = _getStatusColor(transaction.status);
    final statusText = _mapStatus(transaction.status);

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar cho modal
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
          ),

          // 1. Header: Icon trạng thái và Số tiền lớn
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              transaction.status == 'SUCCESS' ? Icons.check_circle_rounded : Icons.pending_rounded,
              color: statusColor,
              size: 48,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            statusText,
            style: theme.textTheme.titleMedium?.copyWith(color: statusColor, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "${isIncome ? '+' : '-'}${currencyFormat.format(transaction.amount)}",
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isIncome ? Colors.green : theme.colorScheme.error,
            ),
          ),
          const SizedBox(height: 24),
          const Divider(),

          // 2. Body: Thông tin chi tiết được chia nhóm
          _buildSectionTitle("Thông tin giao dịch"),
          _buildRow("Loại giao dịch", _mapType(transaction.type), theme),
          _buildRow("Thời gian", DateFormat('HH:mm:ss - dd/MM/yyyy').format(transaction.createdAt), theme),
          _buildRow("Nội dung", transaction.description ?? "Không có mô tả", theme),

          const SizedBox(height: 16),
          _buildSectionTitle("Chi tiết đối soát"),
          _buildRow("Mã giao dịch (ID)", transaction.id.toUpperCase(), theme, isCopyable: true),
          _buildRow("Nguồn tham chiếu", transaction.refType ?? "N/A", theme),
          _buildRow("Số dư sau GD", currencyFormat.format(transaction.balanceAfter ?? 0), theme,
              valueColor: Colors.blueGrey),

          const SizedBox(height: 32),

          // 3. Footer: Nút đóng
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Đóng", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title.toUpperCase(),
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.1),
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, ThemeData theme, {Color? valueColor, bool isCopyable = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: theme.hintColor)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: valueColor ?? theme.textTheme.bodyLarge?.color,
                fontSize: isCopyable ? 12 : 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Map dữ liệu ---

  String _mapType(String type) {
    switch (type) {
      case 'WITHDRAWAL': return "Rút tiền";
      case 'DEPOSIT': return "Nạp tiền";
      case 'MILESTONE_PAYMENT': return "Thanh toán Milestone";
      case 'TRANSACTION_TYPE_DISBURSEMENT': return "Giải ngân dự án";
      default: return type;
    }
  }

  String _mapStatus(String status) {
    switch (status) {
      case 'SUCCESS': return "Giao dịch thành công";
      case 'PENDING': return "Đang xử lý";
      case 'FAILED': return "Giao dịch thất bại";
      default: return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'SUCCESS': return Colors.green;
      case 'PENDING': return Colors.orange;
      case 'FAILED': return Colors.red;
      default: return Colors.grey;
    }
  }
}