import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../backend/models/event_model.dart';
import '../../backend/services/admin_favorites_service.dart';
import '../../backend/services/event_services.dart';
import '../../user/homepage/event.dart';

class AdminFavorites extends StatefulWidget {
  const AdminFavorites({super.key});

  @override
  State<AdminFavorites> createState() => _AdminFavoritesState();
}

class _AdminFavoritesState extends State<AdminFavorites> {
  List<EventModel> _allEvents = [];
  Set<String> _favIds = {};
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
        AdminFavoritesService().getFavorites(),
      ]);
      if (!mounted) return;
      setState(() {
        _allEvents = results[0] as List<EventModel>;
        _favIds = (results[1] as List<String>).toSet();
        _loading = false;
      });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _removeFavorite(EventModel event) async {
    final id = event.docId;
    if (id == null) return;
    setState(() => _favIds.remove(id));
    try {
      await AdminFavoritesService().removeFavorite(id);
    } catch (_) {
      // Revert on error
      if (mounted) setState(() => _favIds.add(id));
    }
  }

  List<EventModel> get _favoriteEvents =>
      _allEvents.where((e) => _favIds.contains(e.docId ?? '')).toList();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final surfaceColor = Theme.of(context).colorScheme.surface;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Text(
                'Favourite',
                style: GoogleFonts.poppins(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ),
            Expanded(child: _buildBody(isDark, surfaceColor, textColor)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(bool isDark, Color surfaceColor, Color? textColor) {
    if (_loading) {
      return const Center(
          child: CircularProgressIndicator(color: Color(0xFFD32F2F)));
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off_outlined,
                size: 48, color: Colors.grey.withOpacity(0.5)),
            const SizedBox(height: 12),
            Text('Failed to load favorites',
                style: GoogleFonts.poppins(color: Colors.grey)),
            TextButton(
              onPressed: _load,
              child: Text('Retry',
                  style: GoogleFonts.poppins(color: const Color(0xFFD32F2F))),
            ),
          ],
        ),
      );
    }

    final favs = _favoriteEvents;
    if (favs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border,
                size: 80, color: isDark ? Colors.white10 : Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No favourite events yet',
              style: GoogleFonts.poppins(
                fontSize: 18,
                color: isDark ? Colors.white38 : Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Tap the heart on any event to save it here.',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: isDark ? Colors.white30 : Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: const Color(0xFFD32F2F),
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics()),
        itemCount: favs.length,
        itemBuilder: (context, index) =>
            _buildFavoriteCard(favs[index], isDark, surfaceColor, textColor),
      ),
    );
  }

  Widget _buildFavoriteCard(EventModel event, bool isDark, Color surfaceColor,
      Color? textColor) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => Event(event: event, initialIsFav: true),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isDark ? Colors.white12 : Colors.grey.shade200),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                  child: (event.imageUrl != null && event.imageUrl!.isNotEmpty)
                      ? Image.network(event.imageUrl!,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Image.asset(
                              'assets/images/features.png',
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover))
                      : Image.asset('assets/images/features.png',
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover),
                ),
                Positioned(
                  top: 15,
                  right: 15,
                  child: GestureDetector(
                    onTap: () => _removeFavorite(event),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.black26,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.favorite,
                          color: Color(0xFFD32F2F), size: 24),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title ?? 'Event',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (event.date != null && event.date!.isNotEmpty)
                    Row(children: [
                      Icon(Icons.calendar_today_outlined,
                          size: 16,
                          color: isDark ? Colors.white70 : Colors.black87),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          [event.date, event.time]
                              .where((s) => s != null && s.isNotEmpty)
                              .join(' · '),
                          style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: isDark ? Colors.white60 : Colors.black87),
                        ),
                      ),
                    ]),
                  if (event.location != null && event.location!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(children: [
                      Icon(Icons.location_on_outlined,
                          size: 16,
                          color: isDark ? Colors.white70 : Colors.black87),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          event.location!,
                          style: GoogleFonts.poppins(
                              fontSize: 13,
                              color:
                                  isDark ? Colors.white60 : Colors.black87),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ]),
                  ],
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD32F2F),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text('Add to my calendar',
                          style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
