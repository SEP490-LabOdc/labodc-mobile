import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/get_it/get_it.dart';
import '../../../project_application/presentation/cubit/my_projects_cubit.dart';
import '../../../project_application/presentation/cubit/my_projects_state.dart';
import 'my_project_card.dart';

class MyProjectsSection extends StatelessWidget {
  final String title;

  /// Nếu muốn load dữ liệu khi widget được tạo
  final bool autoLoad;

  const MyProjectsSection({
    super.key,
    this.title = 'Dự án của tôi',
    this.autoLoad = true,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MyProjectsCubit(
        repository: getIt(),
      )..loadMyProjects(),
      child: _MyProjectsView(title: title),
    );
  }
}

class _MyProjectsView extends StatelessWidget {
  final String title;

  const _MyProjectsView({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),

        BlocBuilder<MyProjectsCubit, MyProjectsState>(
          builder: (context, state) {
            if (state.status == MyProjectsStatus.loading) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (state.status == MyProjectsStatus.failure) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  state.errorMessage ?? 'Không thể tải danh sách dự án.',
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              );
            }

            if (state.projects.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'Bạn chưa tham gia dự án nào.',
                  style: theme.textTheme.bodyMedium,
                ),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.projects.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final project = state.projects[index];
                return MyProjectCard.fromModel(project);
              },
            );
          },
        ),
      ],
    );
  }
}
