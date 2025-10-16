// lib/core/services/vibration/vibration_service.dart
import 'package:flutter/foundation.dart';
import 'package:vibration/vibration.dart';
import 'vibration_model.dart';

class VibrationService {
  /// Rung với kiểu cụ thể (manual)
  static Future<void> vibrate(VibrationType type) async {
    if (!(await Vibration.hasVibrator() ?? false)) {
      debugPrint('⚠️ Thiết bị không hỗ trợ rung');
      return;
    }

    switch (type) {
      case VibrationType.none:
        return;
      case VibrationType.light:
        await Vibration.vibrate(duration: 100);
        break;
      case VibrationType.medium:
        await Vibration.vibrate(duration: 300);
        break;
      case VibrationType.strong:
        await Vibration.vibrate(duration: 600);
        break;
      case VibrationType.pattern:
        await Vibration.vibrate(pattern: [0, 200, 100, 300, 100, 400]);
        break;
      case VibrationType.success:
        await Vibration.vibrate(duration: 100); // Rung nhẹ (light)
        break;
      case VibrationType.error:
        await Vibration.vibrate(pattern: [0, 50, 100, 50], repeat: -1); // Rung pattern ngắn 2 lần
        await Future.delayed(const Duration(milliseconds: 300)); // Chờ rung hoàn tất
        Vibration.cancel();
        break;
    }
  }
}