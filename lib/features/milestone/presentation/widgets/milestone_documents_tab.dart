import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/get_it/get_it.dart';
import '../../../hiring_projects/presentation/utils/project_data_formatter.dart';
import '../../data/models/milestone_document_model.dart';
import '../cubit/milestone_documents_cubit.dart';
import '../cubit/milestone_documents_state.dart';

class MilestoneDocumentsTab extends StatelessWidget {
  final String milestoneId;

  const MilestoneDocumentsTab({super.key, required this.milestoneId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<MilestoneDocumentsCubit>(param1: milestoneId)
        ..loadDocuments(milestoneId),
      child: BlocBuilder<MilestoneDocumentsCubit, MilestoneDocumentsState>(
        builder: (context, state) {
          if (state is MilestoneDocumentsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is MilestoneDocumentsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Colors.red.shade300, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    state.message,
                    style: TextStyle(color: Colors.red.shade700),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  FilledButton.tonalIcon(
                    onPressed: () => context
                        .read<MilestoneDocumentsCubit>()
                        .loadDocuments(milestoneId),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          if (state is MilestoneDocumentsLoaded) {
            if (state.documents.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.folder_off_outlined,
                        size: 64, color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                    Text(
                      "Chưa có tài liệu nào",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.documents.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _MilestoneDocumentCard(document: state.documents[index]);
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _MilestoneDocumentCard extends StatelessWidget {
  final MilestoneDocumentModel document;

  const _MilestoneDocumentCard({required this.document});

  Future<void> _launchUrl(BuildContext context, String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Không thể mở liên kết')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    }
  }

  IconData _getFileIcon(String type) {
    switch (type.toUpperCase()) {
      case 'PDF':
        return Icons.picture_as_pdf;
      case 'IMAGE':
      case 'PNG':
      case 'JPG':
      case 'JPEG':
        return Icons.image;
      case 'DOC':
      case 'DOCX':
        return Icons.description;
      case 'XLS':
      case 'XLSX':
        return Icons.table_chart;
      case 'ZIP':
      case 'RAR':
        return Icons.folder_zip;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _getIconColor(String type) {
    switch (type.toUpperCase()) {
      case 'PDF':
        return Colors.red;
      case 'IMAGE':
      case 'PNG':
      case 'JPG':
        return Colors.purple;
      case 'DOC':
      case 'DOCX':
        return Colors.blue;
      case 'XLS':
      case 'XLSX':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fileType = document.fileType;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _getIconColor(fileType).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            _getFileIcon(fileType),
            color: _getIconColor(fileType),
            size: 24,
          ),
        ),
        title: Text(
          document.fileName,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: Colors.black87,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              Icon(Icons.access_time, size: 12, color: Colors.grey.shade500),
              const SizedBox(width: 4),
              Text(
                ProjectDataFormatter.formatDateTime(document.uploadedAt),
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
        trailing: IconButton(
          style: IconButton.styleFrom(
            backgroundColor: Colors.blue.shade50,
            padding: const EdgeInsets.all(8),
          ),
          icon: Icon(Icons.download_rounded, color: Colors.blue.shade700, size: 20),
          onPressed: () => _launchUrl(context, document.fileUrl),
          tooltip: "Tải xuống / Xem",
        ),
      ),
    );
  }
}