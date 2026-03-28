import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:heritage_lens/utils/map_helper.dart';

class ARModel {
  final String documentId;
  final String modelFileId;
  final String era;
  final String title;
  final String description;
  final String originLocation;
  final String thumbnailUrl;
  final String videoUrl;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;
  final List<String> didYouKnow;
  ARModel({
    required this.documentId,
    required this.modelFileId,
    required this.era,
    required this.title,
    required this.description,
    required this.originLocation,
    required this.thumbnailUrl,
    required this.videoUrl,
    required this.createdAt,
    required this.updatedAt,
    required this.didYouKnow,
  });


  ARModel copyWith({
    String? documentId,
    String? modelFileId,
    String? era,
    String? title,
    String? description,
    String? originLocation,
    String? thumbnailUrl,
    String? videoUrl,
    Timestamp? createdAt,
    Timestamp? updatedAt,
    List<String>? didYouKnow,
  }) {
    return ARModel(
      documentId: documentId ?? this.documentId,
      modelFileId: modelFileId ?? this.modelFileId,
      era: era ?? this.era,
      title: title ?? this.title,
      description: description ?? this.description,
      originLocation: originLocation ?? this.originLocation,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      didYouKnow: didYouKnow ?? this.didYouKnow,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'documentId': documentId,
      'modelFileId': modelFileId,
      'era': era,
      'title': title,
      'description': description,
      'originLocation': originLocation,
      'thumbnailUrl': thumbnailUrl,
      'videoUrl': videoUrl,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'didYouKnow': didYouKnow,
    };
  }

  factory ARModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ARModel(
      documentId: getValue<String>(map, 'documentId', defaultValue: '')!,
      modelFileId: getValue<String>(map, 'modelFileId', defaultValue: '')!,
      era: getValue<String>(map, 'era', defaultValue: '')!,
      title: getValue<String>(map, 'title', defaultValue: '')!,
      description: getValue<String>(map, 'description', defaultValue: '')!,
      originLocation: getValue<String>(map, 'originLocation', defaultValue: '')!,
      thumbnailUrl: getValue<String>(map, 'thumbnailUrl', defaultValue: '')!,
      videoUrl: getValue<String>(map, 'videoUrl', defaultValue: '')!,
      createdAt: getValue<Timestamp>(map, 'createdAt'),
      updatedAt: getValue<Timestamp>(map, 'updatedAt'),
      didYouKnow: getList<String>(map, 'didYouKnow'),
    );
  }

  String toJson() => json.encode(toMap());

  factory ARModel.fromJson(String source, String documentId) => ARModel.fromMap(json.decode(source) as Map<String, dynamic>, documentId);

  @override
  String toString() {
    return 'ARModel(documentId: $documentId, modelFileId: $modelFileId, era: $era, title: $title, description: $description, originLocation: $originLocation, thumbnailUrl: $thumbnailUrl, videoUrl: $videoUrl, createdAt: $createdAt, updatedAt: $updatedAt, didYouKnow: $didYouKnow)';
  }

  @override
  bool operator ==(covariant ARModel other) {
    if (identical(this, other)) return true;
  
    return 
      other.documentId == documentId &&
      other.modelFileId == modelFileId &&
      other.era == era &&
      other.title == title &&
      other.description == description &&
      other.originLocation == originLocation &&
      other.thumbnailUrl == thumbnailUrl &&
      other.videoUrl == videoUrl &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt &&
      listEquals(other.didYouKnow, didYouKnow);
  }

  @override
  int get hashCode {
    return documentId.hashCode ^
      modelFileId.hashCode ^
      era.hashCode ^
      title.hashCode ^
      description.hashCode ^
      originLocation.hashCode ^
      thumbnailUrl.hashCode ^
      videoUrl.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode ^
      didYouKnow.hashCode;
  }
}
