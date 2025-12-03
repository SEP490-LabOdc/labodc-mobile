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
  final String? processingApplicantId; // id đang approve/reject
  final String? snackBarMessage; // message hiển thị 1 lần

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
      // error & snackbar mặc định là null nếu không truyền -> clear message cũ
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
    if (failure is NetworkFailure) {
      return 'Vui lòng kiểm tra kết nối mạng.';
    }
    return 'Đã xảy ra lỗi không xác định.';
  }

  Future<void> loadApplicants() async {
    emit(state.copyWith(
      isLoading: true,
      errorMessage: null,
      snackBarMessage: null,
      processingApplicantId: null,
    ));

    final Either<Failure, List<ProjectApplicantModel>> result =
    await repo.getProjectApplicants(projectId);

    result.fold(
          (failure) {
        emit(
          state.copyWith(
            isLoading: false,
            applicants: const [],
            errorMessage: _mapFailureToMessage(failure),
            snackBarMessage: _mapFailureToMessage(failure),
          ),
        );
      },
          (list) {
        emit(
          state.copyWith(
            isLoading: false,
            applicants: list,
            errorMessage: null,
            snackBarMessage: null,
          ),
        );
      },
    );
  }

  Future<void> approveApplicant(String applicationId) async {
    // set id đang xử lý để disable nút
    emit(
      state.copyWith(
        processingApplicantId: applicationId,
        snackBarMessage: null,
        errorMessage: null,
      ),
    );

    final result = await repo.approveProjectApplication(applicationId);

    result.fold(
          (failure) {
        emit(
          state.copyWith(
            processingApplicantId: null,
            errorMessage: _mapFailureToMessage(failure),
            snackBarMessage: _mapFailureToMessage(failure),
          ),
        );
      },
          (_) async {
        // reload list sau khi approve
        final reload = await repo.getProjectApplicants(projectId);
        reload.fold(
              (failure) {
            emit(
              state.copyWith(
                processingApplicantId: null,
                errorMessage: _mapFailureToMessage(failure),
                snackBarMessage: _mapFailureToMessage(failure),
              ),
            );
          },
              (list) {
            emit(
              state.copyWith(
                isLoading: false,
                applicants: list,
                processingApplicantId: null,
                errorMessage: null,
                snackBarMessage: 'Đã chấp nhận ứng viên.',
              ),
            );
          },
        );
      },
    );
  }

  Future<void> rejectApplicant(
      String applicationId,
      String reviewNotes,
      ) async {
    emit(
      state.copyWith(
        processingApplicantId: applicationId,
        snackBarMessage: null,
        errorMessage: null,
      ),
    );

    final result =
    await repo.rejectProjectApplication(applicationId, reviewNotes);

    result.fold(
          (failure) {
        emit(
          state.copyWith(
            processingApplicantId: null,
            errorMessage: _mapFailureToMessage(failure),
            snackBarMessage: _mapFailureToMessage(failure),
          ),
        );
      },
          (_) async {
        final reload = await repo.getProjectApplicants(projectId);
        reload.fold(
              (failure) {
            emit(
              state.copyWith(
                processingApplicantId: null,
                errorMessage: _mapFailureToMessage(failure),
                snackBarMessage: _mapFailureToMessage(failure),
              ),
            );
          },
              (list) {
            emit(
              state.copyWith(
                isLoading: false,
                applicants: list,
                processingApplicantId: null,
                errorMessage: null,
                snackBarMessage: 'Đã từ chối ứng viên.',
              ),
            );
          },
        );
      },
    );
  }

  /// gọi sau khi listener đã show snackbar để clear message
  void clearSnackBarMessage() {
    emit(
      state.copyWith(
        isLoading: state.isLoading,
        applicants: state.applicants,
        errorMessage: state.errorMessage,
        processingApplicantId: state.processingApplicantId,
        snackBarMessage: null,
      ),
    );
  }
}

/// ====================== PAGE ======================

class ProjectApplicantsPage extends StatelessWidget {
  final String projectId;

  const ProjectApplicantsPage({
    super.key,
    required this.projectId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProjectApplicantsCubit(
        repo: getIt<ProjectApplicationRepository>(),
        projectId: projectId,
      )..loadApplicants(),
      child: Builder(
        builder: (context) {
          final theme = Theme.of(context);

          return Scaffold(
            appBar: AppBar(
              title: const Text(
                'Danh sách ứng viên',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              elevation: 0,
            ),
            body: BlocConsumer<ProjectApplicantsCubit, ProjectApplicantsState>(
              listener: (context, state) {
                if (state.snackBarMessage != null &&
                    state.snackBarMessage!.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.snackBarMessage!)),
                  );
                  context.read<ProjectApplicantsCubit>().clearSnackBarMessage();
                }
              },
              builder: (context, state) {
                if (state.isLoading && state.applicants.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.errorMessage != null &&
                    state.applicants.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        state.errorMessage!,
                        style: TextStyle(color: theme.colorScheme.error),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                if (state.applicants.isEmpty) {
                  return const Center(
                    child: Text('Chưa có ứng viên nào ứng tuyển.'),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () =>
                      context.read<ProjectApplicantsCubit>().loadApplicants(),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.applicants.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final a = state.applicants[index];
                      final isProcessing =
                          state.processingApplicantId == a.id;
                      return _ApplicantCard(
                        applicant: a,
                        isProcessing: isProcessing,
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

/// ====================== CARD UI ======================

class _ApplicantCard extends StatelessWidget {
  final ProjectApplicantModel applicant;
  final bool isProcessing;

  const _ApplicantCard({
    required this.applicant,
    required this.isProcessing,
  });

  Color _statusColor(BuildContext context) {
    switch (applicant.status.toUpperCase()) {
      case 'APPROVED':
        return Colors.green;
      case 'REJECTED':
        return Colors.red;
      case 'PENDING':
        return Colors.orange;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  Future<void> _openCv(BuildContext context) async {
    final uri = Uri.parse(applicant.cvUrl);

    try {
      final ok = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!ok && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể mở CV. Vui lòng thử lại sau.'),
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi mở CV: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _approveApplicant(BuildContext context) async {
    final theme = Theme.of(context);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận chấp nhận'),
        content: Text(
          'Bạn có chắc chắn muốn CHẤP NHẬN ứng viên "${applicant.name}" cho dự án?',
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Huỷ'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.of(ctx).pop(true),
            icon: const Icon(Icons.check),
            label: const Text('Chấp nhận'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await context
        .read<ProjectApplicantsCubit>()
        .approveApplicant(applicant.id);
  }

  Future<void> _rejectApplicant(BuildContext context) async {
    final theme = Theme.of(context);
    final notesController = TextEditingController();

    final String? reviewNotes = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Từ chối ứng viên'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Nhập lý do từ chối (reviewNotes):',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Ví dụ: Hồ sơ chưa phù hợp với yêu cầu...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(null),
            child: const Text('Huỷ'),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              Navigator.of(ctx).pop(notesController.text.trim());
            },
            icon: const Icon(Icons.close),
            label: const Text('Từ chối'),
          ),
        ],
      ),
    );

    if (reviewNotes == null || reviewNotes.isEmpty) return;

    await context
        .read<ProjectApplicantsCubit>()
        .rejectApplicant(applicant.id, reviewNotes);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appliedAt =
        '${applicant.appliedAt.day.toString().padLeft(2, '0')}/'
        '${applicant.appliedAt.month.toString().padLeft(2, '0')}/'
        '${applicant.appliedAt.year} '
        '${applicant.appliedAt.hour.toString().padLeft(2, '0')}:'
        '${applicant.appliedAt.minute.toString().padLeft(2, '0')}';

    final statusColor = _statusColor(context);
    final isPending = applicant.status.toUpperCase() == 'PENDING';

    return ReusableCard(
      onTap: () {},
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // header: avatar + tên + status chip
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor:
                theme.colorScheme.primary.withOpacity(0.15),
                child: Text(
                  (applicant.name.isNotEmpty
                      ? applicant.name[0]
                      : 'U')
                      .toUpperCase(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            applicant.name,
                            style:
                            theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: statusColor.withOpacity(0.4),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.circle,
                                size: 8,
                                color: statusColor,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                applicant.status,
                                style: TextStyle(
                                  color: statusColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ứng tuyển lúc: $appliedAt',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface
                            .withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // CV
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant.withOpacity(0.6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.description_outlined, size: 18),
                // const SizedBox(width: 8),
                // Expanded(
                //   child: Text(
                //     applicant.cvUrl,
                //     maxLines: 2,
                //     overflow: TextOverflow.ellipsis,
                //     style: theme.textTheme.bodySmall?.copyWith(
                //       decoration: TextDecoration.underline,
                //     ),
                //   ),
                // ),
                TextButton(
                  onPressed: () => _openCv(context),
                  child: const Text('Mở CV'),
                ),
              ],
            ),
          ),

          // ==== HÀNG NÚT APPROVE / REJECT KHI ĐANG PENDING ====
          if (isPending) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onPressed:
                    isProcessing ? null : () => _approveApplicant(context),
                    icon: isProcessing
                        ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                        : const Icon(Icons.check),
                    label: Text(
                      isProcessing ? 'Đang xử lý...' : 'Chấp nhận',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onPressed:
                    isProcessing ? null : () => _rejectApplicant(context),
                    icon: const Icon(Icons.close),
                    label: const Text('Từ chối'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
