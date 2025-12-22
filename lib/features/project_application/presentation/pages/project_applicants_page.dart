import 'package:flutter/material.dart';
import 'package:dartz/dartz.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/get_it/get_it.dart';
import '../../../project_application/domain/repositories/project_application_repository.dart';
import '../../../project_application/data/models/project_applicant_model.dart';
import '../../../../shared/widgets/reusable_card.dart';

/// ====================== STATE & CUBIT ======================

class ProjectApplicantsState {
  final bool isLoading;
  final List<ProjectApplicantModel> applicants;
  final String? errorMessage;
  final String? processingApplicantId;
  final String? snackBarMessage;

  ProjectApplicantsState({
    required this.isLoading,
    required this.applicants,
    this.errorMessage,
    this.processingApplicantId,
    this.snackBarMessage,
  });

  factory ProjectApplicantsState.initial() => ProjectApplicantsState(
    isLoading: true,
    applicants: const [],
    errorMessage: null,
    processingApplicantId: null,
    snackBarMessage: null,
  );

  ProjectApplicantsState copyWith({
    bool? isLoading,
    List<ProjectApplicantModel>? applicants,
    String? errorMessage,
    String? processingApplicantId,
    String? snackBarMessage,
  }) {
    return ProjectApplicantsState(
      isLoading: isLoading ?? this.isLoading,
      applicants: applicants ?? this.applicants,
      errorMessage: errorMessage,
      processingApplicantId: processingApplicantId,
      snackBarMessage: snackBarMessage,
    );
  }
}

class ProjectApplicantsCubit extends Cubit<ProjectApplicantsState> {
  final ProjectApplicationRepository repo;
  final String projectId;

  ProjectApplicantsCubit({
    required this.repo,
    required this.projectId,
  }) : super(ProjectApplicantsState.initial());

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) return failure.message;
    if (failure is NetworkFailure) return 'Vui lòng kiểm tra kết nối mạng.';
    return 'Đã xảy ra lỗi không xác định.';
  }

  Future<void> loadApplicants() async {
    emit(state.copyWith(
      isLoading: true,
      errorMessage: null,
      snackBarMessage: null,
      processingApplicantId: null,
    ));

    final result = await repo.getProjectApplicants(projectId);

    result.fold(
          (failure) => emit(state.copyWith(
        isLoading: false,
        applicants: const [],
        errorMessage: _mapFailureToMessage(failure),
        snackBarMessage: _mapFailureToMessage(failure),
      )),
          (list) => emit(state.copyWith(
        isLoading: false,
        applicants: list,
        errorMessage: null,
      )),
    );
  }

  Future<void> approveApplicant(String applicationId) async {
    emit(state.copyWith(processingApplicantId: applicationId, snackBarMessage: null));
    final result = await repo.approveProjectApplication(applicationId);
    result.fold(
          (failure) => emit(state.copyWith(processingApplicantId: null, snackBarMessage: _mapFailureToMessage(failure))),
          (_) async {
        await loadApplicants();
        emit(state.copyWith(snackBarMessage: 'Đã chấp nhận ứng viên.'));
      },
    );
  }

  Future<void> rejectApplicant(String applicationId, String reviewNotes) async {
    emit(state.copyWith(processingApplicantId: applicationId, snackBarMessage: null));
    final result = await repo.rejectProjectApplication(applicationId, reviewNotes);
    result.fold(
          (failure) => emit(state.copyWith(processingApplicantId: null, snackBarMessage: _mapFailureToMessage(failure))),
          (_) async {
        await loadApplicants();
        emit(state.copyWith(snackBarMessage: 'Đã từ chối ứng viên.'));
      },
    );
  }

  void clearSnackBarMessage() => emit(state.copyWith(snackBarMessage: null));
}

/// ====================== PAGE ======================

class ProjectApplicantsPage extends StatelessWidget {
  final String projectId;

  const ProjectApplicantsPage({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProjectApplicantsCubit(
        repo: getIt<ProjectApplicationRepository>(),
        projectId: projectId,
      )..loadApplicants(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Danh sách ứng viên', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          centerTitle: false,
        ),
        body: BlocConsumer<ProjectApplicantsCubit, ProjectApplicantsState>(
          listener: (context, state) {
            if (state.snackBarMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.snackBarMessage!)));
              context.read<ProjectApplicantsCubit>().clearSnackBarMessage();
            }
          },
          builder: (context, state) {
            if (state.isLoading && state.applicants.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.errorMessage != null && state.applicants.isEmpty) {
              return Center(child: Text(state.errorMessage!, style: const TextStyle(color: Colors.red)));
            }
            if (state.applicants.isEmpty) {
              return const Center(child: Text('Chưa có ứng viên nào ứng tuyển.'));
            }

            return RefreshIndicator(
              onRefresh: () => context.read<ProjectApplicantsCubit>().loadApplicants(),
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: state.applicants.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) => _ApplicantCard(
                  applicant: state.applicants[index],
                  isProcessing: state.processingApplicantId == state.applicants[index].id,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// ====================== CARD UI ======================

class _ApplicantCard extends StatelessWidget {
  final ProjectApplicantModel applicant;
  final bool isProcessing;

  const _ApplicantCard({required this.applicant, required this.isProcessing});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isPending = applicant.status.toUpperCase() == 'PENDING';

    return ReusableCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: colorScheme.primary.withOpacity(0.1),
                child: Text(
                  applicant.name.isNotEmpty ? applicant.name[0].toUpperCase() : '?',
                  style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(applicant.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    Text(
                      'Ứng tuyển: ${applicant.appliedAt.day}/${applicant.appliedAt.month}/${applicant.appliedAt.year}',
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(applicant.status),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _openCv(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorScheme.primary,
                    side: BorderSide(color: colorScheme.primary.withOpacity(0.3)),
                  ),
                  icon: const Icon(Icons.description_outlined, size: 18),
                  label: const Text('Xem CV'),
                ),
              ),
              if (applicant.aiScanResult != null) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _showAiScanModal(context),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.deepPurpleAccent.withOpacity(0.1),
                      foregroundColor: Colors.deepPurpleAccent,
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.auto_awesome_outlined, size: 18),
                    label: const Text('AI Đánh giá'),
                  ),
                ),
              ],
            ],
          ),
          if (isPending) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: isProcessing ? null : () => _approveApplicant(context),
                    style: FilledButton.styleFrom(backgroundColor: Colors.green[600]),
                    child: isProcessing
                        ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Chấp nhận'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: isProcessing ? null : () => _rejectApplicant(context),
                    style: OutlinedButton.styleFrom(foregroundColor: colorScheme.error, side: BorderSide(color: colorScheme.error)),
                    child: const Text('Từ chối'),
                  ),
                ),
              ],
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toUpperCase()) {
      case 'APPROVED': color = Colors.green; break;
      case 'REJECTED': color = Colors.red; break;
      default: color = Colors.orange;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
      child: Text(status, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  /// ================= AI SCAN MODAL =================

  void _showAiScanModal(BuildContext context) {
    final scan = applicant.aiScanResult!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(ctx).size.height * 0.85,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            _buildHandleBar(theme),
            _buildModalHeader(ctx, theme),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (scan.isCv == false) _buildWarningBox(scan.reason),
                    _buildSectionTitle('Tóm tắt', Icons.auto_awesome, Colors.purpleAccent, theme),
                    _buildSummaryCard(scan.summary, theme),
                    const SizedBox(height: 24),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildProsConsSection('Điểm mạnh', scan.pros ?? [], Colors.green, Icons.check_circle_outline, theme)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildProsConsSection('Cần cải thiện', scan.cons ?? [], Colors.redAccent, Icons.error_outline, theme)),
                      ],
                    ),
                    const SizedBox(height: 40),
                    _buildScoreIndicator(scan.matchScore ?? 0, theme),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHandleBar(ThemeData theme) {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 12),
        height: 4, width: 40,
        decoration: BoxDecoration(color: theme.dividerColor, borderRadius: BorderRadius.circular(2)),
      ),
    );
  }

  Widget _buildModalHeader(BuildContext ctx, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 10, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Phân tích AI', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close)),
        ],
      ),
    );
  }

  Widget _buildWarningBox(String? reason) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBE6), // Màu vàng nhạt cố định cho cảnh báo
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFE58F)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(reason ?? 'Tài liệu không giống một CV chuẩn.', style: const TextStyle(color: Color(0xFF856404), fontSize: 13))),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, Color color, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String? summary, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.1)),
      ),
      child: Text(
        summary ?? 'Chưa có dữ liệu tóm tắt.',
        style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
      ),
    );
  }

  Widget _buildProsConsSection(String title, List<String> items, Color color, IconData icon, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 6),
            Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 15)),
          ],
        ),
        const SizedBox(height: 12),
        ...items.map((item) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withOpacity(0.1)),
          ),
          child: Text(item, style: theme.textTheme.bodySmall?.copyWith(fontSize: 12)),
        )),
      ],
    );
  }

  Widget _buildScoreIndicator(double score, ThemeData theme) {
    final color = score > 70 ? Colors.green : (score > 40 ? Colors.orange : Colors.red);
    return Center(
      child: Column(
        children: [
          Text('MỨC ĐỘ PHÙ HỢP', style: theme.textTheme.labelLarge?.copyWith(letterSpacing: 1.5, color: theme.hintColor)),
          const SizedBox(height: 16),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 110, height: 110,
                child: CircularProgressIndicator(
                  value: score / 100,
                  strokeWidth: 10,
                  backgroundColor: theme.dividerColor,
                  color: color,
                  strokeCap: StrokeCap.round,
                ),
              ),
              Text('${score.toInt()}%', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: color)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            score > 60 ? 'Ứng viên tiềm năng' : 'Cần xem xét kỹ thêm',
            style: TextStyle(color: color.withOpacity(0.8), fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  /// ================= HELPER ACTIONS =================

  Future<void> _openCv(BuildContext context) async {
    final uri = Uri.parse(applicant.cvUrl);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  Future<void> _approveApplicant(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Chấp nhận ứng viên?'),
        content: Text('Bạn có chắc chắn muốn nhận ${applicant.name} vào dự án này?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Huỷ')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Xác nhận')),
        ],
      ),
    );
    if (confirm == true) context.read<ProjectApplicantsCubit>().approveApplicant(applicant.id);
  }

  Future<void> _rejectApplicant(BuildContext context) async {
    final controller = TextEditingController();
    final notes = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Từ chối ứng viên'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Nhập lý do từ chối...'),
          maxLines: 2,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Huỷ')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Từ chối'),
          ),
        ],
      ),
    );
    if (notes != null && notes.isNotEmpty) {
      context.read<ProjectApplicantsCubit>().rejectApplicant(applicant.id, notes);
    }
  }
}