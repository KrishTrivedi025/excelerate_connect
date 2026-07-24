import 'package:flutter/material.dart';
import '../../core/routes/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../data/mock_data.dart';
import '../../widgets/program_card.dart';

/// Program Listing Screen — Week 2 Build
/// 
/// Features:
/// - Category filter chips (All + 8 opportunity types)
/// - Pull-to-refresh indicator
/// - Animated list with staggered entrance
/// - Empty state with "Clear Filters" CTA
/// - Navigation to Program Details screen with transition
/// 
/// Connected to:
/// - AppRouter.programListing (navigation entry point)
/// - ProgramDetailsScreen (via tap on card)
/// - mock_data.Opportunity & OpportunityType models
class ProgramListingScreen extends StatefulWidget {
  const ProgramListingScreen({super.key});

  @override
  State<ProgramListingScreen> createState() => _ProgramListingScreenState();
}

class _ProgramListingScreenState extends State<ProgramListingScreen> {
  /// Search query — updated via TextField onChanged callback
  String _searchQuery = '';

  /// Selected category filter — null = "All"
  OpportunityType? _selectedCategory;

  /// Advanced filters
  LocationType? _selectedLocation;
  bool _isFreeOnly = false;

  /// Computed getter: filters mockOpportunities by search + category + advanced filters
  List<Opportunity> get _filteredOpportunities {
    return mockOpportunities.where((opp) {
      final matchesSearch = opp.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == null || opp.type == _selectedCategory;
      final matchesLocation = _selectedLocation == null || opp.location == _selectedLocation;
      final matchesCost = !_isFreeOnly || opp.fee == 0;
      return matchesSearch && matchesCategory && matchesLocation && matchesCost;
    }).toList();
  }

  /// Simulates network refresh (mock data is static)
  Future<void> _handleRefresh() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {});
  }

  /// Category label for filter chip display
  String _getCategoryLabel(OpportunityType type) {
    switch (type) {
      case OpportunityType.internship:
        return 'Internship';
      case OpportunityType.jobSimulation:
        return 'Job Simulation';
      case OpportunityType.course:
        return 'Course';
      case OpportunityType.competition:
        return 'Competition';
      case OpportunityType.event:
        return 'Event';
      case OpportunityType.masterclass:
        return 'Masterclass';
      case OpportunityType.career:
        return 'Career';
      case OpportunityType.engagement:
        return 'Engagement';
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = _filteredOpportunities;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // --- HEADER: SliverAppBar with title ---
            SliverAppBar(
              expandedHeight: 110.0,
              floating: false,
              pinned: true,
              elevation: 0,
              backgroundColor: AppColors.surface,
              surfaceTintColor: AppColors.surface,
              leading: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppColors.primary, size: 20),
                    onPressed: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                    },
                  ),
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 64.0, bottom: 14.0),
                centerTitle: false,
                background: Stack(
                  children: [
                    ClipPath(
                      clipper: _SigmoidClipper(offsetY: 30),
                      child: Container(
                        color: AppColors.primary.withValues(alpha: 0.04),
                      ),
                    ),
                    ClipPath(
                      clipper: _SigmoidClipper(offsetY: 15),
                      child: Container(
                        color: AppColors.primary.withValues(alpha: 0.08),
                      ),
                    ),
                    ClipPath(
                      clipper: _SigmoidClipper(offsetY: 0),
                      child: Container(
                        color: AppColors.primary.withValues(alpha: 0.15),
                      ),
                    ),
                  ],
                ),
                title: Text(
                  'Explore Programs',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),

            // --- SEARCH & FILTER SECTION ---
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.sm),
                  
                  // Search Bar Pill
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: AppColors.divider.withValues(alpha: 0.3)),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 2),
                      child: Row(
                        children: [
                          const Icon(Icons.search, color: AppColors.textSecondary, size: 20),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: TextField(
                              onChanged: (value) {
                                setState(() {
                                  _searchQuery = value;
                                });
                              },
                              decoration: InputDecoration(
                                hintText: 'Search programs, skills, or topics...',
                                hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textSecondary,
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
                            color: AppColors.divider.withValues(alpha: 0.3),
                            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                          ),
                          GestureDetector(
                            onTap: _showFilterBottomSheet,
                            child: Icon(Icons.tune, color: AppColors.textPrimary.withValues(alpha: 0.7), size: 20),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  
                  // Filter Chips — Category Selection
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    child: Row(
                      children: [
                        _buildFilterChip(context, 'All', null),
                        ...OpportunityType.values.map((type) {
                          return _buildFilterChip(context, _getCategoryLabel(type), type);
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
              ),
            ),
            
            // --- PROGRAM LIST or EMPTY STATE ---
            if (filteredList.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _buildEmptyState(context),
              )
            else
              SliverPadding(
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
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                AppRouter.programDetails,
                                arguments: program,
                              );
                            },
                          ),
                        ),
                      );
                    },
                    childCount: filteredList.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Builds a category filter chip
  Widget _buildFilterChip(BuildContext context, String label, OpportunityType? type) {
    final isSelected = _selectedCategory == type;
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        showCheckmark: false,
        backgroundColor: AppColors.background,
        selectedColor: AppColors.primary,
        side: isSelected ? BorderSide.none : BorderSide(color: AppColors.divider.withValues(alpha: 0.5)),
        labelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: isSelected ? AppColors.onPrimary : AppColors.textPrimary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        onSelected: (selected) {
          setState(() {
            _selectedCategory = selected ? type : null;
          });
        },
      ),
    );
  }

  /// Empty state shown when no programs match filters
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.60),
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
                left: AppSpacing.lg,
                right: AppSpacing.lg,
                bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
                top: AppSpacing.md,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.divider,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text('Advanced Filters', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: AppSpacing.lg),
                  Text('Location', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: 8,
                    children: LocationType.values.map((loc) {
                      final isSelected = _selectedLocation == loc;
                      return ChoiceChip(
                        label: Text(loc.name.toUpperCase()),
                        selected: isSelected,
                        onSelected: (selected) {
                          setModalState(() => _selectedLocation = selected ? loc : null);
                          setState(() {});
                        },
                        selectedColor: AppColors.primary,
                        showCheckmark: false,
                        labelStyle: TextStyle(
                          color: isSelected ? AppColors.onPrimary : AppColors.textPrimary,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Free Programs Only', style: Theme.of(context).textTheme.titleMedium),
                      Switch(
                        value: _isFreeOnly,
                        activeThumbColor: AppColors.primary,
                        onChanged: (val) {
                          setModalState(() => _isFreeOnly = val);
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Apply Filters', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  )
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
  final double offsetY;
  
  _SigmoidClipper({this.offsetY = 0.0});

  @override
  Path getClip(Size size) {
    final path = Path();
    
    // Diagonal slant: Starts at the bottom left, ends higher on the right
    final leftY = size.height - offsetY;
    final rightY = size.height - 60.0 - offsetY;
    
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
  bool shouldReclip(covariant _SigmoidClipper oldClipper) => oldClipper.offsetY != offsetY;
}
