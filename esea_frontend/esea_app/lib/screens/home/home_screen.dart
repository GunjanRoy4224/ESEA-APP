import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../models/content_model.dart';
import '../../services/content_service.dart';
import '../../widgets/feature_tile.dart';

// Screens
import '../announcements/announcements_screen.dart';
import '../events/events_screen.dart';
import '../blogs/research_blog_screen.dart';
import '../newsletter/newsletter_screen.dart';
import '../internships/internship_screen.dart';
import '../timetable/timetable_screen.dart';
import '../course_material/course_info_screen.dart';
import '../profile/profile_screen.dart';
import '../digital_id/digital_id_screen.dart';
import '../feedback/feedback_screen.dart';
import '../discussions/discussion_feed_screen.dart';
import '../membership/membership_screen.dart';


/// ================= COLORS =================
const Color bgColor = Color(0xFFF6F8F7);
const Color greenDark = Color(0xFF0B5D4B);
const Color greenMid = Color(0xFF1F8F74);
const Color greenLight = Color(0xFF9ED6C5);
const Color textMuted = Color(0xFF6B7280);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<ContentModel>> announcementsFuture;

  @override
  void initState() {
    super.initState();
    context.read<AuthProvider>().refreshProfile();
    announcementsFuture = ContentService().fetchLatestAnnouncements();
  }

  // ================= NAVIGATION =================

  void _openFeature(BuildContext context, String feature) {

  Widget? screen;

  switch (feature) {
    case "Digital ID":
      screen = const DigitalIdScreen();
      break;
    case "Announcements":
      screen = const AnnouncementsScreen();
      break;
    case "Events":
      screen = const EventsScreen();
      break;
    case "Research":
      screen = const ResearchScreen();
      break;
    case "Newsletter":
      screen = const NewslettersScreen();
      break;
    case "Internships":
      screen = const InternshipsScreen();
      break;
    case "Timetable":
      screen = const TimetableScreen();
      break;
    case "Course Info":
      screen = const CourseInfoScreen();
      break;
    case "Discussion":
      screen = const DiscussionFeedScreen();
      break;
    case "Profile":
      screen = const ProfileScreen();
      break;
    case "Feedback":
      screen = const FeedbackScreen();
      break;
    case "Membership":
      screen = const MembershipScreen();
      break;
    default:
      screen = null;
  }

  if (screen != null) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen!),
    );
  }
}

  // ================= BUILD =================

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        title: Row(
          children: [
            Image.asset("assets/images/esea_logo.png", height: 28),
            const SizedBox(width: 10),
            const Text(
              "ESEA App",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      drawer: _buildDrawer(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _welcomeCard(user),
            const SizedBox(height: 26),
            _latestAnnouncements(),
            const SizedBox(height: 36),
            _featuresSection(),
          ],
        ),
      ),
    );
  }

  // ================= WELCOME CARD  =================

  Widget _welcomeCard(user) {
  return Container(
    height: 216,
    width: double.infinity,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(24),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          greenDark,
          greenMid,
          greenLight,
        ],
      ),
      boxShadow: [
        BoxShadow(
          color: greenDark.withOpacity(0.35),
          blurRadius: 20,
          offset: const Offset(0, 12),
        ),
      ],
    ),
    child: Stack(
      children: [
        // Grain / leaf texture
        Positioned(
          right: -20,
          bottom: -20,
          child: Opacity(
            opacity: 0.22,
            child: Image.asset(
              "assets/images/leaf_pattern.png",
              width: 170,
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, // ⭐ important
            children: [
              const Text(
                "Welcome back,",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                "${user.fullName}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                "${user.department}  ${user.year}",
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 10), 

              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: greenDark,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 8,
                  ),
                ),
                icon: const Icon(Icons.badge_outlined),
                label: const Text(
                  "View Digital ID",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: () => _openFeature(context, "Digital ID"),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}


  // ================= ANNOUNCEMENTS =================

  Widget _latestAnnouncements() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 216, 225, 237),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 22,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Latest Announcements",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              TextButton(
                onPressed: () => _openFeature(context, "Announcements"),
                child: const Text(
                  "View all",
                  style: TextStyle(color: greenDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          FutureBuilder<List<ContentModel>>(
            future: announcementsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return const Text("Error loading announcements");
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Text(
                  "No announcements yet",
                  style: TextStyle(color: textMuted),
                );
              }

              return SizedBox(
                height: 130,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: snapshot.data!.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 14),
                  itemBuilder: (context, index) {
                    final a = snapshot.data![index];

                    return Container(
                      width: 230,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 16,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (a.isNew == true)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: greenLight,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                "NEW",
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: greenDark,
                                ),
                              ),
                            ),
                          const SizedBox(height: 10),
                          Text(
                            a.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            a.shortDescription ?? "",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              color: textMuted,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ================= FEATURES =================

  Widget _featuresSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "All Features",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 18),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 18,
          crossAxisSpacing: 18,
          children: [
            FeatureTile(icon: Icons.badge, label: "Digital ID", onTap: () => _openFeature(context, "Digital ID")),
            FeatureTile(icon: Icons.campaign, label: "Announcements", onTap: () => _openFeature(context, "Announcements")),
            FeatureTile(icon: Icons.event, label: "Events", onTap: () => _openFeature(context, "Events")),
            FeatureTile(icon: Icons.search, label: "Research", onTap: () => _openFeature(context, "Research")),
            FeatureTile(icon: Icons.menu_book, label: "Newsletter", onTap: () => _openFeature(context, "Newsletter")),
            FeatureTile(icon: Icons.work, label: "Internships", onTap: () => _openFeature(context, "Internships")),
            FeatureTile(icon: Icons.schedule, label: "Timetable", onTap: () => _openFeature(context, "Timetable")),
            FeatureTile(icon: Icons.school, label: "Course Info", onTap: () => _openFeature(context, "Course Info")),
            FeatureTile(icon: Icons.forum, label: "Discussion", onTap: () => _openFeature(context, "Discussion"),),
            FeatureTile(icon: Icons.person, label: "Profile", onTap: () => _openFeature(context, "Profile")),
            FeatureTile(icon: Icons.card_membership, label: "Membership", onTap: () => _openFeature(context, "Membership")),
            FeatureTile(icon: Icons.feedback, label: "Feedback", onTap: () => _openFeature(context, "Feedback")),
          ],
        ),
      ],
    );
  }

  // ================= DRAWER =================

  Drawer _buildDrawer(BuildContext context) {
    final user = context.read<AuthProvider>().user!;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [greenDark, greenMid]),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: Colors.white,
                  child: Text(
                    user.name[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: greenDark,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(user.name, style: const TextStyle(color: Colors.white)),
                Text(
                  "${user.department} • ${user.year}",
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          _drawerItem("Digital ID"),
          _drawerItem("Announcements"),
          _drawerItem("Events"),
          _drawerItem("Research"),
          _drawerItem("Newsletter"),
          _drawerItem("Internships"),
          _drawerItem("Timetable"),
          _drawerItem("Course Info"),
          _drawerItem("Discussion"),
          _drawerItem("Profile"),
          _drawerItem("Membership"),
          _drawerItem("Feedback"),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Logout"),
            onTap: () => context.read<AuthProvider>().logout(),
          ),
        ],
      ),
    );
  }

  ListTile _drawerItem(String title) {
    return ListTile(
      title: Text(title),
      onTap: () => _openFeature(context, title),
    );
  }
}
