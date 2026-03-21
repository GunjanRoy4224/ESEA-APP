import 'package:flutter/material.dart';
import '../screens/auth/login_sso_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/timetable/timetable_screen.dart';
import '../screens/events/events_screen.dart';
import '../screens/course_material/course_info_screen.dart';
import '../screens/internships/internship_screen.dart';
import '../screens/newsletter/newsletter_screen.dart';
import '../screens/blogs/research_blog_screen.dart';
import '../screens/announcements/announcements_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/digital_id/digital_id_screen.dart';
import '../screens/feedback/feedback_screen.dart';
import '../screens/discussions/discussion_feed_screen.dart';
import '../screens/membership/membership_screen.dart';

class AppRoutes {
  static const login = '/login';
  static const home = '/home';
  
  static const String timetable = '/timetable';
  static const String events = '/events';
  static const String digitalId = '/digital_id';
  static const String info = '/course-info';
  static const String internships = '/internships';
  static const String newsletter = '/newsletter';
  static const String blogs = '/blogs';
  static const String announcements = '/announcements';
  static const String profile = '/profile';
  static const String feedback = '/feedback';
  static const String discussions = '/discussions';
  static const String membership = '/membership';

  static Map<String, WidgetBuilder> get routes => {
     
        login: (context) => const LoginSSOScreen(),

        home: (context) => const HomeScreen(),
        digitalId: (context) => const DigitalIdScreen(),
        timetable: (context) => const TimetableScreen(),
        events: (context) => const EventsScreen(),
        info: (context) => const CourseInfoScreen(),
        internships: (context) => const InternshipsScreen(),
        newsletter: (context) => const NewslettersScreen(),
        blogs: (context) => const ResearchScreen(),
        announcements: (context) => const AnnouncementsScreen(),
        profile: (context) => const ProfileScreen(),
        feedback: (context) => const FeedbackScreen(),
        discussions: (context) => const DiscussionFeedScreen(),
        membership: (context) => const MembershipScreen(),
      };
}
