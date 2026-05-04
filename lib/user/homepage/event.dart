import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../backend/models/event_model.dart';
import '../../backend/services/user_services.dart';

class Event extends StatefulWidget {
  final EventModel? event;
  final bool initialIsFav;

  const Event({super.key, required this.event, this.initialIsFav = false});

  @override
  State<Event> createState() => _EventState();
}

class _EventState extends State<Event> {
  late bool _isFav;

  @override
  void initState() {
    super.initState();
    _isFav = widget.initialIsFav;
  }

  Future<void> _toggleFav() async {
    final id = widget.event?.docId;
    if (id == null) return;
    final nowFav = !_isFav;
    setState(() => _isFav = nowFav);
    try {
      if (nowFav) {
        await UserServices().addFavorite(id);
      } else {
        await UserServices().removeFavorite(id);
      }
    } catch (_) {
      if (mounted) setState(() => _isFav = !nowFav);
    }
  }

  @override
  Widget build(BuildContext context) {
    final event = widget.event;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          // ── Image header ──
          Stack(
            children: [
              Container(
                height: 260,
                width: double.infinity,
                color: isDark ? Colors.grey[900] : Colors.grey[200],
                child: (event?.imageUrl != null && event!.imageUrl!.isNotEmpty)
                    ? Image.network(
                        event.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Image.asset(
                          'assets/images/home1_person.png',
                          fit: BoxFit.cover,
                        ),
                      )
                    : Image.asset(
                        'assets/images/home1_person.png',
                        fit: BoxFit.cover,
                      ),
              ),
              // Back button
              Positioned(
                top: MediaQuery.of(context).padding.top + 8,
                left: 12,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context, _isFav),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.35),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_back,
                        color: Colors.white, size: 22),
                  ),
                ),
              ),
              // Favorite button
              Positioned(
                top: MediaQuery.of(context).padding.top + 8,
                right: 12,
                child: GestureDetector(
                  onTap: _toggleFav,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.35),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isFav ? Icons.favorite : Icons.favorite_border,
                      color: _isFav ? const Color(0xFFD32F2F) : Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ── Details ──
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    event?.title ?? 'Event',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Date & Time
                  if ((event?.date != null && event!.date!.isNotEmpty) ||
                      (event?.time != null && event!.time!.isNotEmpty))
                    _infoRow(
                      Icons.calendar_today_outlined,
                      [event?.date, event?.time]
                          .where((s) => s != null && s!.isNotEmpty)
                          .join('  ·  '),
                      textColor,
                      isDark,
                    ),

                  // Location
                  if (event?.location != null && event!.location!.isNotEmpty)
                    _infoRow(
                      Icons.location_on_outlined,
                      event.location!,
                      textColor,
                      isDark,
                    ),

                  const SizedBox(height: 20),

                  // Detail
                  if (event?.detail != null && event!.detail!.isNotEmpty) ...[
                    Text(
                      'About',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      event.detail!,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: isDark ? Colors.white70 : Colors.black87,
                        height: 1.6,
                      ),
                    ),
                  ],

                  const SizedBox(height: 30),

                  // Add to calendar button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD32F2F),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: Text(
                        'Add to my calendar',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
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

  Widget _infoRow(
      IconData icon, String text, Color? textColor, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFFD32F2F), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
