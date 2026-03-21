// ==========================================================
// CREATE DISCUSSION SHEET (FULL FIXED + POLISHED)
// Features preserved:
// - Image upload
// - Poll system (multiple / quiz / correct answers)
// - Validation
// ==========================================================

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/discussion_service.dart';

class CreateDiscussionSheet extends StatefulWidget {
  final VoidCallback onPostSuccess;

  const CreateDiscussionSheet({
    super.key,
    required this.onPostSuccess,
  });

  @override
  State<CreateDiscussionSheet> createState() =>
      _CreateDiscussionSheetState();
}

class _CreateDiscussionSheetState
    extends State<CreateDiscussionSheet> {

  final _title = TextEditingController();
  final _content = TextEditingController();
  final DiscussionService _service = DiscussionService();

  final List<TextEditingController> _pollControllers = [];
  final ImagePicker _picker = ImagePicker();

  File? _selectedImage;
  bool _loading = false;
  bool _isPollEnabled = false;

  // ================= POLL CONFIG =================
  final bool _anonymous = false;
  bool _multiple = false;
  bool _quizMode = false;
  List<int> _correctIndexes = [];

  // ================= IMAGE PICK =================
  Future<void> _pickImage() async {
    final picked =
        await _picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

  // ================= ADD POLL OPTION =================
  void _addPollOption() {
    setState(() {
      _pollControllers.add(TextEditingController());
    });
  }

  // ================= REMOVE POLL OPTION =================
  void _removePollOption(int index) {
    setState(() {
      _pollControllers.removeAt(index);
      _correctIndexes.remove(index);
    });
  }

  // ================= SHOW MESSAGE =================
  void _showMsg(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  // ================= SUBMIT =================
  Future<void> _submit() async {

    if (_title.text.trim().isEmpty ||
        _content.text.trim().isEmpty) {
      _showMsg("Title and content are required");
      return;
    }

    setState(() => _loading = true);

    List<String>? pollOptions;

    if (_isPollEnabled) {

      pollOptions = _pollControllers
          .map((c) => c.text.trim())
          .where((text) => text.isNotEmpty)
          .toList();

      if (pollOptions.length < 2) {
        _showMsg("Minimum 2 poll options required");
        setState(() => _loading = false);
        return;
      }

      if (_quizMode && _correctIndexes.isEmpty) {
        _showMsg("Select correct answer for quiz");
        setState(() => _loading = false);
        return;
      }
    }

    try {
      await _service.createDiscussion(
        _title.text.trim(),
        _content.text.trim(),
        imageFile: _selectedImage,
        pollOptions: pollOptions,
        anonymous: _anonymous,
        multiple: _multiple,
        quizMode: _quizMode,
        correctIndexes: _correctIndexes,
      );

      widget.onPostSuccess();
      Navigator.pop(context);

    } catch (e) {
      print("Create error: $e");
      _showMsg("Failed to create discussion");
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {

    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ================= HEADER =================
            const Text(
              "Create Discussion",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            // ================= TITLE =================
            TextField(
              controller: _title,
              decoration: const InputDecoration(
                labelText: "Title",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            // ================= CONTENT =================
            TextField(
              controller: _content,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: "Content",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // ================= IMAGE =================
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.image),
                  label: const Text("Add Image"),
                ),
                const SizedBox(width: 12),

                if (_selectedImage != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      _selectedImage!,
                      height: 90,
                      width: 90,
                      fit: BoxFit.cover,
                    ),
                  )
              ],
            ),

            const SizedBox(height: 16),

            // ================= POLL TOGGLE =================
            SwitchListTile(
              title: const Text("Add Poll"),
              value: _isPollEnabled,
              onChanged: (val) {
                setState(() {
                  _isPollEnabled = val;

                  if (val && _pollControllers.isEmpty) {
                    _addPollOption();
                    _addPollOption();
                  }
                });
              },
            ),

            // ================= POLL SECTION =================
            if (_isPollEnabled) ...[

              const SizedBox(height: 8),

              Column(
                children: _pollControllers
                    .asMap()
                    .entries
                    .map((entry) {

                  final index = entry.key;
                  final controller = entry.value;
                  final isCorrect =
                      _correctIndexes.contains(index);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [

                        Expanded(
                          child: TextField(
                            controller: controller,
                            decoration: const InputDecoration(
                              labelText: "Poll Option",
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),

                        const SizedBox(width: 6),

                        if (_quizMode)
                          Checkbox(
                            value: isCorrect,
                            onChanged: (val) {
                              setState(() {
                                if (val == true) {
                                  if (!_multiple) {
                                    _correctIndexes = [index];
                                  } else {
                                    _correctIndexes.add(index);
                                  }
                                } else {
                                  _correctIndexes.remove(index);
                                }
                              });
                            },
                          ),

                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () =>
                              _removePollOption(index),
                        )
                      ],
                    ),
                  );

                }).toList(),
              ),

              TextButton.icon(
                onPressed: _addPollOption,
                icon: const Icon(Icons.add),
                label: const Text("Add Option"),
              ),

              const SizedBox(height: 12),

              SwitchListTile(
                title: const Text("Allow Multiple Answers"),
                value: _multiple,
                onChanged: (val) =>
                    setState(() => _multiple = val),
              ),

              SwitchListTile(
                title: const Text("Enable Quiz Mode"),
                value: _quizMode,
                onChanged: (val) =>
                    setState(() {
                      _quizMode = val;
                      _correctIndexes.clear();
                    }),
              ),
            ],

            const SizedBox(height: 20),

            // ================= SUBMIT =================
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _loading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        "Post",
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}