import 'dart:convert';
import '../models/user.dart';
import 'api_client.dart';

class StudentService {
  /// ✅ Get full user (single source of truth)
  static Future<User?> getCurrentUser() async {
    try {
      final res = await ApiClient.get("/auth/me");

      final data = jsonDecode(res.body);
      return User.fromJson(data);
    } catch (e) {
      print("ERROR fetching user: $e");
      return null;
    }
  }
}