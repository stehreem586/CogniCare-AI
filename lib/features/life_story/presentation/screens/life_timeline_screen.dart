import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../../../../app/routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../services/auth_state_service.dart';
import '../../../caregiver/data/repositories/caregiver_repository_impl.dart';
import '../../data/models/memory_model.dart';
import '../../data/repositories/memory_repository_impl.dart';
import '../../domain/repositories/memory_repository.dart';
import '../widgets/life_story_bottom_bar.dart';
import '../widgets/memory_card.dart';
import '../widgets/timeline_item_card.dart';

/// Screen implementing FE-2: Build a structured memory timeline
/// (childhood, adulthood, recent events).
class LifeTimelineScreen extends StatefulWidget {
  final MemoryRepository? memoryRepository;
  final String? patientId;
  final String? patientName;
  final int? patientBirthYear;

  const LifeTimelineScreen({
    super.key,
    this.memoryRepository,
    this.patientId,
    this.patientName,
    this.patientBirthYear,
  });

  @override
  State<LifeTimelineScreen> createState() => _LifeTimelineScreenState();
}

class _LifeTimelineScreenState extends State<LifeTimelineScreen> {
  late final MemoryRepository _memoryRepository;
  bool _isLoading = true;
  List<MemoryModel> _allMemories = [];

  String _patientName = 'Rahim';
  String _patientId = 'patient_rahim_khan';
  int _patientBirthYear = 1983; // 1989 - 6 = 1983 as in design mockup

  String _selectedEra = 'Childhood';
  final List<String> _eras = const ['Childhood', 'Adulthood', 'Recent'];

  @override
  void initState() {
    super.initState();
    _memoryRepository = widget.memoryRepository ?? MemoryRepositoryImpl();
    if (widget.patientId != null) _patientId = widget.patientId!;
    if (widget.patientName != null) _patientName = widget.patientName!;
    if (widget.patientBirthYear != null) _patientBirthYear = widget.patientBirthYear!;

    _loadData();
  }

  Future<void> _loadData() async {
    if (Firebase.apps.isNotEmpty) {
      try {
        final firebaseUser = AuthStateService.instance.currentFirebaseUser;
        if (firebaseUser != null) {
          final patients = await CaregiverRepositoryImpl().getLinkedPatientProfiles(
            caregiverId: firebaseUser.uid,
          );
          if (patients.isNotEmpty) {
            final p = patients.first;
            _patientName = p.name.split(' ').first;
            _patientId = p.uid;
          }
        }
      } catch (_) {}
    }

    final list = await _memoryRepository.getMemories(patientId: _patientId);
    if (mounted) {
      setState(() {
        _allMemories = list;
        _isLoading = false;
      });
    }
  }

  List<MemoryModel> _getFilteredMemories() {
    List<MemoryModel> filtered;

    if (_selectedEra == 'Childhood') {
      // In design mockup, Childhood timeline includes childhood memories and
      // the graduation transition milestone into early adulthood.
      filtered = _allMemories.where((m) {
        return m.era.toLowerCase() == 'childhood' ||
            (m.title.toLowerCase().contains('graduation') && m.date.year <= 2005);
      }).toList();
    } else if (_selectedEra == 'Adulthood') {
      filtered = _allMemories.where((m) {
        return m.era.toLowerCase() == 'adulthood';
      }).toList();
    } else {
      filtered = _allMemories.where((m) {
        return m.era.toLowerCase() == 'recent';
      }).toList();
    }

    // Sort chronologically (earliest to latest) from childhood to today
    filtered.sort((a, b) => a.date.compareTo(b.date));
    return filtered;
  }

  void _showMemoryDetail(MemoryModel memory) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.72,
          minChildSize: 0.5,
          maxChildSize: 0.92,
          expand: false,
          builder: (_, scrollController) {
            final age = memory.date.year - _patientBirthYear;
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(24),
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
                  const SizedBox(height: 20),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: SizedBox(
                      width: double.infinity,
                      height: 190,
                      child: MemoryCard(memory: memory),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    memory.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.titleNavy,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Text(
                        '${memory.date.year} (Age $age)',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
                      ),
                      if (memory.place.isNotEmpty) ...[
                        const SizedBox(width: 16),
                        const Icon(Icons.location_on_outlined, size: 18, color: AppColors.brandTeal),
                        const SizedBox(width: 4),
                        Text(
                          memory.place,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Era: ${memory.era}',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  if (memory.taggedPeople.isNotEmpty) ...[
                    const Text(
                      'Tagged People:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.titleNavy,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: memory.taggedPeople.map((person) {
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
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 18),
                  ],
                  if (memory.audioDurationSeconds > 0) ...[
                    const Text(
                      'Voice Memory Story:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.titleNavy,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            backgroundColor: Color(0xFF2EAA55),
                            radius: 18,
                            child: Icon(Icons.play_arrow_rounded, color: Colors.white),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Voice recording available',
                              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                            ),
                          ),
                          Text(
                            '0:${memory.audioDurationSeconds.toString().padLeft(2, '0')}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
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
    final filteredMemories = _getFilteredMemories();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _loadData,
                    color: AppColors.primary,
                    child: CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      slivers: [
                        // 1. Deep Navy Curved Header with Segmented Filter
                        SliverToBoxAdapter(
                          child: _buildHeader(),
                        ),

                        const SliverToBoxAdapter(
                          child: SizedBox(height: 24),
                        ),

                        // 2. Timeline List or Empty State
                        if (filteredMemories.isEmpty)
                          SliverToBoxAdapter(
                            child: _buildEmptyState(),
                          )
                        else
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final memory = filteredMemories[index];
                                final isFirst = index == 0;
                                final isLast = index == filteredMemories.length - 1;

                                return TimelineItemCard(
                                  memory: memory,
                                  isFirst: isFirst,
                                  isLast: isLast,
                                  patientBirthYear: _patientBirthYear,
                                  onTap: () => _showMemoryDetail(memory),
                                );
                              },
                              childCount: filteredMemories.length,
                            ),
                          ),

                        const SliverToBoxAdapter(
                          child: SizedBox(height: 20),
                        ),
                      ],
                    ),
                  ),
                ),

                // 3. Docked Bottom Navigation Bar (Timeline active at index 2)
                LifeStoryBottomBar(
                  currentIndex: 2,
                  onTap: (index) {},
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
      child: Stack(
        children: [
          // Decorative subtle curved teal highlight in upper right corner
          Positioned(
            right: -30,
            top: -20,
            child: Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF2E8B57).withValues(alpha: 0.16),
              ),
            ),
          ),

          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  const Text(
                    'Life timeline',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.4,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Subtitle: "Rahim's story, from childhood to today"
                  Text(
                    "$_patientName's story, from childhood to today",
                    style: const TextStyle(
                      color: Color(0xFFBFDBFE),
                      fontSize: 13.5,
                      fontWeight: FontWeight.w400,
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Segmented Pill Filter Container
                  _buildEraFilterPills(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEraFilterPills() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(26),
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
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
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
                      color: isSelected ? const Color(0xFF0F325E) : Colors.white,
                      fontSize: 13.5,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
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

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFBFDBFE), width: 1.5),
            ),
            child: const Icon(
              Icons.auto_stories_outlined,
              color: AppColors.primary,
              size: 34,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No $_selectedEra memories yet',
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.titleNavy,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Add stories from $_patientName\'s $_selectedEra to build out this part of the life timeline.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13.5,
              color: Color(0xFF64748B),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pushNamed(
                AppRoutes.newMemory,
                arguments: _selectedEra,
              );
            },
            icon: const Icon(Icons.add_rounded, size: 20),
            label: Text('Add $_selectedEra memory'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2EAA55),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
