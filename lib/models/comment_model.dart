import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:heritage_lens/utils/map_helper.dart';

class CommentModel {
  final String commentId;
  final String authorId;
  final String authorName;
  final String text;
  final Timestamp createdAt;

  CommentModel({
    required this.commentId,
    required this.authorId,
    required this.authorName,
    required this.text,
    required this.createdAt,
  });

  factory CommentModel.fromMap(Map<String, dynamic> map, String commentId) {
    final createdAt = getValue<Timestamp>(
      map,
      'createdAt',
      defaultValue: Timestamp.fromDate(DateTime.fromMillisecondsSinceEpoch(0)),
    )!;

    return CommentModel(
      commentId: commentId,
      authorId: getValue<String>(map, 'authorId', defaultValue: '')!,
      authorName: getValue<String>(map, 'authorName', defaultValue: '')!,
      text: getValue<String>(map, 'text', defaultValue: '')!,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'authorId': authorId,
      'authorName': authorName,
      'text': text,
      'createdAt': createdAt,
    };
  }
}

