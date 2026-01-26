import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/vietqr_bank_model.dart';

class BankCacheService {
  static const String _cacheKey = 'cached_banks';
  static const String _cacheTimeKey = 'cached_banks_time';
  static const Duration _cacheDuration = Duration(hours: 24);

  final SharedPreferences prefs;

  BankCacheService(this.prefs);

  /// Save banks to cache
  Future<void> saveBanks(List<VietQRBank> banks) async {
    final jsonList = banks.map((b) => b.toJson()).toList();
    final jsonString = json.encode(jsonList);

    await prefs.setString(_cacheKey, jsonString);
    await prefs.setInt(_cacheTimeKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// Get cached banks
  List<VietQRBank>? getCachedBanks() {
    try {
      final jsonString = prefs.getString(_cacheKey);
      if (jsonString == null) return null;

      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList
          .map((json) => VietQRBank.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return null;
    }
  }

  /// Check if cache is still valid
  bool isCacheValid() {
    final cacheTime = prefs.getInt(_cacheTimeKey);
    if (cacheTime == null) return false;

    final cacheDate = DateTime.fromMillisecondsSinceEpoch(cacheTime);
    final now = DateTime.now();

    return now.difference(cacheDate) < _cacheDuration;
  }

  /// Clear cache
  Future<void> clearCache() async {
    await prefs.remove(_cacheKey);
    await prefs.remove(_cacheTimeKey);
  }
}
