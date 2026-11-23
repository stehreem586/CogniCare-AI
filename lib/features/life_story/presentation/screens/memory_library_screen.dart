import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../services/auth_state_service.dart';
import '../../data/models/memory_model.dart';
import '../../data/repositories/memory_repository_impl.dart';
import '../../domain/repositories/memory_repository.dart';
import '../widgets/life_story_bottom_bar.dart';
import '../widgets/memory_card.dart';
import '../widgets/memory_illustration.dart';

class MemoryLibraryScreen extends StatefulWidget {
  final MemoryRepository? memoryRepository;
  final String? patientId;
  final bool readOnly;

  const MemoryLibraryScreen({
    super.key,
    this.memoryRepository,
    this.patientId,
    this.readOnly = false,
  });

  @override
  State<MemoryLibraryScreen> createState() => _MemoryLibraryScreenState();
}

class _MemoryLibraryScreenState extends State<MemoryLibraryScreen> {
  late final MemoryRepository _memoryRepository;
  late final TextEditingController _searchController;

  bool _isLoading = true;
  List<MemoryModel> _allMemories = [];
  List<MemoryModel> _filteredMemories = [];

  String _selectedFilter = 'All'; // 'All', 'People', 'Places', 'Events'
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _memoryRepository = widget.memoryRepository ?? MemoryRepositoryImpl();
    _searchController = TextEditingController();
    _loadMemories();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMemories() async {
    final targetPatientId =
        widget.patientId ??
        (Firebase.apps.isNotEmpty
            ? AuthStateService.instance.currentUserProfile?.uid
            : null) ??
        'patient_rahim_khan';

    final list = await _memoryRepository.getMemories(
      patientId: targetPatientId,
    );
    if (mounted) {
      setState(() {
        _allMemories = list;
        _isLoading = false;
        _applyFilters();
      });
    }
  }

  void _applyFilters() {
    List<MemoryModel> temp = List.from(_allMemories);

    // Filter Category
    if (_selectedFilter == 'People') {
      temp = temp.where((m) => m.taggedPeople.isNotEmpty).toList();
    } else if (_selectedFilter == 'Places') {
      temp = temp.where((m) => m.place.isNotEmpty).toList();
    } else if (_selectedFilter == 'Events') {
      temp = temp.where((m) => m.era.isNotEmpty).toList();
    }

    // Search query
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.trim().toLowerCase();
      temp = temp.where((m) {
        final titleMatch = m.title.toLowerCase().contains(q);
        final placeMatch = m.place.toLowerCase().contains(q);
        final peopleMatch = m.taggedPeople.any(
          (p) => p.toLowerCase().contains(q),
        );
        final eraMatch = m.era.toLowerCase().contains(q);
        return titleMatch || placeMatch || peopleMatch || eraMatch;
      }).toList();
    }

    setState(() {
      _filteredMemories = temp;
    });
  }

  void _onSearchChanged(String val) {
    setState(() {
      _searchQuery = val;
      _applyFilters();
    });
  }

  void _onFilterSelected(String filter) {
    setState(() {
      _selectedFilter = filter;
      _applyFilters();
    });
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
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (_, scrollController) {
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
                    borderRadius: BorderRadius.circular(18),
                    child: SizedBox(
                      width: double.infinity,
                      height: 200,
                      child: MemoryCard(memory: memory),
                    ),
                  ),
                  const SizedBox(height: 16),
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
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${memory.date.day} ${_monthName(memory.date.month)} ${memory.date.year}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 16),
                      const Icon(
                        Icons.location_on_outlined,
                        size: 18,
                        color: AppColors.brandTeal,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        memory.place,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
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
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[(month - 1).clamp(0, 11)];
  }

  @override
  Widget build(BuildContext context) {
    // Featured "On this day" memory (e.g. Murree picnic or first memory)
    final MemoryModel onThisDayMemory = _allMemories.firstWhere(
      (m) => m.illustrationKey == 'murree_picnic' || m.isFavorite,
      orElse: () => _allMemories.isNotEmpty
          ? _allMemories.first
          : _createPlaceholderMemory(),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : Column(
              children: [
                Expanded(
                  child: SafeArea(
                    bottom: false,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Top Header Row: "Memory library" + Filter icon
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Memory library',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.titleNavy,
                                  letterSpacing: -0.4,
                                ),
                              ),
                              Container(
                                width: 42,
                                height: 42,
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.tune_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // 2. Search Bar
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                                width: 1.0,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _searchController,
                              onChanged: _onSearchChanged,
                              decoration: InputDecoration(
                                hintText: 'Search people, places, events',
                                hintStyle: const TextStyle(
                                  fontSize: 14.5,
                                  color: Color(0xFF94A3B8),
                                ),
                                prefixIcon: const Icon(
                                  Icons.search_rounded,
                                  color: Color(0xFF64748B),
                                  size: 22,
                                ),
                                suffixIcon: _searchQuery.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(
                                          Icons.clear_rounded,
                                          size: 18,
                                        ),
                                        onPressed: () {
                                          _searchController.clear();
                                          _onSearchChanged('');
                                        },
                                      )
                                    : null,
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 14),

                          // 3. Filter Pills Row
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            child: Row(
                              children: [
                                _buildFilterPill(
                                  'All',
                                  'All ${_allMemories.length}',
                                ),
                                const SizedBox(width: 8),
                                _buildFilterPill('People', 'People'),
                                const SizedBox(width: 8),
                                _buildFilterPill('Places', 'Places'),
                                const SizedBox(width: 8),
                                _buildFilterPill('Events', 'Events'),
                              ],
                            ),
                          ),

                          const SizedBox(height: 18),

                          // 4. "On this day • 2009" Highlight Card
                          if (_searchQuery.isEmpty) ...[
                            _buildOnThisDayCard(onThisDayMemory),
                            const SizedBox(height: 18),
                          ],

                          // 5. 2-Column Grid of Memories
                          _filteredMemories.isEmpty
                              ? const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 40),
                                  child: Center(
                                    child: Text(
                                      'No memories found matching your search.',
                                      style: TextStyle(
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                  ),
                                )
                              : GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        crossAxisSpacing: 14,
                                        mainAxisSpacing: 14,
                                        childAspectRatio: 0.95,
                                      ),
                                  itemCount: _filteredMemories.length,
                                  itemBuilder: (context, index) {
                                    final memory = _filteredMemories[index];
                                    return MemoryCard(
                                      memory: memory,
                                      onTap: () => _showMemoryDetail(memory),
                                    );
                                  },
                                ),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),

                // Docked Bottom Bar with Library (Index 1) active
                LifeStoryBottomBar(
                  currentIndex: 1,
                  onTap: (index) {},
                  readOnly:
                      widget.readOnly ||
                      (Firebase.apps.isNotEmpty &&
                          AuthStateService.instance.currentUserProfile?.role ==
                              'patient'),
                  patientId: widget.patientId,
                ),
              ],
            ),
    );
  }

  Widget _buildFilterPill(String filterKey, String label) {
    final isSelected = _selectedFilter == filterKey;

    return GestureDetector(
      onTap: () => _onFilterSelected(filterKey),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0),
            width: 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.titleNavy,
            fontSize: 13.5,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildOnThisDayCard(MemoryModel memory) {
    return GestureDetector(
      onTap: () => _showMemoryDetail(memory),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F5A9E), Color(0xFF0B467E)],
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F5A9E).withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Thumbnail Image
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                width: 72,
                height: 72,
                child: MemoryIllustration(
                  illustrationKey: memory.illustrationKey ?? 'murree_picnic',
                  localImagePath: memory.localImagePath,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'On this day • ${memory.date.year}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    memory.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16.5,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.2,
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

  MemoryModel _createPlaceholderMemory() {
    return MemoryModel(
      id: 'placeholder',
      patientId: 'patient_1',
      title: 'Family picnic in Murree',
      date: DateTime(2009, 7, 18),
      place: 'Murree',
      era: 'Adulthood',
      illustrationKey: 'murree_picnic',
      createdAt: DateTime.now(),
    );
  }
}
