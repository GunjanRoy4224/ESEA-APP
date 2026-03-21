import 'package:flutter/material.dart';
import '../../models/course_info_model.dart';
import '../../services/course_info_service.dart';
import 'course_info_detail_screen.dart';

class CourseInfoListScreen extends StatefulWidget {
  const CourseInfoListScreen({super.key});

  @override
  State<CourseInfoListScreen> createState() =>
      _CourseInfoListScreenState();
}

class _CourseInfoListScreenState
    extends State<CourseInfoListScreen> {
  final CourseInfoService _service = CourseInfoService();
  final TextEditingController _searchController =
      TextEditingController();

  List<CourseInfo> allCourses = [];
  List<CourseInfo> filteredCourses = [];

  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _load();
    _searchController.addListener(_applyFilter);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      setState(() {
        loading = true;
        error = null;
      });

      allCourses = await _service.fetchAllCourses();
      filteredCourses = allCourses;
    } catch (e) {
      error = "Failed to load course info";
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void _applyFilter() {
    final q = _searchController.text.toLowerCase().trim();

    if (q.isEmpty) {
      setState(() => filteredCourses = allCourses);
      return;
    }

    setState(() {
      filteredCourses = allCourses.where((c) {
        return c.courseCode.toLowerCase().contains(q) ||
            c.courseTitle.toLowerCase().contains(q);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6FB),
      appBar: AppBar(
        title: const Text("Course Info"),
        elevation: 0,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!))
              : Column(
                  children: [
                    // 🔍 SEARCH BAR
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                          16, 12, 16, 6),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText:
                              "Search by course code or title",
                          prefixIcon:
                              const Icon(Icons.search),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding:
                              const EdgeInsets.symmetric(
                                  vertical: 0),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),

                    // 📋 LIST
                    Expanded(
                      child: filteredCourses.isEmpty
                          ? const Center(
                              child: Text(
                                "No matching courses",
                                style: TextStyle(
                                    color: Colors.grey),
                              ),
                            )
                          : ListView.separated(
                              padding:
                                  const EdgeInsets.all(16),
                              itemCount:
                                  filteredCourses.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(
                                      height: 12),
                              itemBuilder:
                                  (context, index) {
                                final c =
                                    filteredCourses[index];

                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            CourseInfoDetailScreen(
                                                course: c),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding:
                                        const EdgeInsets.all(
                                            14),
                                    decoration:
                                        BoxDecoration(
                                      color: Colors.white,
                                      borderRadius:
                                          BorderRadius
                                              .circular(
                                                  18),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors
                                              .black
                                              .withOpacity(
                                                  0.05),
                                          blurRadius:
                                              16,
                                          offset:
                                              const Offset(
                                                  0, 8),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        // ICON
                                        Container(
                                          width: 56,
                                          height: 56,
                                          decoration:
                                              BoxDecoration(
                                            color: const Color(
                                                0xFFEFF6EC),
                                            borderRadius:
                                                BorderRadius
                                                    .circular(
                                                        14),
                                          ),
                                          child: Center(
                                            child:
                                                Image.asset(
                                              "assets/images/course_material.png",
                                              width: 30,
                                              height: 30,
                                              fit: BoxFit
                                                  .contain,
                                            ),
                                          ),
                                        ),

                                        const SizedBox(
                                            width: 14),

                                        // TEXT
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment
                                                    .start,
                                            children: [
                                              Text(
                                                c.courseCode,
                                                style:
                                                    const TextStyle(
                                                  fontSize:
                                                      16,
                                                  fontWeight:
                                                      FontWeight
                                                          .bold,
                                                ),
                                              ),
                                              const SizedBox(
                                                  height:
                                                      4),
                                              Text(
                                                c.courseTitle,
                                                style:
                                                    const TextStyle(
                                                  fontSize:
                                                      14,
                                                ),
                                              ),
                                              const SizedBox(
                                                  height:
                                                      4),
                                              Text(
                                                "Prof. ${c.instructor ?? 'N/A'}",
                                                style:
                                                    const TextStyle(
                                                  fontSize:
                                                      12,
                                                  color: Colors
                                                      .grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        const Icon(
                                          Icons
                                              .chevron_right,
                                          size: 26,
                                          color:
                                              Colors.grey,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
    );
  }
}

