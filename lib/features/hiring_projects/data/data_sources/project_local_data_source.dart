import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../models/project_model.dart';
import '../../../../core/database/local_database.dart';

abstract class ProjectLocalDataSource {
  Future<void> saveProject(ProjectModel project, String userId);
  Future<void> removeProject(String projectId, String userId);
  Future<List<ProjectModel>> getSavedProjects(String userId);
  Future<bool> isBookmarked(String projectId, String userId);
}

class ProjectLocalDataSourceImpl implements ProjectLocalDataSource {
  final dbProvider = LocalDatabase.instance;

  @override
  Future<void> saveProject(ProjectModel project, String userId) async {
    final db = await dbProvider.database;
    await db.insert(
      'saved_projects',
      {
        'userId': userId,
        'projectId': project.projectId,
        'projectName': project.projectName,
        'description': project.description,
        'startDate': project.startDate.toIso8601String(),
        'endDate': project.endDate.toIso8601String(),
        'currentApplicants': project.currentApplicants,
        'status': project.status,
        // FIX: Mapping thủ công vì SkillEntity không có toJson()
        'skillsJson': jsonEncode(project.skills.map((e) => {
          'id': e.id,
          'name': e.name,
          'description': e.description,
        }).toList()),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<List<ProjectModel>> getSavedProjects(String userId) async {
    final db = await dbProvider.database;
    final maps = await db.query(
      'saved_projects',
      where: 'userId = ?',
      whereArgs: [userId],
    );

    return maps.map((json) {
      final skillsList = (jsonDecode(json['skillsJson'] as String) as List)
          .map((s) => SkillModel.fromJson(s as Map<String, dynamic>))
          .toList();

      return ProjectModel(
        projectId: json['projectId'] as String,
        projectName: json['projectName'] as String,
        description: json['description'] as String,
        startDate: DateTime.parse(json['startDate'] as String),
        endDate: DateTime.parse(json['endDate'] as String),
        currentApplicants: json['currentApplicants'] as int,
        status: json['status'] as String,
        skills: skillsList,
      );
    }).toList();
  }

  @override
  Future<void> removeProject(String projectId, String userId) async {
    final db = await dbProvider.database;
    await db.delete(
      'saved_projects',
      where: 'projectId = ? AND userId = ?',
      whereArgs: [projectId, userId],
    );
  }

  @override
  Future<bool> isBookmarked(String projectId, String userId) async {
    final db = await dbProvider.database;
    final maps = await db.query(
      'saved_projects',
      where: 'projectId = ? AND userId = ?',
      whereArgs: [projectId, userId],
    );
    return maps.isNotEmpty;
  }
}