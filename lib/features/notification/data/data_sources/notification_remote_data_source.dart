// lib/features/notification/data/data_sources/notification_remote_data_source.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../../../../core/error/failures.dart';
import '../../../../core/config/networks/config.dart';
import '../models/notification_model.dart';

class NotificationRemoteDataSource {

  Failure _handleResponseError(http.Response response) {
    String errorMessage = "Lỗi máy chủ (${response.statusCode}).";
    try {
      final jsonResponse = jsonDecode(response.body);
      errorMessage = jsonResponse['message']?.toString() ?? errorMessage;
    } catch (_) {}

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
      // Tất cả các lỗi khác (403, 409, 501, v.v.)
        return ServerFailure(errorMessage, response.statusCode);
    }
  }

  // Lấy danh sách thông báo
  Future<List<NotificationModel>> getNotifications(String token, String userId) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/api/v1/notifications/users/$userId");

    try {
      final response = await http.get(
        url,
        headers: {"Authorization": "Bearer $token"},
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true && jsonResponse['data'] is List) {
          final List<dynamic> dataList = jsonResponse['data'];
          // Map từng item trong list và parse
          return dataList.map((item) => NotificationModel.fromJson({'data': [item]})).toList();
        } else {
          throw InvalidInputFailure(jsonResponse['message'] ?? "Lỗi khi tải danh sách thông báo.");
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

  // Lấy số lượng thông báo chưa đọc
  Future<int> getUnreadCount(String token, String userId) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/api/v1/notifications/users/$userId/unread");

    try {
      final response = await http.get(
        url,
        headers: {"Authorization": "Bearer $token"},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          final data = jsonResponse['data'];
          if (data is int) return data;
          if (data is String) return int.tryParse(data) ?? 0;
          return 0;
        } else {
          return 0;
        }
      } else {
        // Chỉ ném lỗi Network hoặc Server (nếu không phải 200)
        throw _handleResponseError(response);
      }
    } on SocketException {
      throw const NetworkFailure();
    } on TimeoutException {
      throw const NetworkFailure();
    } on Failure {
      rethrow;
    } catch (_) {
      // Bắt các lỗi không xác định (như FormatException) và trả về 0
      return 0;
    }
  }

  // Đánh dấu thông báo đã đọc
  Future<void> markAsRead(String token, String notificationId) async {
    // Giả sử API PATCH /api/v1/notifications/{id} với body {readStatus: true}
    final url = Uri.parse("${ApiConfig.baseUrl}/api/v1/notifications/$notificationId");

    try {
      final response = await http.patch(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({'readStatus': true}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
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