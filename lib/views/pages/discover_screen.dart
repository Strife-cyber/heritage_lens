import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heritage_lens/services/firestore_service.dart';
import 'package:heritage_lens/views/widgets/standard_text_helpers.dart';

import '../../models/ar_model.dart';
import '../widgets/standard_text_field.dart';

class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> {
  List<ARModel> _publicModels = [];
  bool _isLoading = true;

  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _loadPublicModels();
  }

  Future<void> _loadPublicModels() async {
    try {
      // TODO: adapter la query selon tes besoins réels
      final query = await ref.read(firestoreServiceProvider).getDocuments(
        collectionPath: 'ar_models',
        where: [WhereCondition(field: 'isPublic', isEqualTo: true)],
        limit: 20,
      );

      final models = query.docs
          .map((doc) => ARModel.fromMap(doc.id, doc.data()))
          .toList();

      if (mounted) {
        setState(() {
          _publicModels = models;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Erreur chargement modèles publics: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'HeritageLens',
                style: AppText.titleXL()
              ),
              const SizedBox(height: 4),
              Text(
                'Histoire et culture à travers la RA',
                style: AppText.bodyS()
              ),
              const SizedBox(height: 24),

              StandardTextField(
                label: 'Recherche...',
                controller: TextEditingController(),
                icon: Icons.search,
                placeholder: 'Modèle, monument, artiste...',
              ),
              const SizedBox(height: 24),

              Text(
                'Que cherchez-vous ?',
                style: AppText.emphasis(),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildCategoryChip('Technologie', isSelected: _selectedCategory == 'Technologie'),
                    const SizedBox(width: 12),
                    _buildCategoryChip('Peinture', isSelected: _selectedCategory == 'Peinture'),
                    const SizedBox(width: 12),
                    _buildCategoryChip('Monument', isSelected: _selectedCategory == 'Monument'),
                    const SizedBox(width: 12),
                    _buildCategoryChip('Tous', isSelected: _selectedCategory == null),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Liste / Grille des modèles
              Expanded(
                child: _publicModels.isEmpty
                    ? _buildEmptyState()
                    : _buildModelsGrid(),
              )
             ],
          ),
        ),
      ),
    );
  }


  Widget _buildCategoryChip(String label, {bool isSelected = false}) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = isSelected ? null : label;
          // TODO: filtrer _publicModels selon catégorie si implémenté
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.grey[200],
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          label,
          style: AppText.bodyS().copyWith(
            color: isSelected ? Colors.white : Colors.black87
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.view_in_ar_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            'Aucun modèle trouvé',
            style: AppText.bodyM()
          ),
          const SizedBox(height: 12),
          Text(
            'Essayez une autre recherche ou ajoutez votre premier modèle',
            style: AppText.bodyS().copyWith(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildModelsGrid() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.78, // un peu plus haut que large
      ),
      itemCount: _publicModels.length,
      itemBuilder: (context, index) {
        final model = _publicModels[index];
        return GestureDetector(
          onTap: () {
            // TODO: navigation vers détail du modèle
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
                  color: Colors.grey.withValues(alpha: 0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: Container(
                      color: Colors.grey[100],
                      child: Center(
                        child: Icon(
                          Icons.view_in_ar_outlined,
                          size: 48,
                          color: Colors.grey[500],
                        ),
                      ), // ← Remplacer par Image.network(model.thumbnailUrl) quand disponible
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
                          fontSize: 15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        model.formatType,
                        style: TextStyle(
                          fontSize: 12,
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
}
