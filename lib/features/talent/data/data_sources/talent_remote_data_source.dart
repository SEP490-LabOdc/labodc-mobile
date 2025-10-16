// lib/features/talent/data/data_sources/talent_remote_data_source.dart

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../../../core/error/failures.dart';
import '../../../../core/config/networks/config.dart';
import '../models/talent_model.dart';

class TalentRemoteDataSource {

  Failure _handleResponseError(http.Response response) {
    String errorMessage = "Lỗi máy chủ (${response.statusCode}).";
    try {
      final jsonResponse = jsonDecode(response.body);
      errorMessage = jsonResponse['message']?.toString() ?? errorMessage;
    } catch (_) {
    }

    switch (response.statusCode) {
      case 400:
      case 422:
        return InvalidInputFailure(errorMessage);
      case 401:
        return UnAuthorizedFailure(errorMessage);
      case 404:
        return NotFoundFailure(errorMessage);
      case 500:
        return const ServerFailure("Lỗi máy chủ nội bộ. Vui lòng thử lại sau.", 500);
      default:
        return ServerFailure(errorMessage, response.statusCode);
    }
  }

  Future<TalentModel> getTalentProfile(String token, String userId) async {
    final url = ApiConfig.endpoint("/api/v1/users");

    try {
      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          // TalentModel.fromJson được viết để xử lý JSON response chung
          return TalentModel.fromJson(jsonResponse);
        } else {
          // Lỗi nghiệp vụ trong Status 200
          throw InvalidInputFailure(jsonResponse['message'] ?? "Lỗi khi tải hồ sơ Talent.");
        }
      } else {
        throw _handleResponseError(response);
      }
    } on SocketException {
      throw const NetworkFailure();
    } on TimeoutException {
      throw const NetworkFailure();
    } on Failure {
      rethrow;
    } catch (e) {
      throw UnknownFailure(e.toString());
    }
  }
}