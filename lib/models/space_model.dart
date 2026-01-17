// model pour les espaces collaboratif

class SpaceModel {
  final String? id;
  final String name;
  final String description;
  final String? imageUrl;
  final String? location;
  final String? category;
  final DateTime createdAt;
  final String createdBy;
  final List<String> members; // IDs des utilisateurs membres
  final List<String> arModels; // IDs des modèles AR dans cet espace
  // final bool isPublic; // À DÉCOMMENTER POUR FUTURE FONCTIONNALITÉ PUBLIQUE
  final Map<String, dynamic>? metadata;

  SpaceModel({
    this.id,
    required this.name,
    required this.description,
    this.imageUrl,
    this.location,
    this.category,
    required this.createdAt,
    required this.createdBy,
    List<String>? members,
    List<String>? arModels,
    // this.isPublic = false, // PAR DÉFAUT PRIVÉ - À DÉCOMMENTER POUR PUBLIC
    this.metadata,
  })  : members = members ?? [createdBy], // Le créateur est automatiquement membre
        arModels = arModels ?? []; // Pas de modèles AR par défaut
        // isPublic = isPublic; // À DÉCOMMENTER

  // Convertir en Map pour Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'location': location,
      'category': category,
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
      'members': members,
      'arModels': arModels,
      // 'isPublic': isPublic, // À DÉCOMMENTER POUR FUTURE FONCTIONNALITÉ PUBLIQUE
      'metadata': metadata,
    };
  }

  // Créer depuis Map (depuis Firestore)
  factory SpaceModel.fromMap(String id, Map<String, dynamic> map) {
    return SpaceModel(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'],
      location: map['location'],
      category: map['category'],
      createdAt: DateTime.parse(map['createdAt']),
      createdBy: map['createdBy'] ?? '',
      members: List<String>.from(map['members'] ?? []),
      arModels: List<String>.from(map['arModels'] ?? []),
      // isPublic: map['isPublic'] ?? false, // PAR DÉFAUT PRIVÉ - À DÉCOMMENTER
      metadata: map['metadata'],
    );
  }

  // Méthode pour copier avec modifications
  SpaceModel copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    String? location,
    String? category,
    DateTime? createdAt,
    String? createdBy,
    List<String>? members,
    List<String>? arModels,
    // bool? isPublic, // À DÉCOMMENTER POUR FUTURE FONCTIONNALITÉ PUBLIQUE
    Map<String, dynamic>? metadata,
  }) {
    return SpaceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      location: location ?? this.location,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      members: members ?? this.members,
      arModels: arModels ?? this.arModels,
      // isPublic: isPublic ?? this.isPublic, // À DÉCOMMENTER
      metadata: metadata ?? this.metadata,
    );
  }

  // === MÉTHODES UTILES POUR GÉRER LES ESPACES PRIVÉS ===

  // Vérifier si un utilisateur est membre
  bool isMember(String userId) {
    return members.contains(userId);
  }

  // Ajouter un utilisateur comme membre
  SpaceModel addMember(String userId) {
    if (!members.contains(userId)) {
      return copyWith(members: [...members, userId]);
    }
    return this; // Déjà membre
  }

  // Retirer un utilisateur
  SpaceModel removeMember(String userId) {
    return copyWith(
      members: members.where((memberId) => memberId != userId).toList(),
    );
  }

  // Vérifier si l'utilisateur est le créateur
  bool isCreator(String userId) {
    return createdBy == userId;
  }

  // Ajouter un modèle AR à l'espace
  SpaceModel addARModel(String arModelId) {
    if (!arModels.contains(arModelId)) {
      return copyWith(arModels: [...arModels, arModelId]);
    }
    return this; // Modèle déjà présent
  }

  // Retirer un modèle AR
  SpaceModel removeARModel(String arModelId) {
    return copyWith(
      arModels: arModels.where((modelId) => modelId != arModelId).toList(),
    );
  }

  // Vérifier si l'espace est vide (pas de modèles AR)
  bool get isEmpty {
    return arModels.isEmpty;
  }

  // Nombre de membres
  int get memberCount {
    return members.length;
  }

  // Nombre de modèles AR
  int get arModelCount {
    return arModels.length;
  }

  // VERSION AVEC OPTION PUBLIQUE (À DÉCOMMENTER PLUS TARD)
  /*
  // Vérifier si l'espace est accessible (membre OU public)
  bool isAccessible(String userId) {
    return isPublic || isMember(userId);
  }
  */
}