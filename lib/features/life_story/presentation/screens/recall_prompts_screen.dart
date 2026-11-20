import 'package:flutter/material.dart';
import '../../../../app/routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/memory_model.dart';
import '../../data/models/recall_prompt_model.dart';
import '../../data/datasources/recall_prompt_service.dart';
import '../../data/repositories/memory_repository_impl.dart';
import '../../domain/repositories/memory_repository.dart';
import '../widgets/edit_prompt_dialog.dart';
import '../widgets/memory_illustration.dart';

/// Screen implementing FE-4: Generate memory recall prompts for users based on stored data.
class RecallPromptsScreen extends StatefulWidget {
  final MemoryRepository? memoryRepository;
  final String? patientId;

  const RecallPromptsScreen({
    super.key,
    this.memoryRepository,
    this.patientId,
  });

  @override
  State<RecallPromptsScreen> createState() => _RecallPromptsScreenState();
}

class _RecallPromptsScreenState extends State<RecallPromptsScreen> {
  late final MemoryRepository _memoryRepository;
  final RecallPromptService _promptService = RecallPromptService();

  bool _isLoading = true;
  List<MemoryModel> _memories = [];
  List<RecallPromptModel> _prompts = [];
  int _featuredIndex = 0;

  String _patientId = 'patient_rahim_khan';

  @override
  void initState() {
    super.initState();
    _memoryRepository = widget.memoryRepository ?? MemoryRepositoryImpl();
    if (widget.patientId != null) _patientId = widget.patientId!;

    _promptService.initializeWithDefaults();
    _prompts = _promptService.prompts;

    _loadData();
  }

  Future<void> _loadData() async {
    final list = await _memoryRepository.getMemories(patientId: _patientId);
    if (mounted) {
      setState(() {
        _memories = list;
        _isLoading = false;
      });
    }
  }

  void _generateAIPrompt() {
    _promptService.generatePromptFromMemories(_memories);
    setState(() {
      _prompts = _promptService.prompts;
      _featuredIndex = 0; // Point to the newly generated prompt
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.auto_awesome_rounded, color: Colors.amber, size: 20),
            SizedBox(width: 8),
            Expanded(
              child: Text('New AI recall prompt generated from memories!'),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF0F325E),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _sendPrompt(RecallPromptModel prompt) {
    _promptService.sendPrompt(prompt.id);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text('Prompt dispatched for ${prompt.memoryTitle}!'),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF2EAA55),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _openEditDialog(RecallPromptModel prompt) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return EditPromptDialog(
          prompt: prompt,
          onSave: (updated) {
            setState(() {
              _promptService.updatePrompt(updated);
              _prompts = _promptService.prompts;
            });

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Prompt updated successfully!'),
                backgroundColor: Color(0xFF0066BD),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _pickScheduleTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 17, minute: 0),
    );

    if (picked != null) {
      final formattedHour = picked.hourOfPeriod == 0 ? 12 : picked.hourOfPeriod;
      final minuteStr = picked.minute.toString().padLeft(2, '0');
      final period = picked.period == DayPeriod.am ? 'AM' : 'PM';
      final newTime = '$formattedHour:$minuteStr $period';

      setState(() {
        _promptService.smartScheduleTime = newTime;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Smart schedule updated to daily at $newTime'),
            backgroundColor: const Color(0xFF0066BD),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final featuredPrompt = _prompts.isNotEmpty && _featuredIndex < _prompts.length
        ? _prompts[_featuredIndex]
        : null;

    final queuedPrompts = _prompts.asMap().entries
        .where((entry) => entry.key != _featuredIndex)
        .map((entry) => MapEntry(entry.key, entry.value))
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. Curved Navy Header matching media_1795109518619_1f82d867.jpg
                        _buildHeader(),

                        const SizedBox(height: 18),

                        // 2. Large Featured Prompt Card
                        if (featuredPrompt != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: _buildFeaturedCard(featuredPrompt),
                          ),

                        const SizedBox(height: 16),

                        // 3. Queued Upcoming Prompts List
                        if (queuedPrompts.isNotEmpty) ...[
                          ...queuedPrompts.map((entry) {
                            final idx = entry.key;
                            final prompt = entry.value;
                            return Padding(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                              child: _buildQueueCard(prompt, idx),
                            );
                          }),
                        ],

                        const SizedBox(height: 8),

                        // 4. Smart Schedule Banner
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: _buildScheduleBanner(),
                        ),

                        const SizedBox(height: 28),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0F325E),
            Color(0xFF135896),
            Color(0xFF1A6CB0),
          ],
        ),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back Button
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pushReplacementNamed(AppRoutes.lifeStoryHub);
                },
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 38,
                  height: 38,
                  margin: const EdgeInsets.only(right: 12, top: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),

              // Title & Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Recall prompts',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.4,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Generated from stored memories',
                      style: TextStyle(
                        color: Color(0xFFBFDBFE),
                        fontSize: 13.5,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),

              // AI Button with sparkle icon
              GestureDetector(
                onTap: _generateAIPrompt,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.25),
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.auto_awesome,
                        color: Colors.white,
                        size: 15,
                      ),
                      SizedBox(width: 5),
                      Text(
                        'AI',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedCard(RecallPromptModel prompt) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Image Banner with Difficulty Badge
            Stack(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 140,
                  child: MemoryIllustration(
                    illustrationKey: prompt.illustrationKey,
                    localImagePath: prompt.localImagePath,
                    photoBase64: prompt.photoBase64,
                    photoUrl: prompt.photoUrl,
                    fit: BoxFit.cover,
                  ),
                ),

                // Difficulty Pill Badge (e.g. "Easy")
                Positioned(
                  top: 14,
                  left: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0066BD),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      prompt.difficulty,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Card Text Content & Buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'From: ${prompt.memoryTitle}',
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    '"${prompt.question}"',
                    style: const TextStyle(
                      color: AppColors.titleNavy,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.2,
                      height: 1.35,
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Action Buttons: Send & Edit
                  Row(
                    children: [
                      // Send Button
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _sendPrompt(prompt),
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFF48BB78), Color(0xFF2EAA55)],
                              ),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF2EAA55).withValues(alpha: 0.35),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.near_me_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Send',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Edit Button
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _openEditDialog(prompt),
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: const Color(0xFFCBD5E1),
                                width: 1.2,
                              ),
                            ),
                            child: const Center(
                              child: Text(
                                'Edit',
                                style: TextStyle(
                                  color: Color(0xFF0066BD),
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQueueCard(RecallPromptModel prompt, int originalIndex) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _featuredIndex = originalIndex;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Left Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(
                width: 58,
                height: 58,
                child: MemoryIllustration(
                  illustrationKey: prompt.illustrationKey,
                  localImagePath: prompt.localImagePath,
                  photoBase64: prompt.photoBase64,
                  photoUrl: prompt.photoUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(width: 14),

            // Middle Content: Question & Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '"${prompt.question}"',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.titleNavy,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${prompt.difficulty} • ${prompt.memoryTitle}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleBanner() {
    return GestureDetector(
      onTap: _pickScheduleTime,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFEBF5FF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFBFDBFE),
            width: 1.0,
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.access_time_rounded,
              color: Color(0xFF0066BD),
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Smart schedule: daily at ${_promptService.smartScheduleTime}',
                style: const TextStyle(
                  color: Color(0xFF0066BD),
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF0066BD),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
