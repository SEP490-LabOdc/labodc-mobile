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
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- SECTION HEADER ---
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  // Tự động đổi màu dựa trên Brightness của Theme
                  color: colorScheme.onSurface,
                ),
              ),
              // Thêm nút Xem tất cả nếu cần, sử dụng textButtonTheme đã định nghĩa
              // TextButton(
              //     onPressed: () {},
              //     child: const Text('Xem tất cả')
              // ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        BlocBuilder<MyProjectsCubit, MyProjectsState>(
          builder: (context, state) {
            // --- LOADING STATE ---
            if (state.status == MyProjectsStatus.loading) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            // --- FAILURE STATE ---
            if (state.status == MyProjectsStatus.failure) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(
                          Icons.error_outline_rounded,
                          color: colorScheme.error,
                          size: 40
                      ),
                      const SizedBox(height: 12),
                      Text(
                        state.errorMessage ?? 'Không thể tải danh sách dự án.',
                        style: TextStyle(color: colorScheme.error),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: () => context.read<MyProjectsCubit>().loadMyProjects(),
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text("Thử lại"),
                      )
                    ],
                  ),
                ),
              );
            }

            // --- EMPTY STATE ---
            if (state.projects.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 16),
                decoration: BoxDecoration(
                  // Sử dụng surfaceVariant hoặc màu nền nhẹ tùy chỉnh cho cả 2 mode
                  color: colorScheme.surfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
                ),
                child: Column(
                  children: [
                    Icon(
                        Icons.folder_open_outlined,
                        size: 64,
                        color: theme.hintColor.withOpacity(0.5)
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Bạn chưa tham gia dự án nào.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.hintColor,
                      ),
                    ),
                  ],
                ),
              );
            }

            // --- LIST OF PROJECTS ---
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