// lib/core/services/vibration/vibration_prefs.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'vibration_model.dart';

class VibrationPrefs {
  static const _kEnabledKey = 'vibration_enabled';
  static const _kTypeKey = 'vibration_type';

  static Future<bool> getEnabled() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getBool(_kEnabledKey) ?? true; // default: bật rung
  }

  static Future<void> setEnabled(bool value) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_kEnabledKey, value);
  }

  static Future<VibrationType> getType() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_kTypeKey);
    return VibrationType.values.firstWhere(
          (e) => e.name == raw,
      orElse: () => VibrationType.pattern, // default: rung theo nhịp
    );
  }

  static Future<void> setType(VibrationType type) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kTypeKey, type.name);
  }
}
