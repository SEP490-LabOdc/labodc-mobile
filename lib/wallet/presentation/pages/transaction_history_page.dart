import 'package:flutter/material.dart';
import '../../../shared/widgets/reusable_card.dart';

class TransactionHistoryPage extends StatelessWidget {
  const TransactionHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Lịch sử"), // Có thể ẩn nếu dùng Header custom
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
        titleTextStyle: theme.textTheme.titleLarge?.copyWith(
          color: theme.colorScheme.onSurface,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header Section
            Row(
              children: [
                Icon(Icons.history, color: const Color(0xFF00796B), size: 28),
                const SizedBox(width: 8),
                Text(
                  "Lịch sử Giao dịch",
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              "Theo dõi các khoản thu nhập và rút tiền",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),

            // 2. List of Transactions
            // Item 1: Milestone (Income)
            const TransactionItem(
              title: "Thu nhập từ Milestone 1",
              status: "Hoàn thành",
              time: "09:00:00 16/1/2025",
              detailText: "Milestone 1: Setup & Design",
              detailIcon: Icons.location_on, // Icon tượng trưng (pin)
              amount: "+2.500.000 đ",
              typeLabel: "Thu nhập",
              isIncome: true,
              statusColor: Colors.green,
            ),

            // Item 2: Leader (Income)
            const TransactionItem(
              title: "Phân bổ từ Leader",
              status: "Hoàn thành",
              time: "14:30:00 20/1/2025",
              detailText: "Từ: Nguyễn Văn A (Leader)",
              detailIcon: Icons.person,
              amount: "+3.000.000 đ",
              typeLabel: "Thu nhập",
              isIncome: true,
              statusColor: Colors.green,
            ),

            // Item 3: Rút tiền VCB (Pending)
            const TransactionItem(
              title: "Rút tiền về Vietcombank",
              status: "Đang xử lý",
              time: "10:15:00 25/1/2025",
              detailText: "Vietcombank - *****1234",
              detailIcon: Icons.account_balance,
              amount: "-2.000.000 đ",
              typeLabel: "Rút tiền",
              isIncome: false, // Tiền ra
              statusColor: Colors.orange, // Màu status
            ),

            // Item 4: Rút tiền Tech (Done)
            const TransactionItem(
              title: "Rút tiền về Techcombank",
              status: "Hoàn thành",
              time: "16:45:00 10/1/2025",
              detailText: "Techcombank - *****5678",
              detailIcon: Icons.account_balance,
              amount: "-1.000.000 đ",
              typeLabel: "Rút tiền",
              isIncome: false,
              statusColor: Colors.green,
            ),
          ],
        ),
      ),
    );
  }
}

class TransactionItem extends StatelessWidget {
  final String title;
  final String status;
  final String time;
  final String detailText;
  final IconData detailIcon;
  final String amount;
  final String typeLabel;
  final bool isIncome; // True: Tiền vào (Xanh), False: Tiền ra (Đỏ)
  final Color statusColor;

  const TransactionItem({
    super.key,
    required this.title,
    required this.status,
    required this.time,
    required this.detailText,
    required this.detailIcon,
    required this.amount,
    required this.typeLabel,
    required this.isIncome,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Định nghĩa màu sắc dựa trên loại giao dịch
    final mainColor = isIncome ? Colors.green : Colors.redAccent;
    final iconData = isIncome ? Icons.south_west : Icons.north_east; // Mũi tên xuống (vào) / lên (ra)
    final bgColor = isIncome ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.08);

    return ReusableCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Icon Tròn bên trái
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              iconData,
              color: mainColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),

          // 2. Nội dung chính (Giữa)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title + Status Badge
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    _buildStatusBadge(status, statusColor),
                  ],
                ),
                const SizedBox(height: 8),

                // Thời gian
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      time,
                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Chi tiết / Nguồn
                Row(
                  children: [
                    Icon(detailIcon, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        detailText,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[700],
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 3. Số tiền (Phải)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: mainColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                typeLabel,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (text.toLowerCase().contains("hoàn thành")) ...[
            Icon(Icons.check_circle_outline, size: 12, color: color),
            const SizedBox(width: 4),
          ] else if (text.toLowerCase().contains("đang xử lý")) ...[
            Icon(Icons.access_time, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}