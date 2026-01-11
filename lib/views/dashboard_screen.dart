import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_screen.dart';
import '../models/user_model.dart';
import '../models/space_model.dart';
import '../models/ar_model.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedTab = 0;
  int _selectedBottomNav = 0;
  
  // Instances Firebase
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Données
  UserModel? _currentUser;
  List<ARModel> _arModels = [];
  List<SpaceModel> _spaces = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      // 1. Charger le UserModel
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          _currentUser = UserModel.fromMap(userDoc.data()!);
        });
      }

      // 2. Charger les modèles AR de l'utilisateur
      final arModelsQuery = await _firestore
          .collection('ar_models')
          .where('createdBy', isEqualTo: user.uid)
          .get();

      final arModels = arModelsQuery.docs
          .map((doc) => ARModel.fromMap(doc.id, doc.data()))
          .toList();

      // 3. Charger les espaces de l'utilisateur
      final spacesQuery = await _firestore
          .collection('spaces')
          .where('members', arrayContains: user.uid)
          .get();

      final spaces = spacesQuery.docs
          .map((doc) => SpaceModel.fromMap(doc.id, doc.data()))
          .toList();

      setState(() {
        _arModels = arModels;
        _spaces = spaces;
        _isLoading = false;
      });
    } catch (e) {
      print('Erreur chargement données: $e');
      setState(() => _isLoading = false);
    }
  }

  String get userName {
    if (_currentUser != null) {
      return _currentUser!.displayName ?? 
             _currentUser!.email.split('@').first;
    }
    
    final user = _auth.currentUser;
    final name = user?.displayName;
    return name ?? user?.email?.split('@').first ?? 'Utilisateur';
  }

  // Statistiques réelles
  int get favoriteCount {
    // Pour l'instant, on retourne le nombre d'espaces
    return _spaces.length;
  }

  int get modelCount {
    return _arModels.length;
  }

  Future<void> _signOut() async {
    await _auth.signOut();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AuthScreen()),
      );
    }
  }

  Future<void> _createNewSpace() async {
    final user = _auth.currentUser;
    if (user == null) return;

    // TODO: Implémenter une boîte de dialogue pour créer un espace
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Création d\'espace à implémenter'),
      ),
    );
  }

  Future<void> _addNewModel() async {
    final user = _auth.currentUser;
    if (user == null) return;

    // TODO: Implémenter l'ajout de modèle AR
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ajout de modèle AR à implémenter'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bonjour, ${userName.substring(0, 1).toUpperCase()}${userName.substring(1)}',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'serif',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Alors, Qu'allons nous faire aujourd'hui ?",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: _signOut,
                    tooltip: 'Déconnexion',
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IntrinsicHeight(
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildStatItem(
                          favoriteCount.toString(),
                          'Espaces',
                        ),
                      ),
                      VerticalDivider(
                        color: Colors.grey[300],
                        thickness: 1,
                        width: 1,
                      ),
                      Expanded(
                        child: _buildStatItem(
                          modelCount.toString(),
                          'Modèles',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _addNewModel,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Ajouter un Modèle',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _createNewSpace,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Créer un Espace',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  _buildTabButton(0, Icons.star_outline, 'Favoris'),
                  const SizedBox(width: 16),
                  _buildTabButton(1, Icons.grid_view_rounded, 'Modèles'),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: _selectedTab == 0
                    ? _buildSpacesList() // Remplace Favoris par Espaces
                    : _buildModelsGrid(),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(50),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildBottomNavItem(0, Icons.home_outlined),
                    _buildBottomNavItem(1, Icons.view_in_ar),
                    _buildBottomNavItem(2, Icons.person_outline),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(int index, IconData icon, String label) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Column(
        children: [
          Icon(
            icon,
            size: 28,
            color: isSelected ? Colors.black : Colors.grey[400],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? Colors.black : Colors.grey[400],
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpacesList() {
    if (_spaces.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.group_outlined,
              size: 60,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun espace',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Rejoignez ou créez un espace pour commencer',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _spaces.length,
      itemBuilder: (context, index) {
        final space = _spaces[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
          child: ListTile(
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.deepPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.group,
                color: Colors.deepPurple,
              ),
            ),
            title: Text(
              space.name,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              '${space.memberCount} membre${space.memberCount > 1 ? 's' : ''} • ${space.arModelCount} modèle${space.arModelCount > 1 ? 's' : ''}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.arrow_forward_ios, size: 16),
              onPressed: () {
                // TODO: Navigation vers l'espace
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Ouvrir ${space.name}')),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildModelsGrid() {
    if (_arModels.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.view_in_ar_outlined,
              size: 60,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun modèle AR',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ajoutez votre premier modèle 3D',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.9,
      ),
      itemCount: _arModels.length,
      itemBuilder: (context, index) {
        final model = _arModels[index];
        return GestureDetector(
          onTap: () {
            // TODO: Voir les détails du modèle
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Ouvrir ${model.name}')),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    child: Container(
                      color: Colors.grey[100],
                      child: Center(
                        child: Icon(
                          Icons.view_in_ar_outlined,
                          size: 40,
                          color: Colors.grey[400],
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        model.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        model.formatType,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomNavItem(int index, IconData icon) {
    final isSelected = _selectedBottomNav == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedBottomNav = index),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.black : Colors.white,
          size: 24,
        ),
      ),
    );
  }
}