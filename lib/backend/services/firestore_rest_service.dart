import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

/// Shared Firestore helpers used by the app's service layer.
class FirestoreRestService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const _projectId = 'interntask-b7de5';
  static const _apiKey = 'AIzaSyC5Voib6vsPOdaGkwgEgW1biPLVGt542LI';
  static const _databaseId = 'default';
  static const _base =
      'https://firestore.googleapis.com/v1/projects/$_projectId/databases/$_databaseId/documents';
  static const _commitUrl =
      'https://firestore.googleapis.com/v1/projects/$_projectId/databases/$_databaseId/documents:commit';
  static const _queryUrl =
      'https://firestore.googleapis.com/v1/projects/$_projectId/databases/$_databaseId/documents:runQuery';

  static String generateId() {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final rng = Random.secure();
    return List.generate(20, (_) => chars[rng.nextInt(chars.length)]).join();
  }

  static Future<String> setDocument(
    String collection,
    String docId,
    Map<String, dynamic> data,
  ) async {
    final resp = await http.patch(
      _uri('$_base/$collection/$docId'),
      headers: await _headers(),
      body: jsonEncode({'fields': _toFields(data)}),
    );

    if (resp.statusCode == 200) {
      return docId;
    }
    _fail(resp.body, 'write');
  }

  static Future<String> addDocument(
    String collection,
    Map<String, dynamic> data,
  ) async {
    final id = data['docId'] as String? ?? generateId();
    return setDocument(collection, id, {...data, 'docId': id});
  }

  static Future<void> incrementField(
    String collection,
    String docId,
    String fieldPath,
    int amount,
  ) async {
    final body = jsonEncode({
      'writes': [
        {
          'transform': {
            'document':
                'projects/$_projectId/databases/$_databaseId/documents/$collection/$docId',
            'fieldTransforms': [
              {
                'fieldPath': fieldPath,
                'increment': {'integerValue': amount.toString()},
              }
            ],
          }
        }
      ]
    });

    final resp = await http.post(
      _uri(_commitUrl),
      headers: await _headers(),
      body: body,
    );

    if (resp.statusCode == 200) {
      return;
    }
    _fail(resp.body, 'increment');
  }

  static Future<void> deleteDocument(String collection, String docId) async {
    final resp = await http.delete(
      _uri('$_base/$collection/$docId'),
      headers: await _headers(),
    );

    if (resp.statusCode == 200) {
      return;
    }
    _fail(resp.body, 'delete');
  }

  static Future<Map<String, dynamic>?> getDocument(
    String collection,
    String docId,
  ) async {
    try {
      final snapshot = await _firestore.collection(collection).doc(docId).get();
      if (!snapshot.exists) {
        return null;
      }

      final data = Map<String, dynamic>.from(snapshot.data() ?? {});
      data.putIfAbsent('docId', () => snapshot.id);
      return data;
    } on FirebaseException catch (e) {
      throw 'Firestore get failed: ${e.message ?? e.code}';
    } catch (e) {
      throw 'Firestore get failed: $e';
    }
  }

  static Future<Map<String, dynamic>?> getDocumentRest(
    String collection,
    String docId,
  ) async {
    final resp = await http.get(
      _uri('$_base/$collection/$docId'),
      headers: await _headers(),
    );

    if (resp.statusCode == 404) {
      return null;
    }
    if (resp.statusCode != 200) {
      _fail(resp.body, 'get');
    }

    final decoded = jsonDecode(resp.body) as Map<String, dynamic>;
    final raw = (decoded['fields'] as Map<String, dynamic>?) ?? {};
    final data = _fromFields(raw);
    data.putIfAbsent('docId', () => docId);
    return data;
  }

  static Future<List<Map<String, dynamic>>> getDocuments(
    String collection, {
    String orderBy = 'createdAt',
  }) async {
    try {
      final snapshot = await _firestore.collection(collection).get();
      final docs = snapshot.docs
          .where((doc) => !doc.metadata.hasPendingWrites)
          .map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        data.putIfAbsent('docId', () => doc.id);
        return data;
      }).toList();

      docs.sort((a, b) {
        final aVal = a[orderBy];
        final bVal = b[orderBy];
        return '${bVal ?? ''}'.compareTo('${aVal ?? ''}');
      });

      return docs;
    } on FirebaseException catch (e) {
      throw 'Firestore query failed: ${e.message ?? e.code}';
    } catch (e) {
      throw 'Firestore query failed: $e';
    }
  }

  static Future<List<Map<String, dynamic>>> getDocumentsRest(
    String collection, {
    String orderBy = 'createdAt',
  }) async {
    final body = jsonEncode({
      'structuredQuery': {
        'from': [
          {'collectionId': collection}
        ],
        'orderBy': [
          {
            'field': {'fieldPath': orderBy},
            'direction': 'DESCENDING',
          }
        ],
      },
    });

    final resp = await http.post(
      _uri(_queryUrl),
      headers: await _headers(),
      body: body,
    );

    if (resp.statusCode != 200) {
      _fail(resp.body, 'query');
    }

    final list = jsonDecode(resp.body) as List<dynamic>;
    final docs = <Map<String, dynamic>>[];
    for (final item in list) {
      final doc = (item as Map<String, dynamic>)['document'];
      if (doc == null) {
        continue;
      }
      final name = doc['name'] as String;
      final docId = name.split('/').last;
      final raw = (doc['fields'] as Map<String, dynamic>?) ?? {};
      final data = _fromFields(raw);
      data.putIfAbsent('docId', () => docId);
      docs.add(data);
    }
    return docs;
  }

  static Future<void> arrayUnion(
    String collection,
    String docId,
    String fieldPath,
    List<dynamic> values,
  ) async {
    final body = jsonEncode({
      'writes': [
        {
          'transform': {
            'document':
                'projects/$_projectId/databases/$_databaseId/documents/$collection/$docId',
            'fieldTransforms': [
              {
                'fieldPath': fieldPath,
                'appendMissingElements': {
                  'values': values.map(_toVal).toList(),
                },
              }
            ],
          }
        }
      ]
    });

    final resp = await http.post(
      _uri(_commitUrl),
      headers: await _headers(),
      body: body,
    );

    if (resp.statusCode == 200) {
      return;
    }
    _fail(resp.body, 'arrayUnion');
  }

  static Future<void> arrayRemove(
    String collection,
    String docId,
    String fieldPath,
    List<dynamic> values,
  ) async {
    final body = jsonEncode({
      'writes': [
        {
          'transform': {
            'document':
                'projects/$_projectId/databases/$_databaseId/documents/$collection/$docId',
            'fieldTransforms': [
              {
                'fieldPath': fieldPath,
                'removeAllFromArray': {
                  'values': values.map(_toVal).toList(),
                },
              }
            ],
          }
        }
      ]
    });

    final resp = await http.post(
      _uri(_commitUrl),
      headers: await _headers(),
      body: body,
    );

    if (resp.statusCode == 200) {
      return;
    }
    _fail(resp.body, 'arrayRemove');
  }

  static Uri _uri(String url) {
    return Uri.parse(url).replace(queryParameters: {'key': _apiKey});
  }

  static Future<Map<String, String>> _headers() async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'X-Goog-Api-Key': _apiKey,
    };
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      headers['Authorization'] = 'Bearer ${await user.getIdToken()}';
    }
    return headers;
  }

  static Never _fail(String body, String op) {
    try {
      final decoded = jsonDecode(body) as Map<String, dynamic>;
      final message =
          (decoded['error'] as Map?)?['message'] as String? ?? body;
      throw 'Firestore $op failed: $message';
    } catch (_) {
      throw 'Firestore $op failed: $body';
    }
  }

  static Map<String, dynamic> _toFields(Map<String, dynamic> data) =>
      data.map((k, v) => MapEntry(k, _toVal(v)));

  static Map<String, dynamic> _fromFields(Map<String, dynamic> fields) =>
      fields.map((k, v) => MapEntry(k, _fromVal(v)));

  static dynamic _toVal(dynamic v) {
    if (v == null) return {'nullValue': null};
    if (v is bool) return {'booleanValue': v};
    if (v is int) return {'integerValue': v.toString()};
    if (v is double) return {'doubleValue': v};
    if (v is String) return {'stringValue': v};
    if (v is List) {
      return {
        'arrayValue': {'values': v.map(_toVal).toList()}
      };
    }
    if (v is Map<String, dynamic>) {
      return {'mapValue': {'fields': _toFields(v)}};
    }
    return {'stringValue': v.toString()};
  }

  static dynamic _fromVal(dynamic v) {
    if (v is! Map) return null;
    final m = v as Map<String, dynamic>;
    if (m.containsKey('stringValue')) return m['stringValue'];
    if (m.containsKey('integerValue')) {
      return int.tryParse(m['integerValue'].toString()) ?? 0;
    }
    if (m.containsKey('doubleValue')) {
      return (m['doubleValue'] as num).toDouble();
    }
    if (m.containsKey('booleanValue')) return m['booleanValue'] as bool;
    if (m.containsKey('nullValue')) return null;
    if (m.containsKey('arrayValue')) {
      final vals = (m['arrayValue'] as Map?)?['values'] as List? ?? [];
      return vals.map(_fromVal).toList();
    }
    if (m.containsKey('mapValue')) {
      final fields =
          (m['mapValue'] as Map?)?['fields'] as Map<String, dynamic>? ?? {};
      return _fromFields(fields);
    }
    return null;
  }
}
