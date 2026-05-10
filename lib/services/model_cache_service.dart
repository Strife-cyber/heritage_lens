import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

/// Simple persistent cache for remote 3D models.
///
/// Goal: download once and re-use the local file (so `flutter_3d_controller`
/// doesn't repeatedly fetch the model URL through WebView/CORS).
class ModelCacheService {
  final http.Client _httpClient;

  ModelCacheService({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  Future<String?> getCachedModelFileUrl(String? modelUrl) async {
    final url = modelUrl?.trim();
    if (url == null || url.isEmpty) return null;

    final uri = Uri.parse(url);
    final ext = _guessExtension(uri);

    final appDir = await getApplicationDocumentsDirectory();
    final cacheDir = Directory('${appDir.path}/3d_models_cache');
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }

    final key = _sha256(url);
    final modelFile = File('${cacheDir.path}/$key$ext');
    final metaFile = File('${cacheDir.path}/$key.meta.json');

    // If we already have a file, try to validate with ETag/Last-Modified.
    if (await modelFile.exists()) {
      try {
        final meta = await _readMeta(metaFile);
        final head = await _httpClient
            .head(uri, headers: const {'Accept': '*/*'}).timeout(
          const Duration(seconds: 10),
        );

        // Some servers don't support HEAD; in that case we keep the cached file.
        if (head.statusCode >= 200 && head.statusCode < 300) {
          final currentEtag = head.headers['etag'];
          final currentLastModified = head.headers['last-modified'];

          final cachedEtag = meta['etag'] as String?;
          final cachedLastModified = meta['lastModified'] as String?;

          final etagMatches = currentEtag != null &&
              cachedEtag != null &&
              currentEtag == cachedEtag;
          final lastModifiedMatches = currentLastModified != null &&
              cachedLastModified != null &&
              currentLastModified == cachedLastModified;

          // If the server doesn't provide validation headers, keep the cached file.
          final noValidationHeaders =
              currentEtag == null && currentLastModified == null;

          if (noValidationHeaders || etagMatches || lastModifiedMatches) {
            return 'file://${modelFile.path}';
          }
        }
      } catch (_) {
        // If validation fails, we still try to use the cached file.
        return 'file://${modelFile.path}';
      }
    }

    // Download and cache.
    final tmpFile = File('${cacheDir.path}/$key.download');

    final request = http.Request('GET', uri);
    // Allow cache revalidation if server returns ETag.
    if (await metaFile.exists()) {
      final meta = await _readMeta(metaFile);
      final cachedEtag = meta['etag'] as String?;
      if (cachedEtag != null && cachedEtag.isNotEmpty) {
        request.headers['If-None-Match'] = cachedEtag;
      }
    }

    final streamed = await _httpClient.send(request).timeout(
      const Duration(seconds: 60),
    );

    if (streamed.statusCode == 304 && await modelFile.exists()) {
      // Not modified: update meta (if any) and use cached file.
      final head = await _httpClient.head(uri).timeout(
        const Duration(seconds: 10),
      );
      await _writeMeta(metaFile, head.headers);
      return 'file://${modelFile.path}';
    }

    if (streamed.statusCode < 200 || streamed.statusCode >= 300) {
      // If download fails but we have an older cached file, fall back to it.
      if (await modelFile.exists()) return 'file://${modelFile.path}';
      throw HttpException(
        'Failed to download model ($url) status=${streamed.statusCode}',
      );
    }

    final bytes = await streamed.stream.toBytes();
    await tmpFile.writeAsBytes(bytes, flush: true);
    await tmpFile.rename(modelFile.path);

    await _writeMeta(metaFile, streamed.headers);
    return 'file://${modelFile.path}';
  }

  Future<Map<String, dynamic>> _readMeta(File metaFile) async {
    if (!await metaFile.exists()) return const <String, dynamic>{};
    final raw = await metaFile.readAsString();
    return (jsonDecode(raw) as Map).cast<String, dynamic>();
  }

  Future<void> _writeMeta(File metaFile, Map<String, String> headers) async {
    final meta = <String, dynamic>{
      'etag': headers['etag'],
      'lastModified': headers['last-modified'],
      'updatedAt': DateTime.now().toIso8601String(),
    };
    await metaFile.writeAsString(jsonEncode(meta), flush: true);
  }

  static String _sha256(String input) {
    final bytes = utf8.encode(input);
    return sha256.convert(bytes).toString();
  }

  static String _guessExtension(Uri uri) {
    final path = uri.path.toLowerCase();
    if (path.endsWith('.glb')) return '.glb';
    if (path.endsWith('.gltf')) return '.gltf';
    if (path.endsWith('.obj')) return '.obj';
    if (path.endsWith('.fbx')) return '.fbx';
    // Default: the app usually uses GLB.
    return '.glb';
  }
}

