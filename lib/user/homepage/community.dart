import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../backend/models/vote_model.dart';
import '../../backend/services/vote_services.dart';
import '../profiles/group_profile.dart';

class Community extends StatefulWidget {
  const Community({super.key});

  @override
  State<Community> createState() => _CommunityState();
}

class _CommunityState extends State<Community> {
  // Which option the user selected per vote (docId → option index)
  final Map<String, int?> _selectedOptions = {};

  // The live votes list — updated in-memory after each vote
  List<VoteModel> _votes = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadVotes();
  }

  Future<void> _loadVotes() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final votes = await VoteServices().getAllVotes();
      if (mounted) setState(() { _votes = votes; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  /// Updates the local vote counts immediately — no network reload needed.
  void _applyLocalVoteChange(String docId, int? prev, int next) {
    final idx = _votes.indexWhere((v) => v.docId == docId);
    if (idx == -1) return;
    final v = _votes[idx];
    final counts = Map<String, int>.from(v.voteCounts ?? {});

    // Undo previous selection
    if (prev != null) {
      counts[prev.toString()] =
          ((counts[prev.toString()] ?? 0) - 1).clamp(0, 999999);
    }
    // Add new selection
    counts[next.toString()] = (counts[next.toString()] ?? 0) + 1;

    setState(() {
      _votes[idx] = VoteModel(
        docId: v.docId,
        question: v.question,
        options: v.options,
        imageUrl: v.imageUrl,
        createdAt: v.createdAt,
        voteCounts: counts,
      );
    });
  }

  /// Reverts a local vote change on server error.
  void _revertLocalVoteChange(String docId, int? prev, int next) {
    final idx = _votes.indexWhere((v) => v.docId == docId);
    if (idx == -1) return;
    final v = _votes[idx];
    final counts = Map<String, int>.from(v.voteCounts ?? {});

    // Undo the applied change
    counts[next.toString()] =
        ((counts[next.toString()] ?? 0) - 1).clamp(0, 999999);
    if (prev != null) {
      counts[prev.toString()] = (counts[prev.toString()] ?? 0) + 1;
    }

    setState(() {
      _votes[idx] = VoteModel(
        docId: v.docId,
        question: v.question,
        options: v.options,
        imageUrl: v.imageUrl,
        createdAt: v.createdAt,
        voteCounts: counts,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final surfaceColor = Theme.of(context).colorScheme.surface;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Background pattern
          Positioned.fill(
            child: Opacity(
              opacity: isDark ? 0.2 : 0.8,
              child: Image.asset(
                'assets/images/paw pattern 1.png',
                fit: BoxFit.cover,
                color: isDark ? Colors.black : null,
                colorBlendMode: isDark ? BlendMode.darken : null,
              ),
            ),
          ),

          Column(
            children: [
              // Red header
              Container(
                padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
                decoration:
                    const BoxDecoration(color: Color(0xFFD32F2F)),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 20,
                      backgroundImage:
                          AssetImage('assets/images/community.png'),
                    ),
                    const SizedBox(width: 4),
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const GroupProfile()),
                      ),
                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                      child: Text(
                        'Business group',
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

              // Body
              Expanded(
                child: RefreshIndicator(
                  color: const Color(0xFFD32F2F),
                  onRefresh: _loadVotes,
                  child: _buildBody(isDark, surfaceColor, textColor),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBody(bool isDark, Color surfaceColor, Color? textColor) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFD32F2F)),
      );
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
                  Text('No votes yet.',
                      style: GoogleFonts.poppins(
                          color: Colors.grey, fontSize: 14)),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
      physics: const BouncingScrollPhysics(),
      itemCount: _votes.length,
      itemBuilder: (context, index) => _buildVoteCard(
        _votes[index],
        isDark,
        surfaceColor,
        textColor,
      ),
    );
  }

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
                : Image.asset('assets/images/features.png',
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vote.question ?? 'Poll',
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: textColor),
                ),
                const SizedBox(height: 12),

                // Options
                ...List.generate(options.length, (i) {
                  final letter = String.fromCharCode(65 + i);
                  final count = voteCounts[i.toString()] ?? 0;
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
                      // Same option tapped again — ignore
                      if (selectedIndex == val) return;

                      final prevSelection = selectedIndex;
                      final docId = vote.docId!;

                      // 1. Update selection
                      setState(() => _selectedOptions[docId] = val);
                      // 2. Update counts in memory immediately
                      _applyLocalVoteChange(docId, prevSelection, val);

                      // 3. Send to server (UI already updated above)
                      try {
                        if (prevSelection != null) {
                          // Switching vote: undo old then add new in one call
                          await VoteServices().castVote(
                              docId, prevSelection,
                              amount: -1);
                        }
                        await VoteServices().castVote(docId, val);
                      } catch (_) {
                        // Server failed — UI stays as-is so it doesn't
                        // confusingly snap back. User can pull-to-refresh.
                      }
                    },
                  );
                }),

                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    '$totalVotes vote${totalVotes == 1 ? '' : 's'} total',
                    style: GoogleFonts.poppins(
                        color: isDark ? Colors.white38 : Colors.grey,
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
                    color: isDark ? Colors.white70 : Colors.black)),
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
                  Text('$count vote${count == 1 ? '' : 's'}',
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
