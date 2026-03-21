import 'package:dio/dio.dart';
import '../models/content_model.dart';

class ApiService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: "https://betsy-parchable-nonextricably.ngrok-free.dev/api",
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );

  Future<List<ContentModel>> _fetchList(String path,
      {int? limit}) async {
    final res = await _dio.get(path, queryParameters: {
      if (limit != null) "limit": limit,
    });

    return (res.data as List)
        .map((e) => ContentModel.fromJson(e))
        .toList();
  }

  // Announcements
  Future<List<ContentModel>> fetchAnnouncements({int? limit}) =>
      _fetchList("/content/announcements", limit: limit);

  // Events
  Future<List<ContentModel>> fetchEvents() =>
      _fetchList("/content/events");

  // Research Blogs
  Future<List<ContentModel>> fetchResearchBlogs() =>
      _fetchList("/content/research");

  // Newsletters
  Future<List<ContentModel>> fetchNewsletters() =>
      _fetchList("/content/newsletters");

  // Internships
  Future<List<ContentModel>> fetchInternships() =>
      _fetchList("/content/internships");
}
