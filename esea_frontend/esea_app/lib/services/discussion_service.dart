// ==========================================================
// DISCUSSION SERVICE (FINAL FIXED + OPTIMIZED)
// - Safe parsing
// - Better FormData usage
// - Improved error handling
// ==========================================================

import 'dart:io';
import 'package:dio/dio.dart';
import '../services/dio_client.dart';
import '../models/discussion_model.dart';

class DiscussionService {
  final DioClient _client = DioClient();

  // ==========================================================
  // FETCH DISCUSSIONS (Pagination + Sort)
  // ==========================================================
  Future<List<DiscussionModel>> fetchDiscussions({
    int page = 1,
    String sort = "new",
  }) async {
    try {
      final res = await _client.get(
        "/discussions",
        params: {
          "page": page,
          "limit": 20,
          "sort": sort,
        },
      );

      // ✅ SAFE PARSING
      final data = res.data;

      if (data is List) {
        return data
            .map((e) => DiscussionModel.fromJson(e))
            .toList();
      }

      if (data is Map && data["data"] is List) {
        return (data["data"] as List)
            .map((e) => DiscussionModel.fromJson(e))
            .toList();
      }

      return [];

    } on DioException catch (e) {
      print("FETCH DISCUSSIONS ERROR: ${e.response?.data}");
      rethrow;
    }
  }

  // ==========================================================
  // FETCH SINGLE DISCUSSION BY ID
  // ==========================================================
  Future<DiscussionModel> fetchDiscussionById(int id) async {
    try {
      final res = await _client.get("/discussions/$id");
      return DiscussionModel.fromJson(res.data);
    } on DioException catch (e) {
      print("FETCH SINGLE DISCUSSION ERROR: ${e.response?.data}");
      rethrow;
    }
  }

  // ==========================================================
  // CREATE DISCUSSION (Image + Advanced Poll)
  // ==========================================================
  Future<void> createDiscussion(
    String title,
    String content, {
    File? imageFile,
    List<String>? pollOptions,
    bool anonymous = false,
    bool multiple = false,
    bool quizMode = false,
    List<int>? correctIndexes,
  }) async {
    try {
      final Map<String, dynamic> data = {
        "title": title,
        "content": content,
        "category": "general",
      };

      // ================= POLL =================
      if (pollOptions != null && pollOptions.isNotEmpty) {
        data["poll_options"] = pollOptions;
        data["anonymous"] = anonymous.toString();
        data["multiple"] = multiple.toString();
        data["quiz_mode"] = quizMode.toString();

        if (quizMode && correctIndexes != null) {
          data["correct_indexes"] =
              correctIndexes.map((e) => e.toString()).toList();
        }
      }

      final formData = FormData.fromMap(data);

      // ================= IMAGE =================
      if (imageFile != null) {
        formData.files.add(
          MapEntry(
            "image",
            await MultipartFile.fromFile(
              imageFile.path,
              filename: imageFile.path.split('/').last,
            ),
          ),
        );
      }

      await _client.dio.post(
        "/discussions",
        data: formData,
        options: Options(
          contentType: "multipart/form-data",
        ),
      );

    } on DioException catch (e) {
      print("CREATE DISCUSSION ERROR: ${e.response?.data}");
      rethrow;
    }
  }

  // ==========================================================
  // TOGGLE UPVOTE
  // ==========================================================
  Future<Map<String, dynamic>> toggleVote(int id) async {
    try {
      final res =
          await _client.post("/discussions/$id/vote");

      return Map<String, dynamic>.from(res.data);

    } on DioException catch (e) {
      print("TOGGLE VOTE ERROR: ${e.response?.data}");
      rethrow;
    }
  }

  // ==========================================================
  // VOTE IN POLL (Supports Multiple Answers)
  // ==========================================================
  Future<Map<String, dynamic>> votePoll(
    int discussionId,
    List<int> selectedIndexes,
  ) async {
    try {
      final formData = FormData.fromMap({
        "option_indexes":
            selectedIndexes.map((e) => e.toString()).toList(),
      });

      final res = await _client.dio.post(
        "/discussions/$discussionId/poll",
        data: formData,
        options: Options(
          contentType: "multipart/form-data",
        ),
      );

      return Map<String, dynamic>.from(res.data);

    } on DioException catch (e) {
      print("POLL VOTE ERROR: ${e.response?.data}");
      rethrow;
    }
  }

  // ==========================================================
  // FETCH COMMENTS
  // ==========================================================
  Future<List<dynamic>> fetchComments(
      int discussionId) async {
    try {
      final res =
          await _client.get("/comments/$discussionId");

      if (res.data is List) {
        return List<dynamic>.from(res.data);
      }

      return [];

    } on DioException catch (e) {
      print("FETCH COMMENTS ERROR: ${e.response?.data}");
      rethrow;
    }
  }

  // ==========================================================
  // ADD COMMENT (Supports Reply)
  // ==========================================================
  Future<Map<String, dynamic>> addComment(
    int discussionId,
    String content, {
    int? parentId,
  }) async {
    try {
      final res = await _client.post(
        "/comments/$discussionId",
        data: {
          "content": content,
          if (parentId != null) "parent_id": parentId,
        },
      );

      return Map<String, dynamic>.from(res.data);

    } on DioException catch (e) {
      print("ADD COMMENT ERROR: ${e.response?.data}");
      rethrow;
    }
  }

  // ==========================================================
  // EDIT COMMENT
  // ==========================================================
  Future<void> editComment(
    int commentId,
    String content,
  ) async {
    try {
      await _client.dio.put(
        "/comments/$commentId",
        data: {
          "content": content,
        },
      );

    } on DioException catch (e) {
      print("EDIT COMMENT ERROR: ${e.response?.data}");
      rethrow;
    }
  }

  // ==========================================================
  // DELETE COMMENT
  // ==========================================================
  Future<void> deleteComment(int commentId) async {
    try {
      await _client.dio.delete(
        "/comments/$commentId",
      );

    } on DioException catch (e) {
      print("DELETE COMMENT ERROR: ${e.response?.data}");
      rethrow;
    }
  }
}