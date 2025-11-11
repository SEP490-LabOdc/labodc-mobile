import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../../../../core/error/failures.dart';
import '../../../../core/config/networks/config.dart';
import '../models/notification_model.dart';

class NotificationRemoteDataSource {
  final http.Client client;
  NotificationRemoteDataSource({http.Client? client})
      : client = client ?? http.Client();

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
        return const ServerFailure("Lỗi máy chủ nội bộ.", 500);
      default:
        return ServerFailure(errorMessage, response.statusCode);
    }
  }

  /// Lấy danh sách thông báo người dùng
  Future<List<NotificationModel>> fetchNotifications(String userId,
      {String? authToken}) async {
    final url =
    Uri.parse("${ApiConfig.baseUrl}/api/v1/notifications/users/$userId");

    try {
      final response = await client
          .get(url, headers: {
        "Accept": "application/json",
        if (authToken != null) "Authorization": "Bearer $authToken",
      })
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final List<dynamic> dataList = jsonResponse['data'] ?? [];
        return dataList
            .map((e) => NotificationModel.fromJson(e))
            .toList();
      } else {
        throw _handleResponseError(response);
      }
    } on SocketException {
      throw const NetworkFailure();
    } on TimeoutException {
      throw const NetworkFailure();
    } catch (e) {
      throw UnknownFailure(e.toString());
    }
  }

  /// Gửi request đánh dấu đã đọc
  Future<void> markAsRead({
    required String userId,
    required String notificationRecipientId,
    String? authToken,
  }) async {
    final url = Uri.parse(
        "${ApiConfig.baseUrl}/api/v1/notifications/users/$userId/$notificationRecipientId/read");

    try {
      final response = await client
          .post(url, headers: {
        "Accept": "application/json",
        if (authToken != null) "Authorization": "Bearer $authToken",
      })
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw _handleResponseError(response);
      }
    } on SocketException {
      throw const NetworkFailure();
    } on TimeoutException {
      throw const NetworkFailure();
    } catch (e) {
      throw UnknownFailure(e.toString());
    }
  }


  Future<void> registerDeviceToken({
    required String token,
    required String userId,
    required String platform,
    String? authToken,
  }) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/api/v1/device-tokens/register");
    final body = jsonEncode({
      'userId': userId,
      'deviceToken': token,
      'platform': platform,
    });

    try {
      final headers = {
        "Content-Type": "application/json",
        "Accept": "application/json",
        if (authToken != null) "Authorization": "Bearer $authToken",
      };

      final response = await client
          .post(url, headers: headers, body: body)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200 && response.statusCode != 201) {
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
