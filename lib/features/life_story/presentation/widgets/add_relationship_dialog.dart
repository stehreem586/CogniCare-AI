import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/relationship_node_model.dart';
import '../../data/models/memory_model.dart';

class AddRelationshipDialog extends StatefulWidget {
  final List<MemoryModel> availableMemories;
  final Function(String name, String relation, RelationshipNodeType type, List<String> linkedMemoryIds) onAdd;

  const AddRelationshipDialog({
    super.key,
    required this.availableMemories,
    required this.onAdd,
  });

  @override
  State<AddRelationshipDialog> createState() => _AddRelationshipDialogState();
}

class _AddRelationshipDialogState extends State<AddRelationshipDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _relationController = TextEditingController();

  RelationshipNodeType _selectedType = RelationshipNodeType.person;
  String? _selectedMemoryId;

  @override
  void dispose() {
    _nameController.dispose();
    _relationController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onAdd(
        _nameController.text.trim(),
        _relationController.text.trim(),
        _selectedType,
        _selectedMemoryId != null ? [_selectedMemoryId!] : [],
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Grab Handle
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

              const SizedBox(height: 18),

              // Title
              const Text(
                'Link new relationship',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.titleNavy,
                ),
              ),

              const SizedBox(height: 4),

              const Text(
                'Connect people, places, and events to the patient\'s memory map',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                ),
              ),

              const SizedBox(height: 18),

              // 1. Entity Type Segmented Bar
              Row(
                children: [
                  _buildTypeOption('Person', RelationshipNodeType.person, const Color(0xFF2563EB)),
                  const SizedBox(width: 8),
                  _buildTypeOption('Place', RelationshipNodeType.place, const Color(0xFF1E6B38)),
                  const SizedBox(width: 8),
                  _buildTypeOption('Event', RelationshipNodeType.event, const Color(0xFF58C97A)),
                ],
              ),

              const SizedBox(height: 18),

              // 2. Name Field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: _selectedType == RelationshipNodeType.person
                      ? 'Person Name (e.g., Uncle Tariq)'
                      : _selectedType == RelationshipNodeType.place
                          ? 'Place Name (e.g., Murree Hills)'
                          : 'Event Name (e.g., Annual Reunion)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: Icon(
                    _selectedType == RelationshipNodeType.person
                        ? Icons.person_outline_rounded
                        : _selectedType == RelationshipNodeType.place
                            ? Icons.place_outlined
                            : Icons.event_note_outlined,
                  ),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Please enter a name' : null,
              ),

              const SizedBox(height: 14),

              // 3. Relationship / Connection Label Field
              TextFormField(
                controller: _relationController,
                decoration: InputDecoration(
                  labelText: _selectedType == RelationshipNodeType.person
                      ? 'Relationship to patient (e.g., Brother, Doctor)'
                      : _selectedType == RelationshipNodeType.place
                          ? 'Connection to patient (e.g., Visited, Vacation)'
                          : 'Role / Memory tag (e.g., Celebrated, Hosted)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.hub_outlined),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Please specify the relationship' : null,
              ),

              const SizedBox(height: 14),

              // 4. Memory Association Dropdown (Optional)
              if (widget.availableMemories.isNotEmpty) ...[
                DropdownButtonFormField<String>(
                  initialValue: _selectedMemoryId,
                  decoration: InputDecoration(
                    labelText: 'Link to stored memory (Optional)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.photo_library_outlined),
                  ),
                  items: widget.availableMemories.map((m) {
                    return DropdownMenuItem<String>(
                      value: m.id,
                      child: Text(
                        m.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13.5),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedMemoryId = val;
                    });
                  },
                ),
                const SizedBox(height: 20),
              ],

              // 5. Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.add_link_rounded),
                  label: const Text('Add to Relationship Map', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeOption(String label, RelationshipNodeType type, Color activeColor) {
    final isSelected = _selectedType == type;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedType = type;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? activeColor.withValues(alpha: 0.14) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? activeColor : const Color(0xFFCBD5E1),
              width: isSelected ? 1.8 : 1.0,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? activeColor : const Color(0xFF475569),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 13.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
