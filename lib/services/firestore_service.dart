import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Fournit une instance unique du service Firestore via Riverpod.
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  final service = FirestoreService();
  return service;
});

/// Fournit l'instance Firestore.
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// Service responsable des opérations Firestore.
class FirestoreService {
  FirestoreService() : _firestore = FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// Obtient l'instance Firestore.
  FirebaseFirestore get firestore => _firestore;

  /// Obtient une référence à une collection.
  ///
  /// [path] - Le chemin de la collection.
  ///
  /// Retourne une référence à la collection.
  CollectionReference<Map<String, dynamic>> collection(String path) {
    return _firestore.collection(path);
  }

  /// Obtient une référence à un document.
  ///
  /// [path] - Le chemin du document.
  ///
  /// Retourne une référence au document.
  DocumentReference<Map<String, dynamic>> document(String path) {
    return _firestore.doc(path);
  }

  /// Crée un document dans une collection.
  ///
  /// [collectionPath] - Le chemin de la collection.
  /// [data] - Les données du document.
  /// [documentId] - L'identifiant du document (optionnel, généré automatiquement si non fourni).
  ///
  /// Retourne une référence au document créé.
  Future<DocumentReference<Map<String, dynamic>>> createDocument({
    required String collectionPath,
    required Map<String, dynamic> data,
    String? documentId,
  }) async {
    try {
      final collectionRef = _firestore.collection(collectionPath);
      if (documentId != null) {
        await collectionRef.doc(documentId).set(data);
        return collectionRef.doc(documentId);
      } else {
        return await collectionRef.add(data);
      }
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('Erreur lors de la création du document : $error\n$stackTrace');
      }
      rethrow;
    }
  }

  /// Lit un document.
  ///
  /// [documentPath] - Le chemin du document.
  ///
  /// Retourne les données du document.
  Future<DocumentSnapshot<Map<String, dynamic>>> getDocument({
    required String documentPath,
  }) async {
    try {
      return await _firestore.doc(documentPath).get();
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('Erreur lors de la lecture du document : $error\n$stackTrace');
      }
      rethrow;
    }
  }

  /// Met à jour un document.
  ///
  /// [documentPath] - Le chemin du document.
  /// [data] - Les données à mettre à jour.
  /// [merge] - Si true, fusionne les données avec les données existantes (par défaut: false).
  ///
  /// Retourne une Future qui se complète lorsque le document est mis à jour.
  Future<void> updateDocument({
    required String documentPath,
    required Map<String, dynamic> data,
    bool merge = false,
  }) async {
    try {
      final docRef = _firestore.doc(documentPath);
      if (merge) {
        await docRef.set(data, SetOptions(merge: true));
      } else {
        await docRef.update(data);
      }
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('Erreur lors de la mise à jour du document : $error\n$stackTrace');
      }
      rethrow;
    }
  }

  /// Supprime un document.
  ///
  /// [documentPath] - Le chemin du document.
  ///
  /// Retourne une Future qui se complète lorsque le document est supprimé.
  Future<void> deleteDocument({
    required String documentPath,
  }) async {
    try {
      await _firestore.doc(documentPath).delete();
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('Erreur lors de la suppression du document : $error\n$stackTrace');
      }
      rethrow;
    }
  }

  /// Supprime plusieurs documents.
  ///
  /// [documentPaths] - Liste des chemins des documents à supprimer.
  ///
  /// Retourne une Future qui se complète lorsque tous les documents sont supprimés.
  Future<void> deleteDocuments({
    required List<String> documentPaths,
  }) async {
    try {
      await Future.wait(
        documentPaths.map(
          (path) => deleteDocument(documentPath: path),
        ),
      );
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('Erreur lors de la suppression multiple des documents : $error\n$stackTrace');
      }
      rethrow;
    }
  }

  /// Lit les documents d'une collection.
  ///
  /// [collectionPath] - Le chemin de la collection.
  /// [where] - Liste des conditions de filtrage (optionnel).
  /// [orderBy] - Champ de tri (optionnel).
  /// [limit] - Nombre maximum de documents à retourner (optionnel).
  /// [startAfter] - Document de départ pour la pagination (optionnel).
  /// [endBefore] - Document de fin pour la pagination (optionnel).
  ///
  /// Retourne les documents de la collection.
  Future<QuerySnapshot<Map<String, dynamic>>> getDocuments({
    required String collectionPath,
    List<WhereCondition>? where,
    String? orderBy,
    int? limit,
    DocumentSnapshot? startAfter,
    DocumentSnapshot? endBefore,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore.collection(collectionPath);

      if (where != null) {
        for (final condition in where) {
          query = query.where(
            condition.field,
            isEqualTo: condition.isEqualTo,
            isNotEqualTo: condition.isNotEqualTo,
            isLessThan: condition.isLessThan,
            isLessThanOrEqualTo: condition.isLessThanOrEqualTo,
            isGreaterThan: condition.isGreaterThan,
            isGreaterThanOrEqualTo: condition.isGreaterThanOrEqualTo,
            arrayContains: condition.arrayContains,
            arrayContainsAny: condition.arrayContainsAny,
            whereIn: condition.whereIn,
            whereNotIn: condition.whereNotIn,
            isNull: condition.isNull,
          );
        }
      }

      if (orderBy != null) {
        query = query.orderBy(orderBy);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      if (endBefore != null) {
        query = query.endBeforeDocument(endBefore);
      }

      return await query.get();
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('Erreur lors de la lecture des documents : $error\n$stackTrace');
      }
      rethrow;
    }
  }

  /// Écoute les changements d'un document en temps réel.
  ///
  /// [documentPath] - Le chemin du document.
  ///
  /// Retourne un flux des snapshots du document.
  Stream<DocumentSnapshot<Map<String, dynamic>>> watchDocument({
    required String documentPath,
  }) {
    try {
      return _firestore.doc(documentPath).snapshots();
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('Erreur lors de l\'écoute du document : $error\n$stackTrace');
      }
      rethrow;
    }
  }

  /// Écoute les changements d'une collection en temps réel.
  ///
  /// [collectionPath] - Le chemin de la collection.
  /// [where] - Liste des conditions de filtrage (optionnel).
  /// [orderBy] - Champ de tri (optionnel).
  /// [limit] - Nombre maximum de documents à retourner (optionnel).
  ///
  /// Retourne un flux des snapshots de la collection.
  Stream<QuerySnapshot<Map<String, dynamic>>> watchCollection({
    required String collectionPath,
    List<WhereCondition>? where,
    String? orderBy,
    int? limit,
  }) {
    try {
      Query<Map<String, dynamic>> query = _firestore.collection(collectionPath);

      if (where != null) {
        for (final condition in where) {
          query = query.where(
            condition.field,
            isEqualTo: condition.isEqualTo,
            isNotEqualTo: condition.isNotEqualTo,
            isLessThan: condition.isLessThan,
            isLessThanOrEqualTo: condition.isLessThanOrEqualTo,
            isGreaterThan: condition.isGreaterThan,
            isGreaterThanOrEqualTo: condition.isGreaterThanOrEqualTo,
            arrayContains: condition.arrayContains,
            arrayContainsAny: condition.arrayContainsAny,
            whereIn: condition.whereIn,
            whereNotIn: condition.whereNotIn,
            isNull: condition.isNull,
          );
        }
      }

      if (orderBy != null) {
        query = query.orderBy(orderBy);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      return query.snapshots();
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('Erreur lors de l\'écoute de la collection : $error\n$stackTrace');
      }
      rethrow;
    }
  }

  /// Exécute une transaction.
  ///
  /// [transaction] - La fonction de transaction à exécuter.
  ///
  /// Retourne le résultat de la transaction.
  Future<T> runTransaction<T>(
    Future<T> Function(Transaction transaction) transaction,
  ) async {
    try {
      return await _firestore.runTransaction(transaction);
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('Erreur lors de l\'exécution de la transaction : $error\n$stackTrace');
      }
      rethrow;
    }
  }

  /// Exécute un batch d'opérations.
  ///
  /// [operations] - La fonction contenant les opérations batch à exécuter.
  ///
  /// Retourne une Future qui se complète lorsque le batch est exécuté.
  Future<void> runBatch(
    void Function(WriteBatch batch) operations,
  ) async {
    try {
      final batch = _firestore.batch();
      operations(batch);
      await batch.commit();
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('Erreur lors de l\'exécution du batch : $error\n$stackTrace');
      }
      rethrow;
    }
  }
}

/// Classe helper pour construire des conditions Where.
class WhereCondition {
  const WhereCondition({
    required this.field,
    this.isEqualTo,
    this.isNotEqualTo,
    this.isLessThan,
    this.isLessThanOrEqualTo,
    this.isGreaterThan,
    this.isGreaterThanOrEqualTo,
    this.arrayContains,
    this.arrayContainsAny,
    this.whereIn,
    this.whereNotIn,
    this.isNull,
  });

  final String field;
  final Object? isEqualTo;
  final Object? isNotEqualTo;
  final Object? isLessThan;
  final Object? isLessThanOrEqualTo;
  final Object? isGreaterThan;
  final Object? isGreaterThanOrEqualTo;
  final Object? arrayContains;
  final List<Object?>? arrayContainsAny;
  final List<Object?>? whereIn;
  final List<Object?>? whereNotIn;
  final bool? isNull;
}

