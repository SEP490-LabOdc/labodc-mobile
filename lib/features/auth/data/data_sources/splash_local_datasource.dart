import 'package:shared_preferences/shared_preferences.dart';

class SplashLocalDatasource {
  final SharedPreferences sharedPreferences;

  SplashLocalDatasource({required this.sharedPreferences});

  Future<bool> isSplashShown() async {
    return sharedPreferences.getBool('splash_shown') ?? false;
  }

  Future<void> setSplashShown() async {
    await sharedPreferences.setBool('splash_shown', true);
  }
}

