import 'dart:async'; // Quan trọng cho Debounce
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:labodc_mobile/shared/widgets/expandable_text.dart';
import 'package:labodc_mobile/shared/widgets/service_chip.dart';

// Core & Providers
import '../../../../core/get_it/get_it.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/router/route_constants.dart';
import '../../../hiring_projects/domain/entities/project_entity.dart';
import '../../../hiring_projects/presentation/cubit/hiring_projects_cubit.dart';
import '../../../hiring_projects/presentation/cubit/hiring_projects_state.dart';
import '../../../hiring_projects/presentation/pages/hiring_projects_page.dart';
import '../../../hiring_projects/presentation/utils/project_data_formatter.dart';
import '../../../company/domain/entities/company_entity.dart';
import '../../../company/presentation/widgets/company_card.dart';
import '../../../company/presentation/widgets/company_explore_section.dart';
import '../../../hiring_projects/presentation/cubit/search_projects_cubit.dart';
import '../../../company/presentation/cubit/search_companies_cubit.dart';
import '../../../../shared/states/search_state.dart';
import '../../../../shared/models/search_request_model.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late TabController _tabController;
  late SearchProjectsCubit _searchProjectsCubit;
  late SearchCompaniesCubit _searchCompaniesCubit;

  String _currentSearchQuery = '';
  Timer? _debounce;
  bool _isLoadingMore = false;

  // Trạng thái sắp xếp: DESC = Mới nhất, ASC = Cũ nhất
  String _sortDirection = 'DESC';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchProjectsCubit = getIt<SearchProjectsCubit>();
    _searchCompaniesCubit = getIt<SearchCompaniesCubit>();
    _searchController.addListener(_onSearchChanged);
    _scrollController.addListener(_onScroll);
  }

  // Auto-pagination when scroll near bottom
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      if (!_isLoadingMore && _currentSearchQuery.isNotEmpty) {
        _loadMoreResults();
      }
    }
  }

  void _loadMoreResults() {
    setState(() => _isLoadingMore = true);
    final currentTab = _tabController.index;
    if (currentTab == 0) {
      // Load more projects
      final state = _searchProjectsCubit.state;
      if (state is SearchLoaded && state.hasNext) {
        _searchProjectsCubit.loadMore(
          _currentSearchQuery,
          state.currentPage,
          10,
        );
      }
    } else {
      // Load more companies
      final state = _searchCompaniesCubit.state;
      if (state is SearchLoaded && state.hasNext) {
        _searchCompaniesCubit.loadMore(
          _currentSearchQuery,
          state.currentPage,
          10,
        );
      }
    }
    setState(() => _isLoadingMore = false);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    _tabController.dispose();
    // ✅ FIXED: Don't close singleton cubits from GetIt!
    // They're shared across app, closing them causes crashes
    // _searchProjectsCubit.close(); // ❌ REMOVED
    // _searchCompaniesCubit.close(); // ❌ REMOVED
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      final query = _searchController.text.trim();
      if (query != _currentSearchQuery) {
        setState(() => _currentSearchQuery = query);
        _triggerSearch(query);
      }
    });
  }

  void _triggerSearch(String query) {
    if (query.isNotEmpty) {
      // Convert string direction to SortDirection enum
      final direction = _sortDirection == 'DESC'
          ? SortDirection.desc
          : SortDirection.asc;
      _searchProjectsCubit.search(query, direction: direction);
      _searchCompaniesCubit.search(query, direction: direction);
    } else {
      _searchProjectsCubit.clearSearch();
      _searchCompaniesCubit.clearSearch();
    }
  }

  void _toggleSort() {
    setState(() {
      _sortDirection = (_sortDirection == 'DESC') ? 'ASC' : 'DESC';
    });
    // Gọi lại search khi đổi hướng sắp xếp
    if (_currentSearchQuery.isNotEmpty) {
      _triggerSearch(_currentSearchQuery);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MultiBlocProvider(
      providers: [
        BlocProvider<HiringProjectsCubit>(
          create: (context) =>
              getIt<HiringProjectsCubit>()..loadInitialProjects(),
        ),
        BlocProvider<SearchProjectsCubit>.value(value: _searchProjectsCubit),
        BlocProvider<SearchCompaniesCubit>.value(value: _searchCompaniesCubit),
      ],
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text(
            'Khám phá',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          elevation: 0,
        ),
        body: Column(
          children: [
            _buildSearchBar(theme),
            Expanded(
              child: _currentSearchQuery.isNotEmpty
                  ? _buildSearchResults()
                  : _buildDefaultContent(theme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      color: theme.cardColor,
      child: Row(
        children: [
          // Thanh tìm kiếm
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: theme.brightness == Brightness.dark
                    ? theme.colorScheme.surface
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.dividerColor),
              ),
              child: BlocBuilder<SearchProjectsCubit, SearchState>(
                builder: (context, state) {
                  final isLoading = state is SearchLoading && state.isFirstLoad;
                  return TextField(
                    controller: _searchController,
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                      hintText: "Tìm kiếm dự án, công ty...",
                      hintStyle: TextStyle(
                        color: theme.hintColor,
                        fontSize: 14,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: theme.primaryColor,
                        size: 22,
                      ),
                      // Loading indicator in search bar
                      suffixIcon: isLoading
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                          : _currentSearchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchController.clear();
                              },
                            )
                          : null,
                      border: InputBorder.none,
                    ),
                  );
                },
              ),
            ),
          ),

          if (_currentSearchQuery.isNotEmpty) ...[
            const SizedBox(width: 12),
            PopupMenuButton<String>(
              icon: Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.primaryColor.withOpacity(0.2),
                  ),
                ),
                child: Icon(
                  Icons.filter_list_rounded,
                  color: theme.primaryColor,
                  size: 24,
                ),
              ),
              offset: const Offset(0, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onSelected: (String value) {
                setState(() {
                  _sortDirection = value;
                });
                _triggerSearch(_currentSearchQuery);
              },
              itemBuilder: (BuildContext context) => [
                _buildPopupItem(
                  value: 'DESC',
                  icon: Icons.history_rounded,
                  title: 'Mới nhất',
                  isSelected: _sortDirection == 'DESC',
                ),
                _buildPopupItem(
                  value: 'ASC',
                  icon: Icons.update_rounded,
                  title: 'Cũ nhất',
                  isSelected: _sortDirection == 'ASC',
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // Helper widget để tạo item cho PopupMenu cho đồng nhất UI
  PopupMenuItem<String> _buildPopupItem({
    required String value,
    required IconData icon,
    required String title,
    required bool isSelected,
  }) {
    final theme = Theme.of(context);
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isSelected
                ? theme.colorScheme.primary
                : theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.textTheme.bodyMedium?.color,
            ),
          ),
          if (isSelected) ...[
            const Spacer(),
            Icon(
              Icons.check_circle,
              size: 16,
              color: theme.colorScheme.primary,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDefaultContent(ThemeData theme) {
    return AnimationLimiter(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildQuickFilters(theme),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(child: _buildSectionHeader(theme)),
          ),
          _buildHiringProjectsSliverList(),
          const SliverPadding(
            padding: EdgeInsets.only(top: 24, bottom: 80),
            sliver: SliverToBoxAdapter(child: CompanyExploreSection()),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme) {
    return BlocBuilder<HiringProjectsCubit, HiringProjectsState>(
      builder: (context, state) {
        final hasMore =
            state is HiringProjectsLoaded && state.totalElements > 3;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Dự án mới nhất",
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (hasMore)
              TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const HiringProjectsPage()),
                ),
                child: const Text("Xem tất cả"),
              ),
          ],
        );
      },
    );
  }

  Widget _buildHiringProjectsSliverList() {
    return BlocBuilder<HiringProjectsCubit, HiringProjectsState>(
      builder: (context, state) {
        List<ProjectEntity> projects = [];
        if (state is HiringProjectsLoaded)
          projects = state.projects.take(state.displayLimit).toList();
        if (state is HiringProjectsLoading) projects = state.oldProjects;

        if (projects.isEmpty)
          return SliverToBoxAdapter(child: _buildEmptyState());

        return SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: HiringProjectCard(project: projects[index]),
              ),
              childCount: projects.length,
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchResults() {
    return MultiBlocListener(
      listeners: [
        // ✅ ADDED: Error handling for Projects search
        BlocListener<SearchProjectsCubit, SearchState>(
          listener: (context, state) {
            if (state is SearchError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Lỗi tìm kiếm dự án: ${state.message}'),
                  backgroundColor: Theme.of(context).colorScheme.error,
                  action: SnackBarAction(
                    label: 'Thử lại',
                    textColor: Colors.white,
                    onPressed: () => _triggerSearch(_currentSearchQuery),
                  ),
                  duration: const Duration(seconds: 4),
                ),
              );
            }
          },
        ),
        // ✅ ADDED: Error handling for Companies search
        BlocListener<SearchCompaniesCubit, SearchState>(
          listener: (context, state) {
            if (state is SearchError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Lỗi tìm kiếm công ty: ${state.message}'),
                  backgroundColor: Theme.of(context).colorScheme.error,
                  action: SnackBarAction(
                    label: 'Thử lại',
                    textColor: Colors.white,
                    onPressed: () => _triggerSearch(_currentSearchQuery),
                  ),
                  duration: const Duration(seconds: 4),
                ),
              );
            }
          },
        ),
      ],
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Dự án'),
              Tab(text: 'Công ty'),
            ],
            labelColor: Theme.of(context).primaryColor,
            indicatorColor: Theme.of(context).primaryColor,
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSearchListView<ProjectEntity, SearchProjectsCubit>(),
                _buildSearchListView<CompanyEntity, SearchCompaniesCubit>(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchListView<T, C extends Cubit<SearchState>>() {
    return BlocBuilder<C, SearchState>(
      builder: (context, state) {
        if (state is SearchLoading && state.isFirstLoad)
          return const Center(child: CircularProgressIndicator.adaptive());
        if (state is SearchLoaded<T>) {
          if (state.items.isEmpty) return _buildEmptyState();
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: state.items.length + (state.hasNext ? 1 : 0),
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (ctx, index) {
              if (index == state.items.length) {
                return Center(
                  child: FilledButton.tonal(
                    onPressed: () => (context.read<C>() as dynamic).loadMore(
                      _currentSearchQuery,
                      state.currentPage,
                      10,
                    ),
                    child: const Text("Tải thêm"),
                  ),
                );
              }
              final item = state.items[index];
              return item is ProjectEntity
                  ? HiringProjectCard(project: item)
                  : CompanyCard(company: item as CompanyEntity);
            },
          );
        }
        return const Center(child: Text("Nhập từ khóa để tìm kiếm"));
      },
    );
  }

  Widget _buildQuickFilters(ThemeData theme) {
    // ✅ REMOVED: Filter chips were non-functional (onSelected: (_) {})
    // This was misleading to users who clicked expecting filtering
    // TODO: Implement real filtering logic or keep this removed
    return const SizedBox.shrink();
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 48,
              color: theme.disabledColor,
            ),
            Text(
              "Không tìm thấy kết quả",
              style: TextStyle(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HiringProjectCard extends StatelessWidget {
  final ProjectEntity project;
  const HiringProjectCard({required this.project, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final deadline = project.endDate != null
        ? ProjectDataFormatter.formatDate(project.endDate!)
        : 'N/A';

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => AppRouter.pushNamed(
          Routes.projectDetailName,
          pathParameters: {'id': project.projectId},
        ),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.business_center_outlined,
                      color: Colors.blue.shade700,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project.projectName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        ExpandableText(
                          text: project.description,
                          maxLines: 2,
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.color?.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (project.skills.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: project.skills
                      .map(
                        (s) => ServiceChip(
                          name: s.name,
                          color: '#2196F3',
                          small: true,
                        ),
                      )
                      .toList(),
                ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Divider(height: 1, thickness: 0.5),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildFooterBadge(
                    Icons.people_outline,
                    "${project.currentApplicants} Ứng viên",
                  ),
                  Text(
                    "Hạn: $deadline",
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooterBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.blue.shade700),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
