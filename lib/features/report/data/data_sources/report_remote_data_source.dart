import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../../core/config/networks/config.dart';
import '../../../../core/error/exceptions.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../model/report_pagination_model.dart';




abstract class ReportRemoteDataSource {
  Future<ReportPaginationModel> getSentReports({
    required int page,
    required int size,
  });

  Future<ReportPaginationModel> getReceivedReports({
    required int page,
    required int size,
  });
}


class ReportRemoteDataSourceImpl implements ReportRemoteDataSource {
  final http.Client client;
  final AuthRepository authRepository;

  ReportRemoteDataSourceImpl({
    required this.client,
    required this.authRepository,
  });

  Future<Map<String, String>> _getHeaders() async {
    final token = await authRepository.getSavedToken();

    return {
      ...ApiConfig.defaultHeaders,
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }

  // GET /reports/sent
  @override
  Future<ReportPaginationModel> getSentReports({
    required int page,
    required int size,
  }) async {
    final uri = ApiConfig.endpoint(
      "api/v1/reports/sent?page=$page&size=$size",
    );

    try {
      final response = await client.get(
        uri,
        headers: await _getHeaders(),
      );

      final body = utf8.decode(response.bodyBytes);
      final decoded = json.decode(body);

      if (kDebugMode) {
        debugPrint(
            "[ReportRemoteDataSource] GET SENT: status=${response.statusCode} body=$body");
      }

      if (response.statusCode == 200 && decoded["success"] == true) {
        return ReportPaginationModel.fromJson(decoded["data"]);
      }

      throw ServerException(
        decoded["message"] ?? "Không thể tải báo cáo đã gửi",
        statusCode: response.statusCode,
      );
    } on SocketException {
      throw NetworkException();
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;

      throw ServerException("Lỗi không xác định khi tải báo cáo đã gửi: $e");
    }
  }

  // GET /reports/received
  @override
  Future<ReportPaginationModel> getReceivedReports({
    required int page,
    required int size,
  }) async {
    final uri = ApiConfig.endpoint(
      "api/v1/reports/received?page=$page&size=$size",
    );

    try {
      final response = await client.get(
        uri,
        headers: await _getHeaders(),
      );

      final body = utf8.decode(response.bodyBytes);
      final decoded = json.decode(body);

      if (kDebugMode) {
        debugPrint(
            "[ReportRemoteDataSource] GET RECEIVED: status=${response.statusCode} body=$body");
      }

      if (response.statusCode == 200 && decoded["success"] == true) {
        return ReportPaginationModel.fromJson(decoded["data"]);
      }

      throw ServerException(
        decoded["message"] ?? "Không thể tải báo cáo đã nhận",
        statusCode: response.statusCode,
      );
    } on SocketException {
      throw NetworkException();
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;

      throw ServerException("Lỗi không xác định khi tải báo cáo đã nhận: $e");
    }
  }
}
