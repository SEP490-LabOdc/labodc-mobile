import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/config/networks/config.dart';
import '../models/auth_model.dart';

class AuthRemoteDataSource {
  Future<AuthModel> login(String username, String password) async {
    final url = ApiConfig.endpoint("/auth/login");
    final response = await http.post(
      url,
      headers: ApiConfig.defaultHeaders,
      body: jsonEncode({"username": username, "password": password}),
    );

    if (response.statusCode == 200) {
      return AuthModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Login failed: ${response.body}");
    }
  }
}
