import 'package:flutter/material.dart';

import '../entity/theme_entity.dart';
import '../repository/theme_repository.dart';

class GetThemeUseCase {
  final ThemeRepository themeRepository;

  GetThemeUseCase({required this.themeRepository});

 Future<ThemeEntity> call() async {
    return await themeRepository.getTheme();
  }
}