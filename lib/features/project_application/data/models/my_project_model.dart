class ProjectSkillModel {
  final String id;
  final String name;
  final String description;

  const ProjectSkillModel({
    required this.id,
    required this.name,
    required this.description,
  });

  factory ProjectSkillModel.fromJson(Map<String, dynamic> json) {
    return ProjectSkillModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
    );
  }
}

class ProjectMentorModel {
  final String id;
  final String name;
  final String roleName;
  final bool leader;

  const ProjectMentorModel({
    required this.id,
    required this.name,
    required this.roleName,
    required this.leader,
  });

  factory ProjectMentorModel.fromJson(Map<String, dynamic> json) {
    return ProjectMentorModel(
      id: json['id'] as String,
      name: json['name'] as String,
      roleName: json['roleName'] as String? ?? '',
      leader: json['leader'] as bool? ?? false,
    );
  }
}

class MyProjectModel {
  final String id;
  final String companyId;
  final String? mentorId;

  final String title;
  final String description;
  final String status;
  final bool isOpenForApplications;

  final DateTime? startDate;
  final DateTime? endDate;
  final double? budget;

  final List<ProjectSkillModel> skills;
  final List<ProjectMentorModel> mentors;

  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? createdBy;
  final String? createdByName;
  final String? createdByAvatar;

  final String? currentMilestoneId;
  final String? currentMilestoneName;
  final String? companyName;

  const MyProjectModel({
    required this.id,
    required this.companyId,
    this.mentorId,
    required this.title,
    required this.description,
    required this.status,
    required this.isOpenForApplications,
    this.startDate,
    this.endDate,
    this.budget,
    required this.skills,
    required this.mentors,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.createdByName,
    this.createdByAvatar,
    this.currentMilestoneId,
    this.currentMilestoneName,
    this.companyName,
  });

  /// Tiện cho UI cũ: danh sách tên mentor
  List<String> get mentorNames => mentors.map((m) => m.name).toList();

  factory MyProjectModel.fromJson(Map<String, dynamic> json) {
    return MyProjectModel(
      id: json['id'] as String,
      companyId: json['companyId'] as String,
      mentorId: json['mentorId'] as String?,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      status: json['status'] as String,
      isOpenForApplications: json['isOpenForApplications'] as bool? ?? false,
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'] as String)
          : null,
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'] as String)
          : null,
      budget: (json['budget'] as num?)?.toDouble(),
      skills: (json['skills'] as List<dynamic>? ?? [])
          .map(
            (s) => ProjectSkillModel.fromJson(
          s as Map<String, dynamic>,
        ),
      )
          .toList(),
      mentors: (json['mentors'] as List<dynamic>? ?? [])
          .map(
            (m) => ProjectMentorModel.fromJson(
          m as Map<String, dynamic>,
        ),
      )
          .toList(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      createdBy: json['createdBy'] as String?,
      createdByName: json['createdByName'] as String?,
      createdByAvatar: json['createdByAvatar'] as String?,
      currentMilestoneId: json['currentMilestoneId'] as String?,
      currentMilestoneName: json['currentMilestoneName'] as String?,
      companyName: json['companyName'] as String?,
    );
  }
}
