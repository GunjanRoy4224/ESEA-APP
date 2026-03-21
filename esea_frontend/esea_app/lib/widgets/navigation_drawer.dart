import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../config/routes.dart';
import '../providers/auth_provider.dart';

class AppNavigationDrawer extends StatelessWidget {
  const AppNavigationDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Drawer(
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.teal],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  'assets/images/esea_logo.png',
                  height: 50,
                  color: Colors.white,
                ),
                const SizedBox(height: 16),
                if (user != null) ...[
                  Text(
                    user.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.id,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Menu Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  context,
                  icon: Icons.home,
                  title: 'Home',
                  route: AppRoutes.home,
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.credit_card,
                  title: 'Digital ID',
                  route: AppRoutes.digitalId,
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.calendar_today,
                  title: 'Timetable',
                  route: AppRoutes.timetable,
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.event,
                  title: 'Events',
                  route: AppRoutes.events,
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.menu_book,
                  title: 'Course Info',
                  route: AppRoutes.info,
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.work_outline,
                  title: 'Internships',
                  route: AppRoutes.internships,
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.article,
                  title: 'Newsletter',
                  route: AppRoutes.newsletter,
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.book,
                  title: 'Research Blog',
                  route: AppRoutes.blogs,
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.campaign,
                  title: 'Announcements',
                  route: AppRoutes.announcements,
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.person,
                  title: 'Profile',
                  route: AppRoutes.profile,
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.feedback,
                  title: 'Feedback',
                  route: AppRoutes.feedback,
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout, color: AppColors.error),
                  title: const Text(
                    'Logout',
                    style: TextStyle(color: AppColors.error),
                  ),
                  onTap: () async {
                    await authProvider.logout();
                    if (context.mounted) {
                      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String route,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        Navigator.pushNamed(context, route);
      },
    );
  }
}