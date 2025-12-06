import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/get_it/get_it.dart';
import '../../../project_application/presentation/cubit/my_projects_cubit.dart';
import '../../../project_application/presentation/cubit/my_projects_state.dart';
import 'my_project_card.dart';

class MyProjectsSection extends StatelessWidget {
  final String title;
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
        // Section Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              // Có thể thêm nút "Xem tất cả" ở đây nếu cần
            ],
          ),
        ),
        const SizedBox(height: 16),

        BlocBuilder<MyProjectsCubit, MyProjectsState>(
          builder: (context, state) {
            if (state.status == MyProjectsStatus.loading) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (state.status == MyProjectsStatus.failure) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(Icons.error_outline_rounded, color: theme.colorScheme.error, size: 32),
                      const SizedBox(height: 8),
                      Text(
                        state.errorMessage ?? 'Không thể tải danh sách dự án.',
                        style: TextStyle(color: theme.colorScheme.error),
                        textAlign: TextAlign.center,
                      ),
                      TextButton.icon(
                        onPressed: () => context.read<MyProjectsCubit>().loadMyProjects(),
                        icon: const Icon(Icons.refresh),
                        label: const Text("Thử lại"),
                      )
                    ],
                  ),
                ),
              );
            }

            if (state.projects.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    Icon(Icons.folder_open_outlined, size: 48, color: Colors.grey.shade400),
                    const SizedBox(height: 12),
                    Text(
                      'Bạn chưa tham gia dự án nào.',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                    ),
                  ],
                ),
              );
            }

            // List of Projects
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 20),
              itemCount: state.projects.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
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