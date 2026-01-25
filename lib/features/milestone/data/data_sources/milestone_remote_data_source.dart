import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../../core/error/exceptions.dart';
import '../../../../core/config/networks/config.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../models/milestone_detail_model.dart';
import '../models/milestone_disbursement_model.dart';
import '../models/milestone_document_model.dart';
import '../models/milestone_member_model.dart';
import '../models/milestone_wallet_model.dart';
import '../models/project_milestone_model.dart';

abstract class MilestoneRemoteDataSource {
  Future<List<ProjectMilestoneModel>> getMilestones(String projectId);
  Future<MilestoneDetailModel> getMilestoneDetail(String milestoneId);
  Future<List<MilestoneDocumentModel>> getMilestoneDocuments(
    String milestoneId,
  );
  Future<MilestoneDisbursementModel> getMilestoneDisbursement(
    String milestoneId,
  );

  // New methods for paid milestones feature
  Future<List<ProjectMilestoneModel>> getPaidMilestones(String projectId);
  Future<List<MilestoneMemberModel>> getMilestoneMembersByRole(
    String milestoneId,
    String role,
  );
  Future<MilestoneWalletModel?> getMilestoneWallet(String milestoneId);
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
        debugPrint(
          '[MilestoneRemoteDataSource] GET $uri → '
          'status=${response.statusCode}, body=$body',
        );
      }

      final decoded = json.decode(body) as Map<String, dynamic>;

      if (response.statusCode != 200 || decoded['success'] != true) {
        throw ServerException(
          decoded['message']?.toString() ?? 'Không thể lấy danh sách cột mốc.',
          statusCode: response.statusCode,
        );
      }

      final List<dynamic> list = decoded['data'] ?? [];

      return list.map((e) => ProjectMilestoneModel.fromJson(e)).toList();
    } on SocketException {
      throw NetworkException();
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;

      throw ServerException('Lỗi không xác định khi lấy danh sách cột mốc: $e');
    }
  }

  @override
  Future<MilestoneDetailModel> getMilestoneDetail(String milestoneId) async {
    final uri = ApiConfig.endpoint('/api/v1/project-milestones/$milestoneId');

    try {
      final response = await client.get(uri, headers: await _getHeaders());
      final body = utf8.decode(response.bodyBytes);

      if (kDebugMode) {
        debugPrint(
          '[MilestoneRemoteDataSource] GET $uri → '
          'status=${response.statusCode}, body=$body',
        );
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

  @override
  Future<List<MilestoneDocumentModel>> getMilestoneDocuments(
    String milestoneId,
  ) async {
    final uri = ApiConfig.endpoint(
      '/api/v1/project-milestones/$milestoneId/documents',
    );

    try {
      final response = await client.get(uri, headers: await _getHeaders());
      final body = utf8.decode(response.bodyBytes);
      final decoded = json.decode(body) as Map<String, dynamic>;

      if (kDebugMode) {
        debugPrint(
          '[MilestoneDocs] GET $uri -> Status: ${response.statusCode}',
        );
      }

      if (response.statusCode == 200 && decoded['success'] == true) {
        final List<dynamic> list = decoded['data'] ?? [];
        return list.map((e) => MilestoneDocumentModel.fromJson(e)).toList();
      }

      throw ServerException(
        decoded['message']?.toString() ?? 'Không thể tải tài liệu.',
        statusCode: response.statusCode,
      );
    } on SocketException {
      throw NetworkException();
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Lỗi tải tài liệu: $e');
    }
  }

  @override
  Future<MilestoneDisbursementModel> getMilestoneDisbursement(
    String milestoneId,
  ) async {
    final uri = ApiConfig.endpoint(
      '/api/v1/disbursement/milestones/$milestoneId',
    );

    try {
      final response = await client.get(uri, headers: await _getHeaders());
      final body = utf8.decode(response.bodyBytes);
      final decoded = json.decode(body) as Map<String, dynamic>;

      if (kDebugMode) {
        debugPrint(
          '[MilestoneDisbursement] GET $uri → status=${response.statusCode}',
        );
      }

      if (response.statusCode == 200 && decoded['success'] == true) {
        return MilestoneDisbursementModel.fromJson(decoded['data']);
      }

      throw ServerException(
        decoded['message']?.toString() ?? 'Lỗi tải thông tin phân bổ.',
        statusCode: response.statusCode,
      );
    } on SocketException {
      throw NetworkException();
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Lỗi hệ thống: $e');
    }
  }

  @override
  Future<List<ProjectMilestoneModel>> getPaidMilestones(
    String projectId,
  ) async {
    final uri = ApiConfig.endpoint(
      '/api/v1/project-milestones/$projectId/paid',
    );

    try {
      final response = await client.get(uri, headers: await _getHeaders());
      final body = utf8.decode(response.bodyBytes);

      if (kDebugMode) {
        debugPrint(
          '[MilestoneRemoteDataSource] GET $uri → '
          'status=${response.statusCode}, body=$body',
        );
      }

      final decoded = json.decode(body) as Map<String, dynamic>;

      if (response.statusCode != 200 || decoded['success'] != true) {
        throw ServerException(
          decoded['message']?.toString() ??
              'Không thể lấy danh sách milestone đã thanh toán.',
          statusCode: response.statusCode,
        );
      }

      final List<dynamic> list = decoded['data'] ?? [];

      return list.map((e) => ProjectMilestoneModel.fromJson(e)).toList();
    } on SocketException {
      throw NetworkException();
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;

      throw ServerException(
        'Lỗi không xác định khi lấy danh sách milestone đã thanh toán: $e',
      );
    }
  }

  @override
  Future<List<MilestoneMemberModel>> getMilestoneMembersByRole(
    String milestoneId,
    String role,
  ) async {
    final uri = ApiConfig.endpoint(
      '/api/v1/project-milestones/$milestoneId/milestone-members/by-role',
    ).replace(queryParameters: {'role': role});

    try {
      final response = await client.get(uri, headers: await _getHeaders());
      final body = utf8.decode(response.bodyBytes);

      if (kDebugMode) {
        debugPrint(
          '[MilestoneMembers] GET $uri → '
          'status=${response.statusCode}, body=$body',
        );
      }

      final decoded = json.decode(body) as Map<String, dynamic>;

      if (response.statusCode != 200 || decoded['success'] != true) {
        throw ServerException(
          decoded['message']?.toString() ??
              'Không thể lấy danh sách thành viên milestone.',
          statusCode: response.statusCode,
        );
      }

      final List<dynamic> list = decoded['data'] ?? [];

      return list.map((e) => MilestoneMemberModel.fromJson(e)).toList();
    } on SocketException {
      throw NetworkException();
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;

      throw ServerException(
        'Lỗi không xác định khi lấy danh sách thành viên: $e',
      );
    }
  }

  @override
  Future<MilestoneWalletModel?> getMilestoneWallet(String milestoneId) async {
    final uri = ApiConfig.endpoint('/api/v1/wallets/milestones/$milestoneId');

    try {
      final response = await client.get(uri, headers: await _getHeaders());
      final body = utf8.decode(response.bodyBytes);

      if (kDebugMode) {
        debugPrint(
          '[MilestoneWallet] GET $uri → '
          'status=${response.statusCode}, body=$body',
        );
      }

      final decoded = json.decode(body) as Map<String, dynamic>;

      if (response.statusCode == 200 && decoded['success'] == true) {
        return MilestoneWalletModel.fromJson(decoded['data']);
      }

      // If wallet doesn't exist or error, return null instead of throwing
      if (kDebugMode) {
        debugPrint(
          '[MilestoneWallet] Wallet not found or error, returning null',
        );
      }
      return null;
    } on SocketException {
      if (kDebugMode) {
        debugPrint('[MilestoneWallet] Network exception, returning null');
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[MilestoneWallet] Exception: $e, returning null');
      }
      return null;
    }
  }
}
