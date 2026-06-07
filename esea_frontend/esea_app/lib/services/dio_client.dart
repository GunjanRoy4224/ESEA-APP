import 'package:dio/dio.dart';
import '../config/app_config.dart';
import 'storage_service.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();

  factory DioClient() {
    return _instance;
  }

  String? _cachedToken;

  void setToken(String token) {
    _cachedToken = token;
  }

  void clearToken() {
    _cachedToken = null;
  }

  final Dio dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.baseUrl,
      followRedirects: false,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );

  DioClient._internal() {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (_cachedToken == null) {
            _cachedToken = await StorageService().getToken();
          }
          if (_cachedToken != null) {
            options.headers['Authorization'] = 'Bearer $_cachedToken';
          }
          handler.next(options);
        },
      ),
    );
    print("DIO BASE URL = ${dio.options.baseUrl}");
  }

  Future<Response> get(String path, {Map<String, dynamic>? params}) {
    return dio.get(path, queryParameters: params);
  }

  Future<Response> post(String path, {dynamic data}) {
    return dio.post(path, data: data);
  }

  Future<Response> put(String path, {dynamic data}) {
    return dio.put(path, data: data);
  }

  Future<Response> delete(String path) {
    return dio.delete(path);
  }
}
