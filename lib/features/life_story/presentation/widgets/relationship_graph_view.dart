import 'dart:math';
import 'package:flutter/material.dart';
import '../../data/models/relationship_node_model.dart';
import 'relationship_graph_painter.dart';

class RelationshipGraphView extends StatefulWidget {
  final List<RelationshipNode> nodes;
  final List<RelationshipEdge> edges;
  final RelationshipNode? selectedNode;
  final ValueChanged<RelationshipNode> onNodeSelected;
  final VoidCallback? onCenterNodeSelected;
  final bool animate;

  const RelationshipGraphView({
    super.key,
    required this.nodes,
    required this.edges,
    this.selectedNode,
    required this.onNodeSelected,
    this.onCenterNodeSelected,
    this.animate = true,
  });

  @override
  State<RelationshipGraphView> createState() => _RelationshipGraphViewState();
}

class _RelationshipGraphViewState extends State<RelationshipGraphView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    if (widget.animate) {
      _pulseController.repeat(reverse: true);
    }

    _pulseAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _handleTap(Offset localPosition, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.44);
    final graphRadius = min(size.width * 0.46, size.height * 0.38);

    // Check tap on outer nodes
    for (final node in widget.nodes) {
      final nodePos = Offset(
        center.dx + node.relativePosition.dx * graphRadius,
        center.dy + node.relativePosition.dy * graphRadius,
      );

      final dx = localPosition.dx - nodePos.dx;
      final dy = localPosition.dy - nodePos.dy;
      final dist = sqrt(dx * dx + dy * dy);

      if (dist <= 38.0) {
        widget.onNodeSelected(node);
        return;
      }
    }

    // Check tap on center node
    final cDx = localPosition.dx - center.dx;
    final cDy = localPosition.dy - center.dy;
    if (sqrt(cDx * cDx + cDy * cDy) <= 42.0) {
      if (widget.onCenterNodeSelected != null) {
        widget.onCenterNodeSelected!();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);

        return GestureDetector(
          onTapUp: (details) => _handleTap(details.localPosition, size),
          behavior: HitTestBehavior.opaque,
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return CustomPaint(
                size: size,
                painter: RelationshipGraphPainter(
                  nodes: widget.nodes,
                  edges: widget.edges,
                  selectedNode: widget.selectedNode,
                  animationProgress: 0.8 + (_pulseAnimation.value * 0.3),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
