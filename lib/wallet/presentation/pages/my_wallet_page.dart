import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:labodc_mobile/core/router/route_constants.dart';

import '../../../shared/widgets/reusable_card.dart';


class MyWalletPage extends StatelessWidget {
  const MyWalletPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final primaryTeal = const Color(0xFF00796B);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Ví của tôi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.history, color: theme.colorScheme.onSurface),
            onPressed: () {
              context.pushNamed(Routes.transactionHistoryName);
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header Description & User Info
            Text(
              "Quản lý số dư và rút tiền về ngân hàng",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 16),
            _buildUserInfo(theme),
            const SizedBox(height: 24),

            // 2. Top Stats Cards (Horizontal Scroll)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildTopStatCard(
                    context,
                    title: "Tổng thu nhập",
                    amount: "5.500.000 đ",
                    icon: Icons.account_balance_wallet,
                    color: Colors.green,
                  ),
                  const SizedBox(width: 12),
                  _buildTopStatCard(
                    context,
                    title: "Tổng đã rút",
                    amount: "1.000.000 đ",
                    icon: Icons.payments_outlined,
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 12),
                  _buildTopStatCard(
                    context,
                    title: "Đang xử lý",
                    amount: "2.000.000 đ",
                    icon: Icons.pending_actions,
                    color: Colors.orange,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 3. Main Section: Tổng quan Ví
            ReusableCard(
              padding: const EdgeInsets.all(20),
              border: Border.all(color: primaryTeal, width: 1.5), // Viền xanh bao quanh
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.wallet, color: primaryTeal),
                      const SizedBox(width: 8),
                      Text(
                        "Tổng quan Ví",
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 3.1 Dark Balance Card
                  _buildDarkBalanceCard(theme, primaryTeal),
                  const SizedBox(height: 20),

                  // 3.2 Sub-balances (Khả dụng / Đang chờ)
                  Row(
                    children: [
                      Expanded(
                        child: _buildSubBalanceCard(
                          theme,
                          label: "Khả dụng",
                          amount: "0 đ",
                          subText: "Có thể rút ngay",
                          color: Colors.green,
                          icon: Icons.attach_money,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSubBalanceCard(
                          theme,
                          label: "Đang chờ",
                          amount: "0 đ",
                          subText: "Đang xử lý",
                          color: Colors.orange,
                          icon: Icons.schedule,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 3.3 Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          theme,
                          label: "Rút tiền",
                          icon: Icons.account_balance_wallet,
                          isPrimary: true,
                          color: primaryTeal,
                          onTap: () {},
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildActionButton(
                          theme,
                          label: "Tài khoản NH",
                          icon: Icons.credit_card,
                          isPrimary: false,
                          color: primaryTeal,
                          onTap: () {},
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 3.4 Note/Alert
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade100),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.lightbulb, color: Colors.orange, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              text: "Lưu ý: ",
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 13),
                              children: [
                                TextSpan(
                                  text: "Số dư khả dụng của bạn hiện đang là 0. Bạn cần nhận tiền từ Milestone hoặc Leader trước khi có thể rút.",
                                  style: TextStyle(fontWeight: FontWeight.normal, color: Colors.blue.shade900),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 40), // Bottom spacing
          ],
        ),
      ),
    );
  }

  // --- Widget Builders ---

  Widget _buildUserInfo(ThemeData theme) {
    return Row(
      children: [
        Text("Người dùng: ", style: theme.textTheme.bodyMedium),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            "Ho Minh Quyen (k17 HCM)",
            style: TextStyle(
              color: Colors.blue.shade700,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text("• Role: Talent", style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey)),
      ],
    );
  }

  Widget _buildTopStatCard(BuildContext context,
      {required String title, required String amount, required IconData icon, required Color color}) {
    final theme = Theme.of(context);
    return ReusableCard(
      padding: const EdgeInsets.all(16),
      enableShadow: true,
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDarkBalanceCard(ThemeData theme, Color primaryColor) {
    return ReusableCard(
      // Gradient background matching the image
      gradient: LinearGradient(
        colors: [
          const Color(0xFF264653), // Dark Teal/Blue
          const Color(0xFF2A9D8F), // Lighter Teal
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Tổng số dư",
                style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14),
              ),
              Icon(Icons.trending_up, color: Colors.white.withOpacity(0.7)),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            "0 ₫",
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              "Chưa có tiền",
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubBalanceCard(ThemeData theme,
      {required String label,
        required String amount,
        required String subText,
        required Color color,
        required IconData icon}) {
    return ReusableCard(
      backgroundColor: color.withOpacity(0.05),
      border: Border.all(color: color.withOpacity(0.3)),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                    color: theme.colorScheme.onSurface.withOpacity(0.8),
                    fontWeight: FontWeight.bold,
                    fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subText,
            style: TextStyle(color: color.withOpacity(0.8), fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(ThemeData theme,
      {required String label,
        required IconData icon,
        required bool isPrimary,
        required Color color,
        required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isPrimary ? color.withOpacity(0.5) : Colors.transparent, // Adjust opacity based on style
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color),
        ),
        // Note: The image uses a solid/filled style for "Rút tiền" and outlined for "Ngân hàng".
        // Adjusting to match image specifically:
        child: isPrimary
            ? Container( // Style for Rút tiền (Filled background look in image seems actually faded Teal)
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFF80CBC4), // Match the faded teal in image
            borderRadius: BorderRadius.circular(7),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: Colors.white),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
        )
            : Row( // Style for Tài khoản NH (Outlined)
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}