import 'package:heritage_lens/models/ar_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heritage_lens/services/firestore_service.dart';

final arModelServiceProvider = Provider<FirestoreService<ARModel>>((ref) {
  return FirestoreService<ARModel>(
    collectionPath: 'artifacts', 
    fromFirestore: (snapshot, options) {
      final data = snapshot.data();
      return ARModel.fromMap(data ?? {}, snapshot.id);
    }, 
    toFirestore: (model, options) {
      return model.toMap();
    }
  );
});
