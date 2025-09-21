import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:labodc_mobile/core/theme/bloc/theme_events.dart';
import 'package:labodc_mobile/core/theme/bloc/theme_state.dart';
import 'package:labodc_mobile/core/theme/domain/entity/theme_entity.dart';

import '../domain/usecase/get_theme_use_case.dart';
import '../domain/usecase/save_theme_use_case.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final GetThemeUseCase getThemeUseCase;
  final SaveThemeUseCase saveThemeUseCase;

  ThemeBloc({
    required this.getThemeUseCase,
    required this.saveThemeUseCase,
  }) : super(ThemeState.initial()) {
    on<GetThemeEvent>(_onGetThemeEvent);
    on<ToggleThemeEvent>(_onToggleThemeEvent);
  }

  /// Lấy theme hiện tại từ SharedPreferences (hoặc data source khác)
  Future<void> _onGetThemeEvent(
      GetThemeEvent event,
      Emitter<ThemeState> emit,
      ) async {
    emit(state.copyWith(status: ThemeStatus.loading));
    try {
      final result = await getThemeUseCase();
      emit(state.copyWith(
        status: ThemeStatus.success,
        themeEntity: result,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ThemeStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Toggle giữa Light <-> Dark theme
  Future<void> _onToggleThemeEvent(
      ToggleThemeEvent event,
      Emitter<ThemeState> emit,
      ) async {
    if (state.themeEntity == null) return;

    final newThemeType = state.themeEntity!.themeType == ThemeType.light
        ? ThemeType.dark
        : ThemeType.light;

    final newThemeEntity = ThemeEntity(themeType: newThemeType);

    try {
      await saveThemeUseCase(newThemeEntity);
      emit(state.copyWith(
        status: ThemeStatus.success,
        themeEntity: newThemeEntity,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ThemeStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
}
