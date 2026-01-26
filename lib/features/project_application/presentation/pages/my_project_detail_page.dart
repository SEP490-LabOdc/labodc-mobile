import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:labodc_mobile/features/milestone/presentation/widgets/list_milestone_of_project.dart';
import 'package:provider/provider.dart';
import '../../../../core/get_it/get_it.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/network_image_with_fallback.dart';
import '../../../../shared/widgets/expandable_text.dart';

import '../../../hiring_projects/data/models/project_detail_model.dart';
import '../../../hiring_projects/domain/repositories/project_repository.dart';
import '../../../hiring_projects/presentation/utils/project_data_formatter.dart';

import '../../../auth/presentation/provider/auth_provider.dart';
import '../../../milestone/presentation/cubit/milestone_cubit.dart';
import '../../../project_application/presentation/pages/project_applicants_page.dart';
import '../widgets/project_documents_tab.dart';

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

    final isDark = theme.brightness == Brightness.dark;

    final Color primaryColor = isDark
        ? AppColors.darkPrimary
        : AppColors.primary;
    final Color textColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.textPrimary;

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          title: const Text("Chi tiết dự án", style: TextStyle(fontWeight: FontWeight.bold)),
          elevation: 0,
          bottom: TabBar(
            controller: _tab,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: textColor,
            unselectedLabelColor: Colors.grey.shade600,
            indicatorColor: theme.primaryColor,
            tabs: const [
              Tab(text: "Tổng quan"),
              Tab(text: "Cột mốc"),
              Tab(text: "Tệp tin"),
              // Tab(text: "Hoạt động"),
              // Tab(text: "Hóa đơn"),
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

        // FAB
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
          label: const Text("Ứng viên"),
          icon: const Icon(Icons.people_alt_outlined),
        )
            : null,
      ),
    );
  }

  Widget _buildErrorView(ThemeData theme) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.error_outline, color: theme.colorScheme.error, size: 48),
        const SizedBox(height: 12),
        Text(errorMessage ?? "Đã xảy ra lỗi", style: TextStyle(color: theme.colorScheme.error)),
        const SizedBox(height: 16),
        FilledButton.tonal(onPressed: _fetchProject, child: const Text("Thử lại")),
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
        _buildFilesTab(project!)
        // const Center(child: Text("Hoạt động dự án")),
        // const Center(child: Text("Hóa đơn dự án")),
      ],
    );
  }

  Widget _buildOverviewTab(ProjectDetailModel p) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMainInfoCard(p),
          const SizedBox(height: 20),
          _buildDescriptionCard(p.description),
          const SizedBox(height: 20),
          _buildTeamSection("Thành viên", p.talents, isMentor: false),
          const SizedBox(height: 20),
          _buildTeamSection("Giảng viên", p.mentors, isMentor: true),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildMainInfoCard(ProjectDetailModel p) {
    final statusColor = ProjectDataFormatter.getStatusColor(p.status);
    final statusText = ProjectDataFormatter.translateStatus(p.status);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor.withOpacity(0.2)),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              Text(
                "Mã: ${p.id.substring(0, 8).toUpperCase()}",
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            p.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          if (p.companyName != null)
            Row(
              children: [
                Icon(Icons.business, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 6),
                Text(
                  p.companyName!,
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                ),
              ],
            ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1),
          ),

          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  Icons.calendar_today_outlined,
                  "Bắt đầu",
                  p.startDate != null ? ProjectDataFormatter.formatDate(p.startDate!) : "—",
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  Icons.event_available_outlined,
                  "Kết thúc",
                  p.endDate != null ? ProjectDataFormatter.formatDate(p.endDate!) : "—",
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoItem(
            Icons.monetization_on_outlined,
            "Ngân sách",
            ProjectDataFormatter.formatCurrency(context, p.budget),
            isBold: true,
            valueColor: Colors.green.shade700,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value, {bool isBold = false, Color? valueColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: Colors.grey.shade500),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: valueColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionCard(String description) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Mô tả dự án", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ExpandableText(
            text: description,
            maxLines: 5,
            style: const TextStyle(fontSize: 14, height: 1.6, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamSection(String title, List members, {required bool isMentor}) {
    if (members.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: members.length,
            separatorBuilder: (_, __) => Divider(height: 1, thickness: 0.5, color: Colors.grey.shade100, indent: 70),
            itemBuilder: (_, index) {
              final m = members[index];
              // Xử lý dynamic model map từ json hoặc object
              final avatar = m is Map ? m['avatar'] : (m.avatar);
              final name = m is Map ? m['name'] : (m.name);
              final roleName = m is Map ? m['roleName'] : (m.roleName);

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: NetworkImageWithFallback(
                      imageUrl: avatar ?? "",
                      width: 44,
                      height: 44,
                      fallbackIcon: Icons.person,
                    ),
                  ),
                ),
                title: Text(name ?? "N/A", style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                subtitle: Text(roleName ?? (isMentor ? "Mentor" : "Thành viên"), style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMilestoneTab(ProjectDetailModel p) {
    return BlocProvider(
      create: (_) => getIt<MilestoneCubit>()..loadMilestones(p.id),
      child: ListMilestoneOfProject(projectId: p.id),
    );
  }

  Widget _buildFilesTab(ProjectDetailModel p) {
    return ProjectDocumentsTab(projectId: p.id);
  }
}