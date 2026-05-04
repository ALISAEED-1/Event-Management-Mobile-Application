import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../backend/models/event_model.dart';
import '../../backend/services/event_services.dart';
import '../../user/homepage/event.dart';
import '../homepage/create_event.dart';
import '../homepage/create_vote.dart';

class AdminGroupProfile extends StatefulWidget {
  const AdminGroupProfile({super.key});

  @override
  State<AdminGroupProfile> createState() => _AdminGroupProfileState();
}

class _AdminGroupProfileState extends State<AdminGroupProfile> {
  final Color themeRed = const Color(0xFFD32F2F);

  List<EventModel> _events = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() { _loading = true; _error = null; });
    try {
      final events = await EventServices().getAllEvents();
      if (mounted) setState(() { _events = events; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final scaffoldBg = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: Stack(
        children: [
          // Background
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF8B1D1D) : themeRed,
              image: DecorationImage(
                image: const AssetImage("assets/images/paw patter white.png"),
                opacity: isDark ? 1 : 0.8,
                repeat: ImageRepeat.repeat,
                alignment: Alignment.topLeft,
                colorFilter: ColorFilter.mode(
                  isDark ? Colors.black : Colors.white,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),

          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Top bar
              SliverToBoxAdapter(
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 4),
                        Text("Group Profile",
                            style: GoogleFonts.poppins(
                                color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.more_vert, color: Colors.white),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 50)),

              // Main content card
              SliverToBoxAdapter(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(35),
                          topRight: Radius.circular(35),
                        ),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withOpacity(0.1)
                              : Colors.grey.shade200,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 65, bottom: 30),
                        child: Column(
                          children: [
                            Text("Business group",
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22,
                                    color: textColor)),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 45),
                              child: Text(
                                "Lorem ipsum dolor sit amet consectetur. Cras elit volutpat morbi mauris tincidunt lacus.",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                    color: isDark ? Colors.white70 : Colors.black54,
                                    fontSize: 13,
                                    height: 1.4),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? themeRed.withOpacity(0.15)
                                    : const Color(0xFFFDE8E8),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text("14K Members",
                                  style: GoogleFonts.poppins(
                                      color: isDark
                                          ? const Color(0xFFE57373)
                                          : themeRed,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14)),
                            ),
                            const SizedBox(height: 24),

                            // Admin action buttons
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) => const CreateEvent()),
                                      ).then((_) { if (mounted) _loadEvents(); }),
                                      icon: const Icon(Icons.event_outlined,
                                          size: 18, color: Colors.white),
                                      label: Text("Create Event",
                                          style: GoogleFonts.poppins(
                                              color: Colors.white,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600)),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: themeRed,
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12)),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) => const CreateVote()),
                                      ),
                                      icon: const Icon(Icons.how_to_vote_outlined,
                                          size: 18, color: Colors.white),
                                      label: Text("Create Vote",
                                          style: GoogleFonts.poppins(
                                              color: Colors.white,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600)),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: themeRed,
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 30),

                            // Group Events section
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Group Events",
                                      style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: textColor)),
                                  const SizedBox(height: 20),
                                  _buildEventsSection(isDark, surfaceColor, textColor),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Profile avatar overlay
                    Positioned(
                      top: -50,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: surfaceColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withOpacity(0.1)
                                  : Colors.grey.shade200,
                            ),
                          ),
                          child: const CircleAvatar(
                            radius: 50,
                            backgroundImage:
                                AssetImage("assets/images/features.png"),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEventsSection(bool isDark, Color surfaceColor, Color? textColor) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: CircularProgressIndicator(color: Color(0xFFD32F2F))),
      );
    }
    if (_error != null) {
      return Center(
        child: Column(
          children: [
            Text('Failed to load events',
                style: GoogleFonts.poppins(color: Colors.grey)),
            TextButton(
              onPressed: _loadEvents,
              child: Text('Retry',
                  style: GoogleFonts.poppins(color: const Color(0xFFD32F2F))),
            ),
          ],
        ),
      );
    }
    if (_events.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.event_outlined,
                  size: 48, color: Colors.grey.withOpacity(0.4)),
              const SizedBox(height: 12),
              Text('No events yet.',
                  style: GoogleFonts.poppins(color: Colors.grey, fontSize: 13)),
            ],
          ),
        ),
      );
    }
    return Column(
      children: _events
          .map((e) => _buildEventCard(e, isDark, surfaceColor, textColor))
          .toList(),
    );
  }

  Widget _buildEventCard(
      EventModel event, bool isDark, Color surfaceColor, Color? textColor) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => Event(event: event)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.grey.shade300),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: (event.imageUrl != null && event.imageUrl!.isNotEmpty)
                  ? Image.network(event.imageUrl!,
                      height: 160, width: double.infinity, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Image.asset(
                          'assets/images/features.png',
                          height: 160, width: double.infinity, fit: BoxFit.cover))
                  : Image.asset('assets/images/features.png',
                      height: 160, width: double.infinity, fit: BoxFit.cover),
            ),
            const SizedBox(height: 12),
            Text(event.title ?? 'Event',
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold, fontSize: 14, color: textColor)),
            const SizedBox(height: 10),
            if (event.date != null && event.date!.isNotEmpty)
              _iconRow(Icons.calendar_today_outlined,
                  [event.date, event.time]
                      .where((s) => s != null && s.isNotEmpty)
                      .join(' · '),
                  isDark),
            if (event.location != null && event.location!.isNotEmpty) ...[
              const SizedBox(height: 6),
              _iconRow(Icons.location_on_outlined, event.location!, isDark),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeRed,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Text("Add to my calendar",
                    style: GoogleFonts.poppins(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconRow(IconData icon, String text, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 16, color: isDark ? Colors.white54 : Colors.black54),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text,
              style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: isDark ? Colors.white54 : Colors.black54),
              overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}
