import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:labodc_mobile/core/router/route_constants.dart';

import '../../../core/get_it/get_it.dart';
import '../../../features/auth/presentation/provider/auth_provider.dart';
import '../../../shared/widgets/reusable_card.dart';
import '../bloc/wallet_cubit.dart';
import '../bloc/wallet_state.dart';

class MyWalletPage extends StatelessWidget {
  const MyWalletPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<WalletCubit>()..loadWallet(),
      child: const _MyWalletView(),
    );
  }
}

class _MyWalletView extends StatelessWidget {
  const _MyWalletView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const primaryTeal = Color(0xFF00796B);
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Ví của tôi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              context.pushNamed(Routes.transactionHistoryName);
            },
          )
        ],
      ),
      body: BlocBuilder<WalletCubit, WalletState>(
        builder: (context, state) {
          if (state is WalletLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is WalletError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<WalletCubit>().loadWallet(),
                    child: const Text("Thử lại"),
                  ),
                ],
              ),
            );
          }

          if (state is WalletLoaded) {
            final wallet = state.wallet;
            final totalBalance = wallet.balance + wallet.heldBalance;

            return RefreshIndicator(
              onRefresh: () => context.read<WalletCubit>().loadWallet(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Quản lý số dư và rút tiền về ngân hàng",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildUserInfo(context, theme),
                    const SizedBox(height: 24),

                    // Card Tổng quan Ví
                    ReusableCard(
                      padding: const EdgeInsets.all(20),
                      border: Border.all(color: primaryTeal.withOpacity(0.5), width: 1.5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.account_balance_wallet_rounded, color: primaryTeal),
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

                          _buildDarkBalanceCard(currencyFormat.format(totalBalance)),
                          const SizedBox(height: 20),

                          Row(
                            children: [
                              Expanded(
                                child: _buildSubBalanceCard(
                                  theme,
                                  label: "Khả dụng",
                                  amount: currencyFormat.format(wallet.balance),
                                  subText: "Có thể rút ngay",
                                  color: Colors.green,
                                  icon: Icons.check_circle_outline,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildSubBalanceCard(
                                  theme,
                                  label: "Đang chờ",
                                  amount: currencyFormat.format(wallet.heldBalance),
                                  subText: "Đang xử lý",
                                  color: Colors.orange,
                                  icon: Icons.hourglass_empty_rounded,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          Row(
                            children: [
                              Expanded(
                                child: _buildActionButton(
                                  label: "Rút tiền",
                                  icon: Icons.south_east_rounded,
                                  isPrimary: true,
                                  color: primaryTeal,
                                  onTap: wallet.balance > 0 ? () {} : null,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildActionButton(
                                  label: "Ngân hàng",
                                  icon: Icons.credit_card_rounded,
                                  isPrimary: false,
                                  color: primaryTeal,
                                  onTap: () {},
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          _buildSmartNote(wallet.balance.toDouble()),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildUserInfo(BuildContext context, ThemeData theme) {
    final authProvider = context.watch<AuthProvider>();
    final userName = authProvider.currentUser?.fullName ?? "Người dùng";
    final userRole = authProvider.currentUser?.role ?? "Vai trò";

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text("Người dùng: ", style: theme.textTheme.bodyMedium),
        const SizedBox(width: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            userName,
            style: TextStyle(
              color: Colors.blue.shade700,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(userRole, style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
      ],
    );
  }

  Widget _buildDarkBalanceCard(String amount) {
    return ReusableCard(
      gradient: const LinearGradient(
        colors: [Color(0xFF264653), Color(0xFF2A9D8F)],
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
              const Text("Tổng số dư tài khoản", style: TextStyle(color: Colors.white70, fontSize: 13)),
              Icon(Icons.security, color: Colors.white.withOpacity(0.5), size: 18),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              Icon(Icons.circle, size: 8, color: Colors.greenAccent),
              SizedBox(width: 6),
              Text("Ví đang hoạt động", style: TextStyle(color: Colors.white, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubBalanceCard(ThemeData theme,
      {required String label, required String amount, required String subText, required Color color, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 6),
              Text(label, style: TextStyle(color: theme.hintColor, fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          Text(amount, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(subText, style: TextStyle(color: color.withOpacity(0.6), fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildActionButton({required String label, required IconData icon, required bool isPrimary, required Color color, VoidCallback? onTap}) {
    final bool isDisabled = onTap == null;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isPrimary ? (isDisabled ? Colors.grey.shade300 : color) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isDisabled ? Colors.grey.shade300 : color),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: isPrimary ? Colors.white : color),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isPrimary ? Colors.white : color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSmartNote(double balance) {
    final isZero = balance <= 0;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isZero ? Colors.orange.shade50 : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isZero ? Colors.orange.shade100 : Colors.blue.shade100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(isZero ? Icons.warning_amber_rounded : Icons.info_outline, color: isZero ? Colors.orange : Colors.blue, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isZero
                  ? "Bạn chưa có số dư khả dụng để rút tiền. Hãy hoàn thành các Milestone để nhận thanh toán."
                  : "Số dư khả dụng của bạn đã sẵn sàng. Bạn có thể thực hiện lệnh rút tiền về ngân hàng đã liên kết.",
              style: TextStyle(color: isZero ? Colors.orange.shade900 : Colors.blue.shade900, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}