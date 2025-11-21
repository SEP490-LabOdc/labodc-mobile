class SkillEntity {
  final String id;
  final String name;
  final String description;

  SkillEntity({
    required this.id,
    required this.name,
    required this.description,
  });
}

class ProjectEntity {
  final String projectId;
  final String projectName;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final int currentApplicants;
  final List<SkillEntity> skills;

  ProjectEntity({
    required this.projectId,
    required this.projectName,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.currentApplicants,
    required this.skills,
  });
}
//Phân trang
class PaginatedProjectEntity {
  final List<ProjectEntity> projects;
  final int totalElements;
  final int totalPages;
  final int currentPage;
  final bool hasNext;

  PaginatedProjectEntity({
    required this.projects,
    required this.totalElements,
    required this.totalPages,
    required this.currentPage,
    required this.hasNext,
  });
}