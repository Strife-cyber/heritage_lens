// lib/models/ar_model.dart

class ARModel {
  final String? id;
  final String name;
  final String description;
  final String modelUrl;
  final String? thumbnailUrl;
  final String? spaceId;
  final DateTime createdAt;
  final String createdBy;
  final double scale;
  final List<double> position;
  final List<double> rotation;
  final Map<String, dynamic>? metadata;

  // Formats supportés
  static const List<String> supportedFormats = ['.glb', '.gltf', '.fbx', '.obj'];

  ARModel({
    this.id,
    required this.name,
    required this.description,
    required this.modelUrl,
    this.thumbnailUrl,
    this.spaceId,
    required this.createdAt,
    required this.createdBy,
    this.scale = 1.0,
    this.position = const [0, 0, 0],
    this.rotation = const [0, 0, 0],
    this.metadata,
  }) : assert(scale > 0, 'Scale doit être positif'),
       assert(position.length == 3, 'Position doit avoir 3 valeurs [x, y, z]'),
       assert(rotation.length == 3, 'Rotation doit avoir 3 valeurs [x, y, z]');

  // Convertir en Map pour Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'modelUrl': modelUrl,
      'thumbnailUrl': thumbnailUrl,
      'spaceId': spaceId,
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
      'scale': scale,
      'position': position,
      'rotation': rotation,
      'metadata': metadata,
    };
  }

  // Créer depuis Map (depuis Firestore)
  factory ARModel.fromMap(String id, Map<String, dynamic> map) {
    return ARModel(
      id: id,
      name: map['name']?.toString() ?? 'Modèle sans nom',
      description: map['description']?.toString() ?? '',
      modelUrl: map['modelUrl']?.toString() ?? '',
      thumbnailUrl: map['thumbnailUrl']?.toString(),
      spaceId: map['spaceId']?.toString(),
      createdAt: map['createdAt'] != null 
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      createdBy: map['createdBy']?.toString() ?? '',
      scale: (map['scale'] ?? 1.0).toDouble(),
      position: _parseDoubleList(map['position'], defaultValue: [0, 0, 0]),
      rotation: _parseDoubleList(map['rotation'], defaultValue: [0, 0, 0]),
      metadata: map['metadata'] is Map 
          ? Map<String, dynamic>.from(map['metadata']) 
          : null,
    );
  }

  // Méthode helper pour parser les listes de doubles
  static List<double> _parseDoubleList(
    dynamic data, {
    required List<double> defaultValue,
  }) {
    if (data is List) {
      try {
        return data.map((e) {
          if (e is num) return e.toDouble();
          if (e is String) return double.tryParse(e) ?? 0.0;
          return 0.0;
        }).toList();
      } catch (e) {
        return defaultValue;
      }
    }
    return defaultValue;
  }

  // Méthode pour copier avec modifications
  ARModel copyWith({
    String? id,
    String? name,
    String? description,
    String? modelUrl,
    String? thumbnailUrl,
    String? spaceId,
    DateTime? createdAt,
    String? createdBy,
    double? scale,
    List<double>? position,
    List<double>? rotation,
    Map<String, dynamic>? metadata,
  }) {
    return ARModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      modelUrl: modelUrl ?? this.modelUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      spaceId: spaceId ?? this.spaceId,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      scale: scale ?? this.scale,
      position: position ?? this.position,
      rotation: rotation ?? this.rotation,
      metadata: metadata ?? this.metadata,
    );
  }

  // === MÉTHODES UTILES ===

  // Vérifier si le modèle appartient à un espace
  bool get hasSpace => spaceId != null && spaceId!.isNotEmpty;

  // Vérifier si c'est le créateur
  bool isCreator(String userId) => createdBy == userId;

  // Méthode pour préparer les données AR
  Map<String, dynamic> toARData() {
    return {
      'modelUrl': modelUrl,
      'scale': scale,
      'position': position,
      'rotation': rotation,
      'name': name, // Pour affichage dans l'AR
    };
  }

  // Vérifier les formats supportés
  bool get isSupportedFormat {
    final url = modelUrl.toLowerCase();
    return supportedFormats.any((format) => url.endsWith(format));
  }

  // Obtenir le type de format
  String get formatType {
    final url = modelUrl.toLowerCase();
    for (final format in supportedFormats) {
      if (url.endsWith(format)) {
        return format.toUpperCase().replaceAll('.', '');
      }
    }
    return 'AUTRE';
  }

  // Générer une miniature par défaut si absente
  String get thumbnailOrDefault {
    return thumbnailUrl ?? 
           'https://via.placeholder.com/150/cccccc/666666?text=${name.substring(0, 1)}';
  }

  // Vérifier si la position est à l'origine
  bool get isAtOrigin {
    return position[0] == 0 && position[1] == 0 && position[2] == 0;
  }
}