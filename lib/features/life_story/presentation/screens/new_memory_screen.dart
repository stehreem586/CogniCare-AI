import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../app/routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../../services/auth_state_service.dart';
import '../../data/models/memory_model.dart';
import '../../data/repositories/memory_repository_impl.dart';
import '../../domain/repositories/memory_repository.dart';
import '../widgets/memory_illustration.dart';
import '../widgets/people_tag_dialog.dart';
import '../widgets/voice_memo_widget.dart';

class NewMemoryScreen extends StatefulWidget {
  final MemoryRepository? memoryRepository;
  final String? patientId;

  const NewMemoryScreen({
    super.key,
    this.memoryRepository,
    this.patientId,
  });

  @override
  State<NewMemoryScreen> createState() => _NewMemoryScreenState();
}

class _NewMemoryScreenState extends State<NewMemoryScreen> {
  final _formKey = GlobalKey<FormState>();

  late final MemoryRepository _memoryRepository;
  late final TextEditingController _titleController;
  late final TextEditingController _placeController;

  DateTime _selectedDate = DateTime(1998, 4, 14);
  String _selectedEra = 'Childhood';
  List<String> _taggedPeople = ['Ayesha', 'Nani'];
  String? _illustrationKey = 'eid_house';
  String? _pickedImagePath;
  int _audioDurationSeconds = 24;
  bool _isSaving = false;

  final ImagePicker _picker = ImagePicker();

  final List<String> _eras = const ['Childhood', 'Adulthood', 'Recent'];

  @override
  void initState() {
    super.initState();
    _memoryRepository = widget.memoryRepository ?? MemoryRepositoryImpl();
    _titleController = TextEditingController(text: "Eid at Nani's house");
    _placeController = TextEditingController(text: 'Lahore');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String && _eras.contains(args)) {
      _selectedEra = args;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _placeController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _pickedImagePath = image.path;
          _illustrationKey = null; // Use real photo
        });
      }
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showError(context, 'Failed to pick image: $e');
      }
    }
  }

  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                const Text(
                  'Upload Memory Photo',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.titleNavy,
                  ),
                ),
                const SizedBox(height: 14),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFEFF6FF),
                    child: Icon(Icons.photo_library_outlined, color: AppColors.primary),
                  ),
                  title: const Text('Choose from Gallery', style: TextStyle(fontWeight: FontWeight.w600)),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFEFF6FF),
                    child: Icon(Icons.camera_alt_outlined, color: AppColors.primary),
                  ),
                  title: const Text('Take a Photo', style: TextStyle(fontWeight: FontWeight.w600)),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImage(ImageSource.camera);
                  },
                ),
                const Divider(),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Text('Or select a classic life story preset:', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildPresetChip('School Day', 'school_day'),
                    _buildPresetChip('Eid at Nani\'s', 'eid_house'),
                    _buildPresetChip('Lahore Fort', 'lahore_fort'),
                    _buildPresetChip('Murree Picnic', 'murree_picnic'),
                    _buildPresetChip('Graduation', 'graduation'),
                    _buildPresetChip('Wedding Day', 'wedding'),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPresetChip(String label, String key) {
    final isSelected = _illustrationKey == key && _pickedImagePath == null;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.primaryLight,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.textPrimary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12.5,
      ),
      onSelected: (val) {
        if (val) {
          setState(() {
            _illustrationKey = key;
            _pickedImagePath = null;
          });
          Navigator.pop(context);
        }
      },
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.titleNavy,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _openPeopleTagDialog() async {
    final result = await showDialog<List<String>>(
      context: context,
      builder: (_) => PeopleTagDialog(initialTags: _taggedPeople),
    );

    if (result != null) {
      setState(() {
        _taggedPeople = result;
      });
    }
  }

  void _applyAiSuggestions() {
    setState(() {
      _titleController.text = "Eid at Nani's house";
      _placeController.text = 'Lahore';
      _selectedDate = DateTime(1998, 4, 14);
      _selectedEra = 'Childhood';
      if (!_taggedPeople.contains('Ayesha')) _taggedPeople.add('Ayesha');
      if (!_taggedPeople.contains('Nani')) _taggedPeople.add('Nani');
    });

    SnackbarUtils.showSuccess(
      context,
      '✨ AI suggested tags applied: Eid, Lahore, Nani, 1998',
    );
  }

  Future<void> _handleSaveMemory() async {
    if (_titleController.text.trim().isEmpty) {
      SnackbarUtils.showError(context, 'Please enter a title for the memory.');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final targetPatientId = widget.patientId ??
        (Firebase.apps.isNotEmpty ? AuthStateService.instance.currentUserProfile?.uid : null) ??
        'patient_rahim_khan';

    final caregiverId = (Firebase.apps.isNotEmpty ? AuthStateService.instance.currentFirebaseUser?.uid : null) ?? 'caregiver_1';

    final newMemory = MemoryModel(
      id: 'mem_${DateTime.now().millisecondsSinceEpoch}',
      patientId: targetPatientId,
      caregiverId: caregiverId,
      title: _titleController.text.trim(),
      date: _selectedDate,
      place: _placeController.text.trim().isNotEmpty ? _placeController.text.trim() : 'Lahore',
      era: _selectedEra,
      illustrationKey: _illustrationKey,
      localImagePath: _pickedImagePath,
      taggedPeople: _taggedPeople,
      audioDurationSeconds: _audioDurationSeconds,
      aiSuggestions: const ['Eid', 'Lahore', 'Nani', '1998'],
      createdAt: DateTime.now(),
    );

    try {
      await _memoryRepository.addMemory(memory: newMemory);

      if (!mounted) return;
      setState(() {
        _isSaving = false;
      });

      SnackbarUtils.showSuccess(context, 'Memory saved successfully to life story!');

      // Pop and return true or push library
      Navigator.of(context).pushReplacementNamed(AppRoutes.memoryLibrary);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
        SnackbarUtils.showError(context, 'Failed to save memory: $e');
      }
    }
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'New memory',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.titleNavy,
          ),
        ),
        actions: [
          // AI Assist Pill Button
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: InkWell(
                onTap: _applyAiSuggestions,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFC8E6C9),
                      width: 1.0,
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.auto_awesome, size: 14, color: Color(0xFF2E7D32)),
                      SizedBox(width: 4),
                      Text(
                        'AI assist',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Photo Preview Card with "Change photo" Button
                _buildPhotoPreviewCard(),

                const SizedBox(height: 14),

                // 2. AI Suggestions Banner
                _buildAiSuggestionBanner(),

                const SizedBox(height: 16),

                // 3. Title Input Field
                _buildTitleField(),

                const SizedBox(height: 12),

                // 4. Date and Place Row
                _buildDateAndPlaceRow(),

                const SizedBox(height: 16),

                // 5. Era Selector (Childhood, Adulthood, Recent)
                _buildEraSelector(),

                const SizedBox(height: 16),

                // 6. People Tagging Row
                _buildPeopleTagRow(),

                const SizedBox(height: 16),

                // 7. Voice Memo Recorder Row
                VoiceMemoWidget(
                  initialDurationSeconds: _audioDurationSeconds,
                  onDurationChanged: (val) {
                    _audioDurationSeconds = val;
                  },
                ),

                const SizedBox(height: 28),

                // 8. "Save memory" Button
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _handleSaveMemory,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2EAA55),
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shadowColor: const Color(0xFF2EAA55).withValues(alpha: 0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(27),
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Save memory',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.1,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoPreviewCard() {
    return Container(
      width: double.infinity,
      height: 215,
      decoration: BoxDecoration(
        color: const Color(0xFF0D2847),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image / Illustrated Scene
            MemoryIllustration(
              illustrationKey: _illustrationKey,
              localImagePath: _pickedImagePath,
              fit: BoxFit.cover,
            ),

            // Change Photo Button at Bottom-Right
            Positioned(
              right: 14,
              bottom: 14,
              child: GestureDetector(
                onTap: _showImageOptions,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 1.0,
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.camera_alt_outlined, size: 16, color: Colors.white),
                      SizedBox(width: 6),
                      Text(
                        'Change photo',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAiSuggestionBanner() {
    return GestureDetector(
      onTap: _applyAiSuggestions,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F8F0),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFC8E6C9),
            width: 1.0,
          ),
        ),
        child: const Row(
          children: [
            Icon(Icons.auto_awesome, size: 16, color: Color(0xFF2E7D32)),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'AI suggests: Eid • Lahore • Nani • 1998',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1B5E20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.favorite_border_rounded, color: AppColors.primary, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                labelStyle: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                ),
                hintText: 'Eid at Nani\'s house',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 8),
              ),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.titleNavy,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateAndPlaceRow() {
    return Row(
      children: [
        // Date
        Expanded(
          child: GestureDetector(
            onTap: _selectDate,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, color: AppColors.primary, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Date',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatDate(_selectedDate),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.titleNavy,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Place
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on_outlined, color: AppColors.brandTeal, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _placeController,
                    decoration: const InputDecoration(
                      labelText: 'Place',
                      labelStyle: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                      ),
                      hintText: 'Lahore',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 6),
                    ),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.titleNavy,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEraSelector() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: _eras.map((era) {
          final isSelected = _selectedEra == era;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedEra = era;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    era,
                    style: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF64748B),
                      fontSize: 13.5,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPeopleTagRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
      ),
      child: Row(
        children: [
          // Overlapping Avatars
          _buildOverlappingAvatars(),

          const SizedBox(width: 12),

          // Tagged Names Summary
          Expanded(
            child: Text(
              _taggedPeople.isNotEmpty ? _taggedPeople.join(', ') : 'No people tagged',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _taggedPeople.isNotEmpty ? AppColors.titleNavy : AppColors.textMuted,
              ),
            ),
          ),

          // "+ Tag" Blue Pill Button
          ElevatedButton(
            onPressed: _openPeopleTagDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              '+ Tag',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverlappingAvatars() {
    if (_taggedPeople.isEmpty) {
      return Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(
          color: Color(0xFFEFF6FF),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.person_outline, size: 20, color: AppColors.primary),
      );
    }

    final avatarColors = [
      const Color(0xFF6EE7B7),
      const Color(0xFFFDE68A),
      const Color(0xFF93C5FD),
    ];

    return SizedBox(
      width: 24.0 + (_taggedPeople.length.clamp(1, 3) * 16.0),
      height: 36,
      child: Stack(
        children: _taggedPeople.take(3).toList().asMap().entries.map((entry) {
          final idx = entry.key;
          final name = entry.value;
          final color = avatarColors[idx % avatarColors.length];

          return Positioned(
            left: idx * 16.0,
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Center(
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F325E),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
