import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../../../core/config/networks/config.dart';
import '../../../../core/error/exceptions.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../models/user_profile_model.dart';

abstract class UserProfileRemoteDataSource {
  Future<UserProfileModel> getUserProfile(String userId);

  // 👇 thêm profile vào tham số
  Future<UserProfileModel> updateUserProfile(
      String userId,
      UserProfileModel profile,
      );
}

class UserProfileRemoteDataSourceImpl implements UserProfileRemoteDataSource {
  final http.Client client;
  final AuthRepository authRepository;

  UserProfileRemoteDataSourceImpl({
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

  @override
  Future<UserProfileModel> getUserProfile(String userId) async {
    final uri = ApiConfig.endpoint('api/v1/users/$userId');

    try {
      final response = await client.get(uri, headers: await _getHeaders());
      final body = utf8.decode(response.bodyBytes);

      if (kDebugMode) {
        debugPrint(
            '[UserProfileRemoteDataSource] GET $uri -> ${response.statusCode} - $body');
      }

      final decoded = json.decode(body) as Map<String, dynamic>;

      final success = decoded['success'] == true;
      if (response.statusCode == 200 && success) {
        final data = decoded['data'] as Map<String, dynamic>;
        return UserProfileModel.fromJson(data);
      } else {
        final msg = decoded['message']?.toString() ??
            'Lấy thông tin user thất bại';
        throw ServerException(msg, statusCode: response.statusCode);
      }
    } on SocketException {
      throw NetworkException();
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Lỗi không xác định khi lấy thông tin user: $e');
    }
  }

  @override
  Future<UserProfileModel> updateUserProfile(
      String userId,
      UserProfileModel profile,
      ) async {
    final uri = ApiConfig.endpoint('api/v1/users/$userId/profile');

    final bodyMap = {
      "fullName": profile.fullName,
      "phone": profile.phone,
      "gender": profile.gender,
      "birthDate": profile.birthDate != null
          ? DateFormat('yyyy-MM-dd').format(profile.birthDate!)
          : null,
      "address": profile.address,
      "avatarUrl": profile.avatarUrl,
    }..removeWhere((key, value) => value == null);

    try {
      final response = await client.put(
        uri,
        headers: await _getHeaders(),
        body: jsonEncode(bodyMap),
      );
      final body = utf8.decode(response.bodyBytes);

      if (kDebugMode) {
        debugPrint(
            '[UserProfileRemoteDataSource] POST $uri -> ${response.statusCode} - $body');
      }

      final decoded = json.decode(body) as Map<String, dynamic>;
      final success = decoded['success'] == true;

      if (response.statusCode == 200 && success) {
        final data = decoded['data'] as Map<String, dynamic>;
        return UserProfileModel.fromJson(data);
      } else {
        final msg = decoded['message']?.toString() ??
            'Cập nhật hồ sơ thất bại';
        throw ServerException(msg, statusCode: response.statusCode);
      }
    } on SocketException {
      throw NetworkException();
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException('Lỗi không xác định khi cập nhật hồ sơ: $e');
    }
  }
}
