import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import 'alumni_login_screen.dart';
import 'alumni_signup_screen.dart';

class AlumniEntryScreen extends StatelessWidget {
  const AlumniEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Alumni Access"),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withOpacity(0.1),
              AppColors.teal.withOpacity(0.2),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // -------------------------------
                    // TITLE
                    // -------------------------------
                    const Text(
                      "Welcome Alumni",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      "Login or create your alumni account",
                      style: TextStyle(fontSize: 14),
                    ),

                    const SizedBox(height: 32),

                    // -------------------------------
                    // LOGIN BUTTON (PRIMARY)
                    // -------------------------------
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AlumniLoginScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.login),
                        label: const Text("Login as Alumni"),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // -------------------------------
                    // SIGNUP BUTTON
                    // -------------------------------
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AlumniSignupScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.person_add_alt_1),
                        label: const Text("Signup as Alumni"),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // -------------------------------
                    // INFO TEXT
                    // -------------------------------
                    const Text(
                      "New users must verify their alumni ID before access.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}