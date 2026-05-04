import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../backend/models/event_model.dart';
import '../../backend/services/event_services.dart';
import '../../backend/services/user_services.dart';
import '../homepage/event.dart';

class GroupProfile extends StatefulWidget {
  const GroupProfile({super.key});

  @override
  State<GroupProfile> createState() => _GroupProfileState();
}

class _GroupProfileState extends State<GroupProfile> {
  final Color themeRed = const Color(0xFFD32F2F);

  List<EventModel> _events = [];
  Set<String> _favorites = {};
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final results = await Future.wait([
        EventServices().getAllEvents(),
        UserServices().getFavorites(),
      ]);
      if (!mounted) return;
      setState(() {
        _events = results[0] as List<EventModel>;
        _favorites = (results[1] as List<String>).toSet();
        _loading = false;
      });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _toggleFavorite(EventModel event) async {
    final id = event.docId;
    if (id == null) return;
    final nowFav = !_favorites.contains(id);
    setState(() {
      if (nowFav) { _favorites.add(id); } else { _favorites.remove(id); }
    });
    try {
      if (nowFav) {
        await UserServices().addFavorite(id);
      } else {
        await UserServices().removeFavorite(id);
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          if (nowFav) { _favorites.remove(id); } else { _favorites.add(id); }
        });
      }
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
          // 1. DYNAMIC BACKGROUND LAYER
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

          // 2. Scrollable content
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back,
                              color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "Group Profile",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.more_vert,
                              color: Colors.white),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 50)),

              // 3. Main content card
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
                          width: 1,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 65, bottom: 30),
                        child: Column(
                          children: [
                            Text(
                              "Business group",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 45),
                              child: Text(
                                "Lorem ipsum dolor sit amet consectetur. Cras elit volutpat morbi mauris tincidunt lacus.",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  color: isDark
                                      ? Colors.white70
                                      : Colors.black54,
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 10),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? themeRed.withOpacity(0.15)
                                    : const Color(0xFFFDE8E8),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                "14K Members",
                                style: GoogleFonts.poppins(
                                  color: isDark
                                      ? const Color(0xFFE57373)
                                      : themeRed,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),

                            const SizedBox(height: 30),

                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Group Events",
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: textColor,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  _buildEventsSection(
                                      isDark, surfaceColor, textColor),
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

  Widget _buildEventsSection(
      bool isDark, Color surfaceColor, Color? textColor) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(
            child: CircularProgressIndicator(color: Color(0xFFD32F2F))),
      );
    }
    if (_error != null) {
      return Center(
        child: Column(
          children: [
            Text('Failed to load events',
                style: GoogleFonts.poppins(color: Colors.grey)),
            TextButton(
              onPressed: _load,
              child: Text('Retry',
                  style: GoogleFonts.poppins(
                      color: const Color(0xFFD32F2F))),
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
                  style: GoogleFonts.poppins(
                      color: Colors.grey, fontSize: 13)),
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

  Widget _buildEventCard(EventModel event, bool isDark, Color surfaceColor,
      Color? textColor) {
    final isFav = _favorites.contains(event.docId ?? '');

    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (_) => Event(event: event, initialIsFav: isFav),
          ),
        );
        if (result != null && mounted && event.docId != null) {
          setState(() {
            if (result) {
              _favorites.add(event.docId!);
            } else {
              _favorites.remove(event.docId!);
            }
          });
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.grey.shade300,
            width: 1,
          ),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: (event.imageUrl != null && event.imageUrl!.isNotEmpty)
                      ? Image.network(event.imageUrl!,
                          height: 160,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Image.asset(
                              'assets/images/features.png',
                              height: 160,
                              width: double.infinity,
                              fit: BoxFit.cover))
                      : Image.asset('assets/images/features.png',
                          height: 160,
                          width: double.infinity,
                          fit: BoxFit.cover),
                ),
                Positioned(
                  top: 5,
                  right: 5,
                  child: GestureDetector(
                    onTap: () => _toggleFavorite(event),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.black26,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border,
                        color: isFav ? themeRed : Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              event.title ?? 'Event',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: textColor,
              ),
            ),
            const SizedBox(height: 10),
            if (event.date != null && event.date!.isNotEmpty)
              _iconRow(
                  Icons.calendar_today_outlined,
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
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  "Add to my calendar",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: isDark ? Colors.white54 : Colors.black54,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
