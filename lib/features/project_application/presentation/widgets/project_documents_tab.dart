import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:labodc_mobile/core/get_it/get_it.dart';
import 'package:labodc_mobile/features/hiring_projects/presentation/utils/project_data_formatter.dart';

import '../../data/models/project_document_model.dart';
import '../cubit/project_documents_cubit.dart';
import '../cubit/project_documents_state.dart';

class ProjectDocumentsTab extends StatelessWidget {
  final String projectId;

  const ProjectDocumentsTab({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ProjectDocumentsCubit>(param1: projectId)
        ..loadDocuments(projectId),
      child: BlocBuilder<ProjectDocumentsCubit, ProjectDocumentsState>(
        builder: (context, state) {
          if (state is ProjectDocumentsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProjectDocumentsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => context
                        .read<ProjectDocumentsCubit>()
                        .loadDocuments(projectId),
                    child: const Text('Thử lại'),
                  )
                ],
              ),
            );
          }

          if (state is ProjectDocumentsLoaded) {
            if (state.documents.isEmpty) {
              return const Center(
                child: Text("Dự án này chưa có tài liệu nào."),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.documents.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _DocumentCard(document: state.documents[index]);
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _DocumentCard extends StatelessWidget {
  final ProjectDocumentModel document;

  const _DocumentCard({required this.document});

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
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getIconColor(document.documentType).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getFileIcon(document.documentType),
            color: _getIconColor(document.documentType),
          ),
        ),
        title: Text(
          document.documentName,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              "Ngày đăng: ${ProjectDataFormatter.formatDate(document.uploadedAt)}",
              style: TextStyle(fontSize: 12, color: theme.hintColor),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.open_in_new, color: Colors.blue),
          onPressed: () => _launchUrl(context, document.documentUrl),
          tooltip: "Mở tài liệu",
        ),
      ),
    );
  }
}