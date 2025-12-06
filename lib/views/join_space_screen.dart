import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dashboard_screen.dart';
import '../models/space_model.dart';
import '../models/user_model.dart';

class JoinSpaceScreen extends StatefulWidget {
  const JoinSpaceScreen({super.key});

  @override
  State<JoinSpaceScreen> createState() => _JoinSpaceScreenState();
}

class _JoinSpaceScreenState extends State<JoinSpaceScreen> {
  final _linkController = TextEditingController();
  bool isLoading = false;
  String? _createdSpaceLink; // Stocke le lien créé
  
  // Instances Firebase
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    _linkController.dispose();
    super.dispose();
  }

  // Extraire l'ID de l'espace depuis un lien
  String? _extractSpaceId(String link) {
    final text = link.trim();
    
    // Si c'est juste l'ID (format UUID)
    if (_isValidSpaceId(text)) {
      return text;
    }
    
    // Si format "HeritageLens/ID"
    if (text.contains('/')) {
      final parts = text.split('/');
      final lastPart = parts.last;
      if (_isValidSpaceId(lastPart)) {
        return lastPart;
      }
    }
    
    return null;
  }

  bool _isValidSpaceId(String id) {
    // Validation simple d'UUID
    return id.length > 10 && !id.contains(' ');
  }

  // Formater un lien d'espace
  String _formatSpaceLink(String spaceId) {
    return 'HeritageLens/$spaceId';
  }

  Future<void> _joinSpace() async {
    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vous devez être connecté')),
      );
      return;
    }

    final input = _linkController.text.trim();
    if (input.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer un lien ou un ID')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      // Extraire l'ID de l'espace
      final spaceId = _extractSpaceId(input);
      if (spaceId == null) {
        throw Exception('Format de lien invalide');
      }

      // 1. Vérifier si l'espace existe
      final spaceDoc = await _firestore.collection('spaces').doc(spaceId).get();
      if (!spaceDoc.exists) {
        throw Exception('Espace non trouvé');
      }

      // 2. Récupérer l'espace
      final space = SpaceModel.fromMap(spaceId, spaceDoc.data()!);

      // 3. Vérifier si l'utilisateur est déjà membre
      if (space.isMember(user.uid)) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vous êtes déjà membre de cet espace')),
        );
        // ignore: use_build_context_synchronously
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
        return;
      }

      // Ajouter l'utilisateur à l'espace
      await _firestore.collection('spaces').doc(spaceId).update({
        'members': FieldValue.arrayUnion([user.uid]),
      });

      // Mettre à jour le UserModel
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        final userData = userDoc.data()!;
        final userSpaces = List<String>.from(userData['spaces'] ?? []);
        if (!userSpaces.contains(spaceId)) {
          userSpaces.add(spaceId);
          await _firestore.collection('users').doc(user.uid).update({
            'spaces': userSpaces,
          });
        }
      }

      // 6. Afficher succès et naviguer
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Vous avez rejoint "${space.name}"')),
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // Méthode pour créer un espace AVEC GÉNÉRATION DE LIEN
  Future<void> _createSpace() async {
    final user = _auth.currentUser;
    if (user == null) return;

    setState(() {
      isLoading = true;
      _createdSpaceLink = null;
    });

    try {
      // 1. Générer un ID unique pour l'espace
      final spaceId = _firestore.collection('spaces').doc().id;
      
      // 2. Demander le nom de l'espace
      final spaceName = await _showCreateSpaceDialog();
      if (spaceName == null || spaceName.isEmpty) {
        setState(() => isLoading = false);
        return;
      }

      // 3. Créer le SpaceModel
      final newSpace = SpaceModel(
        id: spaceId,
        name: spaceName,
        description: 'Espace collaboratif créé par ${user.displayName ?? user.email}',
        createdAt: DateTime.now(),
        createdBy: user.uid,
        members: [user.uid], // Le créateur est automatiquement membre
      );

      // 4. Sauvegarder dans Firestore
      await _firestore.collection('spaces').doc(spaceId).set(newSpace.toMap());

      // 5. Mettre à jour le UserModel
      await _firestore.collection('users').doc(user.uid).update({
        'spaces': FieldValue.arrayUnion([spaceId]),
      });

      // 6. Générer le lien
      final spaceLink = _formatSpaceLink(spaceId);
      
      // 7. Afficher le lien généré
      if (mounted) {
        setState(() {
          _createdSpaceLink = spaceLink;
          isLoading = false;
        });
        
        await _showLinkGeneratedDialog(spaceLink, spaceName);
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur création: ${e.toString()}')),
        );
      }
    }
  }

  // Boîte de dialogue pour créer l'espace
  Future<String?> _showCreateSpaceDialog() async {
    final nameController = TextEditingController();
    
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nommez votre espace'),
          content: TextField(
            controller: nameController,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Ex: Notre Dame Reconstruction',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isNotEmpty) {
                  Navigator.pop(context, name);
                }
              },
              child: const Text('Créer'),
            ),
          ],
        );
      },
    );
  }

  // Boîte de dialogue pour afficher le lien généré
  Future<void> _showLinkGeneratedDialog(String link, String spaceName) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Espace créé !'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '"$spaceName" a été créé avec succès.',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              const Text(
                'Lien d\'invitation :',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  // Copier dans le presse-papier
                  // Clipboard.setData(ClipboardData(text: link));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Lien copié !')),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SelectableText(
                    link,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Partagez ce lien pour inviter d\'autres personnes.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fermer'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const DashboardScreen()),
                );
              },
              child: const Text('Aller au dashboard'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Espaces Collaboratifs',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'serif',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _createdSpaceLink != null
                    ? 'Votre espace a été créé !'
                    : 'Rejoignez un espace avec un lien d\'invitation',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 40),
              
              // Afficher le lien créé s'il existe
              if (_createdSpaceLink != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green[700]),
                          const SizedBox(width: 8),
                          const Text(
                            'Espace créé avec succès',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Lien d\'invitation :',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () {
                          // Copier le lien
                          // Clipboard.setData(ClipboardData(text: _createdSpaceLink!));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Lien copié !')),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: SelectableText(
                                  _createdSpaceLink!,
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              Icon(Icons.content_copy, size: 16, color: Colors.grey[600]),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (_) => const DashboardScreen()),
                          );
                        },
                        child: const Text('Aller au dashboard'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],

              const Text(
                "Lien d'invitation",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _linkController,
                decoration: InputDecoration(
                  hintText: "HeritageLens/ID ou ID seul...",
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: isLoading ? null : _joinSpace,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Rejoindre l\'espace',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: isLoading ? null : _createSpace,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black,
                  side: BorderSide(color: Colors.grey[300]!),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Créer un nouvel espace',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 48),
              const Text(
                "Comment fonctionnent les espaces ?",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'serif',
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "1. Créez un espace → Obtenez un lien unique\n"
                "2. Partagez le lien → Invitez d'autres personnes\n"
                "3. Placez des modèles AR → Tous les membres les voient",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Exemple de lien généré :',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'HeritageLens/c2ff0d8-8a5e-4a6d-9f0f-4d6e3a6a86f1',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[700],
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(50),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.home_outlined, color: Colors.white),
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const DashboardScreen()),
                        );
                      },
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.group_add, color: Colors.black),
                    ),
                    IconButton(
                      icon: const Icon(Icons.person_outline, color: Colors.white),
                      onPressed: () {
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}