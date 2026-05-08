import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heritage_lens/services/model_service.dart';
import 'package:heritage_lens/views/widgets/standard_button.dart';
import 'package:heritage_lens/views/widgets/standard_text_helpers.dart';

import '../../models/ar_model.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  List<ARModel> _favoriteModels = [];
  List<ARModel> _userModels = [];
  bool _isLoadingFavorites = true;
  bool _isLoadingUserModels = true;
  final _username = "Lionel";


  @override
  void initState() {
    super.initState();
    _loadFavoriteModels();
    _loadUserModels();
  }

  Future<void> _loadFavoriteModels() async { // TODO : Change to actual get of favourites models of current user
    _isLoadingFavorites = true;
    try {
      final query = await ref.read(arModelServiceProvider).getDocuments( limit: 20 );

      final models = query.docs
          .map((doc) => doc.data())
          .toList();

      if (mounted) {
        setState(() {
          _favoriteModels = models;
          _isLoadingFavorites = false;
        });
      }
    } catch (e) {
      debugPrint('Erreur chargement modèles favoris: $e');
      if (mounted) {
        setState(() => _isLoadingFavorites = false);
      }
    }
  }

  Future<void> _loadUserModels() async { //TODO : Change to actual get of user added models
    _isLoadingFavorites = true;
    try {
      final query = await ref.read(arModelServiceProvider).getDocuments( limit: 20 );

      final models = query.docs
          .map((doc) => doc.data())
          .toList();

      if (mounted) {
        setState(() {
          _userModels = models;
          _isLoadingUserModels = false;
        });
      }
    } catch (e) {
      debugPrint('Erreur chargement modèles utilisateurs: $e');
      if (mounted) {
        setState(() => _isLoadingUserModels = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // if (_isLoading) {
    //   return const Scaffold(
    //     body: Center(child: CircularProgressIndicator()),
    //   );
    // }

    return Scaffold(
      body: SafeArea(
        child: DefaultTabController(
          length: 2,
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return <Widget>[
                SliverAppBar(
                  floating: true,
                  expandedHeight: 400.0,
                  backgroundColor: Colors.white,
                  elevation: 0,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Bonjour $_username',
                            style: AppText.titleXL()
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Alors, Qu’allons nous faire aujourd'hui ?",
                            style: AppText.bodyMG()
                          ),
                          const SizedBox(height: 32),
                    
                          Container(
                            decoration: BoxDecoration(
                              border: BoxBorder.all(color: Color(0x11000000)),
                              borderRadius: const BorderRadius.all(Radius.circular(10.0))
                            ),
                            padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border(right: BorderSide(color: Color(0x22000000)))
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          '0',
                                          // "${_favoriteModels.length}", TODO : Fake favoriteModels function to be removed
                                          style: AppText.bodyM(),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          "Favoris",
                                          style: AppText.bodyM(),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    child: Column(
                                      children: [
                                        Text(
                                          '0',
                                          // "${_userModels.length}", TODO : Fake userModels function to be removed
                                          style: AppText.bodyM(),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          "Modèles",
                                          style: AppText.bodyM(),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 32),
                          Row(
                            children: [
                              Expanded(
                                child: StandardButton(
                                  child: Text("Ajouter un Modèle",style: AppText.bodySW()),
                                  onPressed: () => {}),
                              ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: StandardButton(
                                  child: Text("Créer un Espace",style: AppText.bodySW()),
                                  onPressed: () => {}),
                                )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _StickyTabBarDelegate (
                    tabBar: TabBar(
                      tabs: [Tab(icon: Icon(Icons.star)), Tab(icon: Icon(Icons.window))],
                    ),
                  ),
                ),
              ];
            },
            body: TabBarView(
              children: [
                _buildGrid(_favoriteModels, _isLoadingFavorites),
                _buildGrid(_userModels, _isLoadingUserModels),
              ],
            ),
          ),
        ),
      ),
    );
  }

 Widget _buildGrid(List<ARModel> models, bool isLoading) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (models.isEmpty) {
      return _buildEmptyState();
    }
    return GridView.builder(
      // Fix: These two lines are critical for grids inside NestedScrollView
      physics: const ClampingScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: models.length,
      itemBuilder: (context, index) => models[index].thumbnailUrl.isNotEmpty
                      ? CachedNetworkImage(
                          //Images in 1080p so it is better to append /preview to get something lighter
                          imageUrl: models[index].thumbnailUrl,
                          width: double.infinity,
                          height: double.infinity,
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
}

class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  const _StickyTabBarDelegate({required this.tabBar});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white, // Prevents content showing through when pinned
      child: tabBar,
    );
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(_StickyTabBarDelegate oldDelegate) => false;
}