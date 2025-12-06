import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:labodc_mobile/shared/widgets/service_chip.dart';

// Import các file BLoC/Cubit và Entity
import '../../../../core/get_it/get_it.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/router/route_constants.dart';
import '../../../hiring_projects/domain/entities/project_entity.dart';
import '../../../hiring_projects/presentation/cubit/hiring_projects_cubit.dart';
import '../../../hiring_projects/presentation/cubit/hiring_projects_state.dart';
import '../../../hiring_projects/presentation/pages/hiring_projects_page.dart';
import '../../../hiring_projects/presentation/pages/project_detail_page.dart';
import '../../../hiring_projects/presentation/utils/project_data_formatter.dart';

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
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          title: Text(
            'Khám phá',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          elevation: 0,
          centerTitle: false,
        ),
        body: Column(
          children: [
            // --- SEARCH BAR (Fixed at top) ---
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
              ),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: TextField(
                  controller: _searchController,
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    hintText: "Tìm kiếm dự án, kỹ năng...",
                    hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                    prefixIcon: Icon(Icons.search, color: theme.primaryColor, size: 22),
                    suffixIcon: Container(
                      margin: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 2)
                          ]
                      ),
                      child: Icon(Icons.tune, size: 18, color: Colors.grey.shade700),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    isDense: true,
                  ),
                  onSubmitted: (value) {
                    // TODO: Handle search
                  },
                ),
              ),
            ),

            // --- CONTENT LIST (Scrollable) ---
            Expanded(
              child: BlocBuilder<HiringProjectsCubit, HiringProjectsState>(
                builder: (context, state) {
                  final isFirstLoad = state is HiringProjectsInitial || (state is HiringProjectsLoading && state.isFirstFetch);
                  if (isFirstLoad) {
                    return const Center(child: CircularProgressIndicator.adaptive());
                  }

                  return AnimationLimiter(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                      children: AnimationConfiguration.toStaggeredList(
                        duration: const Duration(milliseconds: 375),
                        childAnimationBuilder: (widget) => SlideAnimation(
                          verticalOffset: 50.0,
                          child: FadeInAnimation(child: widget),
                        ),
                        children: [
                          _buildQuickFilters(theme),
                          const SizedBox(height: 24),
                          _buildHiringProjectsSection(context, theme),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickFilters(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.auto_awesome, size: 18, color: theme.primaryColor),
            const SizedBox(width: 8),
            Text(
              "Gợi ý cho bạn",
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _popularFilters.map((filter) => Padding(
              padding: const EdgeInsets.only(right: 10),
              child: FilterChip(
                label: Text(filter),
                onSelected: (bool selected) {},
                backgroundColor: Colors.white,
                selectedColor: theme.primaryColor.withOpacity(0.1),
                checkmarkColor: theme.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  fontSize: 13,
                ),
              ),
            )).toList(),
          ),
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
          showViewAllButton = state.displayLimit == 3 && state.totalElements > 3 && projectsToShow.length >= 3;
          showLoadMoreButton = state.displayLimit >= cubit.getInitialPageSize() && state.hasNext;

          if (showLoadMoreButton) {
            footer = Padding(
              padding: const EdgeInsets.only(top: 24.0),
              child: Center(
                child: FilledButton.tonal(
                  onPressed: cubit.loadMoreProjects,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: Text('Tải thêm ${cubit.getSubsequentPageSize()} dự án'),
                ),
              ),
            );
          }
        } else if (state is HiringProjectsLoading) {
          projectsToShow = state.oldProjects.take(cubit.getCurrentDisplayLimit()).toList();
          isLoadingMore = true;
          footer = const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator.adaptive()));
        } else if (state is HiringProjectsError) {
          footer = Center(child: Text('Lỗi: ${state.message}', style: TextStyle(color: theme.colorScheme.error)));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Dự án mới nhất",
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                if (showViewAllButton)
                  TextButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const HiringProjectsPage()),
                    ),
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      textStyle: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    child: const Text("Xem tất cả"),
                  )
              ],
            ),
            const SizedBox(height: 16),

            if (projectsToShow.isEmpty && !isLoadingMore && !(state is HiringProjectsInitial) && !(state is HiringProjectsError))
              _buildEmptyState()
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: projectsToShow.length,
                separatorBuilder: (ctx, index) => const SizedBox(height: 16),
                itemBuilder: (ctx, index) => HiringProjectCard(project: projectsToShow[index]),
              ),

            footer,
          ],
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.search_off_rounded, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(
            "Không tìm thấy dự án nào",
            style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

// 🔥 Widget Card Dự Án Mới (Được thiết kế lại chuẩn Enterprise UI)
class HiringProjectCard extends StatelessWidget {
  final ProjectEntity project;

  const HiringProjectCard({required this.project, super.key});

  String _colorHexFromString(String input) {
    final hash = input.hashCode;
    final colorInt = 0xFFFFFF & hash;
    return '#${colorInt.toRadixString(16).padLeft(6, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final companyName = project.skills.isNotEmpty ? project.skills.first.description : 'Labodc Inc.';
    final deadline = project.endDate != null ? ProjectDataFormatter.formatDate(project.endDate!) : 'N/A';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
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
            AppRouter.pushNamed(Routes.projectDetailName, pathParameters: {'id': project.projectId});
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // === HEADER ===
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.business_center_outlined, color: Colors.blue.shade700, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // HERO Title
                          Hero(
                            tag: 'hiring_project_title_${project.projectId}',
                            child: Material(
                              color: Colors.transparent,
                              child: Text(
                                project.projectName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                  height: 1.3,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            companyName,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // === SKILLS (Chips) ===
                if (project.skills.isNotEmpty) ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: project.skills.map((s) {
                      final hex = _colorHexFromString(s.name);
                      return ServiceChip(name: s.name, color: hex, small: true);
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                ],

                // === DESCRIPTION ===
                Text(
                  project.description,
                  style: TextStyle(color: Colors.grey.shade700, height: 1.5, fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Divider(height: 1, thickness: 0.5),
                ),

                // === FOOTER (Metrics) ===
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildFooterItem(
                      icon: Icons.people_outline,
                      text: "${project.currentApplicants} Ứng viên",
                      color: Colors.blue.shade700,
                      bgColor: Colors.blue.shade50,
                    ),

                    Row(
                      children: [
                        Icon(Icons.access_time, size: 14, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Text(
                          "Hạn: $deadline",
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooterItem({
    required IconData icon,
    required String text,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}