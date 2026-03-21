import 'package:dio/dio.dart';
import '../config/app_config.dart';
import 'storage_service.dart';

class DioClient {
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.baseUrl,
      followRedirects: false,));

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


  DioClient() {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await StorageService().getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
    print("DIO BASE URL = ${dio.options.baseUrl}");

  }
  
}
