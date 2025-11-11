import 'env.dart';

class ApiConfig {
  static String get baseUrl => Env.baseUrl;

  static String get websocketUrl => Env.webSocketUrl;

  static Map<String, String> get defaultHeaders => {
    "Content-Type": "application/json",
  };

  static Uri endpoint(String path) {
    final base = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    final p = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$base$p');
  }
}