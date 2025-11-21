import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/get_it/get_it.dart';
import '../cubit/hiring_projects_cubit.dart';
import '../cubit/hiring_projects_state.dart';
import '../../domain/entities/project_entity.dart';
import '../../../../shared/widgets/project_card.dart';
import '../../../../shared/widgets/reusable_card.dart';
import '../../../../shared/widgets/service_chip.dart';
import '../../../../shared/widgets/expandable_text.dart';
import 'project_detail_page.dart'; // new import
import '../../../../core/router/app_router.dart';
import '../../../../core/router/route_constants.dart';

// New page: shows projects and triggers loadMoreProjects when scrolling to bottom.
class HiringProjectsPage extends StatefulWidget {
  const HiringProjectsPage({super.key});

  @override
  State<HiringProjectsPage> createState() => _HiringProjectsPageState();
}

class _HiringProjectsPageState extends State<HiringProjectsPage> {
  late final HiringProjectsCubit _cubit;
  final ScrollController _scrollController = ScrollController();
  bool _loadingMoreLock = false;

  @override
  void initState() {
    super.initState();
    // use same DI pattern as ExplorePage
    _cubit = getIt<HiringProjectsCubit>()..loadInitialProjects();

    _scrollController.addListener(() {
      if (_scrollController.position.maxScrollExtent <= 0) return;
      final threshold = 200.0;
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - threshold &&
          !_loadingMoreLock) {
        _loadingMoreLock = true;
        _cubit.loadMoreProjects();
        // release lock after a short delay; cubit/state may also prevent duplicate loads
        Future.delayed(const Duration(milliseconds: 800), () {
          _loadingMoreLock = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    // Do not close cubit if it is managed by getIt as a singleton elsewhere.
    super.dispose();
  }

  Widget _buildProjectItem(ProjectEntity p) {
    String _formatDate(DateTime? d) {
      if (d == null) return 'N/A';
      return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    }

    String _colorHexFromString(String input) {
      final hash = input.hashCode;
      final colorInt = 0xFFFFFF & hash;
      return '#${colorInt.toRadixString(16).padLeft(6, '0')}';
    }

    final role = p.skills.isNotEmpty ? p.skills.first.name : 'N/A';
    final deadline = _formatDate(p.endDate);
    final companyName = p.skills.isNotEmpty ? p.skills.first.description : 'Labodc';

    return ReusableCard(
      onTap: () {
        AppRouter.pushNamed(Routes.projectDetailName, pathParameters: {'id': p.projectId});
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(p.projectName, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(companyName, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7))),
          const SizedBox(height: 8),
          ExpandableText(text: p.description, maxLines: 3, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: p.skills.take(8).map((s) {
              final hex = _colorHexFromString(s.name);
              return ServiceChip(name: s.name, color: hex, small: true);
            }).toList(),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${p.currentApplicants} ứng viên', style: Theme.of(context).textTheme.bodySmall),
              Text('Hạn: $deadline', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.redAccent)),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HiringProjectsCubit>.value(
      value: _cubit,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Tất cả dự án"),
        ),
        body: BlocBuilder<HiringProjectsCubit, HiringProjectsState>(
          builder: (context, state) {
            List<ProjectEntity> projects = [];
            bool isLoading = false;
            bool hasNext = false;

            if (state is HiringProjectsLoaded) {
              projects = state.projects;
              hasNext = state.hasNext;
            } else if (state is HiringProjectsLoading) {
              
              projects = state.oldProjects;
              isLoading = true;
              hasNext = true;
            } else if (state is HiringProjectsInitial) {
              isLoading = true;
            } else if (state is HiringProjectsError) {
              return Center(child: Text('Lỗi: ${state.message}'));
            }

            if (projects.isEmpty && isLoading) {
              return const Center(child: CircularProgressIndicator.adaptive());
            }

            return RefreshIndicator(
              onRefresh: () async {
                await _cubit.loadInitialProjects();
              },
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.only(top: 12, bottom: 24),
                itemCount: projects.length + (hasNext ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index < projects.length) {
                    final p = projects[index];
                    return _buildProjectItem(p);
                  } else {
                    // loading indicator at the bottom when more items expected
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                            SizedBox(width: 12),
                            Text('Đang tải thêm...'),
                          ],
                        ),
                      ),
                    );
                  }
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
