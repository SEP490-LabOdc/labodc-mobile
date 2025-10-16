// lib/features/home/presentation/pages/home_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

// Import AppColors
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/bloc/theme_bloc.dart';
import '../../../../core/theme/bloc/theme_events.dart';
import '../../../../core/theme/domain/entity/theme_entity.dart';
import '../../../auth/presentation/provider/auth_provider.dart';
import '../../data/repository/explore_service.dart';
import '../../domain/entity/explore_models.dart';
import '../../../../core/router/app_router.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final Future<ExploreData> _exploreDataFuture;
  final ExploreService _exploreService = ExploreService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _exploreDataFuture = _exploreService.loadExploreData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Không cần kiểm tra authProvider.isAuthenticated vì GoRouter đã redirect người dùng ĐN.
    final themeBloc = context.read<ThemeBloc>();
    final isDark = context.watch<ThemeBloc>().state.themeEntity?.themeType == ThemeType.dark;

    final Color primaryColor = isDark ? AppColors.darkPrimary : AppColors.primary;
    final Color accentColor = isDark ? AppColors.darkAccent : AppColors.accent;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).canvasColor,
        elevation: 0,
        title: Row(
          children: [
            Image.asset('assets/images/logo.png', height: 32),
            const SizedBox(width: 8),
            const Text('LabOdc', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          // Nút chuyển Theme
          IconButton(
            icon: Icon(isDark ? Icons.dark_mode : Icons.light_mode, color: primaryColor),
            tooltip: isDark ? 'Chuyển sang chế độ sáng' : 'Chuyển sang chế độ tối',
            onPressed: () {
              themeBloc.add(ToggleThemeEvent());
            },
          ),

        ],
        // TabBar
        bottom: TabBar(
          controller: _tabController,
          labelColor: primaryColor,
          unselectedLabelColor: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6),
          indicatorColor: primaryColor,
          indicatorWeight: 3.0,
          tabs: const [
            Tab(text: 'Dành cho Tài năng'),
            Tab(text: 'Dành cho Doanh nghiệp'),
          ],
        ),
      ),
      body: FutureBuilder<ExploreData>(
        future: _exploreDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi tải dữ liệu: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('Không có dữ liệu.'));
          }

          final data = snapshot.data!;

          return Column(
            children: [
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildTalentTab(context, data.talentFeatures, data.projects, isDark),
                    _buildCompanyTab(context, data.companyFeatures, data.partners, isDark),
                  ],
                ),
              ),
              // ✅ CTA ở dưới cùng (Không cần kiểm tra trạng thái đăng nhập)
              _buildBottomCta(context, primaryColor, accentColor),
            ],
          );
        },
      ),
    );
  }

  // --- TAB CONTENT BUILDERS ---

  Widget _buildTalentTab(BuildContext context, List<FeatureItem> features, List<ProjectItem> projects, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero Section
          _buildHeroSection(
            context,
            'Phát triển sự nghiệp. Kiếm thêm thu nhập.',
            'Tìm kiếm các dự án phù hợp với kỹ năng của bạn và kết nối với các công ty hàng đầu.',
            Icons.star_half,
            isDark: isDark,
            isTalent: true,
          ),

          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '⭐ Chức năng chính dành cho bạn:',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildFeatureGrid(context, features),

                const SizedBox(height: 40),
                Text(
                  '🔥 Dự án đang tuyển',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ...projects.map((project) => _buildProjectCard(context, project)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyTab(BuildContext context, List<FeatureItem> features, List<PartnerItem> partners, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero Section
          _buildHeroSection(
            context,
            'Tìm kiếm tài năng chất lượng. Triển khai dự án hiệu quả.',
            'Tiếp cận mạng lưới freelancer và mentor chuyên nghiệp để đẩy nhanh tiến độ dự án.',
            Icons.business_center,
            isDark: isDark,
            isTalent: false,
          ),

          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '💡 Nền tảng của chúng tôi giúp bạn:',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildFeatureGrid(context, features),

                const SizedBox(height: 40),
                Text(
                  '🤝 Các đối tác tiêu biểu',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                _buildPartnerLogos(context, partners),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildHeroSection(BuildContext context, String title, String subtitle, IconData icon, {required bool isDark, required bool isTalent}) {
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.primary;
    final backgroundColor = isTalent
        ? primaryColor.withOpacity(isDark ? 0.2 : 0.1)
        : primaryColor.withOpacity(isDark ? 0.1 : 0.05);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      color: backgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 50, color: primaryColor),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: primaryColor,
                height: 1.2
            ),
          ),
          const SizedBox(height: 12),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.8)
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureGrid(BuildContext context, List<FeatureItem> features) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        final feature = features[index];
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: InkWell(
            onTap: () => context.goNamed('register'),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(feature.icon, size: 36, color: Theme.of(context).colorScheme.secondary),
                  const SizedBox(height: 10),
                  Text(
                    feature.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProjectCard(BuildContext context, ProjectItem project) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => context.goNamed('register'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(project.icon, color: Theme.of(context).colorScheme.primary, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      project.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),

              Text('Kỹ năng cần có:', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: project.skills.map((skill) =>
                    Chip(
                      label: Text(skill, style: Theme.of(context).textTheme.bodySmall),
                      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    )
                ).toList(),
              ),
              const SizedBox(height: 12),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => context.goNamed('register'),
                  icon: const Icon(Icons.arrow_forward_ios, size: 14),
                  label: const Text('Xem chi tiết & Ứng tuyển', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPartnerLogos(BuildContext context, List<PartnerItem> partners) {
    return Wrap(
      spacing: 30.0,
      runSpacing: 30.0,
      alignment: WrapAlignment.center,
      children: partners.map((partner) =>
          SizedBox(
            width: 80,
            child: Column(
              children: [
                // Thay bằng logic tải logo thực tế nếu có
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.background.withOpacity(0.5), // Màu nền nhẹ nhàng
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Image.asset('assets/images/logo.png', width: 40, height: 40, fit: BoxFit.contain),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                    partner.name,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)
                )
              ],
            ),
          )
      ).toList(),
    );
  }

  // ✅ CTA cuối trang (Đăng nhập)
  Widget _buildBottomCta(BuildContext context, Color primaryColor, Color accentColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).canvasColor,
        border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.2))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          icon: const Icon(Icons.login),
          onPressed: () => context.goNamed('login'),
          label: const Text('Đăng nhập ngay để khám phá'),
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: Colors.white),
          ),
        ),
      ),
    );
  }
}