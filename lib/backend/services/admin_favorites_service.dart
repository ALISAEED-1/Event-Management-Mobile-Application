import 'firestore_rest_service.dart';

/// Admin-side favorites service.
///
/// Because the admin account is hardcoded (no Firebase Auth user), we cannot
/// rely solely on Firestore — security rules typically deny anonymous writes,
/// so writes silently fail and the heart "resets" on every page rebuild.
///
/// This service is a singleton that keeps the favorites in memory as the
/// source of truth for the running app session. Firestore is updated as a
/// best-effort sync (errors are swallowed) so favorites can survive app
/// restarts when rules permit.
class AdminFavoritesService {
  AdminFavoritesService._();

  /// Singleton instance — same Set is shared across pages.
  static final AdminFavoritesService instance = AdminFavoritesService._();

  // Allow `AdminFavoritesService()` shorthand to return the singleton.
  factory AdminFavoritesService() => instance;

  static const String _collection = 'Adminmeta';
  static const String _docId = 'global';

  final Set<String> _favorites = {};
  bool _hydrated = false;

  /// Returns favorited event docIds. On first call, attempts to hydrate from
  /// Firestore so favorites survive cold starts when rules allow.
  Future<List<String>> getFavorites() async {
    if (!_hydrated) {
      _hydrated = true;
      try {
        final data =
            await FirestoreRestService.getDocumentRest(_collection, _docId);
        final list =
            (data?['favorites'] as List?)?.map((e) => e.toString()).toList() ??
                const <String>[];
        _favorites.addAll(list);
      } catch (_) {
        // Ignore — fall back to empty in-memory set
      }
    }
    return _favorites.toList();
  }

  /// Adds an event to the admin's favorites (in-memory immediately,
  /// Firestore as best-effort).
  Future<void> addFavorite(String eventDocId) async {
    _favorites.add(eventDocId);
    _hydrated = true;
    await _persist();
  }

  /// Removes an event from the admin's favorites.
  Future<void> removeFavorite(String eventDocId) async {
    _favorites.remove(eventDocId);
    _hydrated = true;
    await _persist();
  }

  /// Best-effort full overwrite of the favorites doc. Never throws.
  Future<void> _persist() async {
    try {
      await FirestoreRestService.setDocument(_collection, _docId, {
        'docId': _docId,
        'favorites': _favorites.toList(),
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (_) {
      // Swallow — in-memory state is the source of truth.
    }
  }
}
