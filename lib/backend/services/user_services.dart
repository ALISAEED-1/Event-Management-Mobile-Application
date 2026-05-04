import 'package:firebase_auth/firebase_auth.dart';

import '../models/users.dart';
import 'firestore_rest_service.dart';

class UserServices {
  static const String _collection = 'Usercollection';

  Never _rethrow(String fallback, Object e) {
    final message = e.toString();
    throw message.isNotEmpty ? message : fallback;
  }

  // ── CRUD ──

  Future<void> createUser(UsersModel model) async {
    try {
      await FirestoreRestService.setDocument(
          _collection, model.docId!, model.toJson());
    } catch (e) {
      _rethrow('Failed to save user data.', e);
    }
  }

  Future<void> updateUser(UsersModel model) async {
    try {
      await FirestoreRestService.setDocument(
          _collection, model.docId!, model.toJson());
    } catch (e) {
      _rethrow('Failed to update user data.', e);
    }
  }

  Future<void> deleteUser(UsersModel model) async {
    try {
      await FirestoreRestService.deleteDocument(_collection, model.docId!);
    } catch (e) {
      _rethrow('Failed to delete user.', e);
    }
  }

  Future<UsersModel> getuserbyID(String userID) async {
    try {
      final data =
          await FirestoreRestService.getDocumentRest(_collection, userID);
      if (data == null) throw 'User data not found.';
      return UsersModel.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  // ── Favorites ──

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  Future<void> _ensureCurrentUserDoc() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final existing =
          await FirestoreRestService.getDocumentRest(_collection, user.uid);
      if (existing != null) {
        return;
      }

      await FirestoreRestService.setDocument(_collection, user.uid, {
        'docId': user.uid,
        'email': user.email,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'favorites': <String>[],
      });
    } catch (e) {
      _rethrow('Failed to prepare user data.', e);
    }
  }

  /// Returns the list of favorited event docIds for the current user.
  Future<List<String>> getFavorites() async {
    final uid = _uid;
    if (uid == null) return [];
    try {
      await _ensureCurrentUserDoc();
      final data =
          await FirestoreRestService.getDocumentRest(_collection, uid);
      if (data == null) return [];
      return (data['favorites'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [];
    } catch (_) {
      return [];
    }
  }

  /// Adds an event to the current user's favorites.
  Future<void> addFavorite(String eventDocId) async {
    final uid = _uid;
    if (uid == null) return;
    await _ensureCurrentUserDoc();
    await FirestoreRestService.arrayUnion(
        _collection, uid, 'favorites', [eventDocId]);
  }

  /// Removes an event from the current user's favorites.
  Future<void> removeFavorite(String eventDocId) async {
    final uid = _uid;
    if (uid == null) return;
    await _ensureCurrentUserDoc();
    await FirestoreRestService.arrayRemove(
        _collection, uid, 'favorites', [eventDocId]);
  }
}
