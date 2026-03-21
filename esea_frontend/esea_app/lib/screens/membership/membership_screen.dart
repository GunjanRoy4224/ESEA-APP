import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MembershipScreen extends StatelessWidget {
  const MembershipScreen({super.key});

  final String formUrl = "https://forms.gle/HpTBxCvkYLxTCDbM8";

  Future<void> _openForm() async {
    final Uri url = Uri.parse(formUrl);

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception("Could not launch form");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ESEA Membership"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Dear ESED Community,",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              const Text(
  "Greetings from ESEA!\n\n"

  "It’s that time of the year again when we come together as passionate members of the Environmental Science and Engineering Association (ESEA) to amplify our collective impact in creating trained and dedicated environmental science and engineering professionals. Your unwavering commitment to environmental stewardship has been instrumental in driving positive change, and we are thrilled to invite you to continue this journey with us.\n\n"

  "We are pleased to announce the ESEA Membership Drive for the Academic Year 2025–26. The existing membership structure will continue unchanged for this academic year. The membership fee is ₹1000, which provides lifetime membership — no renewals or additional payments will be required in future years.\n\n"

  "Mission of ESEA:\n"
  "• To promote the causes of environment\n"
  "• To enable exchange of knowledge between industry and academia\n"
  "• To improve public appreciation and awareness of environmental issues\n"
  "• To advance environmental engineering and technology\n\n"

  "ESEA continues to serve as a dynamic platform for professional growth, collaboration, and engagement through industrial sessions, research talks, student initiatives, and outreach activities.\n\n"

  "Students seeking financial assistance for membership may reach out to any ESEA faculty member or request support through their faculty advisors.\n\n"

  "⚠️ Important Reminder:\n"
  "Please note that No Objection Certificates (NOCs) at the time of graduation will require proof of valid ESEA membership. Hence, all students are strongly encouraged to obtain their memberships during this drive. (Note: Membership drive would not include 1st year BTech students)\n\n"

  "We look forward to your enthusiastic participation and continued contribution to the ESEA community. Together, let us uphold our mission and work toward a more sustainable and equitable future.\n\n"

  "- Environmental Science and Engineering Association",
  style: TextStyle(
    fontSize: 15,
    height: 1.6,
  ),
),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _openForm,
                  child: const Text("Apply for Membership"),
                ),
              ),

              const SizedBox(height: 10),

              const Center(
                child: Text(
                  "Opens Google Form",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}