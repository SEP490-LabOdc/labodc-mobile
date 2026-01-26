import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/get_it/get_it.dart';
import '../../../hiring_projects/presentation/utils/project_data_formatter.dart';
import '../../domain/enums/project_milestone_status.dart';
import '../cubit/disbursement_cubit.dart';
import '../../data/models/milestone_disbursement_model.dart';

class MilestoneDisbursementTab extends StatelessWidget {
  final String milestoneId;
  final double totalAmount;

  const MilestoneDisbursementTab({
    super.key,
    required this.milestoneId,
    required this.totalAmount,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<DisbursementCubit>()
            ..fetchDisbursement(milestoneId, totalAmount),
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

  Widget _buildMainContent(
    BuildContext context,
    MilestoneDisbursementModel data,
  ) {
    return RefreshIndicator(
      onRefresh: () => context.read<DisbursementCubit>().fetchDisbursement(
        milestoneId,
        totalAmount,
      ),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, data),
            const SizedBox(height: 24),
            _buildTotalCard(context, data),
            const SizedBox(height: 24),
            _buildDisbursementChart(context, data),
            const SizedBox(height: 24),
            _buildLeaderCards(context, data),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, MilestoneDisbursementModel data) {
    final status = ProjectMilestoneStatus.fromString(data.status);
    final statusText = status == ProjectMilestoneStatus.PENDING
        ? 'Chưa ký quỹ'
        : ProjectDataFormatter.translateMilestoneStatusFromEnum(status);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Row(
          children: [
            Icon(Icons.account_balance_wallet, color: Colors.teal, size: 24),
            SizedBox(width: 8),
            Text(
              'Chi tiết Phân bổ Milestone',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.orange.shade200),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.info_outline, size: 14, color: Colors.orange.shade700),
              const SizedBox(width: 4),
              Text(
                statusText,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.orange.shade700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTotalCard(
    BuildContext context,
    MilestoneDisbursementModel data,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.account_balance_wallet_outlined,
              color: Colors.teal.shade600,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tổng giá trị Milestone',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 4),
                Text(
                  ProjectDataFormatter.formatCurrency(
                    context,
                    data.totalAmount,
                  ),
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisbursementChart(
    BuildContext context,
    MilestoneDisbursementModel data,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.pie_chart_outline, size: 20, color: Colors.black87),
            SizedBox(width: 8),
            Text(
              'Biểu đồ Phân bổ',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildProgressBar(context, data),
        const SizedBox(height: 12),
        _buildLegend(context, data),
      ],
    );
  }

  Widget _buildProgressBar(
    BuildContext context,
    MilestoneDisbursementModel data,
  ) {
    final systemPercent = (data.systemFee / data.totalAmount) * 100;
    final mentorPercent = data.mentorLeader != null
        ? (data.mentorLeader!.amount / data.totalAmount) * 100
        : 0.0;
    final talentPercent = data.talentLeader != null
        ? (data.talentLeader!.amount / data.totalAmount) * 100
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Phân bổ tự động',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            height: 32,
            child: Row(
              children: [
                if (systemPercent > 0)
                  Expanded(
                    flex: systemPercent.round(),
                    child: Container(
                      color: Colors.grey.shade400,
                      alignment: Alignment.center,
                      child: systemPercent > 8
                          ? Text(
                              '${systemPercent.toStringAsFixed(0)}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                  ),
                if (mentorPercent > 0)
                  Expanded(
                    flex: mentorPercent.round(),
                    child: Container(
                      color: Colors.blue.shade400,
                      alignment: Alignment.center,
                      child: mentorPercent > 8
                          ? Text(
                              '${mentorPercent.toStringAsFixed(0)}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                  ),
                if (talentPercent > 0)
                  Expanded(
                    flex: talentPercent.round(),
                    child: Container(
                      color: Colors.green.shade400,
                      alignment: Alignment.center,
                      child: talentPercent > 8
                          ? Text(
                              '${talentPercent.toStringAsFixed(0)}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegend(BuildContext context, MilestoneDisbursementModel data) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildLegendItem('Hệ thống', Colors.grey.shade400),
        _buildLegendItem('Mentor', Colors.blue.shade400),
        _buildLegendItem('Team Talents', Colors.green.shade400),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildLeaderCards(
    BuildContext context,
    MilestoneDisbursementModel data,
  ) {
    return Column(
      children: [
        if (data.mentorLeader != null) ...[
          _buildLeaderCard(
            context,
            leader: data.mentorLeader!,
            icon: Icons.psychology_rounded,
            color: Colors.blue,
            title: 'Mentor',
          ),
          const SizedBox(height: 12),
        ],
        if (data.talentLeader != null) ...[
          _buildLeaderCard(
            context,
            leader: data.talentLeader!,
            icon: Icons.groups_rounded,
            color: Colors.green,
            title: 'Nhóm Talents',
          ),
          const SizedBox(height: 12),
        ],
        _buildSystemFeeCard(context, data),
      ],
    );
  }

  Widget _buildLeaderCard(
    BuildContext context, {
    required dynamic leader,
    required IconData icon,
    required Color color,
    required String title,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      ProjectDataFormatter.formatCurrency(
                        context,
                        leader.amount,
                      ),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: leader.avatarUrl.isNotEmpty
                    ? NetworkImage(leader.avatarUrl)
                    : null,
                child: leader.avatarUrl.isEmpty
                    ? Icon(Icons.person, color: Colors.grey.shade400, size: 24)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            leader.fullName,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Trưởng nhóm',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      leader.email,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSystemFeeCard(
    BuildContext context,
    MilestoneDisbursementModel data,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.account_balance_rounded,
              color: Colors.grey.shade600,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Phí hệ thống',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 2),
                Text(
                  ProjectDataFormatter.formatCurrency(context, data.systemFee),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
              state.isBusinessError
                  ? Icons.pending_actions_rounded
                  : Icons.cloud_off_rounded,
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
