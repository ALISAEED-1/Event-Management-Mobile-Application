import '../models/event_model.dart';
import 'firestore_rest_service.dart';

class EventServices {
  static const String _collection = 'events';

  Never _rethrow(String fallback, Object e) {
    final message = e.toString();
    throw message.isNotEmpty ? message : fallback;
  }

  Future<String> createEvent(EventModel model) async {
    try {
      final id = FirestoreRestService.generateId();
      final data = {
        ...model.toJson(),
        'docId': id,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      };
      return await FirestoreRestService.addDocument(_collection, data);
    } catch (e) {
      _rethrow('Failed to create event.', e);
    }
  }

  Future<List<EventModel>> getAllEvents() async {
    try {
      final docs = await FirestoreRestService.getDocumentsRest(_collection);
      return docs.map((d) => EventModel.fromJson(d)).toList();
    } catch (e) {
      _rethrow('Failed to load events.', e);
    }
  }

  Future<EventModel?> getEventById(String docId) async {
    try {
      final data = await FirestoreRestService.getDocumentRest(_collection, docId);
      if (data == null) {
        return null;
      }
      return EventModel.fromJson(data);
    } catch (e) {
      _rethrow('Failed to load event.', e);
    }
  }

  Future<void> updateEvent(EventModel model) async {
    try {
      await FirestoreRestService.setDocument(
          _collection, model.docId!, model.toJson());
    } catch (e) {
      _rethrow('Failed to update event.', e);
    }
  }

  Future<void> deleteEvent(String docId) async {
    try {
      await FirestoreRestService.deleteDocument(_collection, docId);
    } catch (e) {
      _rethrow('Failed to delete event.', e);
    }
  }
}
