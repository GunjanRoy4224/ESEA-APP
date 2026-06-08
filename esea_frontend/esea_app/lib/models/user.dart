import 'dart:convert';

class User {
  final String id;
  final String name;

  /// nullable (alumni won't have roll number)
  final String? rollNumber;
  final String? alumniId;

  final String eseaId;
  final String department;

  /// computed by backend
  final String year;

  /// graduation year from backend
  final int? graduationYear;
  final String? photoUrl;

  // ================= ROLE & STATUS =================
  final String? role;   // student / alumni
  final String? status; // pending / verified

  // ================= ACADEMIC PROFILE =================
  final String? program; // B.Tech, M.Tech, PhD, Dual Degree
  final String? minor;
  final String? researchProject;

  User({
    required this.id,
    required this.name,
    this.rollNumber,
    this.alumniId,
    required this.eseaId,
    required this.department,
    required this.year,
    this.graduationYear,
    this.photoUrl,
    this.role,
    this.status,
    this.program,
    this.minor,
    this.researchProject,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      name: json['name'] ?? '',

      rollNumber: json['roll_number'],
      alumniId: json['alumni_id'],

      eseaId: json['esea_id'] ?? '',
      department: json['department'] ?? '',
      year: json['year'] ?? '',

      graduationYear: json['graduation_year'] != null
          ? int.tryParse(json['graduation_year'].toString())
          : null,

      photoUrl: json['photo_url'],

      // ✅ FIX 1: normalize role
      role: json['role']?.toString().toLowerCase(),

      status: json['status'],
      
      program: json['program'],
      minor: json['minor'],
      researchProject: json['research_project'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'roll_number': rollNumber,
      'alumni_id': alumniId,
      'esea_id': eseaId,
      'department': department,
      'year': year,
      'graduation_year': graduationYear,
      'photo_url': photoUrl,
      'role': role,
      'status': status,
      'program': program,
      'minor': minor,
      'research_project': researchProject,
    };
  }

  String toJsonString() => jsonEncode(toJson());

  factory User.fromJsonString(String str) =>
      User.fromJson(jsonDecode(str));

  // ================= UI HELPERS =================

  String get fullName => name;

  /// shown on ID card
  String get memberId => eseaId;

  /// Valid until graduation year
  String get validUntil =>
      graduationYear != null ? graduationYear.toString() : "—";

  String get initials {
    if (name.isEmpty) return 'S';
    return name
        .trim()
        .split(" ")
        .map((e) => e[0])
        .take(2)
        .join()
        .toUpperCase();
  }

  // ✅ FIX 2: helper for role check
  bool get isAlumni => role == "alumni";
}