import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:heritage_lens/views/ar/ar_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heritage_lens/services/auth_service.dart';
import 'package:heritage_lens/services/unity_service.dart';
import 'package:better_player_plus/better_player_plus.dart';
import 'package:heritage_lens/services/comment_service.dart';

import '../../models/ar_model.dart';
import '../../models/comment_model.dart';

class DetailScreen extends ConsumerStatefulWidget {
  final ARModel
  model; // On passe le modèle sélectionné depuis Discover ou Dashboard

  const DetailScreen({super.key, required this.model});

  @override
  ConsumerState<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends ConsumerState<DetailScreen> {
  late int _likeCount;
  late int _commentCount;
  bool _isLikedByUser = false;

  BetterPlayerController? _betterPlayerController;
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _likeCount = widget.model.likeCount;
    _commentCount = widget.model.commentCount;
    _initializePlayer();
    _initLikeState();
  }

  @override
  void dispose() {
    _commentController.dispose();
    _betterPlayerController?.dispose();
    super.dispose();
  }

  void _initializePlayer() {
    if (widget.model.videoUrl.trim().isEmpty) {
      return;
    }

    final dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      widget.model.videoUrl,
      videoFormat: BetterPlayerVideoFormat.other,
      videoExtension: "mp4",
      cacheConfiguration: const BetterPlayerCacheConfiguration(useCache: true),
    );

    _betterPlayerController = BetterPlayerController(
      const BetterPlayerConfiguration(
        aspectRatio: 16 / 9,
        autoPlay: true,
        looping: true,
        fit: BoxFit.contain,
        controlsConfiguration: BetterPlayerControlsConfiguration(
          enableSkips: false,
          enableFullscreen: true,
          enableMute: true,
          progressBarPlayedColor: Colors.black,
          progressBarHandleColor: Colors.black,
          controlBarColor: Colors.black45,
        ),
      ),
      betterPlayerDataSource: dataSource,
    );
  }

  Future<void> _initLikeState() async {
    final user = ref.read(currentUserProvider).value;
    if (user == null) return;

    try {
      final likeDoc = await FirebaseFirestore.instance
          .collection('artifacts')
          .doc(widget.model.documentId)
          .collection('likes')
          .doc(user.uid)
          .get();

      if (!mounted) return;
      setState(() {
        _isLikedByUser = likeDoc.exists;
      });
    } catch (e) {
      debugPrint('Failed to init like state: $e');
    }
  }

  Future<void> _toggleLike() async {
    try {
      final user = ref.read(currentUserProvider).value;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez vous connecter pour liker')),
        );
        return;
      }

      final artifactRef = FirebaseFirestore.instance
          .collection('artifacts')
          .doc(widget.model.documentId);
      final likeRef = artifactRef.collection('likes').doc(user.uid);

      final previousLiked = _isLikedByUser;
      await FirebaseFirestore.instance.runTransaction((tx) async {
        final likeSnap = await tx.get(likeRef);
        final currentlyLiked = likeSnap.exists;

        if (currentlyLiked) {
          tx.delete(likeRef);
          tx.update(artifactRef, {'likeCount': FieldValue.increment(-1)});
        } else {
          tx.set(likeRef, <String, dynamic>{
            'createdAt': FieldValue.serverTimestamp(),
          });
          tx.update(artifactRef, {'likeCount': FieldValue.increment(1)});
        }
      });

      if (!mounted) return;
      setState(() {
        _isLikedByUser = !previousLiked;
        _likeCount += _isLikedByUser ? 1 : -1;
      });
    } catch (e) {
      debugPrint("Le like n'a pas pu être enregistré : $e");
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isLikedByUser ? 'Ajouté aux favoris' : 'Retiré des favoris',
          ),
        ),
      );
    }
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

    try {
      await addComment(
        artifactId: widget.model.documentId,
        authorId: user.uid,
        authorName: user.displayName ?? 'Anonyme',
        text: _commentController.text.trim(),
      );

      setState(() {
        _commentController.clear();
        _commentCount += 1;
      });
    } catch (_) {
      // Keep the input if comment creation fails.
    }

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Commentaire ajouté')));
    }
  }

  Future<void> _viewInAR() async {
    if (widget.model.modelUrl == null ||
        widget.model.modelUrl!.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Le modèle 3D n'est pas encore disponible pour cet objet.",
          ),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Ouverture en RA...')));

    final modelMessage = UnityOutgoingMessage(
      bridge: UnityBridgeTarget.model,
      type: UnityMessageType.modelUrl,
      payload: UnityStringPayload(widget.model.modelUrl!),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ArView(
          modelUrlMessage: modelMessage,
          onMessageReceived: (message) {
            debugPrint("Received a message back from unity: $message");
          },
        ),
      ),
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
              Stack(
                children: [
                  _betterPlayerController == null
                      ? Container(
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
                        )
                      : AspectRatio(
                          aspectRatio: 16 / 9,
                          child: BetterPlayer(
                            controller: _betterPlayerController!,
                          ),
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
                      widget.model.title,
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
                          icon: _isLikedByUser
                              ? Icons.favorite
                              : Icons.favorite_border,
                          count: _likeCount,
                          color: _isLikedByUser
                              ? Colors.red
                              : Colors.grey[600]!,
                          onTap: _toggleLike,
                        ),
                        _buildInteractionButton(
                          icon: Icons.comment_outlined,
                          count: _commentCount,
                          color: Colors.grey[600]!,
                          onTap: () {},
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
                    Consumer(
                      builder: (context, ref, child) {
                        final commentsState = ref.watch(
                          modelCommentsProvider(widget.model.documentId),
                        );
                        return commentsState.when(
                          data: (comments) {
                            if (comments.isEmpty) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16.0),
                                child: Text("Soyez le premier à commenter !"),
                              );
                            }
                            return Column(
                              children: comments
                                  .map((c) => _buildCommentItem(c))
                                  .toList(),
                            );
                          },
                          loading: () => const Center(
                            child: CircularProgressIndicator(
                              color: Colors.black,
                            ),
                          ),
                          error: (e, stack) => Text(
                            'Erreur lors du chargement des commentaires',
                          ),
                        );
                      },
                    ),

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
    );
  }

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

  Widget _buildCommentItem(CommentModel comment) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey[300],
            child: Text(
              comment.authorName.isNotEmpty
                  ? comment.authorName[0].toUpperCase()
                  : '?',
              style: const TextStyle(color: Colors.black54),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  comment.authorName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  comment.text,
                  style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                ),
                const SizedBox(height: 4),
                Text(
                  timeago.format(comment.createdAt.toDate(), locale: 'fr'),
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
