import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../../../../app/routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../services/auth_state_service.dart';
import '../../data/models/memory_model.dart';
import '../../data/models/relationship_node_model.dart';
import '../../data/datasources/relationship_graph_service.dart';
import '../../data/repositories/memory_repository_impl.dart';
import '../../domain/repositories/memory_repository.dart';
import '../widgets/add_relationship_dialog.dart';
import '../widgets/relationship_graph_view.dart';
import '../widgets/memory_card.dart';

/// Screen implementing FE-3: Link people, places, and events
/// using a memory relationship graph.
class RelationshipMapScreen extends StatefulWidget {
  final MemoryRepository? memoryRepository;
  final String? patientId;
  final String? patientName;
  final bool animate;
  final bool readOnly;

  const RelationshipMapScreen({
    super.key,
    this.memoryRepository,
    this.patientId,
    this.patientName,
    this.animate = true,
    this.readOnly = false,
  });

  @override
  State<RelationshipMapScreen> createState() => _RelationshipMapScreenState();
}

class _RelationshipMapScreenState extends State<RelationshipMapScreen> {
  late final MemoryRepository _memoryRepository;
  final RelationshipGraphService _graphService = RelationshipGraphService();

  bool _isLoading = true;
  List<MemoryModel> _allMemories = [];
  List<RelationshipNode> _nodes = [];
  List<RelationshipEdge> _edges = [];

  RelationshipNode? _selectedNode;
  String _patientName = 'Rahim Khan';
  String _patientId = 'patient_rahim_khan';

  bool get _isPatientView =>
      widget.readOnly ||
      (Firebase.apps.isNotEmpty &&
          AuthStateService.instance.currentUserProfile?.role == 'patient');

  @override
  void initState() {
    super.initState();
    _memoryRepository = widget.memoryRepository ?? MemoryRepositoryImpl();
    if (widget.patientId != null) _patientId = widget.patientId!;
    if (widget.patientName != null) _patientName = widget.patientName!;

    if (!_isPatientView) {
      _graphService.initializeWithDefaults();
    }
    _nodes = _graphService.nodes;
    _edges = _graphService.edges;

    // Default selected node is Ayesha (matching screenshot media_1795108410560_43b2d695.jpg)
    if (_nodes.isNotEmpty) {
      _selectedNode = _nodes.first;
    }

    _loadMemories();
  }

  Future<void> _loadMemories() async {
    final list = await _memoryRepository.getMemories(patientId: _patientId);
    if (mounted) {
      setState(() {
        _allMemories = list;
        if (_isPatientView) {
          _graphService.initializeFromMemories(list);
          _nodes = _graphService.nodes;
          _edges = _graphService.edges;
          _selectedNode = _nodes.isEmpty ? null : _nodes.first;
        }
        _isLoading = false;
      });
    }
  }

  void _onNodeSelected(RelationshipNode node) {
    setState(() {
      _selectedNode = node;
    });
  }

  void _onCenterNodeSelected() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$_patientName is the focal patient of this relationship map.',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _openAddRelationshipSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return AddRelationshipDialog(
          availableMemories: _allMemories,
          onAdd: (name, relation, type, linkedIds) {
            final newNode = _graphService.addNode(
              name: name,
              relation: relation,
              type: type,
              linkedMemoryIds: linkedIds,
            );

            setState(() {
              _nodes = _graphService.nodes;
              _edges = _graphService.edges;
              _selectedNode = newNode;
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Linked "$name" ($relation) to relationship map!',
                ),
                backgroundColor: const Color(0xFF2EAA55),
              ),
            );
          },
        );
      },
    );
  }

  void _showLinkedMemories(RelationshipNode node) {
    final linkedMemories = _graphService.getMemoriesForNode(node, _allMemories);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.65,
          minChildSize: 0.45,
          maxChildSize: 0.9,
          expand: false,
          builder: (_, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildNodeAvatar(node, size: 40),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${node.name} • ${node.roleOrRelation}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.titleNavy,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${linkedMemories.length} associated memories found',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const Divider(),
                  const SizedBox(height: 10),
                  Expanded(
                    child: linkedMemories.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.photo_library_outlined,
                                  size: 44,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'No direct memories recorded for ${node.name} yet.',
                                  style: const TextStyle(
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.pop(ctx);
                                    if (!_isPatientView)
                                      Navigator.pushNamed(
                                        context,
                                        AppRoutes.newMemory,
                                        arguments: {'patientId': _patientId},
                                      );
                                  },
                                  icon: const Icon(Icons.add_rounded),
                                  label: const Text('Add Memory'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2EAA55),
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            controller: scrollController,
                            itemCount: linkedMemories.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 14),
                            itemBuilder: (context, index) {
                              final mem = linkedMemories[index];
                              return SizedBox(
                                height: 130,
                                child: MemoryCard(
                                  memory: mem,
                                  showDate: true,
                                  onTap: () {
                                    Navigator.pop(ctx);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Selected "${mem.title}"',
                                        ),
                                        duration: const Duration(seconds: 1),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF062447),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF041833), Color(0xFF062447), Color(0xFF0B3566)],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top Header Area matching media_1795108410560_43b2d695.jpg
              _buildTopHeader(),

              // 2. Center Graph Visualization
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : RelationshipGraphView(
                        nodes: _nodes,
                        edges: _edges,
                        selectedNode: _selectedNode,
                        onNodeSelected: _onNodeSelected,
                        onCenterNodeSelected: _onCenterNodeSelected,
                        animate: widget.animate,
                      ),
              ),

              // 3. Bottom Entity Details Card & Legend Bar
              if (_selectedNode != null) _buildBottomCard(_selectedNode!),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button to easily return to Life Story Hub
          GestureDetector(
            onTap: () {
              Navigator.of(
                context,
              ).pushReplacementNamed(AppRoutes.lifeStoryHub);
            },
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 38,
              height: 38,
              margin: const EdgeInsets.only(right: 12, top: 2),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Relationship map',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.4,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Tap a node to explore connections',
                  style: TextStyle(
                    color: Color(0xFFBFDBFE),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomCard(RelationshipNode node) {
    // Subtitle formatting: "14 memories • 3 places" as in design
    String subtitle;
    if (node.type == RelationshipNodeType.person) {
      subtitle = '${node.memoryCount} memories • ${node.linkedCount} places';
    } else if (node.type == RelationshipNodeType.place) {
      subtitle = '${node.memoryCount} memories • ${node.linkedCount} people';
    } else {
      subtitle = '${node.memoryCount} memories • ${node.linkedCount} people';
    }

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 18,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Row 1: Selected Entity Info & "View" Button
              Row(
                children: [
                  _buildNodeAvatar(node, size: 48),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${node.name} • ${node.roleOrRelation}',
                          style: const TextStyle(
                            fontSize: 16.5,
                            fontWeight: FontWeight.bold,
                            color: AppColors.titleNavy,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _showLinkedMemories(node),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0066BD),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    child: const Text(
                      'View',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13.5,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Row 2: Legend Dots & "+ Link" Action Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Color Legend
                  Row(
                    children: [
                      _buildLegendDot(const Color(0xFF2563EB), 'People'),
                      const SizedBox(width: 14),
                      _buildLegendDot(const Color(0xFF1E6B38), 'Places'),
                      const SizedBox(width: 14),
                      _buildLegendDot(const Color(0xFF58C97A), 'Events'),
                    ],
                  ),

                  if (!_isPatientView)
                    GestureDetector(
                      onTap: _openAddRelationshipSheet,
                      behavior: HitTestBehavior.opaque,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.add_rounded,
                            color: Color(0xFF0066BD),
                            size: 19,
                          ),
                          SizedBox(width: 2),
                          Text(
                            'Link',
                            style: TextStyle(
                              color: Color(0xFF0066BD),
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildNodeAvatar(RelationshipNode node, {required double size}) {
    if (node.type == RelationshipNodeType.person) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF2EAA55), width: 2.2),
        ),
        child: Center(
          child: Icon(
            Icons.person_rounded,
            color: const Color(0xFF2EAA55),
            size: size * 0.58,
          ),
        ),
      );
    } else if (node.type == RelationshipNodeType.place) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF1E6B38), width: 2.2),
        ),
        child: Center(
          child: Icon(
            Icons.location_on_rounded,
            color: const Color(0xFF1E6B38),
            size: size * 0.58,
          ),
        ),
      );
    } else {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFFF0FDF4),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF58C97A), width: 2.2),
        ),
        child: Center(
          child: Icon(
            Icons.celebration_rounded,
            color: const Color(0xFF2EAA55),
            size: size * 0.58,
          ),
        ),
      );
    }
  }
}
