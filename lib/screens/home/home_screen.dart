import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/routes/app_router.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/app_theme.dart';
import '../../data/mock_data.dart';
import '../../services/opportunity_service.dart';
import '../../widgets/ai_chat_button.dart';
import '../../widgets/animated_entrance.dart';
import '../../widgets/announcement_card.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/branded_loader.dart';
import '../../widgets/error_retry_card.dart';
import '../../widgets/flexible_asset_image.dart';
import '../../widgets/hero_banner.dart';
import '../../widgets/program_card.dart';
import '../../widgets/top_header_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  OpportunityType? selectedCategory;
  String searchQuery = '';
  int notificationCount = 3;

  final PageController _announcementController = PageController();
  int _announcementPage = 0;

  bool _showChatHint = false;
  Timer? _chatHintShowTimer;
  Timer? _chatHintHideTimer;

  /// Programs shown in the swipeable Continue Learning section — the
  /// in-progress Flutter internship plus the Data Science course, so a
  /// user can swipe between more than one thing they're learning.
  late final List<Opportunity> continueLearningPrograms = [
    mockOpportunities.firstWhere(
      (o) => o.isInProgress,
      orElse: () => mockOpportunities.first,
    ),
    mockOpportunities.firstWhere(
      (o) => o.name.contains('Data Science'),
      orElse: () => mockOpportunities.first,
    ),
  ];

  final PageController _continueLearningController = PageController();
  int _continueLearningPage = 0;

  // Bookmarked program IDs — shared between the Continue Learning card and
  // the Featured Programs list below, since both reference real
  // mockOpportunities entries now.
  final Set<String> bookmarkedProgramIds = {};

  // Indices into _lessonTitles/_lessonDurations that are marked complete in
  // the syllabus sheet. Tracked per-lesson so tapping one row only ever
  // toggles that row.
  final Set<int> completedLessonIndices = {0, 1, 2, 3, 4, 5};

  static const List<String> _lessonTitles = [
    'Introduction to Flutter & Widgets',
    'Building Beautiful Interfaces with Row & Column',
    'Understanding Stateless vs Stateful Widgets',
    'Mastering Theme and Global Colors',
    'Custom Paints & Particle Effects',
    'Local Storage and App State Lifecycle',
    'Async Network Calls & API Integration',
    'Deploying to App Store and Google Play',
  ];

  static const List<String> _lessonDurations = [
    '15 mins',
    '22 mins',
    '18 mins',
    '25 mins',
    '30 mins',
    '20 mins',
    '28 mins',
    '35 mins',
  ];

  // Continue Learning, Announcements, and Featured Programs all key off
  // this one future — pull-to-refresh re-fetches it, and each section shows
  // the branded loader while it's in flight, exactly like Program Listing.
  late Future<List<Opportunity>> _homeDataFuture;

  void _fetchHomeData() {
    _homeDataFuture = OpportunityService.fetchOpportunities();
  }

  Future<void> _handleRefresh() async {
    setState(_fetchHomeData);
    await _homeDataFuture.catchError((_) => <Opportunity>[]);
  }

  @override
  void initState() {
    super.initState();
    _fetchHomeData();
    // Attention bubble appears a beat after landing on the screen, and
    // dismisses itself after a while if the user hasn't tapped it.
    _chatHintShowTimer = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => _showChatHint = true);
      _chatHintHideTimer = Timer(const Duration(seconds: 5), () {
        if (mounted) setState(() => _showChatHint = false);
      });
    });
  }

  @override
  void dispose() {
    _chatHintShowTimer?.cancel();
    _chatHintHideTimer?.cancel();
    _announcementController.dispose();
    _continueLearningController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Home is the app's root tab (Login/Sign-Up were replaced, not pushed,
      // on the way here) — there is nothing beneath it to pop back to, so
      // system back must stay on Home instead of falling through to
      // Flutter's "nothing left to pop" handling.
      canPop: false,
      child: Scaffold(
        backgroundColor: context.palette.background,
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
                          notificationCount: notificationCount,
                          onNotificationTap: () {
                            setState(() => notificationCount = 0);
                            _showSnackBar('Notifications marked as read!');
                          },
                          onProfileTap: () =>
                              _showSnackBar('Account profile menu! 👤'),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      // Full width, edge-to-edge — no side padding, no
                      // overlaid text, just the hero image as a plain
                      // rectangle (the image already carries its own copy).
                      child: HeroBanner(
                        image: FlexibleAssetImage(
                          baseName: 'assets/images/home_hero',
                          fit: BoxFit.cover,
                          // Anchors the crop to the top of the image instead of
                          // centering it, so any necessary cropping trims the
                          // bottom rather than cutting into the top content.
                          alignment: Alignment.topCenter,
                          fallback: (context) =>
                              const ColoredBox(color: AppColors.primary),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: AppSpacing.lg),
                            _buildGreeting(),
                            const SizedBox(height: AppSpacing.base),
                          ],
                        ),
                      ),
                    ),
                    // Everything below the greeting — Continue Learning,
                    // Announcements, and Featured Programs — refreshes as
                    // one unit behind one big loader, not three separate
                    // small ones.
                    FutureBuilder<List<Opportunity>>(
                      future: _homeDataFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 100),
                              child: Center(child: BrandedLoader()),
                            ),
                          );
                        }

                        if (snapshot.hasError) {
                          return SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.all(AppSpacing.lg),
                              child: ErrorRetryCard(
                                message: snapshot.error.toString(),
                                onRetry: () => setState(_fetchHomeData),
                              ),
                            ),
                          );
                        }

                        final rawPrograms = snapshot.data ?? const [];
                        final filteredPrograms = rawPrograms.where((program) {
                          final matchesCategory =
                              selectedCategory == null ||
                              program.type == selectedCategory;
                          final matchesSearch = program.name
                              .toLowerCase()
                              .contains(searchQuery.toLowerCase());
                          return matchesCategory && matchesSearch;
                        }).toList();

                        return SliverMainAxisGroup(
                          slivers: [
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.lg,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: AppSpacing.lg),
                                    _buildContinueLearningHeader(),
                                    const SizedBox(height: AppSpacing.sm),
                                    _buildContinueLearningSection(),
                                    const SizedBox(height: AppSpacing.xl),
                                    _buildAnnouncementsSection(),
                                    const SizedBox(height: AppSpacing.xl),
                                    _buildExploreProgramsHeader(),
                                    const SizedBox(height: AppSpacing.sm),
                                    _buildCategoryFilterPills(),
                                    const SizedBox(height: AppSpacing.lg),
                                    _buildFeaturedProgramsHeader(),
                                    const SizedBox(height: AppSpacing.sm),
                                  ],
                                ),
                              ),
                            ),
                            if (filteredPrograms.isEmpty)
                              SliverToBoxAdapter(child: _buildEmptyState())
                            else
                              SliverPadding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.lg,
                                ),
                                sliver: SliverList(
                                  delegate: SliverChildBuilderDelegate((
                                    context,
                                    index,
                                  ) {
                                    final program = filteredPrograms[index];
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: AppSpacing.md,
                                      ),
                                      child: AnimatedEntrance(
                                        index: index,
                                        child: _buildFeaturedProgramCard(
                                          program,
                                        ),
                                      ),
                                    );
                                  }, childCount: filteredPrograms.length),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 120)),
                  ],
                ),
              ),
              AiChatButton(
                showHint: _showChatHint,
                onDismissHint: () => setState(() => _showChatHint = false),
                onTap: () => Navigator.pushNamed(context, AppRouter.aiChat),
              ),
              const BottomNavBar(activeTab: AppTab.home),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGreeting() {
    final textTheme = Theme.of(context).textTheme;
    final palette = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: palette.textPrimary,
              letterSpacing: -0.5,
            ),
            children: const [
              TextSpan(text: 'Hello, '),
              TextSpan(
                text: 'Team 7!',
                style: TextStyle(color: AppColors.primary),
              ),
              TextSpan(text: ' 👋'),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Keep learning, keep growing.',
          style: textTheme.bodyMedium?.copyWith(
            color: palette.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildContinueLearningHeader() {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Continue Learning',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: -0.3,
          ),
        ),
        GestureDetector(
          onTap: () => _showSnackBar('Opening overall ongoing dashboard'),
          child: Row(
            children: [
              Text(
                'View all',
                style: textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const Icon(
                Icons.chevron_right,
                size: 16,
                color: AppColors.primary,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Swipeable Continue Learning cards — one per program in
  /// continueLearningPrograms, same visual design as before (just
  /// parameterized), reduced scale, with page-indicator dots like
  /// Announcements.
  Widget _buildContinueLearningSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 148,
          child: PageView.builder(
            controller: _continueLearningController,
            itemCount: continueLearningPrograms.length,
            onPageChanged: (i) => setState(() => _continueLearningPage = i),
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: _buildContinueLearningCard(
                continueLearningPrograms[index],
              ),
            ),
          ),
        ),
        if (continueLearningPrograms.length > 1) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(continueLearningPrograms.length, (i) {
              final isActive = i == _continueLearningPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: isActive ? 18 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary : context.palette.divider,
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }

  Widget _buildContinueLearningCard(Opportunity program) {
    final textTheme = Theme.of(context).textTheme;
    final palette = context.palette;
    final progressRatio = program.progressPercentage;
    // No per-program lesson-count field exists in the data model — derived
    // from a shared assumed total, consistent with the 12/20 already shown
    // for the in-progress Flutter program (0.60 * 20 = 12).
    const totalLessonsAssumed = 20;
    final completedLessonsForProgram = (progressRatio * totalLessonsAssumed)
        .round();
    final isBookmarked = bookmarkedProgramIds.contains(program.id);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: palette.warmSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: palette.warmSurfaceBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  width: 88,
                  height: 108,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      ProgramThumbnail(
                        program: program,
                        width: 88,
                        height: 108,
                      ),
                      Positioned(
                        bottom: 10,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text(
                            '${(progressRatio * 100).toInt()}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CONTINUE LEARNING',
                      style: textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Padding(
                      // Reserves clearance for the bookmark icon overlaid in
                      // the top-right corner (Positioned, not part of this
                      // Row's own width calculation) so a long program name
                      // never truncates right underneath it.
                      padding: const EdgeInsets.only(right: 32),
                      child: Text(
                        program.name,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      program.shortDescription,
                      style: textTheme.bodySmall?.copyWith(
                        color: palette.textSecondary,
                        height: 1.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: SizedBox(
                        height: 5,
                        child: LinearProgressIndicator(
                          value: progressRatio,
                          backgroundColor: palette.progressTrack,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$completedLessonsForProgram / $totalLessonsAssumed Lessons',
                          style: textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: palette.textSecondary,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _showLessonsSheet(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  progressRatio > 0 ? 'Resume' : 'Start',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 2),
                                const Icon(
                                  Icons.chevron_right,
                                  color: Colors.white,
                                  size: 13,
                                ),
                              ],
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
          Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  if (isBookmarked) {
                    bookmarkedProgramIds.remove(program.id);
                  } else {
                    bookmarkedProgramIds.add(program.id);
                  }
                });
                _showSnackBar(
                  !isBookmarked ? 'Bookmarked! 🌟' : 'Removed bookmark',
                );
              },
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Icon(
                  isBookmarked
                      ? Icons.bookmark
                      : Icons.bookmark_border_outlined,
                  size: 14,
                  color: isBookmarked ? AppColors.primary : palette.textPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnnouncementsSection() {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Announcements',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          // Tall enough for the card's content (icon/title/body row + the
          // Apply Now/Know More button row) plus the vertical padding
          // below, which exists so the card's shadow has room to render
          // instead of being clipped by the PageView's viewport edge.
          height: 196,
          child: PageView.builder(
            controller: _announcementController,
            itemCount: mockAnnouncements.length,
            onPageChanged: (i) => setState(() => _announcementPage = i),
            itemBuilder: (context, index) {
              final announcement = mockAnnouncements[index];
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 2,
                  vertical: 10,
                ),
                child: AnnouncementCard(
                  item: announcement,
                  onTap: () => _showSnackBar(announcement.title),
                ),
              );
            },
          ),
        ),
        if (mockAnnouncements.length > 1) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(mockAnnouncements.length, (i) {
              final isActive = i == _announcementPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: isActive ? 18 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary : context.palette.divider,
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }

  Widget _buildExploreProgramsHeader() {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Explore Programs',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: -0.3,
          ),
        ),
        GestureDetector(
          onTap: () {
            setState(() => selectedCategory = null);
            _showSnackBar('Filter reset: Showing all programs');
          },
          child: Row(
            children: [
              Text(
                'View all',
                style: textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const Icon(
                Icons.chevron_right,
                size: 16,
                color: AppColors.primary,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryFilterPills() {
    final textTheme = Theme.of(context).textTheme;
    final palette = context.palette;
    return SizedBox(
      height: 42,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: OpportunityType.values.length + 1,
        itemBuilder: (context, index) {
          final type = index == 0 ? null : OpportunityType.values[index - 1];
          final label = type == null ? 'All' : _categoryPillLabel(type);
          final isActive = selectedCategory == type;

          return Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: GestureDetector(
              onTap: () {
                setState(() => selectedCategory = type);
                _showSnackBar('Showing $label programs');
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: palette.surfaceAlt,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: isActive ? AppColors.primary : palette.divider,
                    width: isActive ? 1.5 : 1,
                  ),
                  boxShadow: [
                    if (isActive)
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      _categoryPillIcon(type),
                      size: 14,
                      color: isActive ? AppColors.primary : palette.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      label,
                      style: textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isActive ? AppColors.primary : palette.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _categoryPillLabel(OpportunityType type) {
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

  IconData _categoryPillIcon(OpportunityType? type) {
    switch (type) {
      case null:
        return Icons.apps_rounded;
      case OpportunityType.internship:
        return Icons.work_outline;
      case OpportunityType.jobSimulation:
        return Icons.psychology;
      case OpportunityType.course:
        return Icons.lightbulb_outline;
      case OpportunityType.competition:
        return Icons.emoji_events;
      case OpportunityType.event:
        return Icons.event;
      case OpportunityType.masterclass:
        return Icons.school;
      case OpportunityType.career:
        return Icons.badge_outlined;
      case OpportunityType.engagement:
        return Icons.groups;
    }
  }

  Widget _buildFeaturedProgramsHeader() {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Featured Programs',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: -0.3,
          ),
        ),
        GestureDetector(
          onTap: () => AppRouter.goToTab(context, AppRouter.programListing),
          child: Row(
            children: [
              Text(
                'View all',
                style: textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const Icon(
                Icons.chevron_right,
                size: 16,
                color: AppColors.primary,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedProgramCard(Opportunity program) {
    return ProgramCard(
      program: program,
      horizontal: true,
      onTap: () => Navigator.pushNamed(
        context,
        AppRouter.programDetails,
        arguments: program,
      ),
    );
  }

  Widget _buildEmptyState() {
    final textTheme = Theme.of(context).textTheme;
    final palette = context.palette;
    return Container(
      margin: const EdgeInsets.symmetric(
        vertical: 24,
        horizontal: AppSpacing.lg,
      ),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: palette.divider),
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: palette.emptyIconBg,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.search_off, color: AppColors.primary),
          ),
          const SizedBox(height: 12),
          Text(
            'No programs found',
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            searchQuery.isEmpty
                ? 'No programs found in this category.'
                : 'We couldn\'t find matches for "$searchQuery" in this category.',
            style: textTheme.bodySmall?.copyWith(
              color: palette.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          TextButton(
            onPressed: () => setState(() {
              searchQuery = '';
              selectedCategory = null;
            }),
            child: const Text('Clear search & filter'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String text) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            // AppColors.primary, not Colors.amber — amber reads fine on
            // light but is unreadable against the dark-mode inverse
            // surface this snackbar now resolves to via snackBarTheme.
            const Icon(Icons.stars, color: AppColors.primary, size: 16),
            const SizedBox(width: 8),
            Text(text),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1800),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        margin: const EdgeInsets.only(bottom: 110, left: 24, right: 24),
        // No backgroundColor override — snackBarTheme now supplies
        // inverseSurface/onInverseSurface, correct in both themes. The old
        // hardcoded AppColors.textPrimary fill would've become near-white
        // in dark mode with unreadable near-white text on it.
      ),
    );
  }

  void _showLessonsSheet(BuildContext context) {
    final palette = context.palette;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final int doneCount = completedLessonIndices.length;
            final int lessonCount = _lessonTitles.length;
            final double progressRatio = doneCount / lessonCount;
            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: BoxDecoration(
                color: palette.surfaceAlt,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 48,
                    height: 4,
                    decoration: BoxDecoration(
                      color: palette.sheetHandle,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Syllabus Progress',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: palette.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Flutter Mobile Development',
                              style: TextStyle(
                                fontSize: 12,
                                color: palette.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
                  Divider(color: palette.divider),
                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: palette.warmSurface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Overall Completion',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            Text(
                              '${(progressRatio * 100).toInt()}% ($doneCount/$lessonCount)',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: palette.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: SizedBox(
                            height: 6,
                            child: LinearProgressIndicator(
                              value: progressRatio,
                              backgroundColor: palette.progressTrack,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 8,
                      ),
                      itemCount: lessonCount,
                      itemBuilder: (context, idx) {
                        final isDone = completedLessonIndices.contains(idx);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                if (isDone) {
                                  completedLessonIndices.remove(idx);
                                } else {
                                  completedLessonIndices.add(idx);
                                }
                              });
                              setSheetState(() {});
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isDone
                                    ? palette.warmRowFill
                                    : palette.surfaceAlt,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isDone
                                      ? palette.warmRowBorder
                                      : palette.divider,
                                ),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 12,
                                    backgroundColor: isDone
                                        ? AppColors.primary
                                        : palette.divider,
                                    child: Text(
                                      '${idx + 1}',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: isDone
                                            ? AppColors.onPrimary
                                            : palette.textSecondary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _lessonTitles[idx],
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: palette.textPrimary,
                                            decoration: isDone
                                                ? TextDecoration.lineThrough
                                                : null,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          _lessonDurations[idx],
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: palette.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    isDone
                                        ? Icons.check_circle
                                        : Icons.radio_button_unchecked,
                                    color: isDone
                                        ? AppColors.primary
                                        : palette.divider,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
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
