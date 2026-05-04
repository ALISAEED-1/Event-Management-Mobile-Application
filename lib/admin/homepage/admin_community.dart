
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../backend/models/vote_model.dart';
import '../../backend/services/vote_services.dart';
import '../profiles/admin_group_profile.dart';
import 'create_event.dart';
import 'create_vote.dart';
import 'edit_vote.dart';

class AdminCommunity extends StatefulWidget {
  const AdminCommunity({super.key});

  @override
  State<AdminCommunity> createState() => _AdminCommunityState();
}

class _AdminCommunityState extends State<AdminCommunity> {
  bool _fabOpen = false;

  final Map<String, int?> _selectedOptions = {};

  List<VoteModel> _votes = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadVotes();
  }

  Future<void> _loadVotes() async {
    setState(() { _loading = true; _error = null; });
    try {
      final votes = await VoteServices().getAllVotes();
      if (mounted) setState(() { _votes = votes; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  void _applyLocalVoteChange(String docId, int? prev, int next) {
    final idx = _votes.indexWhere((v) => v.docId == docId);
    if (idx == -1) return;
    final v = _votes[idx];
    final counts = Map<String, int>.from(v.voteCounts ?? {});
    if (prev != null) {
      counts[prev.toString()] =
          ((counts[prev.toString()] ?? 0) - 1).clamp(0, 999999);
    }
    counts[next.toString()] = (counts[next.toString()] ?? 0) + 1;
    setState(() {
      _votes[idx] = VoteModel(
        docId: v.docId, question: v.question, options: v.options,
        imageUrl: v.imageUrl, createdAt: v.createdAt, voteCounts: counts,
      );
    });
  }

  void _revertLocalVoteChange(String docId, int? prev, int next) {
    final idx = _votes.indexWhere((v) => v.docId == docId);
    if (idx == -1) return;
    final v = _votes[idx];
    final counts = Map<String, int>.from(v.voteCounts ?? {});
    counts[next.toString()] =
        ((counts[next.toString()] ?? 0) - 1).clamp(0, 999999);
    if (prev != null) counts[prev.toString()] = (counts[prev.toString()] ?? 0) + 1;
    setState(() {
      _votes[idx] = VoteModel(
        docId: v.docId, question: v.question, options: v.options,
        imageUrl: v.imageUrl, createdAt: v.createdAt, voteCounts: counts,
      );
    });
  }

  void _toggleFab() => setState(() => _fabOpen = !_fabOpen);
  void _closeFab() {
    if (_fabOpen) setState(() => _fabOpen = false);
  }

  // ── Speed-dial action button ──
  Widget _speedDialBtn(
      String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFD32F2F),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Delete confirmation dialog ──
  Future<bool> _confirmDelete(BuildContext context, String title) async {
    return await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete $title',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text(
            'Are you sure you want to delete this $title?',
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final surfaceColor = Theme.of(context).colorScheme.surface;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      // FAB is inside the Stack body so it works whether this page is
      // a root route OR a tab inside AdminRootPage (nested Scaffold).
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          // ── Background pattern ──
          Positioned.fill(
            child: Opacity(
              opacity: isDark ? 0.2 : 0.8,
              child: Image.asset(
                "assets/images/paw pattern 1.png",
                fit: BoxFit.cover,
                color: isDark ? Colors.black : null,
                colorBlendMode: isDark ? BlendMode.darken : null,
              ),
            ),
          ),

          // ── Main content ──
          Column(
            children: [
              // Red header bar
              Container(
                padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
                decoration:
                const BoxDecoration(color: Color(0xFFD32F2F)),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 20,
                      backgroundImage:
                      AssetImage("assets/images/community.png"),
                    ),
                    const SizedBox(width: 4),
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                            const AdminGroupProfile()),
                      ),
                      style:
                      TextButton.styleFrom(padding: EdgeInsets.zero),
                      child: Text(
                        "Business group",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.more_vert, color: Colors.white),
                  ],
                ),
              ),

              // Votes list
              Expanded(
                child: RefreshIndicator(
                  color: const Color(0xFFD32F2F),
                  onRefresh: _loadVotes,
                  child: _buildVoteBody(isDark, surfaceColor, textColor),
                ),
              ),
            ],
          ),

          // ── Dismiss overlay (closes dial on background tap) ──
          if (_fabOpen)
            Positioned.fill(
              child: GestureDetector(
                onTap: _closeFab,
                behavior: HitTestBehavior.opaque,
                child: const SizedBox.expand(),
              ),
            ),

          // ── Speed-dial labels (above the FAB, z-order above overlay) ──
          if (_fabOpen)
            Positioned(
              bottom: 90,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _speedDialBtn(
                    "Vote",
                    Icons.how_to_vote_outlined,
                    () {
                      _closeFab();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const CreateVote()),
                      ).then((_) { if (mounted) _loadVotes(); });
                    },
                  ),
                  const SizedBox(height: 12),
                  _speedDialBtn(
                    "+ Event",
                    Icons.event_outlined,
                    () {
                      _closeFab();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const CreateEvent()),
                      ).then((_) { if (mounted) _loadVotes(); });
                    },
                  ),
                ],
              ),
            ),

          // ── Main FAB (highest z-order — always on top) ──
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: _toggleFab,
              backgroundColor: const Color(0xFFD32F2F),
              elevation: 6,
              child: AnimatedRotation(
                turns: _fabOpen ? 0.125 : 0,
                duration: const Duration(milliseconds: 200),
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Body widget (replaces FutureBuilder) ──
  Widget _buildVoteBody(bool isDark, Color surfaceColor, Color? textColor) {
    if (_loading) {
      return const Center(
          child: CircularProgressIndicator(color: Color(0xFFD32F2F)));
    }
    if (_error != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: 400,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.wifi_off_outlined,
                      size: 48, color: Colors.grey.withOpacity(0.5)),
                  const SizedBox(height: 12),
                  Text('Failed to load votes',
                      style: GoogleFonts.poppins(color: Colors.grey)),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                      child: Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                            color: Colors.grey, fontSize: 12),
                      ),
                    ),
                  TextButton(
                    onPressed: _loadVotes,
                    child: Text('Retry',
                        style: GoogleFonts.poppins(
                            color: const Color(0xFFD32F2F))),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }
    if (_votes.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: 400,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.how_to_vote_outlined,
                      size: 64, color: Colors.grey.withOpacity(0.4)),
                  const SizedBox(height: 16),
                  Text('No votes yet.\nTap + to create one.',
                      textAlign: TextAlign.center,
                      style:
                          GoogleFonts.poppins(color: Colors.grey, fontSize: 14)),
                ],
              ),
            ),
          ),
        ],
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
      physics: const BouncingScrollPhysics(),
      itemCount: _votes.length,
      itemBuilder: (context, index) =>
          _buildVoteCard(_votes[index], isDark, surfaceColor, textColor),
    );
  }

  // ── Vote card with real Firestore data ──
  Widget _buildVoteCard(VoteModel vote, bool isDark, Color surfaceColor,
      Color? textColor) {
    final options = vote.options ?? [];
    final voteCounts = vote.voteCounts ?? {};
    final totalVotes =
    voteCounts.values.fold<int>(0, (sum, v) => sum + v);
    final selectedIndex = _selectedOptions[vote.docId ?? ''];

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: isDark
            ? surfaceColor.withOpacity(0.95)
            : Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: isDark ? Colors.white12 : Colors.grey.shade200),
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
          // Image header
          ClipRRect(
            borderRadius:
            const BorderRadius.vertical(top: Radius.circular(20)),
            child: (vote.imageUrl != null && vote.imageUrl!.isNotEmpty)
                ? Image.network(vote.imageUrl!,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover)
                : Image.asset("assets/images/features.png",
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Question + admin menu
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        vote.question ?? 'Poll',
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: textColor),
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) async {
                        if (value == 'edit') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    EditVote(vote: vote)),
                          ).then((_) { if (mounted) _loadVotes(); });
                        } else if (value == 'delete') {
                          final ok = await _confirmDelete(
                              context, 'vote');
                          if (ok && vote.docId != null) {
                            await VoteServices()
                                .deleteVote(vote.docId!);
                            if (mounted) _loadVotes();
                          }
                        }
                      },
                      itemBuilder: (_) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(children: [
                            const Icon(Icons.edit_outlined,
                                size: 18),
                            const SizedBox(width: 8),
                            Text('Edit',
                                style: GoogleFonts.poppins()),
                          ]),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(children: [
                            const Icon(Icons.delete_outline,
                                size: 18,
                                color: Color(0xFFD32F2F)),
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
                const SizedBox(height: 12),

                // Options with radio + vote count
                ...List.generate(options.length, (i) {
                  final letter =
                  String.fromCharCode(65 + i); // A, B, C…
                  final count =
                      voteCounts[i.toString()] ?? 0;
                  return _buildRadioOption(
                    letter,
                    options[i],
                    i,
                    selectedIndex,
                    count,
                    isDark,
                    textColor,
                        (val) async {
                      if (vote.docId == null || val == null) return;
                      if (selectedIndex == val) return;

                      final prevSelection = selectedIndex;
                      final docId = vote.docId!;

                      setState(() => _selectedOptions[docId] = val);
                      _applyLocalVoteChange(docId, prevSelection, val);

                      try {
                        if (prevSelection != null) {
                          await VoteServices().castVote(
                              docId, prevSelection, amount: -1);
                        }
                        await VoteServices().castVote(docId, val);
                      } catch (_) {
                        // Server failed — UI stays as-is.
                        // Pull-to-refresh will sync true counts.
                      }
                    },
                  );
                }),

                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    "$totalVotes vote${totalVotes == 1 ? '' : 's'} total",
                    style: GoogleFonts.poppins(
                        color: isDark
                            ? Colors.white38
                            : Colors.grey,
                        fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Single radio option row ──
  Widget _buildRadioOption(
      String letter,
      String text,
      int value,
      int? groupValue,
      int count,
      bool isDark,
      Color? textColor,
      Function(int?) onChanged,
      ) {
    return InkWell(
      onTap: () => onChanged(value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            Text(letter,
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color:
                    isDark ? Colors.white70 : Colors.black)),
            Radio<int>(
              value: value,
              groupValue: groupValue,
              activeColor: const Color(0xFFD32F2F),
              onChanged: onChanged,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(text,
                      style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: isDark
                              ? Colors.white70
                              : Colors.black87)),
                  Text("$count vote${count == 1 ? '' : 's'}",
                      style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: isDark
                              ? Colors.white38
                              : Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
