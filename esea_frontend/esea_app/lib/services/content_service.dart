import 'package:dio/dio.dart';
import '../models/content_model.dart';
import '../constants/api_constants.dart';
import 'dio_client.dart';

class ContentService {
  final Dio _dio = DioClient().dio;

  Future<List<ContentModel>> fetchByType(String type, {int limit = 20, int offset = 0}) async {
    final response = await _dio.get(
      ApiConstants.contentByType(type),
      queryParameters: {
        'limit': limit,
        'offset': offset,
      },
    );

    final List list = response.data;
    return list.map((e) => ContentModel.fromJson(e)).toList();
  }

  Future<List<ContentModel>> fetchLatestAnnouncements() async {
    final response = await _dio.get(
      ApiConstants.contentByType("announcements"),
    );

    final List list = response.data;
    return list
        .take(3)
        .map((e) => ContentModel.fromJson(e))
        .toList();
  }

  Future<ContentModel> fetchContentById(String id) async {
    final response = await _dio.get('/content/$id');
    return ContentModel.fromJson(response.data);
  }
}
