import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../backend/models/event_model.dart';
import '../../backend/services/event_services.dart';
import '../../backend/services/user_services.dart';
import 'event.dart';

class Features extends StatefulWidget {
  const Features({super.key});

  @override
  State<Features> createState() => _FeaturesState();
}

class _FeaturesState extends State<Features> {
  List<EventModel> _allEvents = [];
  Set<String> _favorites = {};
  bool _loading = true;
  String? _error;

  // Filter state
  String? selectedCity;
  String? selectedState;
  String? selectedGroup;
  String? selectedCategory;

  final List<String> countries = ['USA', 'Canada', 'UK', 'Pakistan', 'Germany'];
  final List<String> statesList = ['New York', 'California', 'London', 'Punjab', 'Berlin'];
  final List<String> groups = ['Community A', 'Tech Group', 'Study Circle'];

  // ── Computed filtered list ──────────────────────────────────────────────────
  List<EventModel> get _filteredEvents {
    return _allEvents.where((e) {
      final loc = (e.location ?? '').toLowerCase();
      final title = (e.title ?? '').toLowerCase();
      final detail = (e.detail ?? '').toLowerCase();

      if (selectedCity != null &&
          !loc.contains(selectedCity!.toLowerCase())) return false;
      if (selectedState != null &&
          !loc.contains(selectedState!.toLowerCase())) return false;
      if (selectedCategory != null &&
          !title.contains(selectedCategory!.toLowerCase()) &&
          !detail.contains(selectedCategory!.toLowerCase())) return false;
      return true;
    }).toList();
  }

  bool get _hasActiveFilter =>
      selectedCity != null ||
      selectedState != null ||
      selectedGroup != null ||
      selectedCategory != null;
  // ───────────────────────────────────────────────────────────────────────────

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
      if (mounted) {
        setState(() {
          _allEvents = results[0] as List<EventModel>;
          _favorites = (results[1] as List<String>).toSet();
          _loading = false;
        });
      }
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

  void _showFilterPanel() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;

    // Local copies so dialog changes don't affect list until Apply is tapped
    String? tempCity = selectedCity;
    String? tempState = selectedState;
    String? tempGroup = selectedGroup;
    String? tempCategory = selectedCategory;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: isDark ? Colors.white12 : Colors.transparent),
        ),
        child: StatefulBuilder(
          builder: (context, setModalState) => SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(Icons.close, color: textColor, size: 24),
                        ),
                      ),
                      Text('Filter Events',
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: textColor)),
                    ],
                  ),
                  const SizedBox(height: 25),

                  _buildFilterLabel('City', textColor),
                  _buildDropdown(countries, tempCity, 'Select City', isDark,
                      (val) => setModalState(() => tempCity = val)),

                  const SizedBox(height: 15),
                  _buildFilterLabel('State', textColor),
                  _buildDropdown(statesList, tempState, 'Select State', isDark,
                      (val) => setModalState(() => tempState = val)),

                  const SizedBox(height: 15),
                  _buildFilterLabel('Groups', textColor),
                  _buildDropdown(groups, tempGroup, 'Group', isDark,
                      (val) => setModalState(() => tempGroup = val)),

                  const SizedBox(height: 25),
                  _buildFilterLabel('Category', textColor),
                  Wrap(
                    spacing: 10, runSpacing: 10,
                    children: [
                      _categoryButton('Religious', Icons.nights_stay_outlined, tempCategory, isDark,
                          (val) => setModalState(() => tempCategory = val)),
                      _categoryButton('Business', Icons.business_outlined, tempCategory, isDark,
                          (val) => setModalState(() => tempCategory = val)),
                      _categoryButton('Sports', Icons.directions_run, tempCategory, isDark,
                          (val) => setModalState(() => tempCategory = val)),
                      _categoryButton('Education', Icons.school_outlined, tempCategory, isDark,
                          (val) => setModalState(() => tempCategory = val)),
                      _categoryButton('Community', Icons.people_outline, tempCategory, isDark,
                          (val) => setModalState(() => tempCategory = val)),
                    ],
                  ),

                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setModalState(() {
                              tempCity = null;
                              tempState = null;
                              tempGroup = null;
                              tempCategory = null;
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                                color: isDark ? Colors.white24 : Colors.grey),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          child: Text('Clear Filter',
                              style: GoogleFonts.poppins(color: textColor)),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            // Apply filter values to parent state → triggers rebuild
                            setState(() {
                              selectedCity = tempCity;
                              selectedState = tempState;
                              selectedGroup = tempGroup;
                              selectedCategory = tempCategory;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD32F2F),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          child: Text('Apply Filter',
                              style:
                                  GoogleFonts.poppins(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _categoryButton(String label, IconData icon, String? currentCat,
      bool isDark, ValueChanged<String?> onTap) {
    final isSelected = currentCat == label;
    return GestureDetector(
      onTap: () => onTap(isSelected ? null : label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFD32F2F) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: isSelected
                  ? Colors.transparent
                  : (isDark ? Colors.white24 : Colors.grey.shade300)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 18,
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.white70 : Colors.black54)),
            const SizedBox(width: 6),
            Text(label,
                style: GoogleFonts.poppins(
                    color: isSelected
                        ? Colors.white
                        : (isDark ? Colors.white70 : Colors.black54),
                    fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(List<String> items, String? currentVal, String hint,
      bool isDark, Function(String?) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 45,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: isDark ? Colors.white24 : Colors.grey.shade300)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          dropdownColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          value: currentVal,
          hint: Text(hint,
              style: GoogleFonts.poppins(color: Colors.grey, fontSize: 13)),
          isExpanded: true,
          items: items
              .map((val) => DropdownMenuItem(
                    value: val,
                    child: Text(val,
                        style: TextStyle(
                            color: isDark ? Colors.white : Colors.black)),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildFilterLabel(String text, Color? textColor) => Padding(
        padding: const EdgeInsets.only(bottom: 5),
        child: Text(text,
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600, fontSize: 13, color: textColor)),
      );

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
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Features',
                      style: GoogleFonts.poppins(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 24)),
                  Row(
                    children: [
                      // Active filter indicator
                      if (_hasActiveFilter)
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD32F2F),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Filtered',
                                  style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600)),
                              const SizedBox(width: 4),
                              GestureDetector(
                                onTap: () => setState(() {
                                  selectedCity = null;
                                  selectedState = null;
                                  selectedGroup = null;
                                  selectedCategory = null;
                                }),
                                child: const Icon(Icons.close,
                                    color: Colors.white, size: 14),
                              ),
                            ],
                          ),
                        ),
                      Container(
                        decoration: BoxDecoration(
                            color: isDark ? Colors.white10 : Colors.grey[100],
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: isDark
                                    ? Colors.white12
                                    : Colors.grey.shade300)),
                        child: IconButton(
                          onPressed: _showFilterPanel,
                          icon: Icon(Icons.tune,
                              color: isDark ? Colors.white : Colors.black,
                              size: 20),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Body
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
            Text('Failed to load events',
                style: GoogleFonts.poppins(color: Colors.grey)),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                child: Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12),
                ),
              ),
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

    final events = _filteredEvents;

    if (events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_outlined,
                size: 64, color: Colors.grey.withOpacity(0.4)),
            const SizedBox(height: 16),
            Text(
              _hasActiveFilter
                  ? 'No events match your filters.'
                  : 'No events yet.',
              style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
            ),
            if (_hasActiveFilter) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => setState(() {
                  selectedCity = null;
                  selectedState = null;
                  selectedGroup = null;
                  selectedCategory = null;
                }),
                child: Text('Clear Filters',
                    style: GoogleFonts.poppins(
                        color: const Color(0xFFD32F2F))),
              ),
            ],
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      physics: const BouncingScrollPhysics(),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        final isFav = _favorites.contains(event.docId ?? '');
        return _buildFeatureCard(
          event: event,
          isFav: isFav,
          isDark: isDark,
          surfaceColor: surfaceColor,
          textColor: textColor,
        );
      },
    );
  }

  Widget _buildFeatureCard({
    required EventModel event,
    required bool isFav,
    required bool isDark,
    required Color surfaceColor,
    required Color? textColor,
  }) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (_) => Event(event: event, initialIsFav: isFav),
          ),
        );
        if (result != null && mounted) {
          final id = event.docId;
          if (id != null) {
            setState(() {
              if (result) { _favorites.add(id); } else { _favorites.remove(id); }
            });
          }
        }
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
                  offset: const Offset(0, 4))
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
                          height: 200, width: double.infinity, fit: BoxFit.cover),
                ),
                Positioned(
                  top: 15,
                  right: 15,
                  child: GestureDetector(
                    onTap: () => _toggleFavorite(event),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                          color: Colors.black26, shape: BoxShape.circle),
                      child: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border,
                        color: isFav ? const Color(0xFFD32F2F) : Colors.white,
                        size: 24,
                      ),
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
                  Text(event.title ?? 'Event',
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: textColor)),
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
                        child: Text(event.location!,
                            style: GoogleFonts.poppins(
                                fontSize: 13,
                                color:
                                    isDark ? Colors.white60 : Colors.black87),
                            overflow: TextOverflow.ellipsis),
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
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
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
