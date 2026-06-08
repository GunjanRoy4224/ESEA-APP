import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/search_result.dart';

class SearchService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: const String.fromEnvironment('API_URL', defaultValue: 'http://10.0.2.2:8000/api'),
  ));
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<String?> _getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  Future<List<SearchResult>> globalSearch({
    required String query,
    String? type,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final token = await _getToken();
      final response = await _dio.get(
        '/search/',
        queryParameters: {
          'q': query,
          if (type != null) 'type': type,
          'limit': limit,
          'offset': offset,
        },
        options: Options(
          headers: {
            if (token != null) 'Authorization': 'Bearer $token',
          },
        ),
      );

      final List data = response.data['results'];
      return data.map((json) => SearchResult.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load search results: $e');
    }
  }
}
