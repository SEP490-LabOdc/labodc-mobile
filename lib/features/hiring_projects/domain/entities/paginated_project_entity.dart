import 'package:equatable/equatable.dart';
import 'project_entity.dart';

class PaginatedProjectEntity extends Equatable {
  final List<ProjectEntity> projects;
  final int totalElements;
  final int totalPages;
  final int currentPage;
  final bool hasNext;

  const PaginatedProjectEntity({
    required this.projects,
    required this.totalElements,
    required this.totalPages,
    required this.currentPage,
    required this.hasNext,
  });

  @override
  List<Object?> get props => [projects, totalElements, totalPages, currentPage, hasNext];
}