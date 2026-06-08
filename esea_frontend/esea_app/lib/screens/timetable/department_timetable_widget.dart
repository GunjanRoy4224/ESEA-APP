import 'package:flutter/material.dart';
import '../../services/timetable_service.dart';
import '../../widgets/weekly_timetable_grid.dart';
import '../../widgets/error_state_widget.dart';
import 'package:shimmer/shimmer.dart';

class DepartmentTimetableWidget extends StatefulWidget {
  const DepartmentTimetableWidget({super.key});

  @override
  State<DepartmentTimetableWidget> createState() =>
      _DepartmentTimetableWidgetState();
}

class _DepartmentTimetableWidgetState
    extends State<DepartmentTimetableWidget> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  Map<String, dynamic> timetable = {};
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final data = await TimetableService().fetchDepartmentTimetable();
      setState(() {
        timetable = data;
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

@override
Widget build(BuildContext context) {
  super.build(context);
  if (loading) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Column(
        children: List.generate(
          4,
          (index) => Container(
            margin: const EdgeInsets.only(bottom: 16),
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }

  if (error != null) {
    return ErrorStateWidget(
      title: "Failed to load timetable",
      message: "Please check your connection.",
      onRetry: _load,
    );
  }

  if (timetable.isEmpty) {
    return const Center(child: Text("Timetable not available"));
  }

  return RefreshIndicator(
    onRefresh: _load,
    child: SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 12),
      child: WeeklyTimetableGrid(timetable: timetable),
    ),
  );
}

}
