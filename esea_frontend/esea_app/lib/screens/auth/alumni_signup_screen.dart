import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';

import '../../services/dio_client.dart';
import '../../providers/auth_provider.dart';
import 'qr_scanner_screen.dart';

class AlumniSignupScreen extends StatefulWidget {
  const AlumniSignupScreen({super.key});

  @override
  State<AlumniSignupScreen> createState() => _AlumniSignupScreenState();
}

class _AlumniSignupScreenState extends State<AlumniSignupScreen> {
  final name = TextEditingController();
  final alumniId = TextEditingController();
  final password = TextEditingController();
  final dept = TextEditingController();
  final gradYear = TextEditingController();

  String? qrData;
  bool isLoading = false;

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  // -----------------------------------------
  // SIGNUP WITH QR
  // -----------------------------------------
  Future<void> signup() async {
    if (qrData == null) {
      _showMsg("Please scan QR first");
      return;
    }

    if (name.text.isEmpty ||
        alumniId.text.isEmpty ||
        password.text.isEmpty ||
        dept.text.isEmpty ||
        gradYear.text.isEmpty) {
      _showMsg("Fill all fields");
      return;
    }

    setState(() => isLoading = true);

    try {
      final dio = DioClient().dio;

      final res = await dio.post(
        "/alumni/signup",
        data: FormData.fromMap({
          "name": name.text,
          "alumni_id": alumniId.text,
          "password": password.text,
          "graduation_year": int.parse(gradYear.text),
          "department": dept.text,
          "qr_data": qrData, // ✅ sending QR directly
        }),
      );

      print("RESPONSE: ${res.data}");

      // -----------------------------------------
      // ✅ VERIFIED FLOW (AUTO LOGIN)
      // -----------------------------------------
      if (res.data["status"] == "verified") {
        final token = res.data["token"]; 

        final auth = Provider.of<AuthProvider>(context, listen: false);

        await auth.loginWithToken(token);
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/',
          (route) => false,
        );
        _showMsg("Verified & Logged in");
        
      }

      // -----------------------------------------
      // ⏳ PENDING FLOW
      // -----------------------------------------
      else {
        _showMsg("⏳ Pending admin approval");
      }
    } catch (e) {
      print("SIGNUP ERROR: $e");
      _showMsg("Signup failed");
    }

    setState(() => isLoading = false);
  }

  // -----------------------------------------
  // UI
  // -----------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Alumni Signup")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ListView(
          children: [
            TextField(
              controller: name,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            TextField(
              controller: alumniId,
              decoration: const InputDecoration(labelText: "Alumni ID"),
            ),
            TextField(
              controller: password,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            TextField(
              controller: dept,
              decoration: const InputDecoration(labelText: "Department"),
            ),
            TextField(
              controller: gradYear,
              decoration: const InputDecoration(labelText: "Graduation Year"),
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 20),

            // -------------------------------
            // QR SCAN BUTTON
            // -------------------------------
            ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const QRScannerScreen(),
                  ),
                );

                if (result != null) {
                  setState(() => qrData = result.toString());
                  _showMsg("✅ QR Scanned");
                }
              },
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text("Scan Alumni ID QR"),
            ),

            const SizedBox(height: 10),

            if (qrData != null)
              Container(
                padding: const EdgeInsets.all(8),
                color: Colors.grey.shade100,
                child: Text(
                  "QR: $qrData",
                  style: const TextStyle(fontSize: 12),
                ),
              ),

            const SizedBox(height: 20),

            // -------------------------------
            // SIGNUP BUTTON
            // -------------------------------
            ElevatedButton(
              onPressed: isLoading ? null : signup,
              child: isLoading
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text("Signup"),
            ),
          ],
        ),
      ),
    );
  }
}