// lib/core/services/vibration/vibration_prefs.dart
import '../../../core/storage/storage_service.dart';
import 'vibration_model.dart';

class VibrationPrefs {
  static const _kEnabledKey = 'vibration_enabled';
  static const _kTypeKey = 'vibration_type';

  final StorageService _storage;

  VibrationPrefs(this._storage);

  Future<bool> getEnabled() async {
    return _storage.loadBool(_kEnabledKey) ?? true; // default: bật rung
  }

  Future<void> setEnabled(bool value) async {
    await _storage.saveBool(_kEnabledKey, value);
  }

  Future<VibrationType> getType() async {
    final raw = _storage.loadString(_kTypeKey);
    if (raw == null) return VibrationType.pattern; // default

    return VibrationType.values.firstWhere(
      (e) => e.name == raw,
      orElse: () => VibrationType.pattern,
    );
  }

  Future<void> setType(VibrationType type) async {
    await _storage.saveString(_kTypeKey, type.name);
  }
}
