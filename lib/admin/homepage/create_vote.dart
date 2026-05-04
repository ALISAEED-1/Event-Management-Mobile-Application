import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../backend/models/vote_model.dart';
import '../../backend/services/storage_services.dart';
import '../../backend/services/vote_services.dart';

class CreateVote extends StatefulWidget {
  const CreateVote({super.key});

  @override
  State<CreateVote> createState() => _CreateVoteState();
}

class _CreateVoteState extends State<CreateVote> {
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();
  final List<TextEditingController> _optionControllers = [
    TextEditingController(),
    TextEditingController(),
  ];

  File? _imageFile;
  bool _saving = false;

  Future<String?> _uploadImageIfPossible() async {
    if (_imageFile == null) {
      return null;
    }

    try {
      return await StorageServices()
          .uploadImage(_imageFile!, 'votes')
          .timeout(const Duration(seconds: 45));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Image upload failed. Saving vote without image.\n$e',
              style: GoogleFonts.poppins(),
            ),
          ),
        );
      }
      return null;
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    for (final c in _optionControllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) setState(() => _imageFile = File(picked.path));
  }

  void _addOption() {
    setState(() => _optionControllers.add(TextEditingController()));
  }

  void _removeOption(int index) {
    if (_optionControllers.length <= 2) return;
    setState(() {
      _optionControllers[index].dispose();
      _optionControllers.removeAt(index);
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final imageUrl = await _uploadImageIfPossible();

      final options =
          _optionControllers.map((c) => c.text.trim()).toList();
      final voteCounts = <String, int>{
        for (int i = 0; i < options.length; i++) '$i': 0
      };

      final vote = VoteModel(
        question: _questionController.text.trim(),
        options: options,
        imageUrl: imageUrl,
        voteCounts: voteCounts,
      );
      await VoteServices()
          .createVote(vote)
          .timeout(const Duration(seconds: 15));
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString(), style: GoogleFonts.poppins())),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;

    return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: const Color(0xFFD32F2F),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text('Create Vote',
              style: GoogleFonts.poppins(
                  color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: isDark ? 0.15 : 1.0,
              child: Image.asset(
                'assets/images/paw pattern 1.png',
                fit: BoxFit.cover,
                color: isDark ? Colors.black : null,
                colorBlendMode: isDark ? BlendMode.darken : null,
              ),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image picker
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white10 : Colors.grey[200],
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: isDark
                                ? Colors.white24
                                : Colors.grey.shade300),
                      ),
                      child: _imageFile != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child:
                                  Image.file(_imageFile!, fit: BoxFit.cover),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate_outlined,
                                    size: 40,
                                    color: isDark
                                        ? Colors.white38
                                        : Colors.grey),
                                const SizedBox(height: 8),
                                Text('Tap to add image',
                                    style: GoogleFonts.poppins(
                                        color: isDark
                                            ? Colors.white38
                                            : Colors.grey,
                                        fontSize: 13)),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Question
                  Text('Question',
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: textColor)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _questionController,
                    style: GoogleFonts.poppins(fontSize: 14, color: textColor),
                    decoration: _inputDecoration('Enter your question', isDark),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 20),

                  // Options
                  Text('Options',
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: textColor)),
                  const SizedBox(height: 10),
                  ...List.generate(_optionControllers.length, (i) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: const Color(0xFFD32F2F),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              String.fromCharCode(65 + i),
                              style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              controller: _optionControllers[i],
                              style: GoogleFonts.poppins(
                                  fontSize: 13, color: textColor),
                              decoration:
                                  _inputDecoration('Option ${i + 1}', isDark),
                              validator: (v) =>
                                  (v == null || v.trim().isEmpty)
                                      ? 'Required'
                                      : null,
                            ),
                          ),
                          if (_optionControllers.length > 2) ...[
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () => _removeOption(i),
                              child: const Icon(Icons.remove_circle_outline,
                                  color: Color(0xFFD32F2F), size: 22),
                            ),
                          ],
                        ],
                      ),
                    );
                  }),

                  TextButton.icon(
                    onPressed: _addOption,
                    icon: const Icon(Icons.add, color: Color(0xFFD32F2F)),
                    label: Text('Add Option',
                        style: GoogleFonts.poppins(
                            color: const Color(0xFFD32F2F),
                            fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD32F2F),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: _saving
                          ? const CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2)
                          : Text('Create Vote',
                              style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        ),
      );
  }

  InputDecoration _inputDecoration(String hint, bool isDark) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(color: Colors.grey, fontSize: 13),
      filled: true,
      fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide:
            BorderSide(color: isDark ? Colors.white24 : Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide:
            BorderSide(color: isDark ? Colors.white24 : Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFD32F2F)),
      ),
    );
  }
}
