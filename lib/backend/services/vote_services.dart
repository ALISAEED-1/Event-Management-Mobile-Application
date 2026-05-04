import '../models/vote_model.dart';
import 'firestore_rest_service.dart';

class VoteServices {
  static const String _collection = 'votes';

  Never _rethrow(String fallback, Object e) {
    final message = e.toString();
    throw message.isNotEmpty ? message : fallback;
  }

  Future<String> createVote(VoteModel model) async {
    try {
      final id = FirestoreRestService.generateId();
      final data = {
        ...model.toJson(),
        'docId': id,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      };
      return await FirestoreRestService.addDocument(_collection, data);
    } catch (e) {
      _rethrow('Failed to create vote.', e);
    }
  }

  Future<List<VoteModel>> getAllVotes() async {
    try {
      final docs = await FirestoreRestService.getDocumentsRest(_collection);
      return docs.map((d) => VoteModel.fromJson(d)).toList();
    } catch (e) {
      _rethrow('Failed to load votes.', e);
    }
  }

  Future<void> updateVote(VoteModel model) async {
    try {
      await FirestoreRestService.setDocument(
          _collection, model.docId!, model.toJson());
    } catch (e) {
      _rethrow('Failed to update vote.', e);
    }
  }

  Future<void> deleteVote(String docId) async {
    try {
      await FirestoreRestService.deleteDocument(_collection, docId);
    } catch (e) {
      _rethrow('Failed to delete vote.', e);
    }
  }

  Future<void> castVote(String docId, int optionIndex, {int amount = 1}) async {
    try {
      await FirestoreRestService.incrementField(
        _collection,
        docId,
        'voteCounts.$optionIndex',
        amount,
      );
    } catch (e) {
      _rethrow('Failed to cast vote.', e);
    }
  }
}
