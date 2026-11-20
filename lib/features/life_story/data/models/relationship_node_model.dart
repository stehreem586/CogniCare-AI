import 'package:flutter/material.dart';

/// The category of a node in the memory relationship graph
enum RelationshipNodeType {
  person,
  place,
  event,
}

/// A node representing an entity in the patient's life story
class RelationshipNode {
  final String id;
  final String name;
  final String roleOrRelation;
  final RelationshipNodeType type;
  final int memoryCount;
  final int linkedCount; // linked places or people
  final Offset relativePosition; // Normalized position (-1.0 to 1.0) from graph center
  final String? avatarKey;
  final List<String> linkedMemoryIds;

  const RelationshipNode({
    required this.id,
    required this.name,
    required this.roleOrRelation,
    required this.type,
    this.memoryCount = 1,
    this.linkedCount = 1,
    required this.relativePosition,
    this.avatarKey,
    this.linkedMemoryIds = const [],
  });

  RelationshipNode copyWith({
    String? id,
    String? name,
    String? roleOrRelation,
    RelationshipNodeType? type,
    int? memoryCount,
    int? linkedCount,
    Offset? relativePosition,
    String? avatarKey,
    List<String>? linkedMemoryIds,
  }) {
    return RelationshipNode(
      id: id ?? this.id,
      name: name ?? this.name,
      roleOrRelation: roleOrRelation ?? this.roleOrRelation,
      type: type ?? this.type,
      memoryCount: memoryCount ?? this.memoryCount,
      linkedCount: linkedCount ?? this.linkedCount,
      relativePosition: relativePosition ?? this.relativePosition,
      avatarKey: avatarKey ?? this.avatarKey,
      linkedMemoryIds: linkedMemoryIds ?? this.linkedMemoryIds,
    );
  }

  Color get primaryColor {
    switch (type) {
      case RelationshipNodeType.person:
        return const Color(0xFF2563EB); // Blue
      case RelationshipNodeType.place:
        return const Color(0xFF1E6B38); // Dark Forest Green
      case RelationshipNodeType.event:
        return const Color(0xFF65A30D); // Lime / Light Green
    }
  }

  String get typeLabel {
    switch (type) {
      case RelationshipNodeType.person:
        return 'Person';
      case RelationshipNodeType.place:
        return 'Place';
      case RelationshipNodeType.event:
        return 'Event';
    }
  }
}

/// An edge/link connecting two entities in the relationship graph
class RelationshipEdge {
  final String id;
  final String sourceNodeId;
  final String targetNodeId;
  final String label;
  final bool isDashed;

  const RelationshipEdge({
    required this.id,
    required this.sourceNodeId,
    required this.targetNodeId,
    required this.label,
    this.isDashed = false,
  });
}
