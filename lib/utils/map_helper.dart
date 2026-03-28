import 'package:cloud_firestore/cloud_firestore.dart';

/// Récupère une valeur de manière sécurisée avec une valeur par défaut optionnelle.
/// 
/// [map] : Le dictionnaire de données Firestore.
/// [key] : La clé à extraire.
/// [defaultValue] : La valeur à retourner si la clé est absente ou de mauvais type.
T? getValue<T>(Map<String, dynamic> map, String key, {T? defaultValue}) {
  final value = map[key];
  
  // Vérification si la valeur existe
  if (value == null) return defaultValue;

  // Gestion du cas particulier des nombres dans Firestore :
  // Firestore stocke souvent 20.0 comme un 'int' (20). 
  // Si on attend un 'double', il faut convertir explicitement.
  if (T == double && value is int) {
    return value.toDouble() as T;
  }

  // Vérification du type générique
  if (value is T) {
    return value;
  }
  
  return defaultValue;
}

/// Récupère une liste de manière sécurisée et typée.
/// 
/// Si la donnée n'est pas une liste, retourne une liste vide [].
/// Filtre automatiquement les éléments qui ne correspondent pas au type [T].
List<T> getList<T>(Map<String, dynamic> map, String key) {
  final value = map[key];
  if (value is List) {
    // .whereType<T>() est magique : il enlève les nulls et les mauvais types
    return value.whereType<T>().toList();
  }
  return [];
}

/// Analyse et convertit une date provenant de Firestore (Timestamp, String, int, ou double).
/// 
/// [utc] : Si vrai, convertit la date en UTC (recommandé pour la cohérence des données).
DateTime? getDate(
  Map<String, dynamic> map,
  String key, {
  DateTime? defaultValue,
  bool utc = true,
}) {
  if (!map.containsKey(key)) return defaultValue;

  final value = map[key];
  if (value == null) return defaultValue;

  // --- 1. Cas Native Firebase Timestamp (Le plus fréquent) ---
  if (value is Timestamp) {
    final date = value.toDate();
    return utc ? date.toUtc() : date;
  }

  // --- 2. Cas déjà DateTime ---
  if (value is DateTime) {
    return utc ? value.toUtc() : value;
  }

  // --- 3. Cas Numérique (Timestamp Unix) ---
  if (value is int || value is double) {
    final num timestamp = value as num;
    // Heuristique : secondes vs millisecondes
    // Si < 10^10, on traite comme des secondes.
    final isSeconds = timestamp < 10000000000;
    final millis = isSeconds ? (timestamp * 1000).round() : timestamp.round();

    try {
      return DateTime.fromMillisecondsSinceEpoch(millis, isUtc: utc);
    } catch (_) {
      return defaultValue;
    }
  }

  // --- 4. Cas String (Format ISO 8601 ou texte numérique) ---
  if (value is String) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return defaultValue;

    // Tentative de parse numérique dans une String
    final numeric = num.tryParse(trimmed);
    if (numeric != null) {
      final isSeconds = numeric < 10000000000;
      final millis = isSeconds ? (numeric * 1000).round() : numeric.round();
      try {
        return DateTime.fromMillisecondsSinceEpoch(millis, isUtc: utc);
      } catch (_) {}
    }

    // Tentative de parse format date standard
    try {
      final parsed = DateTime.parse(trimmed);
      return utc ? parsed.toUtc() : parsed;
    } catch (_) {
      return defaultValue;
    }
  }

  return defaultValue;
}