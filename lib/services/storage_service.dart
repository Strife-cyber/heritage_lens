import 'dart:io' as io;

import 'package:appwrite/appwrite.dart';
import 'package:flutter/foundation.dart';
import 'package:appwrite/models.dart' as models;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../managers/appwrite_manager.dart';

/// Fournit une instance unique du service de stockage via Riverpod.
final storageServiceProvider = Provider<StorageService>((ref) {
  final service = StorageService(ref);
  return service;
});

/// Service responsable des opérations de stockage Appwrite.
class StorageService {
  StorageService(this._ref);

  final Ref _ref;

  /// Obtient l'instance Storage Appwrite.
  Future<Storage> _getStorage() async {
    final storage = await _ref.read(appwriteStorageProvider.future);
    return storage;
  }

  /// Téléverse un fichier dans un bucket Appwrite.
  ///
  /// [bucketId] - L'identifiant du bucket de destination.
  /// [fileId] - L'identifiant unique du fichier (optionnel, généré automatiquement si non fourni).
  /// [file] - Le fichier à téléverser (InputFile).
  /// [read] - Liste des permissions de lecture (optionnel).
  /// [write] - Liste des permissions d'écriture (optionnel).
  /// [onProgress] - Callback pour suivre la progression du téléversement (optionnel).
  ///
  /// Retourne l'objet File créé.
  Future<models.File> uploadFile({
    required String bucketId,
    String? fileId,
    required InputFile file,
    List<String>? read,
    List<String>? write,
    void Function(UploadProgress)? onProgress,
  }) async {
    try {
      final storage = await _getStorage();
      return await storage.createFile(
        bucketId: bucketId,
        fileId: fileId ?? ID.unique(),
        file: file,
        permissions: [
          if (read != null) ...read.map((r) => Permission.read(r)),
          if (write != null) ...write.map((w) => Permission.write(w)),
        ],
        onProgress: onProgress,
      );
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('Erreur lors du téléversement du fichier : $error\n$stackTrace');
      }
      rethrow;
    }
  }

  /// Téléverse un fichier depuis le système de fichiers local.
  ///
  /// [bucketId] - L'identifiant du bucket de destination.
  /// [filePath] - Le chemin du fichier local à téléverser.
  /// [fileId] - L'identifiant unique du fichier (optionnel).
  /// [read] - Liste des permissions de lecture (optionnel).
  /// [write] - Liste des permissions d'écriture (optionnel).
  /// [onProgress] - Callback pour suivre la progression du téléversement (optionnel).
  ///
  /// Retourne l'objet File créé.
  Future<models.File> uploadFileFromPath({
    required String bucketId,
    required String filePath,
    String? fileId,
    List<String>? read,
    List<String>? write,
    void Function(UploadProgress)? onProgress,
  }) async {
    try {
      final file = io.File(filePath);
      if (!await file.exists()) {
        throw StateError('Le fichier à $filePath n\'existe pas.');
      }
      return await uploadFile(
        bucketId: bucketId,
        fileId: fileId,
        file: InputFile.fromPath(path: filePath),
        read: read,
        write: write,
        onProgress: onProgress,
      );
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('Erreur lors du téléversement du fichier depuis le chemin : $error\n$stackTrace');
      }
      rethrow;
    }
  }

  /// Téléverse un fichier depuis des données binaires.
  ///
  /// [bucketId] - L'identifiant du bucket de destination.
  /// [data] - Les données binaires à téléverser.
  /// [filename] - Le nom du fichier.
  /// [fileId] - L'identifiant unique du fichier (optionnel).
  /// [read] - Liste des permissions de lecture (optionnel).
  /// [write] - Liste des permissions d'écriture (optionnel).
  /// [onProgress] - Callback pour suivre la progression du téléversement (optionnel).
  ///
  /// Retourne l'objet File créé.
  Future<models.File> uploadFileFromBytes({
    required String bucketId,
    required Uint8List data,
    required String filename,
    String? fileId,
    List<String>? read,
    List<String>? write,
    void Function(UploadProgress)? onProgress,
  }) async {
    try {
      return await uploadFile(
        bucketId: bucketId,
        fileId: fileId,
        file: InputFile.fromBytes(bytes: data, filename: filename),
        read: read,
        write: write,
        onProgress: onProgress,
      );
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('Erreur lors du téléversement du fichier depuis les bytes : $error\n$stackTrace');
      }
      rethrow;
    }
  }

  /// Télécharge un fichier depuis Appwrite.
  ///
  /// [bucketId] - L'identifiant du bucket source.
  /// [fileId] - L'identifiant du fichier à télécharger.
  ///
  /// Retourne les données binaires du fichier.
  Future<Uint8List> downloadFile({
    required String bucketId,
    required String fileId,
  }) async {
    try {
      final storage = await _getStorage();
      return await storage.getFileDownload(
        bucketId: bucketId,
        fileId: fileId,
      );
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('Erreur lors du téléchargement du fichier : $error\n$stackTrace');
      }
      rethrow;
    }
  }

  /// Obtient l'URL de prévisualisation d'un fichier.
  ///
  /// [bucketId] - L'identifiant du bucket.
  /// [fileId] - L'identifiant du fichier.
  /// [width] - Largeur de l'image (optionnel, pour les images).
  /// [height] - Hauteur de l'image (optionnel, pour les images).
  /// [gravity] - Point de focalisation pour le redimensionnement (optionnel).
  /// [quality] - Qualité de l'image (optionnel, 0-100).
  /// [borderWidth] - Largeur de la bordure (optionnel).
  /// [borderColor] - Couleur de la bordure (optionnel).
  /// [borderRadius] - Rayon de la bordure (optionnel).
  /// [opacity] - Opacité de l'image (optionnel, 0-1).
  /// [rotation] - Rotation de l'image (optionnel, 0-360).
  /// [background] - Couleur de fond (optionnel).
  /// [output] - Format de sortie (optionnel).
  ///
  /// Retourne l'URL de prévisualisation.
  Future<String> getFilePreviewUrl({
    required String bucketId,
    required String fileId,
    int? width,
    int? height,
    String? gravity,
    int? quality,
    int? borderWidth,
    String? borderColor,
    int? borderRadius,
    double? opacity,
    int? rotation,
    String? background,
    String? output,
  }) async {
    try {
      final endpoint = (await _ref.read(appwriteClientProvider.future)).endPoint;
      final projectId = dotenv.env['APPWRITE_PROJECT_ID'] ?? '';
      
      final baseUrl = '$endpoint/storage/buckets/$bucketId/files/$fileId/preview';
      final params = <String, String>{};
      
      if (width != null) params['width'] = width.toString();
      if (height != null) params['height'] = height.toString();
      if (gravity != null) params['gravity'] = gravity;
      if (quality != null) params['quality'] = quality.toString();
      if (borderWidth != null) params['borderWidth'] = borderWidth.toString();
      if (borderColor != null) params['borderColor'] = borderColor;
      if (borderRadius != null) params['borderRadius'] = borderRadius.toString();
      if (opacity != null) params['opacity'] = opacity.toString();
      if (rotation != null) params['rotation'] = rotation.toString();
      if (background != null) params['background'] = background;
      if (output != null) params['output'] = output;
      
      if (params.isEmpty) {
        return '$baseUrl?project=$projectId';
      }
      
      final queryString = params.entries
          .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
          .join('&');
      
      return '$baseUrl?$queryString&project=$projectId';
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('Erreur lors de la génération de l\'URL de prévisualisation : $error\n$stackTrace');
      }
      rethrow;
    }
  }

  /// Obtient l'URL de visualisation d'un fichier.
  ///
  /// [bucketId] - L'identifiant du bucket.
  /// [fileId] - L'identifiant du fichier.
  ///
  /// Retourne l'URL de visualisation.
  Future<String> getFileViewUrl({
    required String bucketId,
    required String fileId,
  }) async {
    try {
      final endpoint = (await _ref.read(appwriteClientProvider.future)).endPoint;
      final projectId = dotenv.env['APPWRITE_PROJECT_ID'] ?? '';
      return '$endpoint/storage/buckets/$bucketId/files/$fileId/view?project=$projectId';
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('Erreur lors de la génération de l\'URL de visualisation : $error\n$stackTrace');
      }
      rethrow;
    }
  }

  /// Obtient les informations d'un fichier.
  ///
  /// [bucketId] - L'identifiant du bucket.
  /// [fileId] - L'identifiant du fichier.
  ///
  /// Retourne l'objet File avec les informations du fichier.
  Future<models.File> getFile({
    required String bucketId,
    required String fileId,
  }) async {
    try {
      final storage = await _getStorage();
      return await storage.getFile(
        bucketId: bucketId,
        fileId: fileId,
      );
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('Erreur lors de la récupération du fichier : $error\n$stackTrace');
      }
      rethrow;
    }
  }

  /// Liste les fichiers d'un bucket.
  ///
  /// [bucketId] - L'identifiant du bucket.
  /// [queries] - Liste des requêtes de filtrage (optionnel).
  /// [search] - Terme de recherche (optionnel).
  ///
  /// Retourne la liste des fichiers.
  Future<models.FileList> listFiles({
    required String bucketId,
    List<String>? queries,
    String? search,
  }) async {
    try {
      final storage = await _getStorage();
      return await storage.listFiles(
        bucketId: bucketId,
        queries: queries,
        search: search,
      );
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('Erreur lors de la liste des fichiers : $error\n$stackTrace');
      }
      rethrow;
    }
  }

  /// Met à jour un fichier existant.
  ///
  /// [bucketId] - L'identifiant du bucket.
  /// [fileId] - L'identifiant du fichier à mettre à jour.
  /// [name] - Nouveau nom du fichier (optionnel).
  /// [read] - Liste des permissions de lecture (optionnel).
  /// [write] - Liste des permissions d'écriture (optionnel).
  ///
  /// Retourne l'objet File mis à jour.
  Future<models.File> updateFile({
    required String bucketId,
    required String fileId,
    String? name,
    List<String>? read,
    List<String>? write,
  }) async {
    try {
      final storage = await _getStorage();
      return await storage.updateFile(
        bucketId: bucketId,
        fileId: fileId,
        name: name,
        permissions: [
          if (read != null) ...read.map((r) => Permission.read(r)),
          if (write != null) ...write.map((w) => Permission.write(w)),
        ],
      );
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('Erreur lors de la mise à jour du fichier : $error\n$stackTrace');
      }
      rethrow;
    }
  }

  /// Supprime un fichier.
  ///
  /// [bucketId] - L'identifiant du bucket.
  /// [fileId] - L'identifiant du fichier à supprimer.
  ///
  /// Retourne une Future qui se complète lorsque la suppression est terminée.
  Future<void> deleteFile({
    required String bucketId,
    required String fileId,
  }) async {
    try {
      final storage = await _getStorage();
      await storage.deleteFile(
        bucketId: bucketId,
        fileId: fileId,
      );
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('Erreur lors de la suppression du fichier : $error\n$stackTrace');
      }
      rethrow;
    }
  }

  /// Supprime plusieurs fichiers en une seule opération.
  ///
  /// [bucketId] - L'identifiant du bucket.
  /// [fileIds] - Liste des identifiants des fichiers à supprimer.
  ///
  /// Retourne une Future qui se complète lorsque toutes les suppressions sont terminées.
  Future<void> deleteFiles({
    required String bucketId,
    required List<String> fileIds,
  }) async {
    try {
      await Future.wait(
        fileIds.map(
          (fileId) => deleteFile(
            bucketId: bucketId,
            fileId: fileId,
          ),
        ),
      );
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('Erreur lors de la suppression multiple des fichiers : $error\n$stackTrace');
      }
      rethrow;
    }
  }
}

