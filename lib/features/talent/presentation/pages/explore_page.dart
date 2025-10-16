// lib/features/talent/presentation/pages/explore_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../../../shared/widgets/project_card.dart';
import '../../../../shared/widgets/service_chip.dart';
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

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(theme),

          SliverPadding(
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

                    // 2. New Projects Section
                    _buildNewProjectsSection(theme),
                    const SizedBox(height: 24),

                    // 3. Suggested Talents Section
                    _buildSuggestedTalentsSection(theme),
                  ],
                ),
              ),
            ),
          ),
        ],
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
            color: '#${(0xFF000000 + filter.hashCode % 0xFFFFFF).toRadixString(16).padLeft(6, '0')}', // Màu ngẫu nhiên dựa trên hash
            small: false,
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildNewProjectsSection(ThemeData theme) {
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
            TextButton(onPressed: () {}, child: const Text("Xem thêm")),
          ],
        ),
        const SizedBox(height: 12),
        // Danh sách dự án (hardcode để minh họa)
        ProjectCard(
          projectName: "Phát triển Ứng dụng Quản lý Tài chính",
          companyName: "Finanza Inc.",
          progress: 0.1,
          role: "Flutter/Dart",
          deadline: "10 ngày còn lại",
          status: "pending",
          onTap: () {},
        ),
        ProjectCard(
          projectName: "Thiết kế Landing Page cho Chiến dịch Tết",
          companyName: "Marketing Hub",
          progress: 0.0,
          role: "UI/UX Designer",
          deadline: "2 ngày còn lại",
          status: "pending",
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildSuggestedTalentsSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Talent khác: Có thể bạn muốn kết nối",
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        // Danh sách Talent (hardcode để minh họa)
        const TalentListItem(
          name: "Trần Thị B",
          role: "Chuyên gia Backend (Java/Spring)",
          avatarUrl: "https://randomuser.me/api/portraits/women/12.jpg",
          skills: ["Java", "Spring Boot", "REST API", "MongoDB"],
        ),
        const TalentListItem(
          name: "Lê Văn C",
          role: "Frontend & Mobile (React Native)",
          avatarUrl: "https://randomuser.me/api/portraits/men/45.jpg",
          skills: ["React Native", "TypeScript", "Redux", "CI/CD"],
        ),
      ],
    );
  }
}