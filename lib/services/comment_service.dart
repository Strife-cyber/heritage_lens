import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heritage_lens/models/comment_model.dart';
import 'package:heritage_lens/services/firestore_service.dart';

final commentServiceProvider = Provider.family<FirestoreService<CommentModel>, String>((ref, modelId) {
  return FirestoreService<CommentModel>(
    collectionPath: 'artifacts/$modelId/comments',
    fromFirestore: (snapshot, options) {
      final data = snapshot.data();
      if (data == null) {
        throw Exception('Le snapshot du commentaire est vide.');
      }
      return CommentModel.fromMap(data, snapshot.id);
    },
    toFirestore: (comment, options) => comment.toMap()..remove('documentId'),
  );
});

// Stream provider to instantly see new comments fetched by createdAt
final modelCommentsProvider = StreamProvider.family<List<CommentModel>, String>((ref, modelId) {
  final commentService = ref.watch(commentServiceProvider(modelId));
  return commentService.watchCollection(orderBy: 'createdAt').map(
    (snapshot) => snapshot.docs.map((doc) => doc.data()).toList()
  );
});
