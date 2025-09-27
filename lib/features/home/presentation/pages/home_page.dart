// lib/features/home/presentation/pages/home_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/bloc/theme_bloc.dart';
import '../../../../core/theme/bloc/theme_events.dart';
import '../../../../core/theme/domain/entity/theme_entity.dart';
import '../../../auth/presentation/provider/auth_provider.dart';
import '../../data/repository/explore_service.dart';
import '../../domain/entity/explore_models.dart';


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
    final authProvider = context.watch<AuthProvider>();
    final themeBloc = context.read<ThemeBloc>();
    final isDark = context.watch<ThemeBloc>().state.themeEntity?.themeType == ThemeType.dark;
    return Scaffold(
      appBar: AppBar(

        title: Row(
          children: [
            Image.asset('assets/images/logo.png', height: 32),
            const SizedBox(width: 8),
            Text('LabOdc', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
            tooltip: isDark ? 'Chuyển sang chế độ sáng' : 'Chuyển sang chế độ tối',
            onPressed: () {
              themeBloc.add(ToggleThemeEvent());
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0, top: 8.0, bottom: 8.0),
            child: ElevatedButton(
              onPressed: () => context.goNamed('login'),
              style: ElevatedButton.styleFrom(
                visualDensity: VisualDensity.compact,
              ),
              child: const Text('Đăng nhập'),
            ),
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
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
                    _buildTalentTab(context, data.talentFeatures, data.projects),
                    _buildCompanyTab(context, data.companyFeatures, data.partners),
                  ],
                ),
              ),
              _buildBottomCta(context),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTalentTab(BuildContext context, List<FeatureItem> features, List<ProjectItem> projects) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Phát triển sự nghiệp. Kiếm thêm thu nhập.',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            'Chức năng chính dành cho bạn:',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          ...features.map((feature) => _buildFeatureListItem(feature)),
          const SizedBox(height: 24),
          Text(
            'Dự án đang tuyển',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...projects.map((project) => _buildProjectCard(project)),
        ],
      ),
    );
  }

  Widget _buildCompanyTab(BuildContext context, List<FeatureItem> features, List<PartnerItem> partners) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Triển khai dự án hiệu quả. Tìm kiếm tài năng chất lượng.',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            'Nền tảng của chúng tôi giúp bạn:',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          ...features.map((feature) => _buildFeatureListItem(feature)),
          const SizedBox(height: 24),
          Text(
            'Các đối tác tiêu biểu',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildPartnerLogos(partners),
        ],
      ),
    );
  }

  Widget _buildFeatureListItem(FeatureItem feature) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(feature.icon, size: 30, color: Theme.of(context).colorScheme.primary),
      title: Text(feature.title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(feature.description),
    );
  }

  Widget _buildProjectCard(ProjectItem project) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(project.icon, color: Theme.of(context).colorScheme.secondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(project.title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Kỹ năng cần có:', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: project.skills.map((skill) => Chip(label: Text(skill))).toList(),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(onPressed: (){
                context.goNamed('register');
              }, child: const Text('Xem chi tiết >')),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildPartnerLogos(List<PartnerItem> partners) {
    return Wrap(
      spacing: 16.0,
      runSpacing: 16.0,
      alignment: WrapAlignment.center,
      children: partners.map((partner) =>
          Column(
            children: [
              Image.asset('assets/images/logo.png', width: 80, height: 80, fit: BoxFit.contain),
              const SizedBox(height: 4),
              Text(partner.name, style: Theme.of(context).textTheme.bodySmall)
            ],
          )
      ).toList(),
    );
  }

  Widget _buildBottomCta(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Theme.of(context).canvasColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          icon: const Icon(Icons.rocket_launch),
          onPressed: () => context.goNamed('register'),
          label: const Text('Bắt đầu ngay!'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ),
    );
  }
}