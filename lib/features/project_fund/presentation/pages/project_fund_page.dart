import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:labodc_mobile/core/get_it/get_it.dart';

import '../../../hiring_projects/presentation/utils/project_data_formatter.dart';
import '../cubit/project_fund_cubit.dart';
import '../cubit/project_fund_state.dart';
import '../widgets/milestone_detail_modal.dart';

import 'package:labodc_mobile/features/project_application/data/models/my_project_model.dart';
import 'package:labodc_mobile/features/milestone/data/models/project_milestone_model.dart';

class ProjectFundPage extends StatelessWidget {
  const ProjectFundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProjectFundCubit>(
      create: (_) => getIt<ProjectFundCubit>()..loadInitial(),
      child: const _ProjectFundView(),
    );
  }
}

class _ProjectFundView extends StatelessWidget {
  const _ProjectFundView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "Quản lý Quỹ Nhóm",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: BlocBuilder<ProjectFundCubit, ProjectFundState>(
        builder: (context, state) {
          if (state.isInitialLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return RefreshIndicator(
            onRefresh: () => context.read<ProjectFundCubit>().loadInitial(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- CHỌN DỰ ÁN ---
                  Text(
                    'Dự án đang theo dõi:',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scheme.onSurface.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _ProjectDropdown(state: state),

                  if (state.errorMessage != null) ...[
                    const SizedBox(height: 12),
                    _ErrorBox(message: state.errorMessage!),
                  ],

                  const SizedBox(height: 24),

                  // --- 2 THẺ TỔNG QUAN (Đang giữ / Đã chia) ---
                  Row(
                    children: [
                      Expanded(
                        child: _FundSummaryCard(
                          title: 'Đang Giữ',
                          icon: Icons.account_balance_wallet_rounded,
                          primaryColor: const Color(0xFF5B5FFF),
                          amount: state.holdingAmount,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _FundSummaryCard(
                          title: 'Đã Chia',
                          icon: Icons.payments_rounded,
                          primaryColor: const Color(0xFF00B56A),
                          amount: state.distributedAmount,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // --- DANH SÁCH MILESTONES ---
                  _MilestonesCard(state: state),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ======================= WIDGET PHỤ TRỢ: DROPDOWN =======================

class _ProjectDropdown extends StatelessWidget {
  final ProjectFundState state;
  const _ProjectDropdown({required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    if (state.projects.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: scheme.surfaceVariant.withOpacity(0.3),
        ),
        child: const Text('Bạn chưa có dự án nào.'),
      );
    }

    return DropdownButtonFormField<MyProjectModel>(
      value: state.selectedProject,
      isExpanded: true,
      dropdownColor: theme.cardColor,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        filled: true,
        fillColor: theme.cardColor,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.dividerColor.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
      ),
      items: state.projects.map((p) {
        return DropdownMenuItem<MyProjectModel>(
          value: p,
          child: Text(p.title, style: theme.textTheme.bodyMedium),
        );
      }).toList(),
      onChanged: (project) {
        if (project != null) {
          context.read<ProjectFundCubit>().selectProject(project);
        }
      },
    );
  }
}

// ======================= WIDGET PHỤ TRỢ: SUMMARY CARDS =======================

class _FundSummaryCard extends StatelessWidget {
  final String title;
  final double amount;
  final Color primaryColor;
  final IconData icon;

  const _FundSummaryCard({
    required this.title,
    required this.amount,
    required this.primaryColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final amountText = ProjectDataFormatter.formatCurrency(context, amount);

    return Container(
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            offset: const Offset(0, 4),
            color: primaryColor.withOpacity(0.2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Icon(icon, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(16),
              ),
            ),
            child: Text(
              amountText,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ======================= WIDGET PHỤ TRỢ: MILESTONES =======================

class _MilestonesCard extends StatelessWidget {
  final ProjectFundState state;
  const _MilestonesCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            blurRadius: 12,
            offset: const Offset(0, 4),
            color: Colors.black.withOpacity(
              theme.brightness == Brightness.dark ? 0.2 : 0.05,
            ),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.flag_rounded, size: 20, color: scheme.primary),
              const SizedBox(width: 8),
              Text(
                'Milestones (${state.milestones.length})',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (state.isLoadingMilestones)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (state.milestones.isEmpty && !state.isLoadingMilestones)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'Không có milestone nào',
                  style: TextStyle(color: theme.hintColor),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.milestones.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) =>
                  _MilestoneRow(milestone: state.milestones[index]),
            ),
        ],
      ),
    );
  }
}

class _MilestoneRow extends StatelessWidget {
  final ProjectMilestoneModel milestone;
  const _MilestoneRow({required this.milestone});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final budgetText = ProjectDataFormatter.formatCurrency(
      context,
      milestone.budget,
    );
    final endDateText = ProjectDataFormatter.formatDate(milestone.endDate);

    return InkWell(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder: (context, scrollController) =>
                MilestoneDetailModal(milestone: milestone),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceVariant.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              milestone.title,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Budget Chip
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),
                  child: Text(
                    budgetText,
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                // Date
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 14,
                      color: theme.hintColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      endDateText,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.hintColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  final String message;
  const _ErrorBox({required this.message});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: scheme.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: scheme.error.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: scheme.error, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: scheme.error, fontSize: 13),
            ),
          ),
          IconButton(
            onPressed: () => context.read<ProjectFundCubit>().clearError(),
            icon: Icon(Icons.close, size: 18, color: scheme.error),
          ),
        ],
      ),
    );
  }
}
