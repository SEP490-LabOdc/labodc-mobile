import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../../core/error/exceptions.dart';
import '../../../../core/config/networks/config.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../models/milestone_detail_model.dart';
import '../models/project_milestone_model.dart';

abstract class MilestoneRemoteDataSource {
  Future<List<ProjectMilestoneModel>> getMilestones(String projectId);
  Future<MilestoneDetailModel> getMilestoneDetail(String milestoneId);
}


class MilestoneRemoteDataSourceImpl implements MilestoneRemoteDataSource {
  final http.Client client;
  final AuthRepository authRepository;

  MilestoneRemoteDataSourceImpl({
    required this.client,
    required this.authRepository,
  });

  Future<Map<String, String>> _getHeaders() async {
    final token = await authRepository.getSavedToken();
    return {
      ...ApiConfig.defaultHeaders,
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  @override
  Future<List<ProjectMilestoneModel>> getMilestones(String projectId) async {
    final uri = ApiConfig.endpoint('/api/v1/projects/$projectId/milestones');

    try {
      final response = await client.get(uri, headers: await _getHeaders());

      final body = utf8.decode(response.bodyBytes);

      if (kDebugMode) {
        debugPrint('[MilestoneRemoteDataSource] GET $uri → '
            'status=${response.statusCode}, body=$body');
      }

      final decoded = json.decode(body) as Map<String, dynamic>;

      if (response.statusCode != 200 || decoded['success'] != true) {
        throw ServerException(
          decoded['message']?.toString() ??
              'Không thể lấy danh sách cột mốc.',
          statusCode: response.statusCode,
        );
      }

      final List<dynamic> list = decoded['data'] ?? [];

      return list
          .map((e) => ProjectMilestoneModel.fromJson(e))
          .toList();
    } on SocketException {
      throw NetworkException();
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;

      throw ServerException(
        'Lỗi không xác định khi lấy danh sách cột mốc: $e',
      );
    }
  }

  @override
  Future<MilestoneDetailModel> getMilestoneDetail(String milestoneId) async {
    final uri = ApiConfig.endpoint('/api/v1/project-milestones/$milestoneId');

    try {
      final response = await client.get(uri, headers: await _getHeaders());
      final body = utf8.decode(response.bodyBytes);

      if (kDebugMode) {
        debugPrint('[MilestoneRemoteDataSource] GET $uri → '
            'status=${response.statusCode}, body=$body');
      }

      final decoded = json.decode(body) as Map<String, dynamic>;

      if (response.statusCode != 200 || decoded['success'] != true) {
        throw ServerException(
          decoded['message']?.toString() ?? 'Không thể lấy chi tiết milestone.',
          statusCode: response.statusCode,
        );
      }

      final data = decoded['data'] as Map<String, dynamic>;
      return MilestoneDetailModel.fromJson(data);

    } on SocketException {
      throw NetworkException();
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;

      throw ServerException(
        'Lỗi không xác định khi lấy chi tiết milestone: $e',
      );
    }
  }

}
