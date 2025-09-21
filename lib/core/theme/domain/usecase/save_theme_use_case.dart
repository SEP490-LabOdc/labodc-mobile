import '../entity/theme_entity.dart';
import '../repository/theme_repository.dart';

class SaveThemeUseCase {
  final ThemeRepository themeRepository;

  SaveThemeUseCase({required this.themeRepository});

  Future<void> call(ThemeEntity theme) {
    return themeRepository.saveTheme(theme);
  }
}