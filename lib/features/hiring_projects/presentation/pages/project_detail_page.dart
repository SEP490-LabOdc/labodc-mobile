import 'package:flutter/material.dart';

// 1. Import Clean Architecture Layers
import '../../../../core/get_it/get_it.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/project_repository.dart';
import '../../data/models/project_detail_model.dart';
import '../../data/models/project_model.dart'; // Import SkillModel

// 2. Import Shared Widgets (Điều chỉnh đường dẫn nếu cần)
import '../../../../shared/widgets/reusable_card.dart';
import '../../../../shared/widgets/expandable_text.dart';
import '../../../../shared/widgets/service_chip.dart'; // Sử dụng lại ServiceChip

// 3. Import Formatter Helper (Đảm bảo đường dẫn đúng)
import '../utils/project_data_formatter.dart';

class ProjectDetailPage extends StatefulWidget {
  final String projectId;
  const ProjectDetailPage({super.key, required this.projectId});

  @override
  State<ProjectDetailPage> createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends State<ProjectDetailPage> {
  ProjectDetailModel? _project;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchProjectData();
  }

  Future<void> _fetchProjectData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final projectRepository = getIt<ProjectRepository>();
    final result = await projectRepository.getProjectDetail(widget.projectId);

    if (!mounted) return;

    result.fold(
          (failure) {
        setState(() {
          _error = _mapFailureToMessage(failure);
          _loading = false;
        });
      },
          (data) {
        setState(() {
          _project = data;
          _loading = false;
        });
      },
    );
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) return failure.message;
    if (failure is NetworkFailure) return 'Vui lòng kiểm tra kết nối mạng.';
    return 'Đã xảy ra lỗi không xác định.';
  }

  // ================== WIDGETS CON CHO UI MỚI ==================

  // 1. Header Section: Title, Company, Status
  Widget _buildHeaderSection(BuildContext context, ProjectDetailModel p) {
    final theme = Theme.of(context);
    final statusColor = ProjectDataFormatter.getStatusColor(p.status);
    final statusText = ProjectDataFormatter.translateStatus(p.status);

    return ReusableCard(
      // Loại bỏ shadow và border mặc định để nó hòa vào nền
      elevation: 0,
      border: Border.all(color: Colors.transparent),
      backgroundColor: Colors.transparent,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tên dự án lớn và đậm
                    Text(
                      p.title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Tên công ty
                    if (p.companyName != null && p.companyName!.isNotEmpty)
                      Row(
                        children: [
                          Icon(Icons.business,
                              size: 18, color: theme.colorScheme.primary),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              p.companyName!,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Status Badge (Chip trạng thái)
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: statusColor.withOpacity(0.5)),
                ),
                child: Text(
                  statusText,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 2. Info Cards Row: Thời gian, Ngân sách, Milestone
  Widget _buildInfoCardsRow(BuildContext context, ProjectDetailModel p) {
    return Row(
      children: [
        // Card 1: Thời gian
        Expanded(
          flex: 3,
          child: _buildSmallInfoCard(
            context,
            icon: Icons.calendar_month_outlined,
            title: 'Thời gian',
            content: '${ProjectDataFormatter.formatDate(p.startDate)}\n- ${ProjectDataFormatter.formatDate(p.endDate)}',
          ),
        ),
        const SizedBox(width: 12),
        // Card 2: Ngân sách & Milestone (Gộp lại cho gọn)
        Expanded(
          flex: 4,
          child: _buildSmallInfoCard(
              context,
              icon: Icons.monetization_on_outlined,
              title: 'Ngân sách & Cột mốc',
              contentWidget: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ProjectDataFormatter.formatCurrency(context, p.budget),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.flag_outlined, size: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          p.currentMilestoneName ?? 'Chưa có',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              )

          ),
        ),
      ],
    );
  }

  // Widget con cho thẻ thông tin nhỏ
  Widget _buildSmallInfoCard(BuildContext context,
      {required IconData icon, required String title, String? content, Widget? contentWidget}) {
    final theme = Theme.of(context);
    return ReusableCard(
      padding: const EdgeInsets.all(12),
      backgroundColor: theme.colorScheme.surface, // Sử dụng màu surface
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 6),
              Text(title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurfaceVariant)),
            ],
          ),
          const SizedBox(height: 8),
          contentWidget ?? Text(
            content!,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  // 3. Skills Section (Sử dụng ServiceChip)
  Widget _buildSkillsSection(BuildContext context, List<SkillModel> skills) {
    final theme = Theme.of(context);
    if (skills.isEmpty) return const SizedBox.shrink();

    return SectionCard(
      title: 'Kỹ năng yêu cầu',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: skills.map((skill) => ServiceChip(
          name: skill.name,
          color: '#000000', // Màu này sẽ được ServiceChip xử lý lại
          small: false,
        )).toList(),
      ),
    );
  }

  // 4. Mentors Section
  Widget _buildMentorsSection(BuildContext context, List<dynamic> mentors) {
    final theme = Theme.of(context);
    return SectionCard(
      title: 'Người hướng dẫn (Mentors)',
      child: mentors.isEmpty
          ? Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          'Chưa có mentor nào được chỉ định.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontStyle: FontStyle.italic,
          ),
        ),
      )
          : Column(
        children: mentors.map((m) {
          final name = (m is Map && m['name'] != null) ? m['name'] : 'Unknown';
          final avatarUrl = (m is Map) ? m['avatarUrl'] : null;

          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                radius: 20,
                backgroundColor: theme.colorScheme.primaryContainer,
                backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                child: avatarUrl == null
                    ? Icon(Icons.person, color: theme.colorScheme.onPrimaryContainer, size: 20)
                    : null,
              ),
              title: Text(name.toString(),
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600)),
            ),
          );
        }).toList(),
      ),
    );
  }

  // 5. Metadata Footer
  Widget _buildMetadataFooter(BuildContext context, ProjectDetailModel p) {
    final theme = Theme.of(context);
    final style = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
      fontSize: 11,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Project ID: ${p.id}', style: style),
        const SizedBox(height: 4),
        Text('Tạo lúc: ${ProjectDataFormatter.formatDateTime(p.createdAt)}',
            style: style),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      // Sử dụng màu nền surfaceVariant để làm nổi bật các Card (màu surface)
      backgroundColor: theme.colorScheme.surfaceVariant,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surfaceVariant, // Cùng màu nền
        elevation: 0,
        centerTitle: true,
        // SỬA LỖI NÚT BACK: Dùng IconButton thủ công và maybePop()
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'Chi tiết dự án',
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator.adaptive())
          : _error != null
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline_rounded,
                  size: 64, color: theme.colorScheme.error),
              const SizedBox(height: 16),
              Text(
                _error!,
                style: theme.textTheme.bodyLarge
                    ?.copyWith(color: theme.colorScheme.onSurface),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _fetchProjectData,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Thử lại'),
              )
            ],
          ),
        ),
      )
          : _project == null
          ? const Center(child: Text('Không tìm thấy dữ liệu dự án'))
          : SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header Info (Tên, Công ty, Trạng thái)
            _buildHeaderSection(context, _project!),
            const SizedBox(height: 20),

            // 2. Thông tin chính (Thời gian, Ngân sách...)
            _buildInfoCardsRow(context, _project!),
            const SizedBox(height: 20),

            // 3. Mô tả
            SectionCard(
              title: 'Mô tả dự án',
              child: ExpandableText(
                text: _project!.description,
                maxLines: 6,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 4. Kỹ năng
            _buildSkillsSection(context, _project!.skills),
            const SizedBox(height: 20),

            // 5. Mentors
            _buildMentorsSection(context, _project!.mentors),
            const SizedBox(height: 24),

            // 6. Metadata Footer
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 8.0),
              child: _buildMetadataFooter(context, _project!),
            ),
            // Khoảng trống dưới cùng
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}