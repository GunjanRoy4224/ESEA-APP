import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';

import '../../services/dio_client.dart';
import '../../providers/auth_provider.dart';

class AlumniLoginScreen extends StatefulWidget {
  const AlumniLoginScreen({super.key});

  @override
  State<AlumniLoginScreen> createState() => _AlumniLoginScreenState();
}

class _AlumniLoginScreenState extends State<AlumniLoginScreen> {
  final alumniIdController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> login() async {
    if (alumniIdController.text.isEmpty ||
        passwordController.text.isEmpty) {
      _showMsg("Please fill all fields");
      return;
    }

    setState(() => isLoading = true);

    try {
      final dio = DioClient().dio;

      final res = await dio.post(
        "/alumni/login",
        data: FormData.fromMap({
          "alumni_id": alumniIdController.text.trim(),
          "password": passwordController.text.trim(),
        }),
      );

      final token = res.data["access_token"];

      final auth = Provider.of<AuthProvider>(context, listen: false);
      await auth.loginWithToken(token);
      Navigator.of(context).pushNamedAndRemoveUntil(
  '/',
  (route) => false,
);
      _showMsg("Login successful");
    }

    on DioException catch (e) {
      final error = e.response?.data["detail"];

      if (error == "User not found") {
        _showMsg("User not found");
      } else if (error == "Invalid password") {
        _showMsg("Wrong password");
      } else if (error == "Verification pending") {
        _showMsg("Account not verified yet");
      } else {
        _showMsg("Login failed");
      }
    } catch (e) {
      _showMsg("Something went wrong");
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Alumni Login")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: alumniIdController,
              decoration: const InputDecoration(labelText: "Alumni ID"),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : login,
                child: isLoading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text("Login"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}