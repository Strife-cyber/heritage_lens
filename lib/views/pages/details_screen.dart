import 'package:flutter/material.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';
import 'package:heritage_lens/core/app_theme.dart';
import 'package:heritage_lens/views/auth/login_screen.dart';
import 'package:heritage_lens/views/widgets/ar_not_compatible.dart';
import 'package:heritage_lens/views/widgets/standard_button.dart';
import 'package:heritage_lens/views/widgets/standard_text_helpers.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:heritage_lens/views/ar/ar_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heritage_lens/services/auth_service.dart';
import 'package:heritage_lens/services/unity_service.dart';
import 'package:heritage_lens/services/comment_service.dart';
import 'package:heritage_lens/services/model_cache_service.dart';

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
  bool _isTogglingLike = false;

  final Flutter3DController _modelController = Flutter3DController();
  bool _isModelExpanded = false;
  final TextEditingController _commentController = TextEditingController();
  late final ModelCacheService _modelCacheService;
  late final Future<String?> _cachedModelSrcFuture;

  @override
  void initState() {
    super.initState();
    _modelCacheService = ModelCacheService();
    _cachedModelSrcFuture = _modelCacheService.getCachedModelFileUrl(
      widget.model.modelUrl,
    );
    _likeCount = widget.model.likeCount;
    _commentCount = widget.model.commentCount;
    _initLikeState();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
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
      if (_isTogglingLike) return;
      final user = ref.read(currentUserProvider).value;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez vous connecter pour liker')),
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
        return;
      }

      // Optimistic UI: update immediately so the UI feels responsive.
      final previousLiked = _isLikedByUser;
      setState(() {
        _isTogglingLike = true;
        _isLikedByUser = !previousLiked;
        _likeCount += _isLikedByUser ? 1 : -1;
      });

      final artifactRef = FirebaseFirestore.instance
          .collection('artifacts')
          .doc(widget.model.documentId);
      final likeRef = artifactRef.collection('likes').doc(user.uid);

      await FirebaseFirestore.instance.runTransaction((tx) async {
        final likeSnap = await tx.get(likeRef);
        final currentlyLiked = likeSnap.exists;

        if (currentlyLiked) {
          tx.delete(likeRef);
          tx.update(artifactRef, {'likeCount': FieldValue.increment(-1)});
        } else {
          tx.set(likeRef, <String, dynamic>{
            // Used by ProfileScreen to query likes for the current user.
            'userId': user.uid,
            'createdAt': FieldValue.serverTimestamp(),
          });
          tx.update(artifactRef, {'likeCount': FieldValue.increment(1)});
        }
      });

      // Transaction succeeded; keep optimistic state.
      if (!mounted) return;
    } catch (e) {
      // Revert optimistic update if Firestore fails.
      if (mounted) {
        setState(() {
          _isLikedByUser = !_isLikedByUser;
          _likeCount += _isLikedByUser ? 1 : -1;
        });
      }
      debugPrint("Le like n'a pas pu être enregistré : $e");
    } finally {
      if (mounted) {
        setState(() => _isTogglingLike = false);
      }
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
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
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

  Future<void> _viewInAR(BuildContext dialogContext) async {
    Navigator.of(dialogContext).pop();
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

  Widget _buildModelViewer({
    required double height,
    required String modelSrc,
  }) {
    if (modelSrc.trim().isEmpty) {
      return Container(
        color: Colors.grey[200],
        child: const Center(
          child: Text(
            "Modèle 3D indisponible",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: height,
      width: double.infinity,
      child: Flutter3DViewer(
        src: modelSrc,
        controller: _modelController,
        enableTouch: true,
        activeGestureInterceptor: true,
        progressBarColor: AppTheme.grey,
        onProgress: (double progressValue) {
          debugPrint('3D model loading progress : $progressValue');
        },
        onError: (String error) {
          debugPrint('3D model failed to load : $error');
        },
      ),
    );
  }

  Widget _buildExpandSquareButton({required bool expanded}) {
    return Material(
      color: Colors.black.withValues(alpha: 0.35),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        onTap: () {
          setState(() {
            _isModelExpanded = !expanded;
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(
            expanded ? Icons.fullscreen_exit : Icons.fullscreen,
            size: 22,
            color: Colors.white,
          ),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.arrow_back),
                          ),
                          GestureDetector(
                            onTap: _isTogglingLike ? null : _toggleLike,
                            child: _isTogglingLike
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Icon(
                                    _isLikedByUser
                                        ? Icons.bookmark
                                        : Icons.bookmark_outline,
                                    color: _isLikedByUser
                                        ? Colors.yellow
                                        : Colors.black,
                                  ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.55,
                      width: double.infinity,
                      child: Stack(
                        children: [
                          // When fullscreen is active, hide the preview viewer to
                          // avoid having two Flutter3DViewer widgets sharing one
                          // controller (can result in a black fullscreen).
                          if (!_isModelExpanded)
                            Positioned.fill(
                              child: FutureBuilder<String?>(
                                future: _cachedModelSrcFuture,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }

                                  return _buildModelViewer(
                                    height: MediaQuery.of(context).size.height *
                                        0.55,
                                    modelSrc: snapshot.data ?? '',
                                  );
                                },
                              ),
                            ),
                          if (!_isModelExpanded)
                            Positioned(
                              top: 12,
                              right: 12,
                              child: _buildExpandSquareButton(expanded: false),
                            ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          Text(widget.model.title, style: AppText.titleM()),
                          const SizedBox(height: 8),
                          Text(
                            "${widget.model.originLocation} - ${widget.model.era}",
                            style: AppText.bodyMG(),
                          ),

                          const SizedBox(height: 12),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              if (_isTogglingLike)
                                const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              else
                                Icon(
                                  _isLikedByUser
                                      ? Icons.favorite
                                      : Icons.favorite_outline,
                                  color: _isLikedByUser
                                      ? Colors.red
                                      : Colors.grey[500],
                                ),
                              const SizedBox(width: 8),
                              Text(
                                _likeCount.toString(),
                                style: AppText.bodySNB().copyWith(
                                  color: Colors.grey[500],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Icon(
                                Icons.comment_outlined,
                                color: Colors.grey[500],
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _commentCount.toString(),
                                style: AppText.bodySNB().copyWith(
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),
                          Text("Description", style: AppText.emphasis()),
                          const SizedBox(height: 8),
                          Text(
                            widget.model.description.replaceAll("\n\n", "\n"),
                            style: AppText.bodySNB().copyWith(
                              color: Colors.grey[500],
                              fontSize: 14,
                            ),
                          ),

                          const SizedBox(height: 24),
                          Text("Commentaires", style: AppText.emphasis()),

                          const SizedBox(height: 8),

                          // Add comment input
                          TextField(
                            controller: _commentController,
                            style: AppText.bodySNB().copyWith(
                              color: Colors.grey[500],
                              fontSize: 14,
                            ),
                            maxLines: 3,
                            minLines: 1,
                            decoration: InputDecoration(
                              hintText: "Écrivez un commentaire...",
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.grey,
                                  width: 1,
                                ),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.black,
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 1,
                                vertical: 1,
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
                                      padding: EdgeInsets.symmetric(
                                        vertical: 16.0,
                                      ),
                                      child: Text(
                                        "Soyez le premier à commenter !",
                                      ),
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
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
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
                  ],
                ),
              ),
            ),
            if (!_isModelExpanded)
              Positioned(
                left: 24,
                right: 24,
                bottom: 16,
                child: StandardButton(
                  onPressed: () => arNotCompatibleModal(context, _viewInAR),
                  child: const Text("Voir en RA"),
                ),
              ),

            if (_isModelExpanded)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.88),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: FutureBuilder<String?>(
                          future: _cachedModelSrcFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              );
                            }
                            return _buildModelViewer(
                              height: MediaQuery.of(context).size.height,
                              modelSrc: snapshot.data ?? '',
                            );
                          },
                        ),
                      ),
                      SafeArea(
                        child: Positioned(
                          top: 12,
                          right: 12,
                          child: _buildExpandSquareButton(expanded: true),
                        ),
                      ),
                    ],
                  ),
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
