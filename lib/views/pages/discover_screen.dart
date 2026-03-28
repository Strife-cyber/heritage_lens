import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heritage_lens/services/model_service.dart';
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
  String _selectedCategory = 'Tous';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPublicModels();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPublicModels() async {
    try {
      final query = await ref.read(arModelServiceProvider).getDocuments(limit: 20);
      final models = query.docs.map((doc) => doc.data()).toList();

      if (mounted) {
        setState(() {
          _publicModels = models;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Erreur chargement: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // AppBar dynamique avec Titre et Recherche
          SliverAppBar(
            floating: true,
            expandedHeight: 180.0,
            backgroundColor: Colors.white,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Padding(
                padding: const EdgeInsets.fromLTRB(24, 60, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('HeritageLens', style: AppText.titleXL()),
                    Text('Histoire et culture à travers la RA', style: AppText.bodyMG()),
                  ],
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(80),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: StandardTextField(
                  controller: _searchController,
                  icon: Icons.search,
                  placeholder: 'Recherche un trésor...',
                ),
              ),
            ),
          ),

          // Section "Que cherchez-vous" en Sliver
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Que cherchez-vous ?', style: AppText.titleM()),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildCategoryChip('Tous'),
                        _buildCategoryChip('Technologie'),
                        _buildCategoryChip('Peinture'),
                        _buildCategoryChip('Monument'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Liste des modèles en pleine largeur
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: _publicModels.isEmpty
                ? SliverFillRemaining(child: _buildEmptyState())
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: _ModelCard(model: _publicModels[index]),
                      ),
                      childCount: _publicModels.length,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label) {
    final isSelected = _selectedCategory == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = label),
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.grey[100],
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          label,
          style: AppText.bodySW().copyWith(
            color: isSelected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.history_edu, size: 80, color: Colors.grey[300]),
        const SizedBox(height: 16),
        Text('Aucun trésor trouvé', style: AppText.bodyM()),
      ],
    );
  }
}

class _ModelCard extends StatelessWidget {
  final ARModel model;
  const _ModelCard({required this.model});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // TODO: Navigation vers le détail
      },
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Large avec Aspect Ratio fixe (16:9 est idéal pour le plein écran)
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                children: [
                  model.thumbnailUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: model.thumbnailUrl,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          // Un placeholder propre pendant le chargement (évite le vide blanc)
                          placeholder: (context, url) => Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                          // Gestion des erreurs (image corrompue ou lien mort)
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[200],
                            child: const Icon(Icons.broken_image, color: Colors.grey),
                          ),
                          // Durée de l'animation d'apparition
                          fadeInDuration: const Duration(milliseconds: 500),
                        )
                      : Container(color: Colors.grey[200]),
                  // Badge d'époque
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        model.era.toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Détails du modèle
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(model.title, style: AppText.bodyS()),
                      ),
                      const Icon(Icons.view_in_ar, color: Colors.black54),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(child: Text(model.originLocation, style: AppText.bodyS().copyWith(color: Colors.grey[600]), overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // On montre un extrait de la description maintenant qu'on a de la place
                  Text(
                    model.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.bodyS().copyWith(color: Colors.black54, height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}