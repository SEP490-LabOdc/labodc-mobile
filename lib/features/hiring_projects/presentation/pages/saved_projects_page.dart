// lib/features/hiring_projects/presentation/pages/saved_projects_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/get_it/get_it.dart';
import '../../../auth/presentation/provider/auth_provider.dart';
import '../cubit/bookmark_projects_cubit.dart';
import '../../domain/entities/project_entity.dart';
import '../widgets/saved_project_card.dart'; // Import card vừa tạo

class SavedProjectsPage extends StatelessWidget {
  const SavedProjectsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUserId = context.read<AuthProvider>().userId ?? "";

    return BlocProvider<BookmarkProjectsCubit>(
      create: (context) => getIt<BookmarkProjectsCubit>()..loadBookmarks(currentUserId),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Dự án đã lưu",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: false,
          elevation: 0,
          backgroundColor: theme.colorScheme.primary,
        ),
        body: BlocBuilder<BookmarkProjectsCubit, List<ProjectEntity>>(
          builder: (context, savedProjects) {
            if (savedProjects.isEmpty) {
              return _buildEmptyState(context);
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: savedProjects.length,
              physics: const BouncingScrollPhysics(),
              separatorBuilder: (context, index) => const SizedBox(height: 4),
              itemBuilder: (context, index) {
                final project = savedProjects[index];

                return SavedProjectCard(
                  project: project,
                  onTap: () {
                    context.push('/hiring-projects/${project.projectId}');
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border_rounded,
            size: 80,
            color: theme.colorScheme.outline.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            "Chưa có dự án nào được lưu",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.pop(),
            child: const Text("Khám phá ngay"),
          ),
        ],
      ),
    );
  }
}