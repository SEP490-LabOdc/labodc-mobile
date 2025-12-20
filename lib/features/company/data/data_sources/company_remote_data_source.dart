// lib/features/company/data/data_sources/company_remote_data_source.dart

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../../core/config/networks/config.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../shared/models/search_request_model.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../models/company_model.dart';
import '../models/company_project_model.dart';
import '../models/paginated_company_model.dart';

abstract class CompanyRemoteDataSource {
  Future<List<CompanyModel>> getActiveCompanies();
  Future<CompanyModel> getCompanyDetail(String companyId);
  Future<PaginatedCompanyModel> searchCompanies(SearchRequest request);
  Future<List<CompanyProjectModel>> getProjectsByCompany(String companyId);}

class CompanyRemoteDataSourceImpl implements CompanyRemoteDataSource {
  final http.Client client;
  final AuthRepository authRepository;

  CompanyRemoteDataSourceImpl(this.client, this.authRepository);

  @override
  Future<List<CompanyModel>> getActiveCompanies() async {
    final uri = ApiConfig.endpoint('api/v1/companies');
    final token = await authRepository.getSavedToken();

    final headers = {
      ...ApiConfig.defaultHeaders,
      if (token != null) 'Authorization': 'Bearer $token',
    };

    try {
      final response = await client.get(uri, headers: headers);
      final decoded = json.decode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200) {
        if (decoded['success'] == true) {
          final responseList = CompanyListResponse.fromJson(decoded);

          // Lọc công ty có status là ACTIVE để hiển thị trên trang Explore
          return responseList.companies.where((c) => c.status == 'ACTIVE').toList();
        }
        throw ServerException(
          decoded['message'] ?? 'Unknown business error',
          statusCode: 422,
        );
      }

      throw ServerException(
        decoded['message'] ?? 'Server error',
        statusCode: response.statusCode,
      );
    } on SocketException {
      throw NetworkException();
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      debugPrint(" [Companies] Unexpected Error: $e");
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<CompanyModel> getCompanyDetail(String companyId) async {
    final uri = ApiConfig.endpoint('api/v1/companies/$companyId');
    final token = await authRepository.getSavedToken();

    final headers = {
      ...ApiConfig.defaultHeaders,
      if (token != null) 'Authorization': 'Bearer $token',
    };

    try {
      final response = await client.get(uri, headers: headers);
      final decoded = json.decode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200) {
        if (decoded['success'] == true && decoded['data'] != null) {
          // Model sử dụng data object bên trong response
          return CompanyModel.fromJson(decoded['data'] as Map<String, dynamic>);
        }
        throw ServerException(
          decoded['message'] ?? 'Dữ liệu công ty không hợp lệ',
          statusCode: 422,
        );
      }

      throw ServerException(
        decoded['message'] ?? 'Server error',
        statusCode: response.statusCode,
      );
    } on SocketException {
      throw NetworkException();
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      debugPrint(" [CompanyDetail] Unexpected Error: $e");
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<PaginatedCompanyModel> searchCompanies(SearchRequest request) async {
    final uri = ApiConfig.endpoint('api/v1/companies/search');

    final token = await authRepository.getSavedToken();

    debugPrint(" [SearchCompanies] URI: $uri");
    debugPrint(" [SearchCompanies] Request: ${request.toJson()}");

    final headers = {
      ...ApiConfig.defaultHeaders,
      if (token != null) 'Authorization': 'Bearer $token',
    };

    try {
      final response = await client.post(
        uri,
        headers: headers,
        body: json.encode(request.toJson()),
      );

      final decoded = json.decode(utf8.decode(response.bodyBytes));

      debugPrint("📩 [SearchCompanies] Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        if (decoded['success'] == true) {
          return PaginatedCompanyModel.fromJson(decoded);
        }
        throw ServerException(
          decoded['message'] ?? 'Unknown error',
          statusCode: 422,
        );
      }

      throw ServerException(
        decoded['message'] ?? 'Server error',
        statusCode: response.statusCode,
      );
    } on SocketException {
      throw NetworkException();
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      debugPrint("💥 [SearchCompanies] Unexpected Error: $e");
      throw ServerException('Unexpected error: $e');
    }
  }
  @override
  Future<List<CompanyProjectModel>> getProjectsByCompany(String companyId) async {
    final uri = ApiConfig.endpoint('api/v1/projects/companies/$companyId');

    final token = await authRepository.getSavedToken();

    debugPrint(" [SearchCompanies] URI: $uri");

    final headers = {
      ...ApiConfig.defaultHeaders,
      if (token != null) 'Authorization': 'Bearer $token',
    };

    try {
      final response = await client.get(
        uri,
        headers: headers,
      );

      final decoded = json.decode(utf8.decode(response.bodyBytes));

      debugPrint("📩 [GetProjectsByCompany] Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        if (decoded['success'] == true) {
          return (decoded['data']['projectResponses'] as List)
              .map((p) => CompanyProjectModel.fromJson(p))
              .toList();
        }
        throw ServerException(
          decoded['message'] ?? 'Unknown error',
          statusCode: 422,
        );
      }

      throw ServerException(
        decoded['message'] ?? 'Server error',
        statusCode: response.statusCode,
      );
    } on SocketException {
      throw NetworkException();
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      debugPrint("💥 [GetProjectsByCompany] Unexpected Error: $e");
      throw ServerException('Unexpected error: $e');
    }
  }
}