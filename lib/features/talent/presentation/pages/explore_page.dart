// lib/features/talent/presentation/pages/explore_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:labodc_mobile/shared/widgets/service_chip.dart';

// Import các file BLoC/Cubit và Entity đã định nghĩa
import '../../../../core/get_it/get_it.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/router/route_constants.dart';
import '../../../hiring_projects/domain/entities/project_entity.dart';
import '../../../hiring_projects/presentation/cubit/hiring_projects_cubit.dart';
import '../../../hiring_projects/presentation/cubit/hiring_projects_state.dart';
import '../../../hiring_projects/presentation/pages/hiring_projects_page.dart';
import '../../../hiring_projects/presentation/pages/project_detail_page.dart'; // add import

import '../../../../shared/widgets/project_card.dart';
import '../../../../shared/widgets/reusable_card.dart';
import '../../../../shared/widgets/expandable_text.dart';
import '../widgets/talent_list_item.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _popularFilters = ['Flutter', 'Backend', 'UI/UX', 'Marketing', 'Content'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider<HiringProjectsCubit>(
      create: (context) => getIt<HiringProjectsCubit>()..loadInitialProjects(),
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            _buildSliverAppBar(theme),

            BlocBuilder<HiringProjectsCubit, HiringProjectsState>(
                builder: (context, state) {
                  // Kiểm tra nếu đang loading lần đầu, không hiển thị các section khác
                  final isFirstLoad = state is HiringProjectsInitial || (state is HiringProjectsLoading && state.isFirstFetch);
                  if (isFirstLoad) {
                    return const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator.adaptive()),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.all(16.0),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate(
                        AnimationConfiguration.toStaggeredList(
                          duration: const Duration(milliseconds: 375),
                          childAnimationBuilder: (widget) => SlideAnimation(
                            verticalOffset: 50.0,
                            child: FadeInAnimation(child: widget),
                          ),
                          children: [
                            // 1. Quick Filters
                            _buildQuickFilters(theme),
                            const SizedBox(height: 24),

                            // 2. New Projects Section (Tích hợp Cubit)
                            _buildHiringProjectsSection(context, theme),
                            const SizedBox(height: 24),

                            // 3. Suggested Talents Section
                            // _buildSuggestedTalentsSection(theme),
                          ],
                        ),
                      ),
                    ),
                  );
                }
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(ThemeData theme) {
    return SliverAppBar(
      title: const Text("Khám phá", style: TextStyle(fontWeight: FontWeight.bold),),
      pinned: true,
      floating: true,
      expandedHeight: 120,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        titlePadding: EdgeInsets.zero,
        background: Padding(
          padding: const EdgeInsets.fromLTRB(16, 60, 16, 8),
          child: Container(
            alignment: Alignment.bottomCenter,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Tìm kiếm dự án, hoặc tài năng...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
              ),
              onSubmitted: (value) {
                // TODO: Xử lý logic tìm kiếm
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickFilters(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Lọc nhanh theo chuyên môn",
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _popularFilters.map((filter) => ServiceChip(
            name: filter,
            color: '#${(0xFF000000 + filter.hashCode % 0xFFFFFF).toRadixString(16).padLeft(6, '0')}',
            small: false,
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildHiringProjectsSection(BuildContext context, ThemeData theme) {
    final cubit = context.read<HiringProjectsCubit>();
    return BlocBuilder<HiringProjectsCubit, HiringProjectsState>(
      builder: (context, state) {
        List<ProjectEntity> projectsToShow = [];
        bool showViewAllButton = false;
        bool showLoadMoreButton = false;
        bool isLoadingMore = false;
        Widget footer = const SizedBox.shrink();

        if (state is HiringProjectsLoaded) {
          projectsToShow = state.projects.take(state.displayLimit).toList();

          // 2. Logic hiển thị nút "Xem tất cả" (từ 3 lên 10)
          showViewAllButton = state.displayLimit == 3 && state.totalElements > 3 && projectsToShow.length >= 3;

          // 3. Logic hiển thị nút "Tải thêm" (khi đã >= 10 và còn data)
          showLoadMoreButton = state.displayLimit >= cubit.getInitialPageSize() && state.hasNext;

          if (showLoadMoreButton) {
            footer = Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: TextButton(
                onPressed: cubit.loadMoreProjects,
                child: Text('Tải thêm ${cubit.getSubsequentPageSize()} dự án'),
              ),
            );
          } else if (!state.hasNext && state.totalElements > 0) {
            footer = const Padding(
              padding: EdgeInsets.only(top: 16.0),
            );
          }
        } else if (state is HiringProjectsLoading) {
          projectsToShow = state.oldProjects.take(cubit.getCurrentDisplayLimit()).toList();
          isLoadingMore = true;
          footer = const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator.adaptive()));
        } else if (state is HiringProjectsError) {
          footer = Center(child: Text('Lỗi tải dữ liệu: ${state.message}', style: const TextStyle(color: Colors.red)));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Dự án mới: Cơ hội hàng đầu",
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                if (showViewAllButton)
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const HiringProjectsPage(),
                        ),
                      );
                    },
                    child: const Text("Xem tất cả"),
                  )
                else if (showLoadMoreButton && !isLoadingMore)
                  TextButton(
                    onPressed: cubit.loadMoreProjects,
                    child: const Text("Tải thêm"),
                  )
              ],
            ),
            const SizedBox(height: 12),
            if (projectsToShow.isEmpty && !isLoadingMore && !(state is HiringProjectsInitial) && !(state is HiringProjectsError))
              const Center(child: Padding(padding: EdgeInsets.all(16), child: Text('Không có dự án mới nào.')))
            else
            // Hiển thị danh sách dự án
              ...projectsToShow.map((project) => HiringProjectListItem(project: project)).toList(),

            footer,
          ],
        );
      },
    );
  }

  // Widget _buildSuggestedTalentsSection(ThemeData theme) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text(
  //         "Talent khác: Có thể bạn muốn kết nối",
  //         style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
  //       ),
  //       const SizedBox(height: 12),
  //       const TalentListItem(
  //         name: "Trần Thị B",
  //         role: "Chuyên gia Backend (Java/Spring)",
  //         avatarUrl: "https://randomuser.me/api/portraits/women/12.jpg",
  //         skills: ["Java", "Spring Boot", "REST API", "MongoDB"],
  //       ),
  //       const TalentListItem(
  //         name: "Lê Văn C",
  //         role: "Frontend & Mobile (React Native)",
  //         avatarUrl: "https://randomuser.me/api/portraits/men/45.jpg",
  //         skills: ["React Native", "TypeScript", "Redux", "CI/CD"],
  //       ),
  //     ],
  //   );
  // }
}

// Widget hiển thị ProjectEntity
class HiringProjectListItem extends StatelessWidget {
  final ProjectEntity project;

  const HiringProjectListItem({required this.project, super.key});

  String _formatDateSafe(DateTime? d) {
    if (d == null) return 'N/A';
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  String _colorHexFromString(String input) {
    final hash = input.hashCode;
    final colorInt = 0xFFFFFF & hash;
    return '#${colorInt.toRadixString(16).padLeft(6, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final companyName = project.skills.isNotEmpty ? project.skills.first.description : 'Labodc';
    final deadline = _formatDateSafe(project.endDate);
    return ReusableCard(
      onTap: () {
        AppRouter.pushNamed(Routes.projectDetailName, pathParameters: {'id': project.projectId});
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            project.projectName,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            companyName,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
          ),
          const SizedBox(height: 8),
          ExpandableText(text: project.description, maxLines: 2, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: project.skills.take(6).map((s) {
              final hex = _colorHexFromString(s.name);
              return ServiceChip(name: s.name, color: hex, small: true);
            }).toList(),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Ứng viên: ${project.currentApplicants}', style: Theme.of(context).textTheme.bodySmall),
              Text('Hạn: $deadline', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.redAccent)),
            ],
          ),
        ],
      ),
    );
  }
}