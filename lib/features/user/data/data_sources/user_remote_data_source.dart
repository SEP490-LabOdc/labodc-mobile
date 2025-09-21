import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class UserRemoteDataSource {
  final String baseUrl = "https://your-api.com/api";

  Future<UserModel> getUserProfile(String token) async {
    final url = Uri.parse("$baseUrl/user/profile");
    final response = await http.get(url, headers: {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    });

    if (response.statusCode == 200) {
      return UserModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Failed to load profile: ${response.body}");
    }
  }
}
