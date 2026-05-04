import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../backend/models/event_model.dart';
import '../../backend/services/event_services.dart';
import '../../backend/services/storage_services.dart';

class CreateEvent extends StatefulWidget {
  const CreateEvent({super.key});

  @override
  State<CreateEvent> createState() => _CreateEventState();
}

class _CreateEventState extends State<CreateEvent> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _detailController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  File? _imageFile;
  bool _saving = false;

  Future<String?> _uploadImageIfPossible() async {
    if (_imageFile == null) {
      return null;
    }

    try {
      return await StorageServices()
          .uploadImage(_imageFile!, 'events')
          .timeout(const Duration(seconds: 45));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Image upload failed. Saving event without image.\n$e',
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
    _titleController.dispose();
    _locationController.dispose();
    _detailController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) setState(() => _imageFile = File(picked.path));
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFFD32F2F)),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFFD32F2F)),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  String _formatDate(DateTime d) =>
      '${d.month}/${d.day}/${d.year}';

  String _formatTime(TimeOfDay t) {
    final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final minute = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final imageUrl = await _uploadImageIfPossible();
      final event = EventModel(
        title: _titleController.text.trim(),
        date: _selectedDate != null ? _formatDate(_selectedDate!) : null,
        time: _selectedTime != null ? _formatTime(_selectedTime!) : null,
        location: _locationController.text.trim().isEmpty
            ? null
            : _locationController.text.trim(),
        detail: _detailController.text.trim().isEmpty
            ? null
            : _detailController.text.trim(),
        imageUrl: imageUrl,
      );
      await EventServices()
          .createEvent(event)
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
          title: Text('Create Event',
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
                            color: isDark ? Colors.white24 : Colors.grey.shade300),
                      ),
                      child: _imageFile != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.file(_imageFile!, fit: BoxFit.cover),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate_outlined,
                                    size: 40,
                                    color: isDark ? Colors.white38 : Colors.grey),
                                const SizedBox(height: 8),
                                Text('Tap to add image',
                                    style: GoogleFonts.poppins(
                                        color: isDark ? Colors.white38 : Colors.grey,
                                        fontSize: 13)),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  _buildField('Title', _titleController, textColor, isDark,
                      required: true),
                  const SizedBox(height: 15),

                  // Date picker
                  _buildTapField(
                    label: 'Date',
                    value: _selectedDate != null
                        ? _formatDate(_selectedDate!)
                        : null,
                    hint: 'Select date',
                    icon: Icons.calendar_today_outlined,
                    onTap: _pickDate,
                    isDark: isDark,
                    textColor: textColor,
                  ),
                  const SizedBox(height: 15),

                  // Time picker
                  _buildTapField(
                    label: 'Time',
                    value: _selectedTime != null
                        ? _formatTime(_selectedTime!)
                        : null,
                    hint: 'Select time',
                    icon: Icons.access_time_outlined,
                    onTap: _pickTime,
                    isDark: isDark,
                    textColor: textColor,
                  ),
                  const SizedBox(height: 15),

                  _buildField('Location', _locationController, textColor, isDark),
                  const SizedBox(height: 15),

                  _buildField('Details', _detailController, textColor, isDark,
                      maxLines: 4),
                  const SizedBox(height: 30),

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
                          : Text('Create Event',
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

  Widget _buildField(String label, TextEditingController controller,
      Color? textColor, bool isDark,
      {bool required = false, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: textColor)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: GoogleFonts.poppins(fontSize: 14, color: textColor),
          decoration: InputDecoration(
            hintText: label,
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
          ),
          validator: required
              ? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null
              : null,
        ),
      ],
    );
  }

  Widget _buildTapField({
    required String label,
    required String? value,
    required String hint,
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
    required Color? textColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600, fontSize: 13, color: textColor)),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: isDark ? Colors.white24 : Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Icon(icon, size: 18, color: Colors.grey),
                const SizedBox(width: 10),
                Text(
                  value ?? hint,
                  style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: value != null ? textColor : Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
