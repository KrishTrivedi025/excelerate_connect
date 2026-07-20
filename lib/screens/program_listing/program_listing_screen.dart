import 'package:flutter/material.dart';
import '../../core/routes/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../data/mock_data.dart';
import '../../widgets/program_card.dart';

class ProgramListingScreen extends StatefulWidget {
  const ProgramListingScreen({super.key});

  @override
  State<ProgramListingScreen> createState() => _ProgramListingScreenState();
}

class _ProgramListingScreenState extends State<ProgramListingScreen> {
  String _searchQuery = '';
  OpportunityType? _selectedCategory;

  List<Opportunity> get _filteredOpportunities {
    return mockOpportunities.where((opp) {
      final matchesSearch = opp.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == null || opp.type == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  Future<void> _handleRefresh() async {
    // Since we are using mock data, just delay a bit to simulate network
    await Future.delayed(const Duration(seconds: 1));
    setState(() {});
  }

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
            SliverAppBar(
              expandedHeight: 140.0,
              floating: false,
              pinned: true,
              elevation: 0,
              backgroundColor: AppColors.surface,
              surfaceTintColor: AppColors.surface,
              leading: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppColors.accent, size: 20),
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
                background: Container(
                  color: AppColors.accent.withValues(alpha: 0.10),
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
                          Icon(Icons.tune, color: AppColors.textPrimary.withValues(alpha: 0.7), size: 20),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  
                  // Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    child: Row(
                      children: [
                        _buildFilterChip('All', null),
                        ...OpportunityType.values.map((type) {
                          return _buildFilterChip(_getCategoryLabel(type), type);
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
              ),
            ),
            
            // Program List
            filteredList.isEmpty
                ? SliverFillRemaining(
                    hasScrollBody: false,
                    child: _buildEmptyState(),
                  )
                : SliverPadding(
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

  Widget _buildFilterChip(String label, OpportunityType? type) {
    final isSelected = _selectedCategory == type;
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        showCheckmark: false,
        backgroundColor: AppColors.background,
        selectedColor: AppColors.accent,
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.2),
                  blurRadius: 32,
                  spreadRadius: 8,
                ),
              ],
            ),
            child: const Icon(
              Icons.travel_explore_rounded,
              size: 72,
              color: AppColors.accent,
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
                backgroundColor: AppColors.accent,
                minimumSize: const Size(200, 48), // Explicitly overrides the double.infinity theme default
              ),
              onPressed: () {
                setState(() {
                  _searchQuery = '';
                  _selectedCategory = null;
                });
              },
              child: const Text('Clear Filters'),
            ),
          ),
        ],
      ),
    );
  }
}
