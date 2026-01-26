import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/vietqr_bank_model.dart';

class BankApiService {
  static const String _baseUrl = 'https://api.vietqr.io/v2';
  final http.Client client;

  BankApiService({http.Client? client}) : client = client ?? http.Client();

  /// Fetch all banks from VietQR API
  Future<List<VietQRBank>> fetchBanks() async {
    try {
      final uri = Uri.parse('$_baseUrl/banks');

      if (kDebugMode) {
        debugPrint('[BankAPI] Fetching banks from VietQR...');
      }

      final response = await client.get(uri);

      if (response.statusCode != 200) {
        throw Exception('Failed to load banks: ${response.statusCode}');
      }

      final body = utf8.decode(response.bodyBytes);
      final decoded = json.decode(body) as Map<String, dynamic>;

      if (decoded['code'] != '00') {
        throw Exception('API Error: ${decoded['desc']}');
      }

      final List<dynamic> data = decoded['data'] ?? [];

      final banks = data
          .map((json) => VietQRBank.fromJson(json as Map<String, dynamic>))
          .toList();

      if (kDebugMode) {
        debugPrint('[BankAPI] Loaded ${banks.length} banks successfully');
      }

      return banks;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[BankAPI] Error fetching banks: $e');
      }
      rethrow;
    }
  }

  /// Fetch banks and filter only those that support transfer
  Future<List<VietQRBank>> fetchTransferSupportedBanks() async {
    final banks = await fetchBanks();
    return banks.where((bank) => bank.supportsTransfer).toList();
  }

  void dispose() {
    client.close();
  }
}
