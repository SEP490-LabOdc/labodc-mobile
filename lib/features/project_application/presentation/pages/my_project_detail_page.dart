import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:labodc_mobile/features/milestone/presentation/widgets/list_milestone_of_project.dart';
import 'package:provider/provider.dart';
import '../../../../core/get_it/get_it.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/network_image_with_fallback.dart';
import '../../../../shared/widgets/expandable_text.dart';
import '../../../../shared/widgets/reusable_card.dart';

import '../../../hiring_projects/data/models/project_detail_model.dart';
import '../../../hiring_projects/domain/repositories/project_repository.dart';
import '../../../hiring_projects/presentation/utils/project_data_formatter.dart';

// ⭐ thêm import này
import '../../../auth/presentation/provider/auth_provider.dart';
import '../../../milestone/presentation/cubit/milestone_cubit.dart';
import '../../../project_application/presentation/pages/project_applicants_page.dart';

class MyProjectDetailPage extends StatefulWidget {
  final String projectId;

  const MyProjectDetailPage({
    super.key,
    required this.projectId,
  });

  @override
  State<MyProjectDetailPage> createState() => _MyProjectDetailPageState();
}

class _MyProjectDetailPageState extends State<MyProjectDetailPage>
    with TickerProviderStateMixin {

  late final TabController _tab;
  ProjectDetailModel? project;
  bool loading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 5, vsync: this);
    _fetchProject();
  }

  Future<void> _fetchProject() async {
    setState(() {
      loading = true;
      errorMessage = null;
    });

    final repo = getIt<ProjectRepository>();
    final result = await repo.getProjectDetail(widget.projectId);

    if (!mounted) return;

    result.fold(
          (failure) => setState(() {
        errorMessage = failure.message;
        loading = false;
      }),
          (data) => setState(() {
        project = data;
        loading = false;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final authProvider = context.watch<AuthProvider>();
    final role = (authProvider.currentUser?.role ?? '').toUpperCase();
    final isMentor = role == 'MENTOR';

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        backgroundColor: theme.colorScheme.surfaceVariant,

        appBar: AppBar(
          title: const Text("Chi tiết dự án", style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          elevation: 0,
          bottom: TabBar(
            controller: _tab,
            isScrollable: true,
            indicator: BoxDecoration(
              color: theme.colorScheme.onPrimary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            tabs: const [
              Tab(text: "Tổng quan"),
              Tab(text: "Cột mốc"),
              Tab(text: "Tệp tin"),
              Tab(text: "Hoạt động"),
              Tab(text: "Hóa đơn"),
            ],
          ),
        ),

        // ---------------- CONTENT ----------------
        body: loading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage != null
            ? _buildErrorView(theme)
            : project == null
            ? _buildEmptyView(theme)
            : _buildContent(theme),

        // ⭐⭐ NÚT CHỈ HIỂN THỊ CHO MENTOR ⭐⭐
        floatingActionButton:
        (isMentor && project != null && !loading && errorMessage == null)
            ? FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    ProjectApplicantsPage(projectId: project!.id),
              ),
            );
          },
          label: const Text("Xem danh sách ứng viên"),
          icon: const Icon(Icons.people_alt_outlined),
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
        )
            : null,
      ),
    );
  }


  Widget _buildErrorView(ThemeData theme) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.error_outline, color: theme.colorScheme.error, size: 40),
        const SizedBox(height: 8),
        Text(errorMessage ?? "Đã xảy ra lỗi"),
        const SizedBox(height: 12),
        OutlinedButton(onPressed: _fetchProject, child: const Text("Thử lại")),
      ],
    ),
  );

  Widget _buildEmptyView(ThemeData theme) =>
      Center(child: Text("Không tìm thấy dự án", style: theme.textTheme.bodyLarge));

  Widget _buildContent(ThemeData theme) {
    return TabBarView(
      controller: _tab,
      children: [
        _buildOverviewTab(project!),
        _buildMilestoneTab(project!),
        const Center(child: Text("Tệp tin dự án")),
        const Center(child: Text("Hoạt động dự án")),
        const Center(child: Text("Hóa đơn dự án")),
      ],
    );
  }

  Widget _buildOverviewTab(ProjectDetailModel p) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderSection(p),
          const SizedBox(height: 20),
          _buildProjectInfoSection(p),
          const SizedBox(height: 20),
          _buildDescriptionSection(p.description),
          const SizedBox(height: 20),
          _buildMembersSection(p.talents),
          const SizedBox(height: 20),
          _buildMentorsSection(p.mentors),
        ],
      ),
    );
  }

  Widget _buildHeaderSection(ProjectDetailModel p) {
    final theme = Theme.of(context);

    final statusColor = ProjectDataFormatter.getStatusColor(p.status);
    final statusText = ProjectDataFormatter.translateStatus(p.status);

    return ReusableCard(
      padding: const EdgeInsets.all(20),
      backgroundColor: theme.colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(p.title,
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text("Mã dự án: ${p.id}",
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(statusText,
                style: TextStyle(
                    color: statusColor, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectInfoSection(ProjectDetailModel p) {
    final theme = Theme.of(context);

    return ReusableCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Thông tin dự án",
              style:
              theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),

          _infoRow("Khách hàng", p.companyName ?? "—"),
          _infoRow("Ngân sách",
              ProjectDataFormatter.formatCurrency(context, p.budget)),
          _infoRow("Ngày bắt đầu",
              p.startDate != null ? ProjectDataFormatter.formatDate(p.startDate!) : "—"),
          _infoRow("Ngày kết thúc",
              p.endDate != null ? ProjectDataFormatter.formatDate(p.endDate!) : "—"),

          const SizedBox(height: 16),
          Text("Người tạo", style: theme.textTheme.labelMedium),
          const SizedBox(height: 6),

          Row(
            children: [
              const CircleAvatar(radius: 18, child: Icon(Icons.person)),
              const SizedBox(width: 10),
              Text("Đom Đóm"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(color: Colors.black54))),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection(String description) {
    final theme = Theme.of(context);

    return ReusableCard(
      padding: const EdgeInsets.all(20),
      child: ExpandableText(
        text: description,
        maxLines: 6,
        style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
      ),
    );
  }

  Widget _buildMembersSection(List<ProjectTalentModel> members) {
    final theme = Theme.of(context);

    return ReusableCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Thành viên",
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          if (members.isEmpty)
            Text("Chưa có thành viên.",
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),

          ...members.map((t) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: NetworkImageWithFallback(
                imageUrl: t.avatar ?? "",
                width: 42,
                height: 42,
                fallbackIcon: Icons.person,
              ),
            ),
            title: Text(t.name),
            subtitle: Text(t.roleName),
          )),
        ],
      ),
    );
  }

  Widget _buildMentorsSection(List<ProjectMentorModel> mentors) {
    final theme = Theme.of(context);

    return ReusableCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Giảng viên",
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          if (mentors.isEmpty)
            Text("Không có giảng viên.",
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),

          ...mentors.map((m) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: NetworkImageWithFallback(
                imageUrl: m.avatar ?? "",
                width: 42,
                height: 42,
                fallbackIcon: Icons.person,
              ),
            ),
            title: Text(m.name),
            subtitle: Text(m.roleName),
          )),
        ],
      ),
    );
  }

  Widget _buildMilestoneTab(ProjectDetailModel p) {
    return BlocProvider(
      create: (_) => getIt<MilestoneCubit>()..loadMilestones(p.id),
      child: ListMilestoneOfProject(projectId: p.id),
    );
  }

  Widget _buildFilesTab() => const Center(child: Text("Tệp tin & hình ảnh dự án"));

  Widget _buildActivityNoteTab() =>
      const Center(child: Text("Hoạt động & ghi chú"));

  Widget _buildInvoiceTab() => const Center(child: Text("Hóa đơn dự án"));
}
