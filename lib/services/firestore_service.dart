import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Fournit l'instance Firestore.
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

// Note: Vous créerez un provider par modèle. 
// Exemple: final userServiceProvider = Provider((ref) => FirestoreService<UserModel>(...));

/// Service générique responsable des opérations Firestore pour un modèle [T].
class FirestoreService<T> {
  FirestoreService({
    required this.collectionPath,
    required this.fromFirestore,
    required this.toFirestore,
  }) : _firestore = FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// Le chemin de la collection pour ce service.
  final String collectionPath;

  /// Fonction pour convertir le snapshot Firestore en modèle [T].
  final T Function(DocumentSnapshot<Map<String, dynamic>> snapshot, SnapshotOptions? options) fromFirestore;

  /// Fonction pour convertir le modèle [T] en Map pour Firestore.
  final Map<String, dynamic> Function(T value, SetOptions? options) toFirestore;

  /// Obtient l'instance Firestore.
  FirebaseFirestore get firestore => _firestore;

  /// Obtient une référence à la collection fortement typée [T].
  ///
  /// Retourne une référence à la collection avec le convertisseur.
  CollectionReference<T> get collectionRef {
    return _firestore.collection(collectionPath).withConverter<T>(
          fromFirestore: fromFirestore,
          toFirestore: toFirestore,
        );
  }

  /// Obtient une référence à un document fortement typé [T].
  ///
  /// [documentId] - L'identifiant du document.
  ///
  /// Retourne une référence au document.
  DocumentReference<T> document(String documentId) {
    return collectionRef.doc(documentId);
  }

  /// Crée un document dans la collection.
  ///
  /// [data] - Les données du document (de type T).
  /// [documentId] - L'identifiant du document (optionnel, généré automatiquement si non fourni).
  ///
  /// Retourne une référence au document créé.
  Future<DocumentReference<T>> createDocument({
    required T data,
    String? documentId,
  }) async {
    try {
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
  /// [documentId] - L'identifiant du document.
  ///
  /// Retourne le snapshot du document fortement typé.
  Future<DocumentSnapshot<T>> getDocument({
    required String documentId,
  }) async {
    try {
      return await collectionRef.doc(documentId).get();
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('Erreur lors de la lecture du document : $error\n$stackTrace');
      }
      rethrow;
    }
  }

  /// Met à jour un document.
  ///
  /// [documentId] - L'identifiant du document.
  /// [data] - Les données à mettre à jour (Map utilisé ici pour permettre les mises à jour partielles).
  /// [merge] - Si true, fusionne les données avec les données existantes (par défaut: false).
  ///
  /// Retourne une Future qui se complète lorsque le document est mis à jour.
  Future<void> updateDocument({
    required String documentId,
    required Map<String, dynamic> data,
    bool merge = false,
  }) async {
    try {
      // Note: On utilise la référence non-typée ici car .update() 
      // attend un Map<String, dynamic> pour les mises à jour partielles.
      final docRef = _firestore.collection(collectionPath).doc(documentId);
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
  /// [documentId] - L'identifiant du document.
  ///
  /// Retourne une Future qui se complète lorsque le document est supprimé.
  Future<void> deleteDocument({
    required String documentId,
  }) async {
    try {
      await collectionRef.doc(documentId).delete();
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('Erreur lors de la suppression du document : $error\n$stackTrace');
      }
      rethrow;
    }
  }

  /// Supprime plusieurs documents.
  ///
  /// [documentIds] - Liste des identifiants des documents à supprimer.
  ///
  /// Retourne une Future qui se complète lorsque tous les documents sont supprimés.
  Future<void> deleteDocuments({
    required List<String> documentIds,
  }) async {
    try {
      await Future.wait(
        documentIds.map(
          (id) => deleteDocument(documentId: id),
        ),
      );
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('Erreur lors de la suppression multiple des documents : $error\n$stackTrace');
      }
      rethrow;
    }
  }

  /// Lit les documents de la collection.
  ///
  /// [where] - Liste des conditions de filtrage (optionnel).
  /// [orderBy] - Champ de tri (optionnel).
  /// [limit] - Nombre maximum de documents à retourner (optionnel).
  /// [startAfter] - Document de départ pour la pagination (optionnel).
  /// [endBefore] - Document de fin pour la pagination (optionnel).
  ///
  /// Retourne les documents typés de la collection.
  Future<QuerySnapshot<T>> getDocuments({
    List<WhereCondition>? where,
    String? orderBy,
    int? limit,
    DocumentSnapshot? startAfter,
    DocumentSnapshot? endBefore,
  }) async {
    try {
      Query<T> query = collectionRef;

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
  /// [documentId] - L'identifiant du document.
  ///
  /// Retourne un flux des snapshots typés du document.
  Stream<DocumentSnapshot<T>> watchDocument({
    required String documentId,
  }) {
    try {
      return collectionRef.doc(documentId).snapshots();
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('Erreur lors de l\'écoute du document : $error\n$stackTrace');
      }
      rethrow;
    }
  }

  /// Écoute les changements de la collection en temps réel.
  ///
  /// [where] - Liste des conditions de filtrage (optionnel).
  /// [orderBy] - Champ de tri (optionnel).
  /// [limit] - Nombre maximum de documents à retourner (optionnel).
  ///
  /// Retourne un flux des snapshots typés de la collection.
  Stream<QuerySnapshot<T>> watchCollection({
    List<WhereCondition>? where,
    String? orderBy,
    int? limit,
  }) {
    try {
      Query<T> query = collectionRef;

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
  Future<R> runTransaction<R>(
    Future<R> Function(Transaction transaction) transaction,
  ) async {
    try {
      return await _firestore.runTransaction(transaction);
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint("Erreur lors de l'exécution de la transaction : $error\n$stackTrace");
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
