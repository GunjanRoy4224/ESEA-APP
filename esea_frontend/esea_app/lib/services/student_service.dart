import '../models/user.dart';
import 'dio_client.dart';

class StudentService {
  /// ✅ Get full user (single source of truth)
  static Future<User?> getCurrentUser() async {
    try {
      final res = await DioClient().get("/auth/me");

      return User.fromJson(res.data);
    } catch (e) {
      print("ERROR fetching user: $e");
      return null;
    }
  }
}