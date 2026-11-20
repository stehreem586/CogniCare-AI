import 'package:flutter/material.dart';
import '../models/relationship_node_model.dart';
import '../models/memory_model.dart';

class RelationshipGraphService {
  static final RelationshipGraphService _instance = RelationshipGraphService._internal();
  factory RelationshipGraphService() => _instance;
  RelationshipGraphService._internal();

  List<RelationshipNode> _nodes = [];
  List<RelationshipEdge> _edges = [];

  List<RelationshipNode> get nodes => List.unmodifiable(_nodes);
  List<RelationshipEdge> get edges => List.unmodifiable(_edges);

  /// Initializes graph nodes and relationships matching the design mockup (media_1795108410560_43b2d695.jpg)
  void initializeWithDefaults() {
    _nodes = [
      const RelationshipNode(
        id: 'node_ayesha',
        name: 'Ayesha',
        roleOrRelation: 'Daughter',
        type: RelationshipNodeType.person,
        memoryCount: 14,
        linkedCount: 3,
        relativePosition: Offset(-0.62, -0.60),
        linkedMemoryIds: ['mem_1', 'mem_school', 'mem_3'],
      ),
      const RelationshipNode(
        id: 'node_nani',
        name: 'Nani',
        roleOrRelation: 'Grandmother',
        type: RelationshipNodeType.person,
        memoryCount: 9,
        linkedCount: 2,
        relativePosition: Offset(0.62, -0.60),
        linkedMemoryIds: ['mem_1'],
      ),
      const RelationshipNode(
        id: 'node_lahore',
        name: 'Lahore',
        roleOrRelation: 'Born in',
        type: RelationshipNodeType.place,
        memoryCount: 8,
        linkedCount: 4,
        relativePosition: Offset(-0.74, 0.18),
        linkedMemoryIds: ['mem_1', 'mem_2', 'mem_6'],
      ),
      const RelationshipNode(
        id: 'node_eid',
        name: "Eid '98",
        roleOrRelation: 'Celebrated',
        type: RelationshipNodeType.event,
        memoryCount: 4,
        linkedCount: 4,
        relativePosition: Offset(0.74, 0.15),
        linkedMemoryIds: ['mem_1'],
      ),
      const RelationshipNode(
        id: 'node_wedding',
        name: 'Wedding',
        roleOrRelation: 'Married',
        type: RelationshipNodeType.event,
        memoryCount: 5,
        linkedCount: 2,
        relativePosition: Offset(-0.38, 0.72),
        linkedMemoryIds: ['mem_5'],
      ),
      const RelationshipNode(
        id: 'node_karachi',
        name: 'Karachi',
        roleOrRelation: 'Lives in',
        type: RelationshipNodeType.place,
        memoryCount: 6,
        linkedCount: 2,
        relativePosition: Offset(0.38, 0.72),
        linkedMemoryIds: ['mem_school'],
      ),
    ];

    _edges = [
      // Primary radial connections from center patient
      const RelationshipEdge(
        id: 'edge_ayesha',
        sourceNodeId: 'center',
        targetNodeId: 'node_ayesha',
        label: 'daughter',
      ),
      const RelationshipEdge(
        id: 'edge_nani',
        sourceNodeId: 'center',
        targetNodeId: 'node_nani',
        label: 'grandmother',
      ),
      const RelationshipEdge(
        id: 'edge_lahore',
        sourceNodeId: 'center',
        targetNodeId: 'node_lahore',
        label: 'born in',
      ),
      const RelationshipEdge(
        id: 'edge_eid',
        sourceNodeId: 'center',
        targetNodeId: 'node_eid',
        label: 'celebrated',
      ),
      const RelationshipEdge(
        id: 'edge_wedding',
        sourceNodeId: 'center',
        targetNodeId: 'node_wedding',
        label: 'married',
      ),
      const RelationshipEdge(
        id: 'edge_karachi',
        sourceNodeId: 'center',
        targetNodeId: 'node_karachi',
        label: 'lives in',
      ),

      // Secondary cross-entity dashed associations
      const RelationshipEdge(
        id: 'dash_ayesha_lahore',
        sourceNodeId: 'node_ayesha',
        targetNodeId: 'node_lahore',
        label: '',
        isDashed: true,
      ),
      const RelationshipEdge(
        id: 'dash_nani_eid',
        sourceNodeId: 'node_nani',
        targetNodeId: 'node_eid',
        label: '',
        isDashed: true,
      ),
      const RelationshipEdge(
        id: 'dash_wedding_karachi',
        sourceNodeId: 'node_wedding',
        targetNodeId: 'node_karachi',
        label: '',
        isDashed: true,
      ),
    ];
  }

  /// Adds a new entity node and connects it to the graph
  RelationshipNode addNode({
    required String name,
    required String relation,
    required RelationshipNodeType type,
    List<String> linkedMemoryIds = const [],
  }) {
    // Generate a radial position that avoids overlapping existing nodes
    final double angle = (_nodes.length * 1.1) % 6.28;
    final double radius = 0.68;
    final Offset pos = Offset(radius * 0.9 * (angle > 3.14 ? -1 : 1), radius * 0.8 * (angle < 1.57 || angle > 4.71 ? -1 : 1));

    final newNode = RelationshipNode(
      id: 'node_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      roleOrRelation: relation,
      type: type,
      memoryCount: linkedMemoryIds.isNotEmpty ? linkedMemoryIds.length : 1,
      linkedCount: 1,
      relativePosition: pos,
      linkedMemoryIds: linkedMemoryIds,
    );

    _nodes.add(newNode);

    _edges.add(
      RelationshipEdge(
        id: 'edge_${newNode.id}',
        sourceNodeId: 'center',
        targetNodeId: newNode.id,
        label: relation.toLowerCase(),
      ),
    );

    return newNode;
  }

  /// Finds memories associated with a given relationship node
  List<MemoryModel> getMemoriesForNode(RelationshipNode node, List<MemoryModel> allMemories) {
    return allMemories.where((m) {
      if (node.linkedMemoryIds.contains(m.id)) return true;

      final nodeNameLower = node.name.toLowerCase();
      if (node.type == RelationshipNodeType.person) {
        return m.taggedPeople.any((p) => p.toLowerCase().contains(nodeNameLower));
      } else if (node.type == RelationshipNodeType.place) {
        return m.place.toLowerCase().contains(nodeNameLower);
      } else {
        return m.title.toLowerCase().contains(nodeNameLower);
      }
    }).toList();
  }
}
