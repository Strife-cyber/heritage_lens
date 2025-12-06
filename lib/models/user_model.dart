// Model pour les utilisateurs 
class UserModel {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final DateTime createdAt;
  final List<String> spaces;

  UserModel({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
    required this.createdAt,
    this.spaces = const [],
  });

  // Convertir en Map pour Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'createdAt': createdAt.toIso8601String(),
      'spaces': spaces,
    };
  }

  // Créer depuis un Map (depuis Firestore)
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      displayName: map['displayName']?.toString(),
      photoUrl: map['photoUrl']?.toString(),
      createdAt: map['createdAt'] != null 
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      spaces: map['spaces'] is List 
          ? List<String>.from(map['spaces'].map((x) => x.toString()))
          : [],
    );
  }

  // Méthode pour copier avec modifications
  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    DateTime? createdAt,
    List<String>? spaces,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      spaces: spaces ?? this.spaces,
    );
  }

  // Vérifie si l'utilisateur appartient à un espace
  bool isMemberOfSpace(String spaceId) {
    return spaces.contains(spaceId);
  }

  // Ajouter un espace
  UserModel addSpace(String spaceId) {
    return copyWith(spaces: [...spaces, spaceId]);
  }

  // Retirer un espace
  UserModel removeSpace(String spaceId) {
    return copyWith(spaces: spaces.where((id) => id != spaceId).toList());
  }
}