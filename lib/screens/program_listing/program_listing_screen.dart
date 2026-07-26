import 'package:flutter/material.dart';
import '../../core/routes/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../data/mock_data.dart';
import '../../services/opportunity_service.dart';
import '../../widgets/error_retry_card.dart';
import '../../widgets/program_card.dart';

class ProgramListingScreen extends StatefulWidget {
  const ProgramListingScreen({super.key});

  @override
  State<ProgramListingScreen> createState() => _ProgramListingScreenState();
}

class _ProgramListingScreenState extends State<ProgramListingScreen> {
  String _searchQuery = '';
  OpportunityType? _selectedCategory;
  LocationType? _selectedLocation;
  DurationType? _selectedDuration;
  bool _isFreeOnly = false;

  late Future<List<Opportunity>> _opportunitiesFuture;

  @override
  void initState() {
    super.initState();
    _fetchOpportunities();
  }

  void _fetchOpportunities() {
    _opportunitiesFuture = OpportunityService.fetchOpportunities();
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _fetchOpportunities();
    });
    await _opportunitiesFuture.catchError((_) => <Opportunity>[]);
  }

  List<Opportunity> _filterOpportunities(List<Opportunity> rawList) {
    return rawList.where((opp) {
      final matchesSearch = opp.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == null || opp.type == _selectedCategory;
      final matchesLocation = _selectedLocation == null || opp.location == _selectedLocation;
      final matchesDuration = _selectedDuration == null || opp.durationType == _selectedDuration;
      final matchesCost = !_isFreeOnly || opp.fee == 0;
      return matchesSearch && matchesCategory && matchesLocation && matchesDuration && matchesCost;
    }).toList();
  }

  Future<void> _openProgramDetails(Opportunity program) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );

    try {
      final fetchedProgram = await OpportunityService.fetchOpportunityById(program.id);
      
      if (!mounted) return;
      Navigator.pop(context); 
      
      Navigator.pushNamed(
        context,
        AppRouter.programDetails,
        arguments: fetchedProgram,
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); 
      
      showModalBottomSheet(
        context: context,
        backgroundColor: AppColors.background,
        builder: (sheetContext) => Padding(
          padding: EdgeInsets.only(
            top: 24.0,
            left: 24.0,
            right: 24.0,
            bottom: 24.0 + MediaQuery.of(context).padding.bottom,
          ),
          child: ErrorRetryCard(
            message: e.toString(),
            onRetry: () {
              Navigator.pop(sheetContext); // Close the error bottom sheet
              _openProgramDetails(program); // Retry the fetch immediately
            },
          ),
        ),
      );
    }
  }

  String _getCategoryLabel(OpportunityType type) {
    switch (type) {
      case OpportunityType.internship: return 'Internship';
      case OpportunityType.jobSimulation: return 'Job Simulation';
      case OpportunityType.course: return 'Course';
      case OpportunityType.competition: return 'Competition';
      case OpportunityType.event: return 'Event';
      case OpportunityType.masterclass: return 'Masterclass';
      case OpportunityType.career: return 'Career';
      case OpportunityType.engagement: return 'Engagement';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          RefreshIndicator(
        onRefresh: _handleRefresh,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // --- HEADER, SEARCH & FILTER SECTION ---
            SliverToBoxAdapter(
              child: Stack(
                children: [
                  // 1. The Peach Wave Background
                  ClipPath(
                    clipper: _SigmoidClipper(),
                    child: Container(
                      height: 240,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFFFF7F2), // Pale peach
                            Color(0xFFFFD4B8), // Stronger peach at bottom
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Background Elements
                  const Positioned(
                    top: 45,
                    right: 60,
                    child: Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                  ),
                  const Positioned(
                    top: 100,
                    left: 32,
                    child: Opacity(
                      opacity: 0.3,
                      child: Text(
                        '· · ·\n· · ·\n· · ·',
                        style: TextStyle(color: Colors.white, fontSize: 18, height: 0.6, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 80,
                    right: 20,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(Icons.menu_book_rounded, color: Colors.white.withValues(alpha: 0.4), size: 80),
                        Positioned(
                          top: -15,
                          child: Icon(Icons.school_rounded, color: const Color(0xFF1E293B).withValues(alpha: 0.8), size: 48),
                        ),
                      ],
                    ),
                  ),
                  
                  // 2. The Content Layout
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top spacing for SafeArea
                      SizedBox(height: MediaQuery.of(context).padding.top + 8),
                      // Back Button
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Color(0xFFFFEAD9),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B), size: 20),
                            onPressed: () {
                              if (Navigator.canPop(context)) Navigator.pop(context);
                            },
                          ),
                        ),
                      ),
                      
                      // Title & Subtitle
                      Padding(
                        padding: const EdgeInsets.only(left: 32.0, top: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Explore Programs',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF0F172A),
                                fontSize: 26,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Discover, learn and grow with\ncurated programs for you',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: const Color(0xFF475569),
                                fontSize: 12,
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: 32,
                              height: 3,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Search Bar Pill
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(32),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.textPrimary.withValues(alpha: 0.05),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 4),
                          child: Row(
                            children: [
                              const SizedBox(width: AppSpacing.xs),
                              const Icon(Icons.search, color: Color(0xFF64748B), size: 22),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: TextField(
                                  onChanged: (value) {
                                    setState(() {
                                      _searchQuery = value;
                                    });
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'Search programs, skills, or companies...',
                                    hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: const Color(0xFF94A3B8),
                                    ),
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    isDense: true,
                                  ),
                                ),
                              ),
                              Container(
                                height: 24,
                                width: 1,
                                color: AppColors.divider.withValues(alpha: 0.5),
                                margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                              ),
                              GestureDetector(
                                onTap: _showFilterBottomSheet,
                                child: const Icon(Icons.tune, color: Color(0xFF475569), size: 22),
                              ),
                              const SizedBox(width: AppSpacing.xs),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: AppSpacing.lg),
                      
                      // Filter Chips — Category Selection
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                        child: Row(
                          children: [
                            _buildFilterChip(context, 'All', null, Icons.grid_view_rounded),
                            ...OpportunityType.values.map((type) {
                              IconData? icon;
                              switch(type) {
                                case OpportunityType.internship: icon = Icons.work_outline_rounded; break;
                                case OpportunityType.jobSimulation: icon = Icons.computer_rounded; break;
                                case OpportunityType.course: icon = Icons.menu_book_rounded; break;
                                case OpportunityType.competition: icon = Icons.emoji_events_outlined; break;
                                case OpportunityType.event: icon = Icons.event; break;
                                case OpportunityType.masterclass: icon = Icons.co_present; break;
                                case OpportunityType.career: icon = Icons.trending_up; break;
                                case OpportunityType.engagement: icon = Icons.people_outline; break;
                              }
                              return _buildFilterChip(context, _getCategoryLabel(type), type, icon);
                            }),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: AppSpacing.xxl),
                      
                      // Featured Today Card (ONLY SHOWN IF 'ALL' IS SELECTED)
                      if (_selectedCategory == null)
                        Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFFFFF8F3),
                              Color(0xFFFFE8D6),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Text('', style: TextStyle(fontSize: 16)),
                                      Text(
                                        'Featured Today',
                                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                          color: AppColors.primaryDark,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  Text(
                                    'Flutter Development\nBootcamp',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF0F172A),
                                      height: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  Text(
                                    'Build real-world apps and become a Flutter expert.',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: const Color(0xFF475569),
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.lg),
                                  // Bottom row
                                  Wrap(
                                    crossAxisAlignment: WrapCrossAlignment.center,
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.star_rounded, color: AppColors.accent, size: 14),
                                            const SizedBox(width: 4),
                                            Text(
                                              '4.6 ',
                                              style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700),
                                            ),
                                            Text(
                                              '(128)',
                                              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textSecondary),
                                            ),
                                          ],
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {},
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primary,
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                                          elevation: 4,
                                          shadowColor: AppColors.primary.withValues(alpha: 0.4),
                                          minimumSize: const Size(0, 36),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: const [
                                            Text('Explore Now ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                                            Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 14),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Graphic perfectly sized on the right side
                            Container(
                              width: 80,
                              height: 100,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E3A8A),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF1E3A8A).withValues(alpha: 0.3),
                                    blurRadius: 12,
                                    offset: const Offset(4, 6),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: FlutterLogo(size: 40),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ), // Closes Padding
                    // End of Featured Today Card
                    
                    const SizedBox(height: AppSpacing.sm),
                  ], // Closes Column children
                ), // Closes Column
              ], // Closes Stack children
            ), // Closes Stack
          ), // Closes SliverToBoxAdapter
            
            // --- PROGRAM LIST or EMPTY STATE (NOW WITH ASYNC FUTUREBUILDER) ---
            FutureBuilder<List<Opportunity>>(
              future: _opportunitiesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                  );
                }
                
                if (snapshot.hasError) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: ErrorRetryCard(
                          message: snapshot.error.toString(),
                          onRetry: () => setState(() => _fetchOpportunities()),
                        ),
                      ),
                    ),
                  );
                }

                final rawList = snapshot.data ?? [];
                final filteredList = _filterOpportunities(rawList);

                if (filteredList.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: _buildEmptyState(context),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final program = filteredList[index];
                        return TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: Duration(milliseconds: 400 + (index * 100).clamp(0, 500)),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, child) {
                            return Transform.translate(
                              offset: Offset(0, 20 * (1 - value)),
                              child: Opacity(
                                opacity: value,
                                child: child,
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                            child: ProgramCard(
                              program: program,
                              onTap: () => _openProgramDetails(program),
                            ),
                          ),
                        );
                      },
                      childCount: filteredList.length,
                    ),
                  ),
                );
              },
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 100), // Spacing for bottom navbar
            ),
          ],
        ),
      ),
      // === BOTTOM NAVIGATION BAR (Anchored permanently above the scroll view) ===
      _buildBottomFloatingNavBar(),
    ],
  ),
);
}

// Excelerate exact Bottom Navigation Bar replication, fully aligned horizontally
Widget _buildBottomFloatingNavBar() {
  return Positioned(
    bottom: 20,
    left: 16,
    right: 16,
    child: Container(
      height: 74,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF3F4F6).withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 32,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Home Tab
          GestureDetector(
            onTap: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            },
            child: _buildNavItem(Icons.home_outlined, 'Home', false),
          ),
          // Explore Tab
          _buildNavItem(Icons.grid_view, 'Explore', true),
          
          // Syllabus index open-book button
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.22),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: const Icon(
                Icons.book_outlined,
                color: Colors.white,
                size: 21,
              ),
            ),
          ),

          // Learning History Tab
          _buildNavItem(Icons.play_circle_outline, 'Learning', false),
          // Profile Tab
          _buildNavItem(Icons.person_outline, 'Profile', false),
        ],
      ),
    ),
  );
}

// Navigation Item Builder helper
Widget _buildNavItem(IconData icon, String label, bool isActive) {
  final activeColor = AppColors.primary;
  final inactiveColor = AppColors.textSecondary;

  return SizedBox(
    width: 50,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: isActive ? activeColor : inactiveColor,
          size: 22,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: isActive ? activeColor : inactiveColor,
          ),
        ),
      ],
    ),
  );
}

  Widget _buildFilterChip(BuildContext context, String label, OpportunityType? type, IconData? icon) {
    final isSelected = _selectedCategory == type;
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: ChoiceChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : const Color(0xFF64748B),
              ),
              const SizedBox(width: 6),
            ],
            Text(label),
          ],
        ),
        selected: isSelected,
        showCheckmark: false,
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.primary,
        side: isSelected ? BorderSide.none : const BorderSide(color: Color(0xFFE2E8F0)), // faint grey border
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 8),
        labelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: isSelected ? Colors.white : const Color(0xFF334155),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        onSelected: (selected) {
          setState(() {
            _selectedCategory = selected ? type : null;
          });
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.06),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.22),
                  blurRadius: 32,
                  spreadRadius: 8,
                ),
              ],
            ),
            child: const Icon(
              Icons.travel_explore_rounded,
              size: 72,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'No programs found.',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Try adjusting your search or filters.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            width: 200,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(200, 48),
              ),
              onPressed: () {
                setState(() {
                  _searchQuery = '';
                  _selectedCategory = null;
                  _selectedLocation = null;
                  _selectedDuration = null;
                  _isFreeOnly = false;
                });
              },
              child: const Text('Clear Filters'),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.sm, AppSpacing.sm),
                    child: Row(
                      children: [
                        Text('Filters', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            setModalState(() {
                              _selectedLocation = null;
                              _selectedDuration = null;
                              _isFreeOnly = false;
                            });
                            setState(() {});
                          },
                          child: const Text('Reset', style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  // Scrollable Body
                  Flexible(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Format Section
                          Text('Format', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                          const SizedBox(height: AppSpacing.md),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: LocationType.values.map((loc) {
                              final isSelected = _selectedLocation == loc;
                              return ChoiceChip(
                                label: Text(loc.name.toUpperCase()),
                                selected: isSelected,
                                showCheckmark: false,
                                elevation: isSelected ? 2 : 0,
                                backgroundColor: AppColors.surface,
                                selectedColor: AppColors.primary,
                                side: isSelected ? BorderSide.none : BorderSide(color: AppColors.divider.withValues(alpha: 0.8)),
                                labelStyle: TextStyle(
                                  color: isSelected ? AppColors.onPrimary : AppColors.textPrimary,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                ),
                                onSelected: (selected) {
                                  setModalState(() => _selectedLocation = selected ? loc : null);
                                  setState(() {});
                                },
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: AppSpacing.xxl),
                          
                          // Duration Section
                          Text('Duration', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                          const SizedBox(height: AppSpacing.md),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: DurationType.values.map((duration) {
                              final isSelected = _selectedDuration == duration;
                              return ChoiceChip(
                                label: Text(duration.name.toUpperCase()),
                                selected: isSelected,
                                showCheckmark: false,
                                elevation: isSelected ? 2 : 0,
                                backgroundColor: AppColors.surface,
                                selectedColor: AppColors.primary,
                                side: isSelected ? BorderSide.none : BorderSide(color: AppColors.divider.withValues(alpha: 0.8)),
                                labelStyle: TextStyle(
                                  color: isSelected ? AppColors.onPrimary : AppColors.textPrimary,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                ),
                                onSelected: (selected) {
                                  setModalState(() => _selectedDuration = selected ? duration : null);
                                  setState(() {});
                                },
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: AppSpacing.xxl),
                          
                          // Pricing Section
                          Text('Pricing', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                          const SizedBox(height: AppSpacing.md),
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(AppRadius.card),
                              border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
                            ),
                            child: SwitchListTile(
                              title: const Text('Free programs only', style: TextStyle(fontWeight: FontWeight.w500)),
                              subtitle: const Text('Show scholarships and fully funded options', style: TextStyle(fontSize: 12)),
                              value: _isFreeOnly,
                              activeThumbColor: AppColors.onPrimary,
                              activeTrackColor: AppColors.primary,
                              contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 4),
                              onChanged: (val) {
                                setModalState(() => _isFreeOnly = val);
                                setState(() {});
                              },
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                        ],
                      ),
                    ),
                  ),
                  // Bottom sticky button
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.textPrimary.withValues(alpha: 0.05),
                          offset: const Offset(0, -4),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button)),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Show Results', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
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
}

class _SigmoidClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    
    // Diagonal slant: Starts at the bottom left, ends higher on the right
    final leftY = size.height;
    final rightY = size.height - 40.0;
    
    path.lineTo(0, leftY);
    
    // Smooth diagonal S-curve connecting the two points
    path.cubicTo(
      size.width * 0.4, leftY, 
      size.width * 0.6, rightY, 
      size.width, rightY,
    );
    
    path.lineTo(size.width, 0);
    path.close();
    
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
