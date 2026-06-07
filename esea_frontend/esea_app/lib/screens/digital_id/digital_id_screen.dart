import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class DigitalIdScreen extends StatelessWidget {
  const DigitalIdScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user!;
    final isAlumni = user.isAlumni;

    final gradientColors = isAlumni
        ? [const Color.fromARGB(255, 118, 182, 255), const Color.fromARGB(255, 159, 181, 243)] // 🔵 alumni blue
        : [const Color(0xFF3ED598), const Color(0xFF0B6E4F)]; // 🟢 student green

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Digital ID"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Center(
        child: Container(
  margin: const EdgeInsets.all(20),
  padding: const EdgeInsets.all(22),
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(28),

    // 🎯 EXACT SOFT GRADIENT (MATCHED TO IMAGE)
    gradient: LinearGradient(
      colors: isAlumni
          ? [
              Color(0xFF9EC5FF), // soft top glow blue
              Color(0xFF4F7BFF),
              Color(0xFF2A4FD7),
              Color(0xFF1E2F8F),
            ]
          : [
              Color(0xFFB9FBC0), // soft green top glow
              Color(0xFF4ADE80),
              Color(0xFF16A34A),
              Color(0xFF065F46),
            ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),

    border: Border.all(
      color: Colors.white.withOpacity(0.25),
      width: 1.2,
    ),

    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.25),
        blurRadius: 50,
        offset: Offset(0, 25),
      ),
    ],
  ),

  child: Stack(
    children: [

      // 🌟 TOP LEFT GLOW (IMPORTANT)
      Positioned(
        top: -40,
        left: -40,
        child: SizedBox(
          width: 180,
          height: 180,
           
        ),
      ),

      // 🌊 WAVE 1 (MAIN LIGHT FLOW)
      Positioned(
        bottom: -20,
        right: -30,
        child: Transform.rotate(
          angle: -0.25,
          child: Container(
            width: 260,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(80),
              gradient: LinearGradient(
                colors: [
                  const Color.fromARGB(255, 221, 223, 255).withOpacity(0.18),
                  const Color.fromARGB(255, 255, 227, 227).withOpacity(0.05),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ),

      // 🌊 WAVE 2 (SUBTLE SECOND LAYER)
      Positioned(
        bottom: 20,
        right: -10,
        child: Transform.rotate(
          angle: -0.2,
          child: Container(
            width: 200,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(80),
              gradient: LinearGradient(
                colors: [
                  const Color.fromARGB(255, 245, 230, 255).withOpacity(0.1),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ),

      Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          // ================= HEADER =================
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "ESEA MEMBER ID",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  letterSpacing: 1.6,
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isAlumni ? "ALUMNI" : "STUDENT",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            ],
          ),

          const SizedBox(height: 8),

          Text(
            user.memberId,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              letterSpacing: 2,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 25),

          // ================= PROFILE =================
          Row(
            children: [
              CircleAvatar(
                radius: 34,
                backgroundColor: Colors.white.withOpacity(0.95),
                child: Text(
                  user.initials,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      isAlumni
                          ? "Alumni ID: ${user.alumniId ?? "-"}"
                          : "Roll No: ${user.rollNumber ?? "-"}",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),

          const SizedBox(height: 28),

          // ================= DETAILS =================
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _info("Department", user.department),

              if (!isAlumni)
                _info("Year", user.year),
            ],
          ),

          const SizedBox(height: 20),

          // ================= DIVIDER =================
          Container(
            height: 1,
            color: Colors.white.withOpacity(0.35),
          ),

          const SizedBox(height: 10),

          // ================= FOOTER =================
          Text(
            isAlumni
                ? "GRADUATED IN ${user.graduationYear ?? "N/A"}"
                : "VALID UNTIL ${user.validUntil}",
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    ],
  ),
)
      ),
    );
  }

  Widget _info(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}