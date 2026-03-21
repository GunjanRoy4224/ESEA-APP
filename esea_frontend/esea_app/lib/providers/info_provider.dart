import 'package:flutter/foundation.dart';
import '../models/course_info_model.dart';
import '../services/course_info_service.dart';

class InfoProvider with ChangeNotifier {
  final CourseInfoService _service = CourseInfoService();

  List<CourseInfo> _materials = [];
  bool _isLoading = false;
  String? _error;

  List<CourseInfo> get materials => _materials;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchMaterials() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _materials = await _service.fetchAllCourses();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
