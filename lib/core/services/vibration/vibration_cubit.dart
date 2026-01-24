// lib/core/services/vibration/vibration_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'vibration_model.dart';
import 'vibration_prefs.dart';
import 'vibration_service.dart';

class VibrationState {
  final bool enabled;
  final VibrationType type;

  const VibrationState({required this.enabled, required this.type});

  VibrationState copyWith({bool? enabled, VibrationType? type}) =>
      VibrationState(enabled: enabled ?? this.enabled, type: type ?? this.type);
}

class VibrationCubit extends Cubit<VibrationState> {
  final VibrationPrefs _prefs;

  VibrationCubit(this._prefs)
    : super(const VibrationState(enabled: true, type: VibrationType.pattern));

  /// load setting lúc khởi động
  Future<void> load() async {
    final e = await _prefs.getEnabled();
    final t = await _prefs.getType();
    emit(VibrationState(enabled: e, type: t));
  }

  Future<void> setEnabled(bool v) async {
    await _prefs.setEnabled(v);
    emit(state.copyWith(enabled: v));
  }

  Future<void> setType(VibrationType t) async {
    await _prefs.setType(t);
    emit(state.copyWith(type: t));
  }

  /// Rung theo setting người dùng
  Future<void> vibrateIfEnabled() async {
    if (!state.enabled) return;
    await VibrationService.vibrate(state.type);
  }
}
