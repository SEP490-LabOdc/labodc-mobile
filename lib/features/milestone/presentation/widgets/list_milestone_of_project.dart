import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/get_it/get_it.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/router/route_constants.dart';
import '../../../hiring_projects/presentation/utils/project_data_formatter.dart';

import '../../data/models/project_milestone_model.dart';
import '../cubit/milestone_cubit.dart';
import '../cubit/milestone_state.dart';

class ListMilestoneOfProject extends StatelessWidget {
  final String projectId;

  const ListMilestoneOfProject({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<MilestoneCubit>()..loadMilestones(projectId),
      child: BlocBuilder<MilestoneCubit, MilestoneState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (state.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 48,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.errorMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.tonalIcon(
                      onPressed: () => context
                          .read<MilestoneCubit>()
                          .loadMilestones(projectId),
                      icon: const Icon(Icons.refresh),
                      label: const Text("Thử lại"),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state.milestones.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.flag_outlined,
                      size: 40,
                      color: Colors.grey.shade400,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Chưa có cột mốc nào",
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 100), // Bottom padding for FAB
            itemCount: state.milestones.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (_, index) {
              final ms = state.milestones[index];
              return _MilestoneCard(m: ms);
            },
          );
        },
      ),
    );
  }
}

class _MilestoneCard extends StatelessWidget {
  final ProjectMilestoneModel m;

  const _MilestoneCard({required this.m});

  @override
  Widget build(BuildContext context) {
    // Sử dụng formatter mới cho Milestone Status
    final statusColor = ProjectDataFormatter.getMilestoneStatusColor(m.status);
    final statusText = ProjectDataFormatter.translateMilestoneStatus(m.status);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            AppRouter.pushNamed(
              Routes.milestoneDetailName,
              pathParameters: {'id': m.id},
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // === HEADER: TITLE & STATUS ===
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        m.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          height: 1.3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: statusColor.withOpacity(0.2), width: 1),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // === DESCRIPTION ===
                if (m.description.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      m.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        height: 1.5,
                      ),
                    ),
                  ),

                const Divider(height: 1, thickness: 0.5),
                const SizedBox(height: 12),

                // === FOOTER: INFO ROW ===
                Row(
                  children: [
                    // Budget
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.monetization_on_outlined,
                            size: 16,
                            color: Colors.green.shade700,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            ProjectDataFormatter.formatCurrency(context, m.budget),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // Date Range
                    Icon(
                      Icons.calendar_month_outlined,
                      size: 14,
                      color: Colors.grey.shade500,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "${ProjectDataFormatter.formatDate(m.startDate)} - ${ProjectDataFormatter.formatDate(m.endDate)}",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}