import 'package:flutter/material.dart';
import '../../core/routes/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../data/mock_data.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/flexible_asset_image.dart';
import '../../widgets/hero_banner.dart';
import '../../widgets/program_card.dart';
import '../../widgets/top_header_bar.dart';

/// Program Listing Screen ("Explore" tab) — Week 3 redesign
///
/// Features:
/// - Shared TopHeaderBar + BottomNavBar (consistent with Home, no more
///   disappearing nav bar and no back arrow — this is a tab, not a push)
/// - Hero section with a personalized greeting
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

  /// Computed getter: filters mockOpportunities by search + category
  List<Opportunity> get _filteredOpportunities {
    return mockOpportunities.where((opp) {
      final matchesSearch = opp.name.toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
      final matchesCategory =
          _selectedCategory == null || opp.type == _selectedCategory;
      return matchesSearch && matchesCategory;
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

    return PopScope(
      // This tab was reached via goToTab's pushReplacement, so it is the
      // only entry on the Navigator stack — there is nothing beneath it for
      // system back to reveal. Route it back to the Home tab explicitly
      // instead of falling through to Flutter's "nothing left to pop"
      // handling.
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) AppRouter.goToTab(context, AppRouter.home);
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        // Without this, the Scaffold shrinks its body when the keyboard opens,
        // which drags the Positioned(bottom:0) nav bar up to float above the
        // keyboard instead of staying pinned to the physical screen bottom.
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              RefreshIndicator(
                onRefresh: _handleRefresh,
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.sm,
                        ),
                        child: TopHeaderBar(
                          onNotificationTap: () {},
                          onProfileTap: () {},
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      // Full width, edge-to-edge — no side padding, no
                      // overlaid text, just the hero image as a plain
                      // rectangle.
                      child: HeroBanner(
                        image: FlexibleAssetImage(
                          baseName: 'assets/images/explore_hero',
                          fit: BoxFit.cover,
                          alignment: Alignment.topCenter,
                          fallback: (context) =>
                              const ColoredBox(color: AppColors.primary),
                        ),
                      ),
                    ),

                    // --- SEARCH & FILTER SECTION ---
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          const SizedBox(height: AppSpacing.lg),

                          // Personalized greeting — plain page content, not
                          // overlaid on the hero image. Wrapped in a
                          // full-width SizedBox so it's genuinely flush
                          // left; the outer Column here defaults to
                          // centered cross-axis alignment, and without an
                          // explicit width this block would just shrink-wrap
                          // to its own text width and end up centered on
                          // the page instead of aligned with everything
                          // else below it.
                          SizedBox(
                            width: double.infinity,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RichText(
                                    text: TextSpan(
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textPrimary,
                                          ),
                                      children: const [
                                        TextSpan(text: 'Hi, '),
                                        TextSpan(
                                          text: 'Team 7!',
                                          style: TextStyle(
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Here's what you can explore today.",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),

                          // Search Bar Pill
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: AppColors.divider.withValues(
                                    alpha: 0.3,
                                  ),
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: 2,
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.search,
                                    color: AppColors.textSecondary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Expanded(
                                    child: TextField(
                                      onChanged: (value) {
                                        setState(() {
                                          _searchQuery = value;
                                        });
                                      },
                                      decoration: InputDecoration(
                                        hintText:
                                            'Search programs, skills, or topics...',
                                        hintStyle: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
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
                                    color: AppColors.divider.withValues(
                                      alpha: 0.3,
                                    ),
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.sm,
                                    ),
                                  ),
                                  Icon(
                                    Icons.tune,
                                    color: AppColors.textPrimary.withValues(
                                      alpha: 0.7,
                                    ),
                                    size: 20,
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                            ),
                            child: Row(
                              children: [
                                _buildFilterChip(context, 'All', null),
                                ...OpportunityType.values.map((type) {
                                  return _buildFilterChip(
                                    context,
                                    _getCategoryLabel(type),
                                    type,
                                  );
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.xs,
                        ),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final program = filteredList[index];
                            return TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.0, end: 1.0),
                              duration: Duration(
                                milliseconds: 380 + (index * 90).clamp(0, 450),
                              ),
                              curve: Curves.easeOutCubic,
                              builder: (context, value, child) {
                                return Transform.translate(
                                  offset: Offset(0, 24 * (1 - value)),
                                  child: Opacity(opacity: value, child: child),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  bottom: AppSpacing.md,
                                ),
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
                          }, childCount: filteredList.length),
                        ),
                      ),
                    const SliverToBoxAdapter(child: SizedBox(height: 120)),
                  ],
                ),
              ),
              const BottomNavBar(activeTab: AppTab.explore),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a category filter chip
  Widget _buildFilterChip(
    BuildContext context,
    String label,
    OpportunityType? type,
  ) {
    final isSelected = _selectedCategory == type;
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        showCheckmark: false,
        backgroundColor: AppColors.background,
        selectedColor: AppColors.accent,
        side: isSelected
            ? BorderSide.none
            : BorderSide(color: AppColors.divider.withValues(alpha: 0.5)),
        labelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: isSelected ? AppColors.onPrimary : AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            width: 200,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                minimumSize: const Size(200, 48),
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
