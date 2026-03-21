import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';

class StorageService {
  final FlutterSecureStorage _storage =
      const FlutterSecureStorage();

  static const _tokenKey = "jwt_token";
  static const _userKey = "user_profile";

  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<void> saveUser(User user) async {
    await _storage.write(
      key: _userKey,
      value: jsonEncode(user.toJson()),
    );
  }

  Future<User?> getUser() async {
    final data = await _storage.read(key: _userKey);
    if (data == null) return null;
    return User.fromJson(jsonDecode(data));
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
