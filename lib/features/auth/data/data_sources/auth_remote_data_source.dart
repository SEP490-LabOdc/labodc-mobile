// lib/features/auth/data/data_sources/auth_remote_data_source.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../../../../core/config/networks/config.dart';
import '../../../../core/error/failures.dart'; // THÊM IMPORT FAILURE
import '../models/auth_model.dart';

class AuthRemoteDataSource {

  // Hàm phụ trợ để xử lý logic Mapping lỗi (giúp code sạch hơn)
  Failure _handleResponseError(http.Response response) {
    String errorMessage = "Lỗi máy chủ (${response.statusCode}).";
    try {
      final jsonResponse = jsonDecode(response.body);
      errorMessage = jsonResponse['message']?.toString() ?? errorMessage;
    } catch (_) {
      // Bỏ qua lỗi parsing nếu response body không phải JSON
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


  Future<AuthModel> login(String email, String password) async {
    final url = ApiConfig.endpoint("/api/v1/auth/login");

    try {
      final response = await http.post(
        url,
        headers: ApiConfig.defaultHeaders,
        body: jsonEncode({"email": email, "password": password}),
      ).timeout(const Duration(seconds: 15)); // Giới hạn thời gian chờ

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          return AuthModel.fromJson(jsonResponse['data']);
        } else {
          throw InvalidInputFailure(jsonResponse['message'] ?? "Login failed");
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

  Future<AuthModel> refreshToken(String refreshToken, String userId) async {
    if (userId.isEmpty || userId == 'null') {
      debugPrint('API Debug: Refresh Token FAILED: User ID is required but missing or invalid.');
      throw const InvalidInputFailure("User ID is required but missing or invalid.");
    }

    final url = ApiConfig.endpoint("/api/v1/auth/refresh");
    final requestBody = jsonEncode({
      "refreshToken": refreshToken,
      "userId": userId,
    });

    debugPrint('API Debug: Refresh Token Request URL: $url');
    debugPrint('API Debug: Refresh Token Body: $requestBody');

    try {
      final response = await http.post(
        url,
        headers: ApiConfig.defaultHeaders,
        body: requestBody,
      ).timeout(const Duration(seconds: 15));

      final responseBody = response.body;
      debugPrint('API Debug: Refresh Token Response Status: ${response.statusCode}');
      debugPrint('API Debug: Refresh Token Response Body: $responseBody');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(responseBody);
        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          return AuthModel.fromJson(jsonResponse['data']);
        } else {
          throw InvalidInputFailure(jsonResponse['message'] ?? "Token refresh failed: success=false");
        }
      } else {
        throw _handleResponseError(response); // CHUYỂN ĐỔI SANG FAILURE
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