class ProjectDetailModel {
  final String id;
  final String companyId;
  final String? mentorId;

  final String title;
  final String description;
  final String status;
  final bool isOpenForApplications;

  final DateTime? startDate;   
  final DateTime? endDate;     

  final double budget;
  final double remainingBudget;

  final List<ProjectSkillModel> skills;
  final List<ProjectMentorModel> mentors;
  final List<ProjectTalentModel> talents;

  final DateTime createdAt;
  final DateTime updatedAt;

  final String createdBy;
  final String createdByName;
  final String? createdByAvatar;

  final String? currentMilestoneId;
  final String? currentMilestoneName;

  final String? companyName;

  ProjectDetailModel({
    required this.id,
    required this.companyId,
    required this.mentorId,
    required this.title,
    required this.description,
    required this.status,
    required this.isOpenForApplications,
    required this.startDate,
    required this.endDate,
    required this.budget,
    required this.remainingBudget,
    required this.skills,
    required this.mentors,
    required this.talents,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    required this.createdByName,
    required this.createdByAvatar,
    required this.currentMilestoneId,
    required this.currentMilestoneName,
    required this.companyName,
  });

  factory ProjectDetailModel.fromJson(Map<String, dynamic> json) {
    DateTime? _parseNullableDate(dynamic value) {
      if (value == null) return null;
      if (value is String && value.isNotEmpty) {
        try {
          return DateTime.parse(value);
        } catch (_) {
          return null;
        }
      }
      return null;
    }

    DateTime _parseRequiredDate(dynamic value) {
      final result = _parseNullableDate(value);
      return result ?? DateTime.now(); 
    }

    return ProjectDetailModel(
      id: (json['id'] ?? '').toString(),
      companyId: (json['companyId'] ?? '').toString(),
      mentorId: json['mentorId']?.toString(),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      isOpenForApplications:
      json['isOpenForApplications'] as bool? ?? false,

      // ✅ an toàn với null
      startDate: _parseNullableDate(json['startDate']),
      endDate: _parseNullableDate(json['endDate']),

      budget: (json['budget'] as num?)?.toDouble() ?? 0.0,
      remainingBudget:
      (json['remainingBudget'] as num?)?.toDouble() ?? 0.0,

      skills: (json['skills'] as List<dynamic>? ?? [])
          .map((e) =>
          ProjectSkillModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      mentors: (json['mentors'] as List<dynamic>? ?? [])
          .map((e) =>
          ProjectMentorModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      talents: (json['talents'] as List<dynamic>? ?? [])
          .map((e) =>
          ProjectTalentModel.fromJson(e as Map<String, dynamic>))
          .toList(),

      createdAt: _parseRequiredDate(json['createdAt']),
      updatedAt: _parseRequiredDate(json['updatedAt']),
      createdBy: (json['createdBy'] ?? '').toString(),
      createdByName: (json['createdByName'] ?? '').toString(),
      createdByAvatar: json['createdByAvatar']?.toString(),
      currentMilestoneId: json['currentMilestoneId']?.toString(),
      currentMilestoneName: json['currentMilestoneName']?.toString(),
      companyName: json['companyName']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'companyId': companyId,
      'mentorId': mentorId,
      'title': title,
      'description': description,
      'status': status,
      'isOpenForApplications': isOpenForApplications,
      'startDate':
      startDate?.toIso8601String().split('T').first, 
      'endDate':
      endDate?.toIso8601String().split('T').first, 
      'budget': budget,
      'remainingBudget': remainingBudget,
      'skills': skills.map((e) => e.toJson()).toList(),
      'mentors': mentors.map((e) => e.toJson()).toList(),
      'talents': talents.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy,
      'createdByName': createdByName,
      'createdByAvatar': createdByAvatar,
      'currentMilestoneId': currentMilestoneId,
      'currentMilestoneName': currentMilestoneName,
      'companyName': companyName,
    };
  }
}

class ProjectSkillModel {
  final String id;
  final String name;
  final String description;

  ProjectSkillModel({
    required this.id,
    required this.name,
    required this.description,
  });

  factory ProjectSkillModel.fromJson(Map<String, dynamic> json) {
    final id = (json['id'] ?? json['skillId'] ?? '').toString();
    final name = (json['name'] ?? json['title'] ?? '').toString();
    final description =
    (json['description'] ?? json['desc'] ?? '').toString();

    return ProjectSkillModel(
      id: id,
      name: name,
      description: description,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }
}

class ProjectMentorModel {
  final String id;
  final String name;
  final String roleName;
  final bool leader;
  final String? avatar;

  ProjectMentorModel({
    required this.id,
    required this.name,
    required this.roleName,
    required this.leader,
    required this.avatar,
  });

  factory ProjectMentorModel.fromJson(Map<String, dynamic> json) {
    return ProjectMentorModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      roleName: (json['roleName'] ?? '').toString(),
      leader: json['leader'] as bool? ?? false,
      avatar: json['avatar']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'roleName': roleName,
      'leader': leader,
      'avatar': avatar,
    };
  }
}

class ProjectTalentModel {
  final String id;
  final String name;
  final String roleName;
  final bool leader;
  final String? avatar;

  ProjectTalentModel({
    required this.id,
    required this.name,
    required this.roleName,
    required this.leader,
    required this.avatar,
  });

  factory ProjectTalentModel.fromJson(Map<String, dynamic> json) {
    return ProjectTalentModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      roleName: (json['roleName'] ?? '').toString(),
      leader: json['leader'] as bool? ?? false,
      avatar: json['avatar']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'roleName': roleName,
      'leader': leader,
      'avatar': avatar,
    };
  }
}
