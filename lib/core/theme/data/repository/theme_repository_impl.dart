import 'package:labodc_mobile/core/theme/data/datasource/theme_local_datasource.dart';
import 'package:labodc_mobile/core/theme/domain/entity/theme_entity.dart';

import '../../domain/repository/theme_repository.dart';

class ThemeRepositoryImpl implements ThemeRepository {
  final ThemeLocalDatasource themeLocalDatasource;

  ThemeRepositoryImpl({required this.themeLocalDatasource});


  @override
  Future<ThemeEntity> getTheme() {
    return themeLocalDatasource.getTheme();
  }

  @override
  Future saveTheme(ThemeEntity theme) {
    return themeLocalDatasource.saveTheme(theme);
  }}