import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../providers/auth_provider.dart';
import '../../constants/colors.dart';
import 'alumni_entry_screen.dart';
import '../membership/membership_screen.dart';

class LoginSSOScreen extends StatelessWidget {
  const LoginSSOScreen({super.key});

  Future<void> _startSSOLogin(BuildContext context) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    final String? url = await auth.getSSOLoginUrl();

    if (url == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Unable to start SSO login"),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final uri = Uri.parse(url);

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Could not open IITB SSO page"),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // -------------------------------
                    // LOGO
                    // -------------------------------
                    Image.asset(
                      'assets/images/esea_logo.png',
                      height: 80,
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      'ESEA APP',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Login to continue',
                      style: TextStyle(fontSize: 16),
                    ),

                    const SizedBox(height: 32),

                    // -------------------------------
                    // SSO BUTTON (PRIMARY)
                    // -------------------------------
                    Consumer<AuthProvider>(
                      builder: (_, auth, __) {
                        return SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: auth.isLoading
                                ? null
                                : () => _startSSOLogin(context),
                            icon: auth.isLoading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.lock_outline),
                            label: Text(
                              auth.isLoading
                                  ? 'Connecting...'
                                  : 'Continue as Student (SSO)',
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    // -------------------------------
                    // ALUMNI BUTTON
                    // -------------------------------
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AlumniEntryScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.school_outlined),
                        label: const Text("Continue as Alumni"),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // -------------------------------
                    // MEMBERSHIP BUTTON
                    // -------------------------------
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MembershipScreen(),
                          ),
                        );
                      },
                      child: const Text("Become an ESEA Member"),
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