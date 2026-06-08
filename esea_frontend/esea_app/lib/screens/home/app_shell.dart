import 'package:flutter/material.dart';
import 'home_screen.dart';
import '../../services/notification_service.dart';

import '../announcements/announcements_screen.dart';
import '../discussions/discussion_feed_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {

  int _currentIndex = 1;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();

    NotificationService().handleNotificationTap(context);

    _screens = const [
      AnnouncementsScreen(),
      HomeScreen(),
      DiscussionFeedScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_currentIndex != 1) {
          setState(() => _currentIndex = 1);
          return false;
        }
        return false;
      },
      child: Scaffold(

        // ================= BODY =================
        body: Stack(
          children: [
            IndexedStack(
              index: _currentIndex,
              children: _screens,
            ),

            // ================= FLOATING NAV =================
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: _buildFloatingNav(),
            ),
          ],
        ),
      ),
    );
  }

  // ================= FLOATING NAV =================
  Widget _buildFloatingNav() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [

          _navItem(0, Icons.campaign_outlined, "Announcements"),
          _navItem(1, Icons.home_outlined, "Home"),
          _navItem(2, Icons.forum_outlined, "Discussion"),
        ],
      ),
    );
  }

  // ================= NAV ITEM =================
  Widget _navItem(int index, IconData icon, String label) {

    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() => _currentIndex = index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 16 : 10,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF0B5D4B).withOpacity(0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [

            Icon(
              icon,
              color: isSelected
                  ? const Color(0xFF0B5D4B)
                  : Colors.grey,
            ),

            if (isSelected) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF0B5D4B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}