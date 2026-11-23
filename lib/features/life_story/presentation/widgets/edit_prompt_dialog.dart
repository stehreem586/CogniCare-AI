import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/recall_prompt_model.dart';

class EditPromptDialog extends StatefulWidget {
  final RecallPromptModel prompt;
  final ValueChanged<RecallPromptModel> onSave;

  const EditPromptDialog({
    super.key,
    required this.prompt,
    required this.onSave,
  });

  @override
  State<EditPromptDialog> createState() => _EditPromptDialogState();
}

class _EditPromptDialogState extends State<EditPromptDialog> {
  late final TextEditingController _questionController;
  late String _difficulty;

  final List<String> _difficulties = const ['Easy', 'Medium', 'Hard'];

  @override
  void initState() {
    super.initState();
    _questionController = TextEditingController(text: widget.prompt.question);
    _difficulty = widget.prompt.difficulty;
  }

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _questionController.text.trim();
    if (text.isEmpty) return;

    final updated = widget.prompt.copyWith(
      question: text,
      difficulty: _difficulty,
    );
    widget.onSave(updated);
    Navigator.of(context).pop();
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
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

            const Text(
              'Edit Recall Prompt',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.titleNavy,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              'Memory: ${widget.prompt.memoryTitle}',
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 18),

            // Question Input
            TextField(
              controller: _questionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Prompt Question',
                hintText: 'Enter question for the patient...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),

            const SizedBox(height: 18),

            // Difficulty Selector
            const Text(
              'Difficulty Level',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.titleNavy,
              ),
            ),

            const SizedBox(height: 8),

            Row(
              children: _difficulties.map((diff) {
                final isSelected = _difficulty == diff;
                Color activeColor;
                if (diff == 'Easy') {
                  activeColor = const Color(0xFF0066BD);
                } else if (diff == 'Medium') {
                  activeColor = const Color(0xFFE65100);
                } else {
                  activeColor = const Color(0xFFC53030);
                }

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _difficulty = diff;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? activeColor.withValues(alpha: 0.14)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? activeColor
                                : const Color(0xFFCBD5E1),
                            width: isSelected ? 1.8 : 1.0,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            diff,
                            style: TextStyle(
                              color: isSelected
                                  ? activeColor
                                  : const Color(0xFF475569),
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Save Changes',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
