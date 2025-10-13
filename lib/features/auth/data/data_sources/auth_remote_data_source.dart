// lib/features/auth/data/data_sources/auth_remote_data_source.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../../../../core/config/networks/config.dart';
import '../models/auth_model.dart';

class AuthRemoteDataSource {
  Future<AuthModel> login(String email, String password) async {
    final url = ApiConfig.endpoint("/api/v1/auth/login");
    final response = await http.post(
      url,
      headers: ApiConfig.defaultHeaders,
      body: jsonEncode({"email": email, "password": password}),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
        return AuthModel.fromJson(jsonResponse['data']);
      } else {
        throw Exception(jsonResponse['message'] ?? "Login failed");
      }
    } else {
      throw Exception("Login failed: ${response.body}");
    }
  }

  // ĐÃ SỬA: Thêm check lỗi userId rỗng
  Future<AuthModel> refreshToken(String refreshToken, String userId) async {
    // 🔔 THÊM CHECK: Ném lỗi sớm nếu userId bị thiếu/rỗng
    if (userId.isEmpty || userId == 'null') {
      debugPrint('API Debug: Refresh Token FAILED: User ID is required but missing or invalid.');
      throw Exception("Token refresh failed: User ID is required but missing or invalid.");
    }

    final url = ApiConfig.endpoint("/api/v1/auth/refresh");
    final requestBody = jsonEncode({
      "refreshToken": refreshToken,
      "userId": userId, // THAM SỐ CẦN THIẾT
    });

    debugPrint('API Debug: Refresh Token Request URL: $url');
    debugPrint('API Debug: Refresh Token Headers: ${ApiConfig.defaultHeaders}');
    debugPrint('API Debug: Refresh Token Body: $requestBody');

    final response = await http.post(
      url,
      headers: ApiConfig.defaultHeaders,
      body: requestBody,
    );

    final responseBody = response.body;

    debugPrint('API Debug: Refresh Token Response Status: ${response.statusCode}');
    debugPrint('API Debug: Refresh Token Response Body: $responseBody');


    if (response.statusCode == 200) {
      try {
        final Map<String, dynamic> jsonResponse = jsonDecode(responseBody);

        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          return AuthModel.fromJson(jsonResponse['data']);
        } else {
          // Xử lý trường hợp Status 200 nhưng API trả về success: false
          throw Exception(jsonResponse['message'] ?? "Token refresh failed: success=false");
        }
      } catch (e) {
        // Lỗi Parse JSON (lỗi format)
        throw Exception("Token refresh failed: Invalid JSON response. $e");
      }
    } else {
      // Xử lý trường hợp Status != 200
      try {
        final Map<String, dynamic> jsonResponse = jsonDecode(responseBody);
        throw Exception(jsonResponse['message'] ?? "Token refresh failed: Server error ${response.statusCode}");
      } catch (e) {
        // Lỗi không phải JSON (VD: HTML Error page)
        throw Exception("Token refresh failed: Server error ${response.statusCode}. Cannot parse error message.");
      }
    }
  }
}