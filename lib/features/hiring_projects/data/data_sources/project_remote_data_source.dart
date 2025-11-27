// lib/features/hiring_projects/data/data_sources/project_remote_data_source.dart

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../../core/config/networks/config.dart';
import '../../../../core/error/exceptions.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../models/project_detail_model.dart';
import '../models/project_model.dart';

abstract class ProjectRemoteDataSource {
  Future<PaginatedProjectModel> getHiringProjects({
    required int page,
    required int pageSize,
  });

  Future<ProjectDetailModel> getProjectDetail(String projectId);
}


class ProjectRemoteDataSourceImpl implements ProjectRemoteDataSource {
  final http.Client client;
  final AuthRepository authRepository;

  ProjectRemoteDataSourceImpl(this.client, this.authRepository);

  @override
  Future<PaginatedProjectModel> getHiringProjects({
    required int page,
    required int pageSize,
  }) async {
    final uri = ApiConfig.endpoint('api/v1/projects/hiring').replace(
      queryParameters: {
        'page': page.toString(),
        'pageSize': pageSize.toString(),
      },
    );

    final token = await authRepository.getSavedToken();

    debugPrint(" [HiringProjects] URI: $uri");
    debugPrint(" [HiringProjects] Token: $token");


    final headers = {
      ...ApiConfig.defaultHeaders,
      if (token != null) 'Authorization': 'Bearer $token',
    };

    try {
      final response = await client.get(uri, headers: headers);

      final decoded = json.decode(utf8.decode(response.bodyBytes));

      debugPrint("📩 [HiringProjects] Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        if (decoded['success'] == true) {
          return PaginatedProjectModel.fromJson(decoded);
        }
        throw ServerException(
          decoded['message'] ?? 'Unknown error',
          statusCode: 422,
        );
      }

      throw ServerException(
        decoded['message'] ?? 'Server error',
        statusCode: response.statusCode,
      );
    } on SocketException {
      throw NetworkException();
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<ProjectDetailModel> getProjectDetail(String projectId) async {
    final uri = ApiConfig.endpoint('api/v1/projects/$projectId');
    final token = await authRepository.getSavedToken();

    final headers = {
      ...ApiConfig.defaultHeaders,
      if (token != null) 'Authorization': 'Bearer $token',
    };
    try {
      final response = await client.get(uri, headers: headers);

      debugPrint("🔥 [ProjectDetail] Raw Response Body: ${utf8.decode(response.bodyBytes)}");

      final decoded = json.decode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200) {
        debugPrint("✅ [ProjectDetail] Success Flag: ${decoded['success']}");
        debugPrint("📦 [ProjectDetail] Data Object Exists: ${decoded['data'] != null}");

        if (decoded['success'] == true && decoded['data'] != null) {
          try {
            debugPrint("🛠️ [ProjectDetail] Starting JSON parsing...");
            final model = ProjectDetailModel.fromJson(decoded['data']);
            debugPrint("🎉 [ProjectDetail] JSON parsing successful!");
            return model;
          } catch (parseError) {
            debugPrint("❌❌❌ [ProjectDetail] JSON Parsing Error: $parseError");
            throw ServerException('Lỗi phân tích dữ liệu dự án: ${parseError.toString()}');
          }
        }

        final message = decoded['message']?.toString() ?? 'Dữ liệu dự án không hợp lệ';
        debugPrint("⚠️ [ProjectDetail] Business Error: $message");
        throw ServerException(message, statusCode: 200);
      }

      throw ServerException(
        decoded['message'] ?? 'Server error',
        statusCode: response.statusCode,
      );

    } on SocketException {
      throw NetworkException();
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      debugPrint("💥 [ProjectDetail] Unexpected Error: $e");
      throw ServerException('Unexpected error: $e');
    }
  }
}
