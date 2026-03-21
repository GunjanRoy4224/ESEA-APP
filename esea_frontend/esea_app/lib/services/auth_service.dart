import 'package:dio/dio.dart';

import '../models/user.dart';
import '../constants/api_constants.dart';
import 'dio_client.dart';
import 'storage_service.dart';

class AuthService {
  final Dio _dio = DioClient().dio;
  final StorageService _storage = StorageService();

  /// ================================
  /// STEP 1: Get SSO redirect URL
  /// ================================
  Future<String?> getSSOLoginUrl() async {
    final res = await _dio.get(ApiConstants.ssoLogin);
    return res.data['url'];
  }

  /// ================================
  /// STEP 2: Fetch current user
  /// ================================
  Future<User?> fetchCurrentUser() async {
    final token = await _storage.getToken();
    if (token == null) return null;

    try {
      final res = await _dio.get(
        ApiConstants.me,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      final user = User.fromJson(res.data);

      // ✅ ALWAYS SAVE LATEST USER
      await _storage.saveUser(user);

      return user;
    } on DioException catch (e) {
      print("❌ FETCH USER ERROR: ${e.response?.data}");

      // ✅ If token invalid → logout
      if (e.response?.statusCode == 401) {
        await _storage.clearAll();
        return null;
      }

      // ✅ fallback to cached user
      return await _storage.getUser();
    } catch (e) {
      print("❌ UNKNOWN ERROR: $e");
      return await _storage.getUser();
    }
  }

  /// ================================
  /// LOGIN WITH TOKEN (🔥 IMPORTANT FIX)
  /// ================================
  Future<User?> loginWithToken(String token) async {
    try {
      // ✅ Save token first
      await _storage.saveToken(token);

      // ✅ Immediately fetch user
      final user = await fetchCurrentUser();

      return user;
    } catch (e) {
      print("❌ LOGIN TOKEN ERROR: $e");
      return null;
    }
  }

  /// ================================
  /// GET SAVED TOKEN
  /// ================================
  Future<String?> getSavedToken() async {
    return await _storage.getToken();
  }

  /// ================================
  /// LOGOUT
  /// ================================
  Future<void> logout() async {
    await _storage.clearAll();
  }
}