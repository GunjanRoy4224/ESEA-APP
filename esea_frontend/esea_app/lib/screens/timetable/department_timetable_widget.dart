import 'package:flutter/material.dart';
import '../../services/timetable_service.dart';
import '../../widgets/weekly_timetable_grid.dart';

class DepartmentTimetableWidget extends StatefulWidget {
  const DepartmentTimetableWidget({super.key});

  @override
  State<DepartmentTimetableWidget> createState() =>
      _DepartmentTimetableWidgetState();
}

class _DepartmentTimetableWidgetState
    extends State<DepartmentTimetableWidget> {
  Map<String, dynamic> timetable = {};
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await TimetableService().fetchDepartmentTimetable();
    setState(() {
      timetable = data;
      loading = false;
    });
  }

  @override
Widget build(BuildContext context) {
  if (loading) {
    return const Center(child: CircularProgressIndicator());
  }

  if (timetable.isEmpty) {
    return const Text("Timetable not available");
  }

  return SingleChildScrollView(
    padding: const EdgeInsets.only(bottom: 12),
    child: WeeklyTimetableGrid(timetable: timetable),
  );
}

}
