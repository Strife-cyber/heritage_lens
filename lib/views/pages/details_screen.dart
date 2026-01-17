import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heritage_lens/services/auth_service.dart';

import '../../models/ar_model.dart';

class DetailScreen extends ConsumerStatefulWidget {
  final ARModel model; // On passe le modèle sélectionné depuis Discover ou Dashboard

  const DetailScreen({
    super.key,
    required this.model,
  });

  @override
  ConsumerState<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends ConsumerState<DetailScreen> {
  // ───────────────────────────────────────────────
  // Variables d'état
  // ───────────────────────────────────────────────
  int _selectedBottomNav = 0; // 0 = retour discover/home

  // Données mockées / futures (TODO: implémenter)
  int _likeCount = 10;           // TODO: fetch réel depuis Firestore
  int _commentCount = 1;         // TODO: fetch réel
  bool _isLikedByUser = false;   // TODO: check si l'utilisateur a liké
  final List<Map<String, dynamic>> _comments = [ // Mock pour l'affichage
    {
      'username': 'JoliModèleFan',
      'text': 'Joli modèle, j’aime la RA !',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 5)),
    },
  ];

  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  // ───────────────────────────────────────────────
  // Actions (TODO: implémenter la logique réelle)
  // ───────────────────────────────────────────────
  Future<void> _toggleLike() async {
    // TODO: implémenter like/unlike dans Firestore
    // Exemple futur : update likes array ou counter
    setState(() {
      _isLikedByUser = !_isLikedByUser;
      _likeCount += _isLikedByUser ? 1 : -1;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_isLikedByUser ? 'Ajouté aux favoris' : 'Retiré des favoris')),
    );
  }

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) return;

    final user = ref.read(currentUserProvider).value;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez vous connecter pour commenter')),
      );
      return;
    }

    // TODO: implémenter l'ajout réel dans Firestore (collection comments sous le modèle)
    setState(() {
      _comments.add({
        'username': user.displayName ?? user.email?.split('@').first ?? 'Anonyme',
        'text': _commentController.text.trim(),
        'timestamp': DateTime.now(),
      });
      _commentCount++;
      _commentController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Commentaire ajouté')),
    );
  }

  Future<void> _viewInAR() async {
    // TODO: Implémenter l'ouverture Unity / AR
    // Exemple : Navigator.push vers UnityWidget screen
    // ou lancer FlutterUnityWidget avec model.assetPath
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ouverture en RA... (à implémenter)')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Image principale (grand format noir) ──────────────
              Stack(
                children: [
                  // Image / placeholder
                  Container(
                    height: 300,
                    width: double.infinity,
                    color: Colors.black,
                    child: Center(
                      child: Icon(
                        Icons.view_in_ar_outlined,
                        size: 120,
                        color: Colors.white.withValues(alpha: 0.4),
                      ),
                    ), // ← Remplacer par Image.network(widget.model.imageUrl ?? '')
                  ),

                  // Bouton flottant "Voir en RA"
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: FloatingActionButton.extended(
                      onPressed: _viewInAR,
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      icon: const Icon(Icons.view_in_ar),
                      label: const Text('Voir en RA'),
                    ),
                  ),
                ],
              ),

              // ── Infos principales ──────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.model.name,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Alike', // ou ta police titre
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          'John Mauchly & J. Presper Eckert', // ← à rendre dynamique si dans model
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Likes + Commentaires count
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildInteractionButton(
                          icon: _isLikedByUser ? Icons.favorite : Icons.favorite_border,
                          count: _likeCount,
                          color: _isLikedByUser ? Colors.red : Colors.grey[600]!,
                          onTap: _toggleLike,
                        ),
                        _buildInteractionButton(
                          icon: Icons.comment_outlined,
                          count: _commentCount,
                          color: Colors.grey[600]!,
                          onTap: () {
                            // Optionnel : scroll vers commentaires
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Description
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.model.description,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        color: Colors.grey[800],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Commentaires
                    const Text(
                      'Commentaires',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Liste des commentaires existants
                    ..._comments.map((comment) => _buildCommentItem(comment)),

                    const SizedBox(height: 24),

                    // Champ pour ajouter un commentaire
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _commentController,
                            decoration: InputDecoration(
                              hintText: 'Écrivez un commentaire...',
                              hintStyle: TextStyle(color: Colors.grey[500]),
                              filled: true,
                              fillColor: Colors.grey[100],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            maxLines: 3,
                            minLines: 1,
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: _addComment,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 14,
                            ),
                          ),
                          child: const Text('Envoyer'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      // Bottom navigation capsule (comme dans dashboard)
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(50),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
    );
  }

  // ───────────────────────────────────────────────
  // Widgets réutilisables
  // ───────────────────────────────────────────────

  Widget _buildInteractionButton({
    required IconData icon,
    required int count,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 6),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentItem(Map<String, dynamic> comment) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey[300],
            child: Text(
              (comment['username'] as String)[0].toUpperCase(),
              style: const TextStyle(color: Colors.black54),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  comment['username'] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  comment['text'] as String,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTimeAgo(comment['timestamp'] as DateTime),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'À l\'instant';
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours} h';
    return 'Il y a ${diff.inDays} j';
  }

  Widget _buildBottomNavItem(int index, IconData icon) {
    final isSelected = _selectedBottomNav == index;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedBottomNav = index);
        if (index != 0) {
          // TODO: navigation vers autres écrans
          Navigator.pop(context); // Exemple : retour à discover
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.black : Colors.white,
          size: 28,
        ),
      ),
    );
  }
}
