import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../../../core/error/failures.dart';
import '../../../../../core/config/networks/config.dart';
import '../models/transaction_model.dart';
import '../models/wallet_model.dart';
import '../models/withdraw_request.dart';

class TransactionRemoteDataSource {

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
        return ServerFailure(errorMessage, response.statusCode);
    }
  }

  Future<List<TransactionModel>> getMyTransactions(String token, {int page = 0, int size = 20}) async {
    // Sử dụng endpoint từ ApiConfig
    final url = Uri.parse("${ApiConfig.baseUrl}/api/v1/transactions/my-transactions")
        .replace(queryParameters: {
      "page": page.toString(),
      "size": size.toString(),
      "sortBy": "createdAt",
      "sortDir": "DESC",
    });

    try {
      // Log URL để kiểm tra query parameters
      debugPrint('🚀 Request URL: $url');

      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      ).timeout(const Duration(seconds: 15));

      // In toàn bộ Body phản hồi để kiểm tra cấu trúc JSON thực tế
      debugPrint('📥 Response Status: ${response.statusCode}');
      debugPrint('📥 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          final List<dynamic> content = jsonResponse['data']['content'];
          return TransactionModel.fromJsonList(content);
        } else {
          throw InvalidInputFailure(jsonResponse['message'] ?? "Lỗi khi tải lịch sử giao dịch.");
        }
      } else {
        throw _handleResponseError(response);
      }
    } on SocketException catch (e) {
      debugPrint('❌ Network Error (SocketException): $e');
      throw const NetworkFailure();
    } on TimeoutException catch (e) {
      debugPrint('❌ Timeout Error: $e');
      throw const NetworkFailure();
    } on Failure {
      rethrow;
    } catch (e) {
      debugPrint('❌ Unknown Error in TransactionRemoteDataSource: $e');
      throw UnknownFailure(e.toString());
    }
  }

  Future<WalletModel> getMyWallet(String token) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/api/v1/wallets/me");
    try {
      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      ).timeout(const Duration(seconds: 15));

      debugPrint('📥 Wallet Response: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true) {
          return WalletModel.fromJson(jsonResponse['data']);
        } else {
          throw InvalidInputFailure(jsonResponse['message'] ?? "Lỗi lấy thông tin ví");
        }
      } else {
        throw _handleResponseError(response);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> withdraw(String token, WithdrawRequest request) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/api/v1/wallets/withdraw");

    try {
      final response = await http.post(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode(request.toJson()),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse['success'] == true;
      } else {
        throw _handleResponseError(response);
      }
    } catch (e) {
      rethrow;
    }
  }
}