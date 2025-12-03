import '../../domain/entities/project_entity.dart';

class SkillModel extends SkillEntity {
  SkillModel({
    required super.id,
    required super.name,
    required super.description,
  });

  factory SkillModel.fromJson(Map<String, dynamic> json) {
    // ...sử dụng fallback cho các tên trường khác nhau và giá trị null
    final id = (json['id'] ?? json['skillId'] ?? '').toString();
    final name = (json['name'] ?? json['title'] ?? '').toString();
    final description = (json['description'] ?? json['desc'] ?? '').toString();

    return SkillModel(
      id: id,
      name: name,
      description: description,
    );
  }
}

class ProjectModel extends ProjectEntity {
  ProjectModel({
    required super.projectId,
    required super.projectName,
    required super.description,
    required super.startDate,
    required super.endDate,
    required super.currentApplicants,
    required super.skills,
    required super.status,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    // Fallbacks cho nhiều tên trường và parse an toàn
    final projectId = (json['projectId'] ?? json['id'] ?? '').toString();
    final projectName =
        (json['projectName'] ?? json['name'] ?? json['title'] ?? 'Dự án chưa có tên')
            .toString();
    final description = (json['description'] ?? json['desc'] ?? '').toString();

    DateTime parseDateSafe(dynamic val, DateTime fallback) {
      if (val == null) return fallback;
      try {
        final s = val is String ? val : val.toString();
        final dt = DateTime.tryParse(s);
        return dt ?? fallback;
      } catch (_) {
        return fallback;
      }
    }

    final now = DateTime.now();
    final startDate = parseDateSafe(json['startDate'] ?? json['startedAt'], now);
    final endDate = parseDateSafe(json['endDate'] ?? json['deadline'] ?? json['dueDate'], now.add(const Duration(days: 30)));

    int parseIntSafe(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is String) return int.tryParse(v) ?? 0;
      try {
        return (v as num).toInt();
      } catch (_) {
        return 0;
      }
    }

    final currentApplicants = parseIntSafe(json['currentApplicants'] ?? json['applicants'] ?? 0);

    final skillsList = <SkillModel>[];
    final rawSkills = json['skills'] ?? json['skillList'] ?? json['tags'];
    if (rawSkills is List) {
      for (final s in rawSkills) {
        if (s is Map<String, dynamic>) {
          skillsList.add(SkillModel.fromJson(s));
        } else if (s is String) {
          skillsList.add(SkillModel(id: s, name: s, description: ''));
        }
      }
    }

    final status = (json['status'] ?? 'unknown').toString();

    return ProjectModel(
      projectId: projectId,
      projectName: projectName,
      description: description,
      startDate: startDate,
      endDate: endDate,
      currentApplicants: currentApplicants,
      skills: skillsList,
      status: status,
    );
  }
}

class PaginatedProjectModel extends PaginatedProjectEntity {
  PaginatedProjectModel({
    required super.projects,
    required super.totalElements,
    required super.totalPages,
    required super.currentPage,
    required super.hasNext,
  });

  factory PaginatedProjectModel.fromJson(Map<String, dynamic> json) {
    // Hỗ trợ nhiều cấu trúc trả về của backend:
    // - { data: { data: [...], totalElements... } }
    // - { data: [...], totalElements... }
    // - { projects: [...], totalElements... }
    final dataNode = json['data'] ?? json;
    List<dynamic> listRaw = [];
    int totalElements = 0;
    int totalPages = 1;
    int currentPage = 1;
    bool hasNext = false;

    try {
      if (dataNode is Map<String, dynamic>) {
        // tìm danh sách trong data.data hoặc data.list hoặc data.items
        if (dataNode['data'] is List) {
          listRaw = dataNode['data'] as List<dynamic>;
        } else if (dataNode['projects'] is List) {
          listRaw = dataNode['projects'] as List<dynamic>;
        } else if (dataNode['items'] is List) {
          listRaw = dataNode['items'] as List<dynamic>;
        } else if (dataNode is List) {
          listRaw = dataNode as List<dynamic>;
        }

        totalElements = (dataNode['totalElements'] ?? dataNode['total'] ?? 0) is int
            ? (dataNode['totalElements'] ?? dataNode['total'] ?? 0) as int
            : int.tryParse((dataNode['totalElements'] ?? dataNode['total'] ?? '0').toString()) ?? 0;

        totalPages = (dataNode['totalPages'] ?? dataNode['pages'] ?? 1) is int
            ? (dataNode['totalPages'] ?? dataNode['pages'] ?? 1) as int
            : int.tryParse((dataNode['totalPages'] ?? dataNode['pages'] ?? '1').toString()) ?? 1;

        currentPage = (dataNode['currentPage'] ?? dataNode['page'] ?? 1) is int
            ? (dataNode['currentPage'] ?? dataNode['page'] ?? 1) as int
            : int.tryParse((dataNode['currentPage'] ?? dataNode['page'] ?? '1').toString()) ?? 1;

        hasNext = (dataNode['hasNext'] ?? dataNode['has_more'] ?? false) == true;
      } else if (dataNode is List) {
        listRaw = dataNode;
      }
    } catch (_) {
      // fallback empty
      listRaw = [];
      totalElements = 0;
      totalPages = 1;
      currentPage = 1;
      hasNext = false;
    }

    final projects = listRaw
        .whereType<Map<String, dynamic>>()
        .map((p) => ProjectModel.fromJson(p))
        .toList();

    return PaginatedProjectModel(
      projects: projects,
      totalElements: totalElements,
      totalPages: totalPages,
      currentPage: currentPage,
      hasNext: hasNext,
    );
  }
}