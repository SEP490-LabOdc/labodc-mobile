import 'package:flutter/foundation.dart';
import '../../../hiring_projects/domain/entities/project_entity.dart';

@immutable
abstract class HiringProjectsState {}

class HiringProjectsInitial extends HiringProjectsState {}

class HiringProjectsLoading extends HiringProjectsState {
  final List<ProjectEntity> oldProjects;
  final bool isFirstFetch;

  HiringProjectsLoading(this.oldProjects, {this.isFirstFetch = false});
}

class HiringProjectsLoaded extends HiringProjectsState {
  final List<ProjectEntity> projects;
  final int totalElements;
  final int currentPage;
  final int pageSize;
  final bool hasNext;
  final int displayLimit;

  HiringProjectsLoaded({
    required this.projects,
    required this.totalElements,
    required this.currentPage,
    required this.pageSize,
    required this.hasNext,
    this.displayLimit = 3,
  });

  HiringProjectsLoaded copyWith({
    int? displayLimit,
    List<ProjectEntity>? projects,
    int? totalElements,
    int? currentPage,
    bool? hasNext,
  }) {
    return HiringProjectsLoaded(
      projects: projects ?? this.projects,
      totalElements: totalElements ?? this.totalElements,
      currentPage: currentPage ?? this.currentPage,
      pageSize: this.pageSize,
      hasNext: hasNext ?? this.hasNext,
      displayLimit: displayLimit ?? this.displayLimit,
    );
  }
}

class HiringProjectsError extends HiringProjectsState {
  final String message;
  HiringProjectsError(this.message);
}