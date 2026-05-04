import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../backend/models/event_model.dart';
import '../../backend/services/event_services.dart';
import '../../backend/services/user_services.dart';
import 'event.dart';

class Favorite extends StatefulWidget {
  const Favorite({super.key});

  @override
  State<Favorite> createState() => _FavoriteState();
}

class _FavoriteState extends State<Favorite> {
  Future<List<EventModel>>? _favEventsFuture;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final future = _fetchFavoriteEvents();
    setState(() {
      _favEventsFuture = future;
    });
  }

  Future<List<EventModel>> _fetchFavoriteEvents() async {
    final favIds = await UserServices().getFavorites();
    if (favIds.isEmpty) return [];
    final events = await Future.wait(
      favIds.map((id) => EventServices().getEventById(id)),
    );
    return events.whereType<EventModel>().toList();
  }

  Future<void> _removeFavorite(EventModel event) async {
    if (event.docId == null) return;
    await UserServices().removeFavorite(event.docId!);
    if (mounted) _load(); // Refresh list
  }

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
                'Favourites',
                style: GoogleFonts.poppins(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                color: const Color(0xFFD32F2F),
                onRefresh: () async => _load(),
                child: FutureBuilder<List<EventModel>>(
                  future: _favEventsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                            color: Color(0xFFD32F2F)),
                      );
                    }
                    final events = snapshot.data ?? [];
                    if (events.isEmpty) {
                      return ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(
                            height: 400,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.favorite_border,
                                      size: 80,
                                      color: isDark
                                          ? Colors.white10
                                          : Colors.grey[300]),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No favourite events yet.',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      color: isDark
                                          ? Colors.white38
                                          : Colors.grey,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
                      physics: const BouncingScrollPhysics(),
                      itemCount: events.length,
                      itemBuilder: (context, index) => _buildFavoriteCard(
                        events[index],
                        isDark,
                        surfaceColor,
                        textColor,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoriteCard(
    EventModel event,
    bool isDark,
    Color surfaceColor,
    Color? textColor,
  ) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (_) => Event(event: event, initialIsFav: true),
          ),
        );
        // If user un-favorited from the detail page, refresh our list
        if (result == false && mounted) _load();
      },
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
                  offset: const Offset(0, 4)),
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
                  child: (event.imageUrl != null &&
                          event.imageUrl!.isNotEmpty)
                      ? Image.network(
                          event.imageUrl!,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Image.asset(
                              'assets/images/features.png',
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover),
                        )
                      : Image.asset(
                          'assets/images/features.png',
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                ),
                // Red heart — tap to un-favourite
                Positioned(
                  top: 15,
                  right: 15,
                  child: GestureDetector(
                    onTap: () => _removeFavorite(event),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                          color: Colors.black26, shape: BoxShape.circle),
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
                        color: textColor),
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
                              color: isDark
                                  ? Colors.white60
                                  : Colors.black87),
                        ),
                      ),
                    ]),
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
                      child: Text(
                        'Add to my calendar',
                        style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600),
                      ),
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
