import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/get_it/get_it.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/router/route_constants.dart';
import '../../../hiring_projects/presentation/utils/project_data_formatter.dart';

import '../../data/models/project_milestone_model.dart';
import '../cubit/milestone_cubit.dart';
import '../cubit/milestone_state.dart';
import '../../../../shared/widgets/reusable_card.dart';

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
            return const Center(child: CircularProgressIndicator());
          }

          if (state.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  state.errorMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }

          if (state.milestones.isEmpty) {
            return const Center(child: Text("Chưa có cột mốc nào."));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: state.milestones.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
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
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        AppRouter.pushNamed(Routes.milestoneDetailName, pathParameters: {'id': m.id}
        );
      },
      child: ReusableCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== Title + Status =====
            Row(
              children: [
                Expanded(
                  child: Text(
                    m.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: ProjectDataFormatter.getStatusColor(m.status)
                        .withOpacity(0.15),
                  ),
                  child: Text(
                    ProjectDataFormatter.translateStatus(m.status),
                    style: TextStyle(
                      color: ProjectDataFormatter.getStatusColor(m.status),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // ===== Date range =====
            Row(
              children: [
                Icon(
                  Icons.calendar_month,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  "${ProjectDataFormatter.formatDate(m.startDate)} → "
                      "${ProjectDataFormatter.formatDate(m.endDate)}",
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ===== Description =====
            Text(
              m.description,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
            ),

            const SizedBox(height: 12),

            // ===== Budget =====
            Row(
              children: [
                Icon(
                  Icons.monetization_on_outlined,
                  size: 18,
                  color: Colors.green.shade700,
                ),
                const SizedBox(width: 6),
                Text(
                  ProjectDataFormatter.formatCurrency(context, m.budget),
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: Colors.green.shade800,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
