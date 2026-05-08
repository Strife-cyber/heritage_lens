import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:heritage_lens/core/app_theme.dart';
import 'package:heritage_lens/views/widgets/standard_button.dart';
import 'package:heritage_lens/views/widgets/standard_text_helpers.dart';
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
  bool _shouldShowVideo = false;
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _likeCount = widget.model.likeCount;
    _commentCount = widget.model.commentCount;
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

  Future<void> _onPlayVideo() async {
    if (widget.model.videoUrl.trim().isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vidéo indisponible pour cet objet.')),
      );
      return;
    }

    if (_betterPlayerController == null) {
      _initializePlayer();
    }

    if (!mounted) return;
    setState(() => _shouldShowVideo = true);
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
        child: Stack(
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
                  child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back),
                    ),
                    Icon(Icons.bookmark_outline)
                  ],
                ),

                const SizedBox(height: 16),

                // Large image (>= half screen height)
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.55,
                  width: double.infinity,
                  child: _shouldShowVideo && _betterPlayerController != null
                      ? BetterPlayer(controller: _betterPlayerController!)
                      : Stack(
                          children: [
                            Positioned.fill(
                              child: widget.model.thumbnailUrl.isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: widget.model.thumbnailUrl,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) =>
                                          Container(
                                        color: Colors.grey[200],
                                        child: const Center(
                                          child:
                                              CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Container(
                                        color: Colors.grey[200],
                                        child: const Icon(Icons.broken_image),
                                      ),
                                    )
                                  : Container(color: Colors.grey[200]),
                            ),
                            if (widget.model.videoUrl.trim().isNotEmpty)
                              Positioned.fill(
                                child: Align(
                                  alignment: Alignment.center,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(18),
                                    onTap: _onPlayVideo,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 18,
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(
                                          alpha: 0.45,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(999),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: const [
                                          Icon(Icons.play_arrow,
                                              color: Colors.white),
                                          SizedBox(width: 10),
                                          Text(
                                            'Lire la vidéo',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                ),

                const SizedBox(height: 20),
                Text(widget.model.title, style: AppText.titleM()),
                const SizedBox(height: 8),
                Text(
                  "${widget.model.originLocation} - ${widget.model.era}",
                  style: AppText.bodyS(),
                ),

                const SizedBox(height: 12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: _toggleLike,
                      child: Icon(
                        _isLikedByUser
                            ? Icons.favorite
                            : Icons.favorite_outline,
                        color: _isLikedByUser ? Colors.red : Colors.black,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(_likeCount.toString(), style: AppText.bodySNB()),
                    const SizedBox(width: 16),
                    const Icon(Icons.comment_outlined),
                    const SizedBox(width: 8),
                    Text(_commentCount.toString(), style: AppText.bodySNB()),
                  ],
                ),

                const SizedBox(height: 16),
                Text("Description", style: AppText.emphasis()),
                const SizedBox(height: 8),
                Text(
                  widget.model.description.replaceAll("\n\n", "\n"),
                  style: AppText.bodySNB(),
                ),

                const SizedBox(height: 24),
                Text("Commentaires", style: AppText.emphasis()),
                
                const SizedBox(height: 8),

                // Add comment input
                TextField(
                  controller: _commentController,
                  style: AppText.bodySNB(),
                  maxLines: 3,
                  minLines: 1,
                  decoration: InputDecoration(
                    hintText: "Écrivez un commentaire...",
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.grey, width: 1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 2),
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),

                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: StandardButton(
                    onPressed: _addComment,
                    child: const Text("Envoyer"),
                  ),
                ),

                const SizedBox(height: 12),

                // Comments list
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
                      loading: () => const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      error: (e, stack) => const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Text(
                          "Erreur lors du chargement des commentaires",
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
              ),
            ),
            Positioned(
              left: 24,
              right: 24,
              bottom: 16,
              child: StandardButton(
                onPressed: _viewInAR,
                child: const Text("Voir en RA"),
              ),
            ),
          ],
        ),
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
