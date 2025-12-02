import 'package:flutter/material.dart';
import 'package:dartz/dartz.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/get_it/get_it.dart';
import '../../../project_application/domain/repositories/project_application_repository.dart';
import '../../../project_application/data/models/project_applicant_model.dart';
import '../../../../shared/widgets/reusable_card.dart';

class ProjectApplicantsPage extends StatelessWidget {
  final String projectId;

  const ProjectApplicantsPage({
    super.key,
    required this.projectId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final repo = getIt<ProjectApplicationRepository>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách ứng viên'),
      ),
      body: FutureBuilder<Either<Failure, List<ProjectApplicantModel>>>(
        future: repo.getProjectApplicants(projectId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Lỗi khi tải danh sách ứng viên.',
                style: TextStyle(color: theme.colorScheme.error),
              ),
            );
          }

          final result = snapshot.data;

          if (result == null) {
            return const Center(child: Text('Không có dữ liệu.'));
          }

          return result.fold(
                (failure) => Center(
              child: Text(
                _mapFailureToMessage(failure),
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ),
                (applicants) {
              if (applicants.isEmpty) {
                return const Center(
                  child: Text('Chưa có ứng viên nào ứng tuyển.'),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: applicants.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final a = applicants[index];
                  return _ApplicantCard(applicant: a);
                },
              );
            },
          );
        },
      ),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) return failure.message;
    if (failure is NetworkFailure) {
      return 'Vui lòng kiểm tra kết nối mạng.';
    }
    return 'Đã xảy ra lỗi không xác định.';
  }
}

class _ApplicantCard extends StatelessWidget {
  final ProjectApplicantModel applicant;

  const _ApplicantCard({required this.applicant});

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
      final canLaunch = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!canLaunch && context.mounted) {
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

    return ReusableCard(
      onTap: () {
        // TODO: nếu cần, mở chi tiết ứng viên / CV, hoặc bottom sheet
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tên + status pill
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  applicant.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  applicant.status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Ứng tuyển lúc: $appliedAt',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'CV: ${applicant.cvUrl}',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              decoration: TextDecoration.underline,
            ),
          ),
          TextButton.icon(
            onPressed: () => _openCv(context),
            icon: const Icon(Icons.open_in_new),
            label: const Text('Mở CV'),
          ),
        ],
      ),
    );
  }
}
