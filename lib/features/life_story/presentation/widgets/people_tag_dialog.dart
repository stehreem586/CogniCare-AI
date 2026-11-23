import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class PeopleTagDialog extends StatefulWidget {
  final List<String> initialTags;

  const PeopleTagDialog({super.key, required this.initialTags});

  @override
  State<PeopleTagDialog> createState() => _PeopleTagDialogState();
}

class _PeopleTagDialogState extends State<PeopleTagDialog> {
  late final List<String> _tags;
  final TextEditingController _controller = TextEditingController();

  final List<String> _suggestedPeople = const [
    'Ayesha',
    'Nani',
    'Uncle Tariq',
    'Hamza',
    'Zainab',
    'Grandkids',
    'Dr. Ali',
    'Sara',
    'Brother Usman',
  ];

  @override
  void initState() {
    super.initState();
    _tags = List.from(widget.initialTags);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addTag(String name) {
    final trimmed = name.trim();
    if (trimmed.isNotEmpty && !_tags.contains(trimmed)) {
      setState(() {
        _tags.add(trimmed);
        _controller.clear();
      });
    }
  }

  void _removeTag(String name) {
    setState(() {
      _tags.remove(name);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      title: const Row(
        children: [
          Icon(
            Icons.people_outline_rounded,
            color: AppColors.primary,
            size: 24,
          ),
          SizedBox(width: 10),
          Text(
            'Tag People',
            style: TextStyle(
              color: AppColors.titleNavy,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add family members or friends connected to this memory.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),

            // Text Input
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      hintText: 'e.g. Ayesha / Nani',
                      hintStyle: const TextStyle(fontSize: 14),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                      ),
                    ),
                    onSubmitted: _addTag,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _addTag(_controller.text),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                  child: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Tagged People Chips
            if (_tags.isNotEmpty) ...[
              const Text(
                'Tagged in this memory:',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.titleNavy,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: _tags.map((person) {
                  return Chip(
                    backgroundColor: const Color(0xFFEFF6FF),
                    side: const BorderSide(color: Color(0xFFBFDBFE)),
                    avatar: CircleAvatar(
                      backgroundColor: AppColors.primary,
                      child: Text(
                        person.isNotEmpty ? person[0].toUpperCase() : '?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    label: Text(
                      person,
                      style: const TextStyle(
                        color: AppColors.titleNavy,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    deleteIcon: const Icon(
                      Icons.close_rounded,
                      size: 16,
                      color: Colors.redAccent,
                    ),
                    onDeleted: () => _removeTag(person),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],

            // Quick Suggestions
            const Text(
              'Quick suggestions:',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _suggestedPeople.where((p) => !_tags.contains(p)).map((
                p,
              ) {
                return ActionChip(
                  label: Text('+ $p', style: const TextStyle(fontSize: 12)),
                  backgroundColor: const Color(0xFFF1F5F9),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                  onPressed: () => _addTag(p),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Cancel',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(_tags),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: const Text('Done'),
        ),
      ],
    );
  }
}
