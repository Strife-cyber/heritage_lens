import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heritage_lens/models/comment_model.dart';

/// Streams comments for a given artifact (Firestore: `artifacts/{artifactId}/comments`).
final modelCommentsProvider = StreamProvider.family<List<CommentModel>, String>(
  (ref, artifactId) {
    final firestore = FirebaseFirestore.instance;

    final query = firestore
        .collection('artifacts')
        .doc(artifactId)
        .collection('comments')
        .orderBy('createdAt', descending: false);

    return query.snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => CommentModel.fromMap(doc.data(), doc.id))
          .toList(),
    );
  },
);

/// Adds a comment under `artifacts/{artifactId}/comments` and increments the
/// aggregated `commentCount` stored on the artifact document.
Future<void> addComment({
  required String artifactId,
  required String authorId,
  required String authorName,
  required String text,
}) async {
  final firestore = FirebaseFirestore.instance;

  await firestore.runTransaction((tx) async {
    final artifactRef = firestore.collection('artifacts').doc(artifactId);

    final commentRef = artifactRef.collection('comments').doc();

    tx.set(commentRef, <String, dynamic>{
      'authorId': authorId,
      'authorName': authorName,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
    });

    tx.update(artifactRef, <String, dynamic>{
      'commentCount': FieldValue.increment(1),
    });
  });
}
