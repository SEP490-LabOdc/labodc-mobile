import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:labodc_mobile/features/project_application/data/models/my_project_model.dart';

// Điều chỉnh import theo cấu trúc dự án thực tế của bạn
import '../../../../core/config/networks/config.dart';
import '../../../../core/error/exceptions.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../models/project_applicant_model.dart';
import '../models/project_application_status_model.dart';
import '../models/submitted_cv_model.dart';
import '../models/uploaded_file_model.dart';

abstract class ProjectApplicationRemoteDataSource {
  Future<List<SubmittedCvModel>> getMySubmittedCvs();
  Future<void> applyProject({
    required String userId,
    required String projectId,
    required String cvUrl,
  });
  Future<UploadedFileModel> uploadCvFile(File file);
  Future<bool> hasAppliedProject(String projectId);
  Future<ProjectApplicationStatusModel> getApplicationStatus(String projectId);
  Future<List<MyProjectModel>> getMyProjects({String? status});
  Future<List<ProjectApplicantModel>> getProjectApplicants(String projectId);

}

class ProjectApplicationRemoteDataSourceImpl
    implements ProjectApplicationRemoteDataSource {
  final http.Client client;
  final AuthRepository authRepository;

  ProjectApplicationRemoteDataSourceImpl({
    required this.client,
    required this.authRepository,
  });

  Future<Map<String, String>> _getHeaders({bool isJson = true}) async {
    final token = await authRepository.getSavedToken();
    return {
      ...ApiConfig.defaultHeaders,
      if (isJson) 'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // 1. API lấy CV đã ứng tuyển
  @override
  Future<List<SubmittedCvModel>> getMySubmittedCvs() async {
    final uri =
    ApiConfig.endpoint('api/v1/project-applications/my-submitted-cvs');

    try {
      final response = await client.get(
        uri,
        headers: await _getHeaders(),
      );

      final decoded = json.decode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200 && decoded['success'] == true) {
        final dataList = decoded['data'] as List<dynamic>;
        return dataList
            .map((json) => SubmittedCvModel.fromJson(json))
            .toList();
      } else {
        // Trường hợp success=true nhưng data rỗng (chưa có CV) thì trả về []
        if (decoded['data'] is List && (decoded['data'] as List).isEmpty) {
          return [];
        }
        throw ServerException(
          decoded['message'] ?? 'Lỗi kiểm tra danh sách CV',
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      throw NetworkException();
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Lỗi không xác định khi lấy danh sách CV: $e');
    }
  }

  // 2. API Apply Dự án
  @override
  Future<void> applyProject({
    required String userId,
    required String projectId,
    required String cvUrl,
  }) async {
    final uri = ApiConfig.endpoint('api/v1/project-applications/apply');
    final body = json.encode({
      'userId': userId,
      'projectId': projectId,
      'cvUrl': cvUrl,
    });

    try {
      final response = await client.post(
        uri,
        headers: await _getHeaders(),
        body: body,
      );

      if (kDebugMode) {
        debugPrint(
          'Apply Project Response: '
              '${response.statusCode} - ${utf8.decode(response.bodyBytes)}',
        );
      }

      final decoded = json.decode(utf8.decode(response.bodyBytes));

      // Ở đây backend đang trả 200, nếu sau này đổi sang 201
      // có thể nới điều kiện tương tự như upload.
      if (response.statusCode != 200 || decoded['success'] != true) {
        throw ServerException(
          decoded['message'] ?? 'Ứng tuyển thất bại',
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      throw NetworkException();
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Lỗi không xác định khi ứng tuyển: $e');
    }
  }

  // 3. API Upload CV (Multipart)
  @override
  Future<UploadedFileModel> uploadCvFile(File file) async {
    final uri = ApiConfig.endpoint('api/v1/files/upload');
    final token = await authRepository.getSavedToken();

    final request = http.MultipartRequest('POST', uri);
    request.headers.addAll({
      ...ApiConfig.defaultHeaders,
      // Content-Type cho multipart thường được tự set
      if (token != null) 'Authorization': 'Bearer $token',
    });

    // 'file' là tên field mà backend yêu cầu
    request.files.add(
      await http.MultipartFile.fromPath('file', file.path),
    );

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (kDebugMode) {
        debugPrint(
          'Upload CV Response: '
              '${response.statusCode} - ${utf8.decode(response.bodyBytes)}',
        );
      }

      final decoded = json.decode(utf8.decode(response.bodyBytes));


      if ((response.statusCode == 200 || response.statusCode == 201) &&
          decoded['success'] == true) {
        return UploadedFileModel.fromJson(decoded);
      } else {
        throw ServerException(
          decoded['message'] ?? 'Upload thất bại',
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      throw NetworkException();
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Lỗi kết nối khi upload: $e');
    }
  }
  @override
  Future<bool> hasAppliedProject(String projectId) async {
    final uri = ApiConfig.endpoint(
      'api/v1/projects/my-applications?page=1&size=50',
    );

    try {
      final response = await client.get(
        uri,
        headers: await _getHeaders(),
      );

      final body = utf8.decode(response.bodyBytes);
      if (kDebugMode) {
        debugPrint(
          '[ProjectApplicationRemoteDataSource] GET $uri -> '
              '${response.statusCode} - $body',
        );
      }

      final decoded = json.decode(body) as Map<String, dynamic>;

      if (response.statusCode == 200 && decoded['success'] == true) {
        final dataWrapper = decoded['data'] as Map<String, dynamic>;
        final list = dataWrapper['data'] as List<dynamic>;

        // ✅ Kiểm tra có projectId trùng không
        final alreadyApplied = list.any(
              (item) => item['projectId']?.toString() == projectId,
        );
        return alreadyApplied;
      } else {
        final msg = decoded['message']?.toString() ??
            'Không thể lấy danh sách đơn ứng tuyển';
        throw ServerException(msg, statusCode: response.statusCode);
      }
    } on SocketException {
      throw NetworkException();
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException(
        'Lỗi không xác định khi kiểm tra đơn ứng tuyển: $e',
      );
    }
  }

  @override
  Future<ProjectApplicationStatusModel> getApplicationStatus(
      String projectId,
      ) async {
    final uri = ApiConfig.endpoint(
      'api/v1/projects/$projectId/application-status',
    );

    try {
      final response = await client.get(
        uri,
        headers: await _getHeaders(),
      );

      final decoded =
      json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;

      if (kDebugMode) {
        debugPrint(
          'ApplicationStatus Response: '
              '${response.statusCode} - ${utf8.decode(response.bodyBytes)}',
        );
      }

      final dataJson = decoded['data'] as Map<String, dynamic>?;

      if (dataJson == null) {
        throw ServerException(
          'Không đọc được dữ liệu trạng thái ứng tuyển',
          statusCode: response.statusCode,
        );
      }

      return ProjectApplicationStatusModel.fromJson(dataJson);
    } on SocketException {
      throw NetworkException();
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException(
        'Lỗi không xác định khi kiểm tra trạng thái ứng tuyển: $e',
      );
    }
  }

  @override
  Future<List<MyProjectModel>> getMyProjects({String? status}) async {
    final baseUri = ApiConfig.endpoint('api/v1/projects/my-projects');

    final uri = (status != null && status.isNotEmpty)
        ? baseUri.replace(queryParameters: {
      ...baseUri.queryParameters,
      'status': status,
    })
        : baseUri;

    try {
      final response = await client.get(
        uri,
        headers: await _getHeaders(),
      );

      final decoded = json.decode(
        utf8.decode(response.bodyBytes),
      ) as Map<String, dynamic>;

      if (kDebugMode) {
        debugPrint(
          'MyProjects Response: '
              '${response.statusCode} - ${utf8.decode(response.bodyBytes)}',
        );
      }

      if (response.statusCode == 200 && decoded['success'] == true) {
        final dataList = decoded['data'] as List<dynamic>;

        return dataList
            .map((item) => MyProjectModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw ServerException(
          decoded['message'] ?? 'Không đọc được danh sách dự án của bạn',
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      throw NetworkException();
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException(
        'Lỗi không xác định khi lấy danh sách dự án của bạn: $e',
      );
    }
  }
  @override
  Future<List<ProjectApplicantModel>> getProjectApplicants(
      String projectId) async {
    final uri =
    ApiConfig.endpoint('api/v1/projects/$projectId/applicants');

    try {
      final headers = await _getHeaders();
      final response = await http.get(uri, headers: headers);

      debugPrint(
          '[ProjectApplicationRemoteDataSourceImpl] getProjectApplicants(${uri.toString()}), status=${response.statusCode}');

      final decoded = json.decode(utf8.decode(response.bodyBytes));

      if (response.statusCode != 200 || decoded['success'] != true) {
        throw ServerException(
          decoded['message'] ?? 'Lấy danh sách ứng viên thất bại',
          statusCode: response.statusCode,
        );
      }

      final List<dynamic> data = decoded['data'] as List<dynamic>;
      return data
          .map(
            (e) => ProjectApplicantModel.fromJson(
          e as Map<String, dynamic>,
        ),
      )
          .toList();
    } on SocketException {
      throw NetworkException();
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException(
        'Lỗi không xác định khi lấy danh sách ứng viên: $e',
      );
    }
  }



}
