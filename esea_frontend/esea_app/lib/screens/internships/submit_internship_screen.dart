import 'package:flutter/material.dart';
import '../../services/dio_client.dart';

class SubmitInternshipScreen extends StatefulWidget {
  const SubmitInternshipScreen({super.key});

  @override
  State<SubmitInternshipScreen> createState() =>
      _SubmitInternshipScreenState();
}

class _SubmitInternshipScreenState
    extends State<SubmitInternshipScreen> {

  final _formKey = GlobalKey<FormState>();

  final titleController = TextEditingController();
  final shortDescController = TextEditingController();
  final fullDescController = TextEditingController();
  final linkController = TextEditingController();

  DateTime? selectedDeadline;
  bool isLoading = false;

  // ================= SUBMIT =================
  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (selectedDeadline == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Select deadline")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await DioClient().dio.post(
        "/internships/submit",
        data: {
          "type": "internship",
          "title": titleController.text,
          "short_description": shortDescController.text,
          "full_description": fullDescController.text,
          "external_link": linkController.text,
          "deadline": selectedDeadline!
              .toIso8601String()
              .split("T")
              .first,
        },
      );

      if (mounted) Navigator.pop(context, true);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Submission failed")),
      );
    }

    setState(() => isLoading = false);
  }

  // ================= DATE PICK =================
  Future<void> pickDate() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
    );

    if (date != null) {
      setState(() => selectedDeadline = date);
    }
  }

  // ================= INPUT DECOR =================
  InputDecoration _input(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F7),

      // ================= APP BAR =================
      appBar: AppBar(
        title: const Text("Submit Internship"),
        elevation: 0,
      ),

      body: Column(
        children: [

          // ================= HEADER =================
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0B5D4B), Color(0xFF0F7B63)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Crowdsource Internships",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  "Help others by sharing verified opportunities",
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),

          // ================= FORM =================
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [

                  // CARD
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Column(
                      children: [

                        TextFormField(
                          controller: titleController,
                          decoration: _input("Title", Icons.work),
                          validator: (v) =>
                              v!.isEmpty ? "Required" : null,
                        ),

                        const SizedBox(height: 14),

                        TextFormField(
                          controller: shortDescController,
                          decoration: _input(
                              "Short Description", Icons.short_text),
                          validator: (v) =>
                              v!.isEmpty ? "Required" : null,
                        ),

                        const SizedBox(height: 14),

                        TextFormField(
                          controller: fullDescController,
                          maxLines: 4,
                          decoration: _input(
                              "Full Description", Icons.description),
                        ),

                        const SizedBox(height: 14),

                        TextFormField(
                          controller: linkController,
                          decoration:
                              _input("Apply Link", Icons.link),
                        ),

                        const SizedBox(height: 14),

                        // ================= DEADLINE =================
                        GestureDetector(
                          onTap: pickDate,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 14, horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius:
                                  BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today),
                                const SizedBox(width: 12),
                                Text(
                                  selectedDeadline == null
                                      ? "Select Deadline"
                                      : selectedDeadline!
                                          .toLocal()
                                          .toString()
                                          .split(" ")[0],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),

      // ================= SUBMIT BUTTON =================
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: isLoading ? null : submit,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: const Color.fromARGB(255, 170, 255, 237),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text(
                  "Submit for Verification",
                  style: TextStyle(fontSize: 16),
                ),
        ),
      ),
    );
  }
}