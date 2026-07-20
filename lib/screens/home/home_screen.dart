// import 'package:flutter/material.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return const Scaffold(
//       body: Center(child: Text('Home Screen')),
//     );
//   }
// }
import 'package:flutter/material.dart';

void main() {
  runApp(const HomeScreen());
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Excelerate',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Inter',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFF97316),
          primary: const Color(0xFFF97316),
          background: const Color(0xFFFAFAFA),
        ),
        useMaterial3: true,
      ),
      home: const HomeScreenA(),
    );
  }
}

// Data Model for Course Cards
class Course {
  final int id;
  final String title;
  final String subtitle;
  final String level;
  final double rating;
  final int reviewsCount;
  final String category;
  final String imageType;

  const Course({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.level,
    required this.rating,
    required this.reviewsCount,
    required this.category,
    required this.imageType,
  });
}

class HomeScreenA extends StatefulWidget {
  const HomeScreenA({super.key});

  @override
  State<HomeScreenA> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreenA> {
  String selectedCategory = 'All';
  String searchQuery = '';
  int notificationCount = 3;
  int completedLessons = 12;
  final int totalLessons = 20;

  // Bookmarked course IDs
  final Set<int> bookmarkedCourseIds = {2};
  bool isFlutterBookmarked = false;

  final List<String> categories = [
    'All',
    'Development',
    'Design',
    'Data Science',
    'Business',
  ];

  final List<Course> courses = const [
    Course(
      id: 1,
      title: "Flutter Development",
      subtitle: "Build cross-platform apps with Flutter",
      level: "Beginner",
      rating: 4.5,
      reviewsCount: 120,
      category: "Development",
      imageType: "flutter",
    ),
    Course(
      id: 2,
      title: "UI/UX Design Basics",
      subtitle: "Learn the basics of UI/UX design",
      level: "Intermediate",
      rating: 4.7,
      reviewsCount: 85,
      category: "Design",
      imageType: "design",
    ),
    Course(
      id: 3,
      title: "Data Science Fundamentals",
      subtitle: "Master Python, SQL, and predictive analytics",
      level: "Beginner",
      rating: 4.9,
      reviewsCount: 240,
      category: "Data Science",
      imageType: "datascience",
    ),
    Course(
      id: 4,
      title: "Product Management 101",
      subtitle: "Learn strategic roadmapping and agile metrics",
      level: "Intermediate",
      rating: 4.6,
      reviewsCount: 95,
      category: "Business",
      imageType: "business",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // Filter courses dynamically based on selection and query
    final filteredCourses = courses.where((course) {
      final matchesCategory = selectedCategory == 'All' || course.category == selectedCategory;
      final matchesSearch = course.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          course.subtitle.toLowerCase().contains(searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Stack(
          children: [
            // Scrollable main screen body
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // === HEADER & GREETING ===
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 24),
                        _buildGreeting(),
                        const SizedBox(height: 20),
                        _buildSearchBar(),
                        const SizedBox(height: 24),
                        _buildContinueLearningHeader(),
                        const SizedBox(height: 12),
                        _buildContinueLearningCard(),
                        const SizedBox(height: 28),
                        _buildExploreProgramsHeader(),
                        const SizedBox(height: 12),
                        _buildCategoryFilterPills(),
                        const SizedBox(height: 28),
                        _buildFeaturedProgramsHeader(),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),

                // === FEATURED PROGRAMS LIST ===
                filteredCourses.isNotEmpty
                    ? SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final course = filteredCourses[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 14.0),
                                child: _buildFeaturedCourseCard(course),
                              );
                            },
                            childCount: filteredCourses.length,
                          ),
                        ),
                      )
                    : SliverToBoxAdapter(
                        child: _buildEmptyState(),
                      ),

                // Generous bottom spacer so content isn't covered by bottom bar
                const SliverToBoxAdapter(
                  child: SizedBox(height: 120),
                ),
              ],
            ),

            // === FLOATING ACTION BUTTON ===
            _buildFloatingChatbotButton(),

            // === BOTTOM NAVIGATION BAR (Anchored permanently above the scroll view) ===
            _buildBottomFloatingNavBar(),
          ],
        ),
      ),
    );
  }

  // Header element (Logo + Bell Notification + Avatar)
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // App brand Logo and name
        Row(
          children: [
            _buildLogoMark(),
            const SizedBox(width: 10),
            const Text(
              'Excelerate',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1A1A1A),
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        // Action buttons
        Row(
          children: [
            // Bell Notification Icon button with Red circle counter
            GestureDetector(
              onTap: () {
                setState(() {
                  notificationCount = 0;
                });
                _showSnackBar('Notifications marked as read!');
              },
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFF3F4F6)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    child: const Icon(
                      Icons.notifications_none_outlined,
                      color: Color(0xFF1A1A1A),
                      size: 22,
                    ),
                  ),
                  if (notificationCount > 0)
                    Positioned(
                      top: -2,
                      right: -2,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF97316),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Center(
                          child: Text(
                            '$notificationCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Circular profile Avatar photo
            GestureDetector(
              onTap: () => _showSnackBar('Account profile menu! 👤'),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
                  image: const DecorationImage(
                    image: NetworkImage(
                      'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&auto=format&fit=crop&q=80',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ],
        )
      ],
    );
  }

  // Bold branding Header Logo element
  Widget _buildLogoMark() {
    return SizedBox(
      width: 32,
      height: 32,
      child: Stack(
        children: [
          Transform.rotate(
            angle: -0.785, // -45 deg
            child: Container(
              width: 10,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFF97316),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          Positioned(
            left: 12,
            child: Transform.rotate(
              angle: 0.785, // 45 deg
              child: Container(
                width: 10,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFF97316),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Greeting Section containing name and waving hand emoji
  Widget _buildGreeting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: const TextSpan(
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
              letterSpacing: -0.5,
              fontFamily: 'Inter',
            ),
            children: [
              TextSpan(text: 'Hello, '),
              TextSpan(
                text: 'Learner!',
                style: TextStyle(color: Color(0xFFF97316)),
              ),
              TextSpan(text: ' 👋'),
            ],
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Keep learning, keep growing.',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF6B7280),
            fontWeight: FontWeight.w500,
          ),
        )
      ],
    );
  }

  // Pill-shaped search bar with grey placeholder
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: const Color(0xFFF3F4F6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.01),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: Row(
        children: [
          const Icon(
            Icons.search,
            color: Color(0xFF6B7280),
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              onChanged: (val) {
                setState(() {
                  searchQuery = val;
                });
              },
              decoration: const InputDecoration(
                hintText: 'Search programs, skills, or topics...',
                hintStyle: TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                border: InputBorder.none,
                isDense: true,
              ),
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF1A1A1A),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          IconButton(
            onPressed: () => _showSnackBar('Refine settings filter active'),
            icon: const Icon(
              Icons.tune,
              color: Color(0xFF1A1A1A),
              size: 20,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          )
        ],
      ),
    );
  }

  // Segment headers reusable
  Widget _buildContinueLearningHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Continue Learning',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
            letterSpacing: -0.3,
          ),
        ),
        GestureDetector(
          onTap: () => _showSnackBar('Opening overall ongoing dashboard'),
          child: Row(
            children: const [
              Text(
                'View all',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFF97316),
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 16,
                color: Color(0xFFF97316),
              )
            ],
          ),
        )
      ],
    );
  }

  // Peach Highlighted card detailing Flutter Course progress
  Widget _buildContinueLearningCard() {
    final double progressRatio = completedLessons / totalLessons;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFDEDE1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFBE3D1).withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF97316).withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Blue Flutter Thumbnail graphic
              Container(
                width: 115,
                height: 142,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F1B3D),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Flutter graphical logo icon representation
                    _buildFlutterLogo(size: 48),
                    // Percentage Badge
                    Positioned(
                      bottom: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          '${(progressRatio * 100).toInt()}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Description information
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 2),
                    const Text(
                      'CONTINUE LEARNING',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFF97316),
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Flutter Development',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Build beautiful cross-platform apps with Flutter',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 14),
                    // Progress Bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: SizedBox(
                        height: 6,
                        child: LinearProgressIndicator(
                          value: progressRatio,
                          backgroundColor: Colors.white,
                          color: const Color(0xFFF97316),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$completedLessons / $totalLessons Lessons',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        // Resume Pill Action Button
                        GestureDetector(
                          onTap: () => _showLessonsSheet(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF97316),
                              borderRadius: BorderRadius.circular(100),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFF97316).withValues(alpha: 0.25),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: Row(
                              children: const [
                                Text(
                                  'Resume',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 2),
                                Icon(
                                  Icons.chevron_right,
                                  color: Colors.white,
                                  size: 14,
                                )
                              ],
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
          // Bookmark trigger button (top right)
          Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  isFlutterBookmarked = !isFlutterBookmarked;
                });
                _showSnackBar(
                  isFlutterBookmarked ? 'Flutter course bookmarked! 🌟' : 'Removed bookmark',
                );
              },
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 4,
                    )
                  ],
                ),
                child: Icon(
                  isFlutterBookmarked ? Icons.bookmark : Icons.bookmark_border_outlined,
                  size: 16,
                  color: isFlutterBookmarked ? const Color(0xFFF97316) : const Color(0xFF1A1A1A),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  // Flutter Logo vector builder
  Widget _buildFlutterLogo({double size = 24}) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _FlutterLogoPainter(),
      ),
    );
  }

  Widget _buildExploreProgramsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Explore Programs',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
            letterSpacing: -0.3,
          ),
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              selectedCategory = 'All';
            });
            _showSnackBar('Filter reset: Showing all courses');
          },
          child: Row(
            children: const [
              Text(
                'View all',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFF97316),
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 16,
                color: Color(0xFFF97316),
              )
            ],
          ),
        )
      ],
    );
  }

  // Horizontal scrollable Categories Pill Chips row
  Widget _buildCategoryFilterPills() {
    return SizedBox(
      height: 42,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final bool isActive = selectedCategory == cat;

          IconData iconData = Icons.code_rounded;
          if (cat == 'Design') {
            iconData = Icons.palette_outlined;
          } else if (cat == 'Data Science') {
            iconData = Icons.bar_chart_outlined;
          } else if (cat == 'Business') {
            iconData = Icons.business_center_outlined;
          }

          return Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedCategory = cat;
                });
                _showSnackBar('Showing $cat courses');
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: isActive ? const Color(0xFFF97316) : const Color(0xFFE5E7EB),
                    width: isActive ? 1.5 : 1,
                  ),
                  boxShadow: [
                    if (isActive)
                      BoxShadow(
                        color: const Color(0xFFF97316).withValues(alpha: 0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      )
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      iconData,
                      size: 14,
                      color: isActive ? const Color(0xFFF97316) : const Color(0xFF6B7280),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      cat,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isActive ? const Color(0xFFF97316) : const Color(0xFF1A1A1A),
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

  Widget _buildFeaturedProgramsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Featured Programs',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
            letterSpacing: -0.3,
          ),
        ),
        GestureDetector(
          onTap: () => _showSnackBar('Opening Featured program list'),
          child: Row(
            children: const [
              Text(
                'View all',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFF97316),
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 16,
                color: Color(0xFFF97316),
              )
            ],
          ),
        )
      ],
    );
  }

  // White Card elements mimicking detailed designs
  Widget _buildFeaturedCourseCard(Course course) {
    final isBookmarked = bookmarkedCourseIds.contains(course.id);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF9FAFB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 16,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Stack(
        children: [
          Row(
            children: [
              // Thumbnail Container Graphic mockup
              _buildCourseThumbnail(course.imageType),
              const SizedBox(width: 14),
              // Text and rating description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      course.subtitle,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF6B7280),
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    // Rating + Level Tag
                    Row(
                      children: [
                        const Icon(
                          Icons.school_outlined,
                          size: 14,
                          color: Color(0xFF6B7280),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          course.level,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Icon(
                          Icons.star,
                          size: 14,
                          color: Color(0xFFFFB000),
                        ),
                        const SizedBox(width: 4),
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF1A1A1A),
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Inter',
                            ),
                            children: [
                              TextSpan(text: '${course.rating} '),
                              TextSpan(
                                text: '(${course.reviewsCount})',
                                style: const TextStyle(
                                  color: Color(0xFF6B7280),
                                  fontWeight: FontWeight.normal,
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
          // Bookmark icon
          Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  if (isBookmarked) {
                    bookmarkedCourseIds.remove(course.id);
                  } else {
                    bookmarkedCourseIds.add(course.id);
                  }
                });
                _showSnackBar(
                  !isBookmarked ? 'Added program to bookmarks! 🌟' : 'Removed from bookmarks',
                );
              },
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFF3F4F6)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.01),
                      blurRadius: 4,
                    )
                  ],
                ),
                child: Icon(
                  isBookmarked ? Icons.bookmark : Icons.bookmark_border_outlined,
                  size: 14,
                  color: isBookmarked ? const Color(0xFFF97316) : const Color(0xFF1A1A1A),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  // Adaptive mockup visual builders mimicking custom mobile UI layouts
  Widget _buildCourseThumbnail(String type) {
    if (type == 'flutter') {
      return Container(
        width: 84,
        height: 84,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFEEF2FF), Color(0xFFE0E7FF)],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.bottomCenter,
        child: Container(
          width: 36,
          height: 68,
          decoration: BoxDecoration(
            color: const Color(0xFF0F1B3D),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
            border: Border.all(color: const Color(0xFF312E81), width: 1.5),
          ),
          child: Center(
            child: _buildFlutterLogo(size: 16),
          ),
        ),
      );
    } else if (type == 'design') {
      return Container(
        width: 84,
        height: 84,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFAE8FF), Color(0xFFF3E8FF)],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.bottomCenter,
        child: Container(
          width: 36,
          height: 68,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF4C1D95), Color(0xFF6B21A8)],
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
            border: Border.all(color: const Color(0xFF2E1065), width: 1.5),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.palette_outlined,
                color: Colors.white,
                size: 14,
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 5,
                    height: 5,
                    decoration: const BoxDecoration(color: Colors.amber, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 2),
                  Container(
                    width: 5,
                    height: 5,
                    decoration: const BoxDecoration(color: Colors.pink, shape: BoxShape.circle),
                  ),
                ],
              )
            ],
          ),
        ),
      );
    } else if (type == 'datascience') {
      return Container(
        width: 84,
        height: 84,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFECFDF5), Color(0xFFD1FAE5)],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.bottomCenter,
        child: Container(
          width: 36,
          height: 68,
          decoration: BoxDecoration(
            color: const Color(0xFF064E3B),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
            border: Border.all(color: const Color(0xFF065F46), width: 1.5),
          ),
          child: const Center(
            child: Icon(
              Icons.bar_chart,
              color: Color(0xFF34D399),
              size: 18,
            ),
          ),
        ),
      );
    } else {
      return Container(
        width: 84,
        height: 84,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFF7ED), Color(0xFFFFEDD5)],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.bottomCenter,
        child: Container(
          width: 36,
          height: 68,
          decoration: BoxDecoration(
            color: const Color(0xFF78350F),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
            border: Border.all(color: const Color(0xFF92400E), width: 1.5),
          ),
          child: const Center(
            child: Icon(
              Icons.business_center_outlined,
              color: Color(0xFFFDBA74),
              size: 14,
            ),
          ),
        ),
      );
    }
  }

  // Floating Action bot button bottom-right
  Widget _buildFloatingChatbotButton() {
    return Positioned(
      bottom: 104,
      right: 20,
      child: GestureDetector(
        onTap: () => _showChatbotDialog(context),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFF97316), width: 2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFF97316).withValues(alpha: 0.25),
                blurRadius: 20,
                offset: const Offset(0, 6),
              )
            ],
          ),
          padding: const EdgeInsets.all(3),
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFFF97316),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.smart_toy_outlined,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
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
            _buildNavItem(Icons.home, 'Home', true),
            // Explore Tab
            _buildNavItem(Icons.grid_view, 'Explore', false),
            
            // Syllabus index open-book button (Horizontally aligned inline for pixel-perfect neatness)
            GestureDetector(
              onTap: () => _showSnackBar('Opening Course Syllabus index! 📖'),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFF97316),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF97316).withValues(alpha: 0.22),
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
    final activeColor = const Color(0xFFF97316);
    final inactiveColor = const Color(0xFF6B7280);

    return GestureDetector(
      onTap: () => _showSnackBar('$label feed loaded successfully'),
      child: SizedBox(
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
            )
          ],
        ),
      ),
    );
  }

  // Empty Search results placeholder state
  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Color(0xFFFFF7ED),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_off,
              color: Color(0xFFF97316),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'No courses found',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'We couldn\'t find matches for "$searchQuery" in this category.',
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7280),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          TextButton(
            onPressed: () {
              setState(() {
                searchQuery = '';
                selectedCategory = 'All';
              });
            },
            child: const Text(
              'Clear searches & filter',
              style: TextStyle(
                color: Color(0xFFF97316),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          )
        ],
      ),
    );
  }

  // Floating SnackBar/Toast helper
  void _showSnackBar(String text) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.stars, color: Colors.amber, size: 16),
            const SizedBox(width: 8),
            Text(text),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1800),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        margin: const EdgeInsets.only(bottom: 110, left: 24, right: 24),
        backgroundColor: const Color(0xFF1F2937),
      ),
    );
  }

  // Interactive lessons bottom drawer sheet
  void _showLessonsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final double progressRatio = completedLessons / totalLessons;
            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  // Drag handle
                  Container(
                    width: 48,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Syllabus Progress',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Flutter Mobile Development',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF6B7280),
                              ),
                            )
                          ],
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        )
                      ],
                    ),
                  ),
                  const Divider(color: Color(0xFFF3F4F6)),
                  // Progress card
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDEDE1),
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
                                color: Color(0xFFF97316),
                              ),
                            ),
                            Text(
                              '${(progressRatio * 100).toInt()}% ($completedLessons/$totalLessons)',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1A1A),
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
                              backgroundColor: Colors.white,
                              color: const Color(0xFFF97316),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // List of interactive lessons
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      itemCount: 8,
                      itemBuilder: (context, idx) {
                        final titles = [
                          'Introduction to Flutter & Widgets',
                          'Building Beautiful Interfaces with Row & Column',
                          'Understanding Stateless vs Stateful Widgets',
                          'Mastering Theme and Global Colors',
                          'Custom Paints & Particle Effects',
                          'Local Storage and App State Lifecycle',
                          'Async Network Calls & API Integration',
                          'Deploying to App Store and Google Play'
                        ];
                        final durations = [
                          '15 mins',
                          '22 mins',
                          '18 mins',
                          '25 mins',
                          '30 mins',
                          '20 mins',
                          '28 mins',
                          '35 mins'
                        ];
                        final isDone = idx < (completedLessons - 6);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                if (isDone) {
                                  completedLessons = completedLessons > 10 ? completedLessons - 1 : 10;
                                } else {
                                  completedLessons = completedLessons < 20 ? completedLessons + 1 : 20;
                                }
                              });
                              setSheetState(() {});
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isDone ? const Color(0xFFFFFDFB) : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isDone ? const Color(0xFFFFEDD5) : const Color(0xFFF3F4F6),
                                ),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 12,
                                    backgroundColor: isDone ? const Color(0xFFF97316) : const Color(0xFFF3F4F6),
                                    child: Text(
                                      '${idx + 1}',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: isDone ? Colors.white : const Color(0xFF6B7280),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          titles[idx],
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF1A1A1A),
                                            decoration: isDone ? TextDecoration.lineThrough : null,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          durations[idx],
                                          style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    isDone ? Icons.check_circle : Icons.radio_button_unchecked,
                                    color: isDone ? const Color(0xFFF97316) : const Color(0xFFD1D5DB),
                                    size: 20,
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      },
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

  // Simulated AI Chatbot guide dialog
  void _showChatbotDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: const [
              Icon(Icons.smart_toy_outlined, color: Color(0xFFF97316)),
              SizedBox(width: 10),
              Text(
                'Excelerate AI Guide',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              )
            ],
          ),
          content: const Text(
            'Hey there! 👋 I\'m your Excelerate Assistant.\n\nYou can ask me anything about Dart, Flutter, or UI/UX design. Would you like to resume your Flutter course right now?',
            style: TextStyle(fontSize: 13, height: 1.4, color: Color(0xFF1A1A1A)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Color(0xFF6B7280))),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _showLessonsSheet(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF97316),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
              ),
              child: const Text('Resume Lesson'),
            )
          ],
        );
      },
    );
  }
}

// Custom Painter for drawing the native Flutter geometric Logo shapes
class _FlutterLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Top diamond light blue path
    final path1 = Path()
      ..moveTo(size.width * 0.56, size.height * 0.08)
      ..lineTo(size.width * 0.24, size.height * 0.40)
      ..lineTo(size.width * 0.34, size.height * 0.50)
      ..lineTo(size.width * 0.76, size.height * 0.08)
      ..close();
    paint.color = const Color(0xFF39D3FE);
    canvas.drawPath(path1, paint);

    // Bottom dark blue path
    final path2 = Path()
      ..moveTo(size.width * 0.56, size.height * 0.92)
      ..lineTo(size.width * 0.76, size.height * 0.92)
      ..lineTo(size.width * 0.43, size.height * 0.60)
      ..lineTo(size.width * 0.34, size.height * 0.69)
      ..close();
    paint.color = const Color(0xFF02569B);
    canvas.drawPath(path2, paint);

    // Mid blue connecting piece path
    final path3 = Path()
      ..moveTo(size.width * 0.43, size.height * 0.60)
      ..lineTo(size.width * 0.56, size.height * 0.47)
      ..lineTo(size.width * 0.76, size.height * 0.47)
      ..lineTo(size.width * 0.53, size.height * 0.69)
      ..close();
    paint.color = const Color(0xFF0175C2);
    canvas.drawPath(path3, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

