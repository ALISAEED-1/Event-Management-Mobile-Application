import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../backend/models/event_model.dart';
import '../../backend/services/event_services.dart';
import '../../backend/services/user_services.dart';
import '../../user/homepage/event.dart';
import 'edit_event.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool isCalendarView = true;

  Future<List<EventModel>>? _eventsFuture;
  Set<String> _favorites = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadEvents();
  }

  void _loadEvents() {
    final future = EventServices().getAllEvents();
    setState(() { _eventsFuture = future; });
    UserServices().getFavorites().then((favorites) {
      if (mounted) {
        setState(() {
          _favorites = favorites.toSet();
        });
      }
    });
  }

  Future<void> _toggleFavorite(EventModel event) async {
    final id = event.docId;
    if (id == null) return;
    final nowFav = !_favorites.contains(id);
    setState(() {
      if (nowFav) {
        _favorites.add(id);
      } else {
        _favorites.remove(id);
      }
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
          if (nowFav) {
            _favorites.remove(id);
          } else {
            _favorites.add(id);
          }
        });
      }
    }
  }

  String? selectedCity;
  String? selectedState;
  String? selectedGroup;
  String selectedCategory = "Business";

  final List<String> countries = [
    "USA", "Canada", "UK", "Pakistan", "Germany"
  ];
  final List<String> statesList = [
    "New York", "California", "London", "Punjab", "Berlin"
  ];
  final List<String> groups = [
    "Community A", "Tech Group", "Study Circle"
  ];

  // ── Delete confirmation ──
  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('Delete Event',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            content: Text('Are you sure you want to delete this event?',
                style: GoogleFonts.poppins()),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text('Cancel', style: GoogleFonts.poppins()),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text('Delete',
                    style: GoogleFonts.poppins(
                        color: const Color(0xFFD32F2F))),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showFilterPanel() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: surfaceColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.transparent,
            ),
          ),
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
              return SingleChildScrollView(
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
                              icon: Icon(Icons.close,
                                  color: textColor, size: 24),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ),
                          Text(
                            "Filter Events",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 25),
                      _buildFilterLabel("City", textColor),
                      _buildDropdown(countries, selectedCity, "Select City",
                          isDark, (val) {
                        setModalState(() => selectedCity = val);
                      }),
                      const SizedBox(height: 15),
                      _buildFilterLabel("State", textColor),
                      _buildDropdown(statesList, selectedState,
                          "Select State", isDark, (val) {
                        setModalState(() => selectedState = val);
                      }),
                      const SizedBox(height: 15),
                      _buildFilterLabel("Groups", textColor),
                      _buildDropdown(groups, selectedGroup, "Group",
                          isDark, (val) {
                        setModalState(() => selectedGroup = val);
                      }),
                      const SizedBox(height: 25),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _categoryButton("Religious",
                              Icons.nights_stay_outlined,
                              isDark, setModalState),
                          _categoryButton("Business",
                              Icons.business_outlined,
                              isDark, setModalState),
                          _categoryButton("Sports",
                              Icons.directions_run,
                              isDark, setModalState),
                          _categoryButton("Education",
                              Icons.school_outlined,
                              isDark, setModalState),
                          _categoryButton("Community",
                              Icons.people_outline,
                              isDark, setModalState),
                        ],
                      ),
                      const SizedBox(height: 30),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                setModalState(() {
                                  selectedCity = null;
                                  selectedState = null;
                                  selectedGroup = null;
                                  selectedCategory = "Business";
                                });
                              },
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14),
                                side: BorderSide(
                                    color: isDark
                                        ? Colors.white24
                                        : Colors.grey.shade400),
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(10)),
                              ),
                              child: Text("Clear Filter",
                                  style: GoogleFonts.poppins(
                                      color: textColor,
                                      fontWeight: FontWeight.w600)),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14),
                                backgroundColor:
                                    const Color(0xFFD32F2F),
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(10)),
                                elevation: 0,
                              ),
                              child: Text("Apply Filter",
                                  style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _categoryButton(String label, IconData icon, bool isDark,
      StateSetter setModalState) {
    bool isSelected = selectedCategory == label;
    return GestureDetector(
      onTap: () => setModalState(() => selectedCategory = label),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFD32F2F)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: isSelected
                  ? Colors.transparent
                  : (isDark
                      ? Colors.white24
                      : Colors.grey.shade300)),
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
            Text(
              label,
              style: GoogleFonts.poppins(
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.white70 : Colors.black54),
                fontSize: 13,
                fontWeight: isSelected
                    ? FontWeight.w500
                    : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(List<String> items, String? currentVal,
      String hint, bool isDark, Function(String?) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 45,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: isDark ? Colors.white24 : Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          dropdownColor:
              isDark ? const Color(0xFF1E1E1E) : Colors.white,
          value: currentVal,
          hint: Text(hint,
              style:
                  GoogleFonts.poppins(color: Colors.grey, fontSize: 13)),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down,
              color: Colors.grey),
          items: items.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value,
                  style: GoogleFonts.poppins(
                      fontSize: 13,
                      color:
                          isDark ? Colors.white : Colors.black)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildFilterLabel(String text, Color? textColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, left: 2),
      child: Text(text,
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: textColor)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final surfaceColor = Theme.of(context).colorScheme.surface;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: isDark ? 0.2 : 1.0,
                child: Image.asset(
                  "assets/images/paw pattern 1.png",
                  fit: BoxFit.cover,
                  color: isDark ? Colors.black : null,
                  colorBlendMode: isDark ? BlendMode.darken : null,
                ),
              ),
            ),
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMainHeader(textColor, isDark),
                  const SizedBox(height: 10),
                  _buildToggleSwitch(isDark),
                  const SizedBox(height: 15),
                  _buildCalendar(isDark, textColor),
                  const SizedBox(height: 20),

                  // ── Events via REST API ──
                  FutureBuilder<List<EventModel>>(
                    future: _eventsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Center(
                            child: CircularProgressIndicator(
                                color: Color(0xFFD32F2F)),
                          ),
                        );
                      }
                      if (snapshot.hasError) {
                        return Padding(
                          padding: const EdgeInsets.all(20),
                          child: Center(
                            child: Column(
                              children: [
                                Text('Failed to load events',
                                    style: GoogleFonts.poppins(
                                        color: Colors.grey)),
                                TextButton(
                                  onPressed: _loadEvents,
                                  child: Text('Retry',
                                      style: GoogleFonts.poppins(
                                          color:
                                              const Color(0xFFD32F2F))),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      final events = snapshot.data ?? [];
                      if (events.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 40, horizontal: 20),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(Icons.event_busy_outlined,
                                    size: 56,
                                    color: Colors.grey.withOpacity(0.4)),
                                const SizedBox(height: 12),
                                Text(
                                  "No events yet.\nGo to Community → + to create one.",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                      color: Colors.grey, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      return Column(
                        children: [
                          ...events.map((event) => _buildEventCard(
                                event: event,
                                isFav: _favorites.contains(event.docId ?? ''),
                                isDark: isDark,
                                surfaceColor: surfaceColor,
                                textColor: textColor,
                              )),
                          const SizedBox(height: 20),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainHeader(Color? textColor, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(25, 30, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Events",
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: textColor)),
          Container(
            decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.grey[100],
                shape: BoxShape.circle),
            child: IconButton(
              onPressed: _showFilterPanel,
              icon: Icon(Icons.tune,
                  color: isDark ? Colors.white : Colors.black87,
                  size: 22),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar(bool isDark, Color? textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: GoogleFonts.poppins(
              color: isDark ? Colors.white70 : Colors.black),
          weekendStyle: GoogleFonts.poppins(
              color: isDark ? Colors.white70 : Colors.black),
        ),
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          leftChevronIcon: Icon(Icons.chevron_left,
              color: isDark ? Colors.white : Colors.black),
          rightChevronIcon: Icon(Icons.chevron_right,
              color: isDark ? Colors.white : Colors.black),
          titleTextStyle: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: textColor),
        ),
        calendarStyle: CalendarStyle(
          defaultTextStyle: GoogleFonts.poppins(color: textColor),
          weekendTextStyle: GoogleFonts.poppins(color: textColor),
          outsideTextStyle:
              GoogleFonts.poppins(color: Colors.grey),
          todayDecoration: const BoxDecoration(
              color: Color(0xFFD32F2F), shape: BoxShape.circle),
          selectedDecoration: const BoxDecoration(
              color: Color(0xFFD32F2F), shape: BoxShape.circle),
        ),
      ),
    );
  }

  Widget _buildToggleSwitch(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 55,
      decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withOpacity(0.05)
              : const Color(0xFFF7F7F7),
          borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: [
          _toggleItem("Calendar View", isCalendarView, true, isDark),
          _toggleItem("List View", !isCalendarView, false, isDark),
        ],
      ),
    );
  }

  Widget _toggleItem(
      String label, bool active, bool isCal, bool isDark) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => isCalendarView = isCal),
        child: Container(
          margin: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: active
                ? const Color(0xFFD32F2F)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(label,
              style: GoogleFonts.poppins(
                  color: active ? Colors.white : Colors.grey,
                  fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }

  // ── Real event card from Firestore ──
  Widget _buildEventCard({
    required EventModel event,
    required bool isFav,
    required bool isDark,
    required Color surfaceColor,
    required Color? textColor,
  }) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => Event(event: event, initialIsFav: isFav),
        ),
      ),
      child: Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.grey.shade200),
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
            Row(
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: 50,
                        height: 50,
                        color: isDark
                            ? Colors.white10
                            : Colors.grey[200],
                        child: (event.imageUrl != null &&
                                event.imageUrl!.isNotEmpty)
                            ? Image.network(event.imageUrl!,
                                fit: BoxFit.cover)
                            : Image.asset(
                                "assets/images/home1_person.png"),
                      ),
                    ),
                    Positioned(
                      right: -2,
                      top: -2,
                      child: GestureDetector(
                        onTap: () => _toggleFavorite(event),
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.black26,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            color: isFav ? const Color(0xFFD32F2F) : Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title ?? 'Untitled Event',
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: textColor),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (event.date != null &&
                          event.date!.isNotEmpty)
                        Text(
                          "${event.date}${event.time != null && event.time!.isNotEmpty ? '  ${event.time}' : ''}",
                          style: GoogleFonts.poppins(
                              color: isDark
                                  ? Colors.white54
                                  : Colors.grey,
                              fontSize: 11),
                        ),
                    ],
                  ),
                ),
                // Admin menu: edit + delete
                PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'edit') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                EditEvent(event: event)),
                      ).then((_) { if (mounted) _loadEvents(); });
                    } else if (value == 'delete') {
                      final ok =
                          await _confirmDelete(context);
                      if (ok && event.docId != null) {
                        await EventServices()
                            .deleteEvent(event.docId!);
                        if (mounted) _loadEvents();
                      }
                    }
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(children: [
                        const Icon(Icons.edit_outlined, size: 18),
                        const SizedBox(width: 8),
                        Text('Edit', style: GoogleFonts.poppins()),
                      ]),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(children: [
                        const Icon(Icons.delete_outline,
                            size: 18, color: Color(0xFFD32F2F)),
                        const SizedBox(width: 8),
                        Text('Delete',
                            style: GoogleFonts.poppins(
                                color:
                                    const Color(0xFFD32F2F))),
                      ]),
                    ),
                  ],
                  icon: Icon(Icons.more_vert,
                      color: isDark
                          ? Colors.white54
                          : Colors.black54),
                ),
              ],
            ),
            if (event.location != null &&
                event.location!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(children: [
                const Icon(Icons.location_on,
                    color: Color(0xFFD32F2F), size: 18),
                const SizedBox(width: 8),
                Expanded(
                    child: Text(
                  event.location!,
                  style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: isDark
                          ? Colors.white70
                          : Colors.black87),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )),
              ]),
            ],
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD32F2F),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    elevation: 0),
                child: Text("Add to my calendar",
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
