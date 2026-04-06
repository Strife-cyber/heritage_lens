import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:heritage_lens/utils/map_helper.dart';

class CommentModel {
  final String documentId;
  final String authorId;
  final String authorName;
  final String text;
  final Timestamp createdAt;

  CommentModel({
    required this.documentId,
    required this.authorId,
    required this.authorName,
    required this.text,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'documentId': documentId,
      'authorId': authorId,
      'authorName': authorName,
      'text': text,
      'createdAt': createdAt,
    };
  }

  factory CommentModel.fromMap(Map<String, dynamic> map, String documentId) {
    return CommentModel(
      documentId: documentId,
      authorId: getValue<String>(map, 'authorId', defaultValue: '')!,
      authorName: getValue<String>(map, 'authorName', defaultValue: '')!,
      text: getValue<String>(map, 'text', defaultValue: '')!,
      createdAt: getValue<Timestamp>(map, 'createdAt') ?? Timestamp.now(),
    );
  }

  String toJson() => json.encode(toMap());

  factory CommentModel.fromJson(String source, String documentId) => 
      CommentModel.fromMap(json.decode(source) as Map<String, dynamic>, documentId);
}
