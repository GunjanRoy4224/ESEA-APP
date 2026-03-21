import 'package:dio/dio.dart';
import '../models/content_model.dart';
import '../constants/api_constants.dart';
import 'dio_client.dart';

class ContentService {
  final Dio _dio = DioClient().dio;

  Future<List<ContentModel>> fetchByType(String type) async {
    final response = await _dio.get(
      ApiConstants.contentByType(type),
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
}
