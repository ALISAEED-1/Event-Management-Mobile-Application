import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../backend/models/event_model.dart';
import '../../backend/services/event_services.dart';

class EditEvent extends StatefulWidget {
  final EventModel event;
  const EditEvent({super.key, required this.event});

  @override
  State<EditEvent> createState() => _EditEventState();
}

class _EditEventState extends State<EditEvent> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _locationController;
  late final TextEditingController _detailController;

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.event.title ?? '');
    _locationController =
        TextEditingController(text: widget.event.location ?? '');
    _detailController =
        TextEditingController(text: widget.event.detail ?? '');

    // Parse stored date "M/D/YYYY"
    final dateStr = widget.event.date;
    if (dateStr != null && dateStr.isNotEmpty) {
      final parts = dateStr.split('/');
      if (parts.length == 3) {
        _selectedDate = DateTime(
          int.tryParse(parts[2]) ?? DateTime.now().year,
          int.tryParse(parts[0]) ?? 1,
          int.tryParse(parts[1]) ?? 1,
        );
      }
    }

    // Parse stored time "H:MM AM/PM"
    final timeStr = widget.event.time;
    if (timeStr != null && timeStr.isNotEmpty) {
      final parts = timeStr.split(' ');
      if (parts.length == 2) {
        final hm = parts[0].split(':');
        if (hm.length == 2) {
          int hour = int.tryParse(hm[0]) ?? 0;
          final minute = int.tryParse(hm[1]) ?? 0;
          final isPm = parts[1].toUpperCase() == 'PM';
          if (isPm && hour != 12) hour += 12;
          if (!isPm && hour == 12) hour = 0;
          _selectedTime = TimeOfDay(hour: hour, minute: minute);
        }
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _detailController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(2020),
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

  String _formatDate(DateTime d) => '${d.month}/${d.day}/${d.year}';

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
      final updated = EventModel(
        docId: widget.event.docId,
        title: _titleController.text.trim(),
        date: _selectedDate != null ? _formatDate(_selectedDate!) : widget.event.date,
        time: _selectedTime != null ? _formatTime(_selectedTime!) : widget.event.time,
        location: _locationController.text.trim().isEmpty
            ? null
            : _locationController.text.trim(),
        detail: _detailController.text.trim().isEmpty
            ? null
            : _detailController.text.trim(),
        imageUrl: widget.event.imageUrl,
        createdAt: widget.event.createdAt,
      );
      await EventServices().updateEvent(updated);
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
        title: Text('Edit Event',
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
                  _buildField('Title', _titleController, textColor, isDark,
                      required: true),
                  const SizedBox(height: 15),

                  _buildTapField(
                    label: 'Date',
                    value: _selectedDate != null
                        ? _formatDate(_selectedDate!)
                        : widget.event.date,
                    hint: 'Select date',
                    icon: Icons.calendar_today_outlined,
                    onTap: _pickDate,
                    isDark: isDark,
                    textColor: textColor,
                  ),
                  const SizedBox(height: 15),

                  _buildTapField(
                    label: 'Time',
                    value: _selectedTime != null
                        ? _formatTime(_selectedTime!)
                        : widget.event.time,
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

  Widget _buildField(String label, TextEditingController controller,
      Color? textColor, bool isDark,
      {bool required = false, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600, fontSize: 13, color: textColor)),
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
