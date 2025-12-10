import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../hiring_projects/presentation/utils/project_data_formatter.dart';
import '../cubit/project_fund_cubit.dart';
import '../cubit/project_fund_state.dart';
import 'package:labodc_mobile/core/get_it/get_it.dart';

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
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: SafeArea(
        child: BlocBuilder<ProjectFundCubit, ProjectFundState>(
          builder: (context, state) {
            if (state.isInitialLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            return RefreshIndicator(
              onRefresh: () => context.read<ProjectFundCubit>().loadInitial(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: scheme.primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.account_balance_wallet_outlined,
                            color: scheme.primary,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Quản lý Quỹ Nhóm',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Phân bổ và quản lý nguồn tiền cho các thành viên trong nhóm',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: Colors.grey[700]),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Chọn dự án
                    Text(
                      'Chọn dự án:',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _ProjectDropdown(state: state),

                    if (state.errorMessage != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: scheme.error,
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              state.errorMessage!,
                              style: TextStyle(color: scheme.error),
                            ),
                          ),
                          IconButton(
                            onPressed: () => context
                                .read<ProjectFundCubit>()
                                .clearError(),
                            icon: const Icon(Icons.close, size: 18),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 24),

                    // 2 thẻ Đang giữ / Đã chia (dùng formatter)
                    Row(
                      children: [
                        Expanded(
                          child: _FundSummaryCard(
                            title: 'Đang Giữ',
                            icon: Icons.credit_card_outlined,
                            backgroundColor: const Color(0xFF5B5FFF),
                            amountText: ProjectDataFormatter.formatCurrency(
                              context,
                              state.holdingAmount,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _FundSummaryCard(
                            title: 'Đã Chia',
                            icon: Icons.show_chart_outlined,
                            backgroundColor: const Color(0xFF00B56A),
                            amountText: ProjectDataFormatter.formatCurrency(
                              context,
                              state.distributedAmount,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Card Milestones
                    _MilestonesCard(
                      state: state,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ======================= DROPDOWN =======================

class _ProjectDropdown extends StatelessWidget {
  final ProjectFundState state;

  const _ProjectDropdown({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.projects.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey[200],
        ),
        child: const Text('Bạn chưa có dự án nào.'),
      );
    }

    return DropdownButtonFormField<MyProjectModel>(
      value: state.selectedProject,
      isExpanded: true,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(999)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 1.6,
          ),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      items: state.projects
          .map(
            (p) => DropdownMenuItem<MyProjectModel>(
          value: p,
          child: Text(
            p.title,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      )
          .toList(),
      onChanged: (project) {
        if (project != null) {
          context.read<ProjectFundCubit>().selectProject(project);
        }
      },
    );
  }
}

// ======================= SUMMARY CARDS =======================

class _FundSummaryCard extends StatelessWidget {
  final String title;
  final String amountText;
  final Color backgroundColor;
  final IconData icon;

  const _FundSummaryCard({
    required this.title,
    required this.amountText,
    required this.backgroundColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            offset: const Offset(0, 4),
            color: Colors.black.withOpacity(0.12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top colored area
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  const SizedBox(width: 2),
                  Icon(icon, color: Colors.white, size: 22),
                  const SizedBox(width: 6),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Amount
          Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
            ),
            alignment: Alignment.centerLeft,
            child: Text(
              amountText,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

// ======================= MILESTONES CARD =======================

class _MilestonesCard extends StatelessWidget {
  final ProjectFundState state;

  const _MilestonesCard({
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            blurRadius: 8,
            offset: const Offset(0, 2),
            color: Colors.black.withOpacity(0.05),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Milestones
          Row(
            children: [
              Icon(
                Icons.layers_outlined,
                size: 20,
                color: scheme.primary.withOpacity(0.9),
              ),
              const SizedBox(width: 6),
              Text(
                'Milestones (${state.milestones.length})',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              if (state.isLoadingMilestones)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          const SizedBox(height: 12),

          if (state.milestones.isEmpty && !state.isLoadingMilestones)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  'Không có milestone nào đang mở',
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.milestones.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final m = state.milestones[index];
                return _MilestoneRow(
                  milestone: m,
                );
              },
            ),
        ],
      ),
    );
  }
}

// ======================= MILESTONE ROW =======================

class _MilestoneRow extends StatelessWidget {
  final ProjectMilestoneModel milestone;

  const _MilestoneRow({
    required this.milestone,
  });

  @override
  Widget build(BuildContext context) {
    final budgetText =
    ProjectDataFormatter.formatCurrency(context, milestone.budget);
    final endDateText = ProjectDataFormatter.formatDate(milestone.endDate);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        color: Colors.white,
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + "Còn lại"
          Row(
            children: [
              Expanded(
                child: Text(
                  milestone.title,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Còn lại',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Budget chip
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  border: const Border.fromBorderSide(
                    BorderSide(color: Color(0xFF00B56A)),
                  ),
                  color: const Color(0xFFE8FFF4),
                ),
                child: Text(
                  budgetText,
                  style: const TextStyle(
                    color: Color(0xFF00B56A),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // End date
          Row(
            children: [
              Icon(Icons.access_time, size: 16, color: Colors.grey.shade500),
              const SizedBox(width: 4),
              Text(
                endDateText,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
