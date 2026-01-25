class ProjectMilestoneModel {
  final String id;
  final String projectId;
  final String projectName;
  final String title;
  final double budget;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final String status;

  final List<MilestoneUserModel> talents;
  final List<MilestoneUserModel> mentors;
  final List<MilestoneAttachmentModel> attachments;

  ProjectMilestoneModel({
    required this.id,
    required this.projectId,
    required this.projectName,
    required this.title,
    required this.budget,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.talents,
    required this.mentors,
    required this.attachments,
  });

  factory ProjectMilestoneModel.fromJson(Map<String, dynamic> json) {
    return ProjectMilestoneModel(
      id: json['id'],
      projectId: json['projectId'],
      projectName: json['projectName'],
      title: json['title'],
      budget: (json['budget'] ?? 0).toDouble(),
      description: json['description'] ?? '',
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      status: json['status'],
      talents:
          (json['talents'] as List<dynamic>?)
              ?.map((e) => MilestoneUserModel.fromJson(e))
              .toList() ??
          [],
      mentors:
          (json['mentors'] as List<dynamic>?)
              ?.map((e) => MilestoneUserModel.fromJson(e))
              .toList() ??
          [],
      attachments:
          (json['attachments'] as List<dynamic>?)
              ?.map((e) => MilestoneAttachmentModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class MilestoneUserModel {
  final String userId;
  final String name;
  final String avatar;
  final String email;
  final String phone;

  MilestoneUserModel({
    required this.userId,
    required this.name,
    required this.avatar,
    required this.email,
    required this.phone,
  });

  factory MilestoneUserModel.fromJson(Map<String, dynamic> json) {
    return MilestoneUserModel(
      userId: json['userId'],
      name: json['name'],
      avatar: json['avatar'] ?? "",
      email: json['email'] ?? "",
      phone: json['phone'] ?? "",
    );
  }
}

class MilestoneAttachmentModel {
  final String id;
  final String name;
  final String fileName;
  final String url;

  MilestoneAttachmentModel({
    required this.id,
    required this.name,
    required this.fileName,
    required this.url,
  });

  factory MilestoneAttachmentModel.fromJson(Map<String, dynamic> json) {
    return MilestoneAttachmentModel(
      id: json['id'],
      name: json['name'],
      fileName: json['fileName'],
      url: json['url'],
    );
  }
}
