import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
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
      // Cố gắng đọc message từ body lỗi nếu có
      final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
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

  Future<List<NotificationModel>> fetchNotifications(String userId,
      {String? authToken}) async {
    final url =
    Uri.parse("${ApiConfig.baseUrl}/api/v1/notifications/users/$userId");
    return _fetchList(url, authToken);
  }

  Future<List<NotificationModel>> fetchUnreadNotifications(String userId,
      {String? authToken}) async {
    final url = Uri.parse(
        "${ApiConfig.baseUrl}/api/v1/notifications/users/$userId/unread");
    return _fetchList(url, authToken);
  }

  Future<List<NotificationModel>> _fetchList(Uri url, String? authToken) async {
    try {
      final response = await client.get(
        url,
        headers: {
          "Accept": "application/json",
          if (authToken != null) "Authorization": "Bearer $authToken",
        },
      ).timeout(const Duration(seconds: 15));

      // [DEBUG FIX] In ra body raw để kiểm tra cấu trúc JSON
      debugPrint('📥 API Response [${response.statusCode}]: ${utf8.decode(response.bodyBytes)}');

      if (response.statusCode == 200) {
        final bodyStr = utf8.decode(response.bodyBytes);
        final jsonResponse = jsonDecode(bodyStr);

        List<dynamic> dataList = [];

        // [LOGIC FIX] Xử lý an toàn: API có thể trả về { "data": [...] } hoặc trực tiếp [...]
        if (jsonResponse is Map<String, dynamic> && jsonResponse.containsKey('data')) {
          dataList = jsonResponse['data'] ?? [];
        } else if (jsonResponse is List) {
          dataList = jsonResponse;
        }

        return dataList.map((e) => NotificationModel.fromJson(e)).toList();
      } else {
        throw _handleResponseError(response);
      }
    } on SocketException {
      throw const NetworkFailure();
    } on TimeoutException {
      throw const NetworkFailure();
    } catch (e) {
      debugPrint("❌ Exception in _fetchList: $e");
      throw UnknownFailure(e.toString());
    }
  }

  Future<void> markAsRead({
    required String userId,
    required String notificationRecipientId,
    String? authToken,
  }) async {
    final url = Uri.parse(
        "${ApiConfig.baseUrl}/api/v1/notifications/users/$userId/$notificationRecipientId/read");
    try {
      final response = await client.post(
        url,
        headers: {
          "Accept": "application/json",
          if (authToken != null) "Authorization": "Bearer $authToken",
        },
      ).timeout(const Duration(seconds: 10));

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

      final response =
      await client.post(url, headers: headers, body: body).timeout(
        const Duration(seconds: 10),
      );

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