import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/get_it/get_it.dart';
import '../../../hiring_projects/presentation/utils/project_data_formatter.dart';
import '../cubit/disbursement_cubit.dart';
import '../../data/models/milestone_disbursement_model.dart';

class MilestoneDisbursementTab extends StatelessWidget {
  final String milestoneId;

  const MilestoneDisbursementTab({super.key, required this.milestoneId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<DisbursementCubit>()..fetchDisbursement(milestoneId),
      child: BlocBuilder<DisbursementCubit, DisbursementState>(
        builder: (context, state) {
          if (state is DisbursementLoading) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }

          if (state is DisbursementFailure) {
            return _buildEmptyOrError(state);
          }

          if (state is DisbursementLoaded) {
            return _buildMainContent(context, state.disbursement);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, MilestoneDisbursementModel data) {
    return RefreshIndicator(
      onRefresh: () => context.read<DisbursementCubit>().fetchDisbursement(milestoneId),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildTotalCard(context, data),
            const SizedBox(height: 24),
            _buildSectionHeader("Chi tiết phân bổ"),
            const SizedBox(height: 12),
            _buildAmountTile(
              context,
              title: "Nhóm Talent",
              amount: data.talentAmount,
              icon: Icons.groups_rounded,
              color: Colors.blue,
              subtitle: "80% ngân sách cột mốc",
            ),
            const SizedBox(height: 12),
            _buildAmountTile(
              context,
              title: "Mentor",
              amount: data.mentorAmount,
              icon: Icons.psychology_rounded,
              color: Colors.purple,
              subtitle: "Hỗ trợ hướng dẫn dự án",
            ),
            const SizedBox(height: 12),
            _buildAmountTile(
              context,
              title: "Phí dịch vụ LabODC",
              amount: data.systemFee,
              icon: Icons.account_balance_rounded,
              color: Colors.orange,
              subtitle: "Vận hành và bảo trì hệ thống",
            ),
            const SizedBox(height: 32),
            _buildFooter(data.updatedAt),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalCard(BuildContext context, MilestoneDisbursementModel data) {
    final theme = Theme.of(context);
    final isCompleted = data.status == 'COMPLETED';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.primaryColor, theme.primaryColor.withBlue(200)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Tổng giải ngân", style: TextStyle(color: Colors.white70, fontSize: 16)),
              _statusChip(isCompleted),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            ProjectDataFormatter.formatCurrency(context, data.totalAmount),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white24),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info_outline, color: Colors.white60, size: 14),
              SizedBox(width: 6),
              Text(
                "Tiền sẽ được chuyển vào ví sau khi phê duyệt",
                style: TextStyle(color: Colors.white60, fontSize: 12),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildAmountTile(
      BuildContext context, {
        required String title,
        required double amount,
        required IconData icon,
        required Color color,
        required String subtitle,
      }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Text(subtitle, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
              ],
            ),
          ),
          Text(
            ProjectDataFormatter.formatCurrency(context, amount),
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(bool isCompleted) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isCompleted ? "Hoàn tất" : "Chờ xử lý",
        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        const SizedBox(width: 4),
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildFooter(DateTime date) {
    final timeStr = DateFormat('dd/MM/yyyy HH:mm').format(date);
    return Column(
      children: [
        Text("Dữ liệu được tính toán tự động dựa trên hợp đồng",
            style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
        const SizedBox(height: 4),
        Text("Cập nhật: $timeStr",
            style: TextStyle(color: Colors.grey.shade400, fontSize: 11)),
      ],
    );
  }

  Widget _buildEmptyOrError(DisbursementFailure state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              state.isBusinessError ? Icons.pending_actions_rounded : Icons.cloud_off_rounded,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              state.isBusinessError ? "Chưa sẵn sàng" : "Rất tiếc!",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              state.message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}