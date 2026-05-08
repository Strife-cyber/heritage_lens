import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:heritage_lens/utils/map_helper.dart';

class ARModel {
  final String documentId;
  final String modelFileId;
  final String category;
  final String era;
  final String title;
  final String description;
  final String originLocation;
  final String thumbnailUrl;
  final String videoUrl;
  final String? modelUrl;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;
  final List<String> didYouKnow;
  final int likeCount;
  final int commentCount;

  ARModel({
    required this.documentId,
    required this.modelFileId,
    required this.category,
    required this.era,
    required this.title,
    required this.description,
    required this.originLocation,
    required this.thumbnailUrl,
    required this.videoUrl,
    required this.modelUrl,
    required this.createdAt,
    required this.updatedAt,
    required this.didYouKnow,
    this.likeCount = 0,
    this.commentCount = 0,
  });


  ARModel copyWith({
    String? documentId,
    String? modelFileId,
    String? category,
    String? era,
    String? title,
    String? description,
    String? originLocation,
    String? thumbnailUrl,
    String? videoUrl,
    String? modelUrl,
    Timestamp? createdAt,
    Timestamp? updatedAt,
    List<String>? didYouKnow,
    int? likeCount,
    int? commentCount,
  }) {
    return ARModel(
      documentId: documentId ?? this.documentId,
      modelFileId: modelFileId ?? this.modelFileId,
      category: category ?? this.category,
      era: era ?? this.era,
      title: title ?? this.title,
      description: description ?? this.description,
      originLocation: originLocation ?? this.originLocation,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      modelUrl: modelUrl ?? this.modelUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      didYouKnow: didYouKnow ?? this.didYouKnow,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'documentId': documentId,
      'modelFileId': modelFileId,
      'category': category,
      'era': era,
      'title': title,
      'description': description,
      'originLocation': originLocation,
      'thumbnailUrl': thumbnailUrl,
      'videoUrl': videoUrl,
      'modelUrl': modelUrl,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'didYouKnow': didYouKnow,
      'likeCount': likeCount,
      'commentCount': commentCount,
    };
  }

  factory ARModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ARModel(
      documentId: documentId,
      modelFileId: getValue<String>(map, 'modelFileId', defaultValue: '')!,
      category: getValue<String>(map, 'category', defaultValue: '')!,
      era: getValue<String>(map, 'era', defaultValue: '')!,
      title: getValue<String>(map, 'title', defaultValue: '')!,
      description: getValue<String>(map, 'description', defaultValue: '')!,
      originLocation: getValue<String>(map, 'originLocation', defaultValue: '')!,
      thumbnailUrl: getValue<String>(map, 'thumbnailUrl', defaultValue: '')!,
      videoUrl: getValue<String>(map, 'videoUrl', defaultValue: '')!,
      modelUrl: getValue<String>(map, 'modelUrl'),
      createdAt: getValue<Timestamp>(map, 'createdAt'),
      updatedAt: getValue<Timestamp>(map, 'updatedAt'),
      didYouKnow: getList<String>(map, 'didYouKnow'),
      likeCount: getValue<int>(map, 'likeCount', defaultValue: 0)!,
      commentCount: getValue<int>(map, 'commentCount', defaultValue: 0)!,
    );
  }

  String toJson() => json.encode(toMap());

  factory ARModel.fromJson(String source, String documentId) => ARModel.fromMap(json.decode(source) as Map<String, dynamic>, documentId);

  @override
  String toString() {
    return 'ARModel(documentId: $documentId, modelFileId: $modelFileId, category: $category, era: $era, title: $title, description: $description, originLocation: $originLocation, thumbnailUrl: $thumbnailUrl, videoUrl: $videoUrl, modelUrl: $modelUrl, createdAt: $createdAt, updatedAt: $updatedAt, didYouKnow: $didYouKnow, likeCount: $likeCount, commentCount: $commentCount)';
  }

  @override
  bool operator ==(covariant ARModel other) {
    if (identical(this, other)) return true;
  
    return 
      other.documentId == documentId &&
      other.modelFileId == modelFileId &&
      other.category == category &&
      other.era == era &&
      other.title == title &&
      other.description == description &&
      other.originLocation == originLocation &&
      other.thumbnailUrl == thumbnailUrl &&
      other.videoUrl == videoUrl &&
      other.modelUrl == modelUrl &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt &&
      other.likeCount == likeCount &&
      other.commentCount == commentCount &&
      listEquals(other.didYouKnow, didYouKnow);
  }

  @override
  int get hashCode {
    return documentId.hashCode ^
      modelFileId.hashCode ^
      category.hashCode ^
      era.hashCode ^
      title.hashCode ^
      description.hashCode ^
      originLocation.hashCode ^
      thumbnailUrl.hashCode ^
      videoUrl.hashCode ^
      modelUrl.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode ^
      didYouKnow.hashCode ^
      likeCount.hashCode ^
      commentCount.hashCode;
  }
}
