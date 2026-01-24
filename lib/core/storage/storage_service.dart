import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Type-safe storage service wrapper for SharedPreferences
///
/// Features:
/// - Automatic JSON serialization/deserialization
/// - Type-safe operations
/// - Support for complex objects via JSON
/// - Consistent API across all data types
class StorageService {
  final SharedPreferences _prefs;

  StorageService(this._prefs);

  // ==================== Simple Types ====================

  /// Save a string value
  Future<bool> saveString(String key, String value) async {
    return await _prefs.setString(key, value);
  }

  /// Load a string value
  String? loadString(String key) {
    return _prefs.getString(key);
  }

  /// Save an int value
  Future<bool> saveInt(String key, int value) async {
    return await _prefs.setInt(key, value);
  }

  /// Load an int value
  int? loadInt(String key) {
    return _prefs.getInt(key);
  }

  /// Save a bool value
  Future<bool> saveBool(String key, bool value) async {
    return await _prefs.setBool(key, value);
  }

  /// Load a bool value
  bool? loadBool(String key) {
    return _prefs.getBool(key);
  }

  /// Save a double value
  Future<bool> saveDouble(String key, double value) async {
    return await _prefs.setDouble(key, value);
  }

  /// Load a double value
  double? loadDouble(String key) {
    return _prefs.getDouble(key);
  }

  // ==================== Complex Types (JSON) ====================

  /// Save an object as JSON
  /// The object must be JSON-serializable (have toJson method or be a Map)
  Future<bool> saveJson<T>(String key, T object) async {
    try {
      final String jsonString;

      if (object is Map || object is List) {
        jsonString = jsonEncode(object);
      } else if (object is JsonSerializable) {
        jsonString = jsonEncode((object as JsonSerializable).toJson());
      } else {
        // Try to encode directly, will throw if not serializable
        jsonString = jsonEncode(object);
      }

      return await _prefs.setString(key, jsonString);
    } catch (e) {
      throw StorageException('Failed to save JSON for key "$key": $e');
    }
  }

  /// Load an object from JSON
  /// You must provide a fromJson factory function
  T? loadJson<T>(String key, T Function(Map<String, dynamic>) fromJson) {
    try {
      final jsonString = _prefs.getString(key);
      if (jsonString == null) return null;

      final decoded = jsonDecode(jsonString);
      if (decoded is! Map<String, dynamic>) {
        throw StorageException('Expected Map but got ${decoded.runtimeType}');
      }

      return fromJson(decoded);
    } catch (e) {
      throw StorageException('Failed to load JSON for key "$key": $e');
    }
  }

  /// Load a list of objects from JSON
  List<T>? loadJsonList<T>(
    String key,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    try {
      final jsonString = _prefs.getString(key);
      if (jsonString == null) return null;

      final decoded = jsonDecode(jsonString);
      if (decoded is! List) {
        throw StorageException('Expected List but got ${decoded.runtimeType}');
      }

      return decoded
          .map((item) => fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw StorageException('Failed to load JSON list for key "$key": $e');
    }
  }

  // ==================== Utility Methods ====================

  /// Check if a key exists
  bool contains(String key) {
    return _prefs.containsKey(key);
  }

  /// Remove a specific key
  Future<bool> remove(String key) async {
    return await _prefs.remove(key);
  }

  /// Clear all stored data
  Future<bool> clear() async {
    return await _prefs.clear();
  }

  /// Get all keys
  Set<String> getAllKeys() {
    return _prefs.getKeys();
  }

  /// Reload data from disk (useful after background changes)
  Future<void> reload() async {
    await _prefs.reload();
  }
}

/// Interface for JSON-serializable objects
abstract class JsonSerializable {
  Map<String, dynamic> toJson();
}

/// Custom exception for storage errors
class StorageException implements Exception {
  final String message;
  StorageException(this.message);

  @override
  String toString() => 'StorageException: $message';
}
