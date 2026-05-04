import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../backend/models/vote_model.dart';
import '../../backend/services/vote_services.dart';

class EditVote extends StatefulWidget {
  final VoteModel vote;
  const EditVote({super.key, required this.vote});

  @override
  State<EditVote> createState() => _EditVoteState();
}

class _EditVoteState extends State<EditVote> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _questionController;
  late final List<TextEditingController> _optionControllers;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _questionController =
        TextEditingController(text: widget.vote.question ?? '');
    _optionControllers = (widget.vote.options ?? ['', ''])
        .map((o) => TextEditingController(text: o))
        .toList();
    // Ensure at least 2 options
    while (_optionControllers.length < 2) {
      _optionControllers.add(TextEditingController());
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
      final options =
          _optionControllers.map((c) => c.text.trim()).toList();

      // Preserve existing vote counts; zero-fill new options
      final existingCounts =
          Map<String, int>.from(widget.vote.voteCounts ?? {});
      final updatedCounts = <String, int>{
        for (int i = 0; i < options.length; i++)
          '$i': existingCounts['$i'] ?? 0,
      };

      final updated = VoteModel(
        docId: widget.vote.docId,
        question: _questionController.text.trim(),
        options: options,
        imageUrl: widget.vote.imageUrl,
        createdAt: widget.vote.createdAt,
        voteCounts: updatedCounts,
      );
      await VoteServices().updateVote(updated);
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
        title: Text('Edit Vote',
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
                  Text('Question',
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: textColor)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _questionController,
                    style: GoogleFonts.poppins(fontSize: 14, color: textColor),
                    decoration:
                        _inputDecoration('Enter your question', isDark),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 20),

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
                          : Text('Save Changes',
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
