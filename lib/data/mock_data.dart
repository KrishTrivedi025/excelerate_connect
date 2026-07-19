// mock_data.dart
// Fixed & Extended — aligned with Excelerate's actual data model
// Covers: Home, Program Listing, Program Details screens
//
// CHANGES FROM ORIGINAL:
//   FIX 1 — durationLabel getter: used durationType.name ('hours','days'...)
//            then added 's', producing 'hourss','dayss' for plurals and
//            '1 hours' for singular. Fixed with explicit singular word map.
//   FIX 2 — scholarshipDisplay: returned 'Free' when scholarship==0
//            (misleading — 'Free' means no cost, not no reward).
//            Fixed to return 'None'. Also output 'USD $500' (redundant).
//            Fixed to output '$500'.
//   FIX 3 — feeDisplay: output 'USD $500' (redundant currency label +
//            dollar sign). Fixed to output '$500'.
//   FIX 4 — opp_002 lastAccessed was DateTime(2026, 9, 1) — a future
//            date for a program marked as completed. Fixed to a past date.
//   ADDED — AnnouncementType enum
//   ADDED — UserProfile model + mockUser       (Home Screen greeting/stats)
//   ADDED — Announcement model + mockAnnouncements (Home Screen cards)
//   ADDED — QuickLink model + mockQuickLinks   (Home Screen quick links)
//   ADDED — mockEnrolledOpportunities helper   (Home Screen "My Programs")

// =============================================================
// ENUMS
// =============================================================

enum OpportunityType {
  internship,
  jobSimulation,
  course,
  competition,
  event,
  masterclass,
  career,
  engagement,
}

enum LocationType {
  inPerson,
  virtual,
  remote,
}

enum DurationType {
  hours,
  days,
  weeks,
  months,
  years,
}

enum ApplicationStatus {
  applied,
  payNow,
  rejected,
  cohortAllocated,
  startMyExperience,
  opportunityEnded,
  rewardsAwarded,
  withdrawn,
  droppedOut,
  failToStart,
  sentForApproval,
}

/// NEW — used by Announcement model and Home Screen card color/icon logic
enum AnnouncementType {
  general,
  urgent,
  opportunity,
  system,
}

// =============================================================
// MODELS — unchanged from original
// =============================================================

class Sponsor {
  final String name;
  final String logoUrl;
  const Sponsor({required this.name, required this.logoUrl});
}

class Skill {
  final String name;
  final int points;
  const Skill({required this.name, this.points = 0});
}

class Cohort {
  final DateTime startDate;
  final DateTime lastDateToApply;
  final DateTime? endDate;
  const Cohort({
    required this.startDate,
    required this.lastDateToApply,
    this.endDate,
  });
}

class CompetitionAddOn {
  final int teamSizeMin;
  final int teamSizeMax;
  final int numberOfRounds;
  const CompetitionAddOn({
    required this.teamSizeMin,
    required this.teamSizeMax,
    required this.numberOfRounds,
  });
}

class CareerAddOn {
  final String jobType;
  final String requiredExperience;
  final String ctc;
  const CareerAddOn({
    required this.jobType,
    required this.requiredExperience,
    required this.ctc,
  });
}

class ModulePage {
  final String id;
  final String title;
  final String type; // 'content', 'quiz', 'assignment', 'scorm'
  final String? content;
  final int estimatedMinutes;
  final DateTime? unlockDate;
  final DateTime? dueDate;
  final int? questionCount;
  final int? durationMinutes;
  final int? maxAttempts;
  final int? maxFiles;
  final double? maxFileSizeMB;
  final List<String>? allowedFileTypes;
  final int? requiredFiles;

  const ModulePage({
    required this.id,
    required this.title,
    required this.type,
    this.content,
    required this.estimatedMinutes,
    this.unlockDate,
    this.dueDate,
    this.questionCount,
    this.durationMinutes,
    this.maxAttempts,
    this.maxFiles,
    this.maxFileSizeMB,
    this.allowedFileTypes,
    this.requiredFiles,
  });
}

class Module {
  final String id;
  final String title;
  final String? description;
  final List<ModulePage> pages;
  const Module({
    required this.id,
    required this.title,
    this.description,
    required this.pages,
  });
}

// =============================================================
// MODELS — NEW
// =============================================================

/// Logged-in user — drives Home Screen greeting, avatar initials, and stats row.
class UserProfile {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? avatarUrl; // null → show initials avatar
  final String university;
  final int totalPoints;
  final int badgesEarned;

  const UserProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.avatarUrl,
    required this.university,
    this.totalPoints = 0,
    this.badgesEarned = 0,
  });

  /// Full name for greeting text: "Hello, Alex 👋"
  String get displayName => '$firstName $lastName';

  /// Two-letter initials for avatar fallback circle: "AR"
  String get initials => '${firstName[0]}${lastName[0]}';
}

/// Platform announcement — drives Home Screen AnnouncementCard.
class Announcement {
  final String id;
  final String title;
  final String body;
  final DateTime publishedAt;
  final AnnouncementType type;
  final bool isRead;
  final String? actionUrl; // optional deep-link or external URL

  const Announcement({
    required this.id,
    required this.title,
    required this.body,
    required this.publishedAt,
    required this.type,
    this.isRead = false,
    this.actionUrl,
  });
}

/// Quick navigation tile — drives Home Screen QuickLinkTile row.
/// [icon] is the Material Icons name string (e.g. 'explore').
/// In UI: Icon(IconData(0xe[codepoint], fontFamily: 'MaterialIcons'))
/// or map via a switch to Icons.explore, Icons.trending_up, etc.
class QuickLink {
  final String id;
  final String label;
  final String icon; // Material Icons name — resolved in UI widget
  final String route;

  const QuickLink({
    required this.id,
    required this.label,
    required this.icon,
    required this.route,
  });
}

// =============================================================
// OPPORTUNITY MODEL — with fixed getters
// =============================================================

class Opportunity {
  final String id;
  final String name;
  final OpportunityType type;
  final String imageUrl;
  final String shortDescription;
  final String? fullDescription;
  final List<String> learningOutcomes;
  final String? role;
  final Sponsor? sponsor;
  final Sponsor? publisher;
  final String? instructor;
  final List<Skill> skills;
  final LocationType location;
  final List<String> eligibility;
  final List<String>? rolesAndResponsibilities;
  final String? theme;
  final List<Cohort> cohorts;
  final double fee;
  final String currencyType;
  final double scholarship;
  final List<String>? rewards;
  final int duration;
  final DurationType durationType;
  final CompetitionAddOn? competitionAddOn;
  final CareerAddOn? careerAddOn;
  final List<Module> modules;
  final ApplicationStatus? userStatus;
  final double progressPercentage;
  final DateTime? registrationDate;
  final DateTime? lastAccessed;
  final bool isFavorited;

  const Opportunity({
    required this.id,
    required this.name,
    required this.type,
    required this.imageUrl,
    required this.shortDescription,
    this.fullDescription,
    this.learningOutcomes = const [],
    this.role,
    this.sponsor,
    this.publisher,
    this.instructor,
    required this.skills,
    required this.location,
    required this.eligibility,
    this.rolesAndResponsibilities,
    this.theme,
    required this.cohorts,
    required this.fee,
    required this.currencyType,
    required this.scholarship,
    this.rewards,
    required this.duration,
    required this.durationType,
    this.competitionAddOn,
    this.careerAddOn,
    required this.modules,
    this.userStatus,
    this.progressPercentage = 0.0,
    this.registrationDate,
    this.lastAccessed,
    this.isFavorited = false,
  });

  // --- Computed Getters ---

  String get categoryLabel {
    switch (type) {
      case OpportunityType.internship:
        return 'Global Internship';
      case OpportunityType.jobSimulation:
        return 'Job Simulation';
      case OpportunityType.course:
        return 'Power Skill Course';
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

  /// FIX 1: Original used durationType.name (e.g. 'hours') then added 's',
  /// producing 'hourss'/'dayss' for plurals and '1 hours' for singular.
  /// Fixed: explicit singular word map + correct plural logic.
  ///   6 weeks → "6 weeks" ✓   1 year → "1 year" ✓   40 hours → "40 hours" ✓
  String get durationLabel {
    const Map<DurationType, String> singular = {
      DurationType.hours: 'hour',
      DurationType.days: 'day',
      DurationType.weeks: 'week',
      DurationType.months: 'month',
      DurationType.years: 'year',
    };
    final word = singular[durationType]!;
    return '$duration ${duration == 1 ? word : '${word}s'}';
  }

  /// FIX 2a: Original returned 'Free' when scholarship == 0, which is
  /// semantically wrong — 'Free' means no cost, not no reward.
  /// Fixed to return 'None' when no scholarship is available.
  /// FIX 2b: Original output 'USD $500' — currency code + dollar sign
  /// is redundant. Fixed to output '$500'.
  String get scholarshipDisplay {
    if (scholarship == 0) return 'None';
    return '\$${scholarship.toStringAsFixed(0)}';
  }

  /// FIX 3: Original output 'USD $500' — redundant.
  /// Fixed to output '$500'. 'Free' when fee == 0 is correct and unchanged.
  String get feeDisplay {
    if (fee == 0) return 'Free';
    return '\$${fee.toStringAsFixed(0)}';
  }

  String get locationLabel {
    switch (location) {
      case LocationType.inPerson:
        return 'In Person';
      case LocationType.virtual:
        return 'Virtual';
      case LocationType.remote:
        return 'Remote';
    }
  }

  bool get isEnrolled => userStatus != null;
  bool get isInProgress => userStatus == ApplicationStatus.startMyExperience;
  bool get isCompleted =>
      userStatus == ApplicationStatus.opportunityEnded ||
      userStatus == ApplicationStatus.rewardsAwarded;

  /// Flat map for ProgramCard widget — avoids passing full Opportunity object
  /// where only listing-level fields are needed.
  Map<String, dynamic> toCardData() => {
        'id': id,
        'imageUrl': imageUrl,
        'name': name,
        'categoryLabel': categoryLabel,
        'durationLabel': durationLabel,
        'scholarshipDisplay': scholarshipDisplay,
        'sponsorName': sponsor?.name,
        'skillNames': skills.map((s) => s.name).toList(),
        'locationLabel': locationLabel,
        'role': role,
        'isFavorited': isFavorited,
        'isEnrolled': isEnrolled,
        'userStatus': userStatus,
        'progressPercentage': progressPercentage,
      };
}

// =============================================================
// MOCK DATA: 5 Excelerate Opportunities
// =============================================================

final List<Opportunity> mockOpportunities = [
  // 1. Flutter Internship — In Progress (40%)
  Opportunity(
    id: 'opp_001',
    name: 'Mobile App Development with Flutter',
    type: OpportunityType.internship,
    imageUrl: 'assets/images/flutter_card.png',
    shortDescription:
        'Build cross-platform mobile apps using Flutter and Dart. Learn widget trees, state management, and deploy your first app.',
    fullDescription:
        'This comprehensive 4-6 week remote internship takes you from Flutter basics '
        'to building a fully functional mobile application. You will learn widget composition, '
        'state management with Provider, REST API integration, and app deployment. '
        'Delivered through interactive SCORM content with hands-on projects.',
    learningOutcomes: const [
      'Build complete Flutter apps from scratch',
      'Manage app state using Provider pattern',
      'Integrate REST APIs and Firebase backend',
      'Deploy apps to app stores',
    ],
    role: 'Flutter Developer Intern',
    sponsor: const Sponsor(
      name: 'Excelerate',
      logoUrl: 'assets/images/excelerate_logo.png',
    ),
    publisher: const Sponsor(
      name: 'Excelerate',
      logoUrl: 'assets/images/excelerate_logo.png',
    ),
    instructor: 'Excelerate',
    skills: const [
      Skill(name: 'Flutter', points: 200),
      Skill(name: 'Dart', points: 150),
      Skill(name: 'Firebase', points: 100),
      Skill(name: 'REST APIs', points: 100),
      Skill(name: 'Git', points: 50),
    ],
    location: LocationType.remote,
    eligibility: const [
      'Basic programming knowledge',
      'Familiarity with object-oriented concepts',
      'Laptop with internet access',
    ],
    rolesAndResponsibilities: const [
      'Complete all modules and assignments',
      'Build a capstone project',
      'Submit weekly reflections',
      'Participate in peer code reviews',
    ],
    cohorts: [
      Cohort(
        startDate: DateTime(2026, 7, 1),
        lastDateToApply: DateTime(2026, 6, 25),
        endDate: DateTime(2026, 8, 15),
      ),
    ],
    fee: 0,
    currencyType: 'USD',
    scholarship: 500,
    rewards: const ['Certificate of Completion', 'LinkedIn Badge', 'Scholarship Award'],
    duration: 6,
    durationType: DurationType.weeks,
    modules: [
      Module(
        id: 'mod_flutter_1',
        title: 'Welcome & Onboarding',
        description: 'Get familiar with the program structure and expectations.',
        pages: [
          ModulePage(
            id: 'page_flutter_1_1',
            title: 'Welcome Message',
            type: 'content',
            content:
                'Welcome to the Mobile App Development with Flutter Internship! We are excited...',
            estimatedMinutes: 5,
          ),
          ModulePage(
            id: 'page_flutter_1_2',
            title: 'Internship Overview',
            type: 'scorm',
            content: 'https://lms.4excelerate.org/scorm/flutter-overview',
            estimatedMinutes: 15,
          ),
        ],
      ),
      Module(
        id: 'mod_flutter_2',
        title: 'Flutter Fundamentals',
        description: 'Set up your environment and understand core Flutter concepts.',
        pages: [
          ModulePage(
            id: 'page_flutter_2_1',
            title: 'Installing Flutter SDK',
            type: 'content',
            content: 'Follow these steps to install Flutter on your machine...',
            estimatedMinutes: 20,
          ),
          ModulePage(
            id: 'page_flutter_2_2',
            title: 'Understanding Widgets',
            type: 'content',
            content: 'Widgets are the building blocks of every Flutter app...',
            estimatedMinutes: 25,
          ),
          ModulePage(
            id: 'page_flutter_2_3',
            title: 'Widget Basics Quiz',
            type: 'quiz',
            estimatedMinutes: 15,
            questionCount: 10,
            durationMinutes: 20,
            maxAttempts: 2,
          ),
          ModulePage(
            id: 'page_flutter_2_4',
            title: 'First App Assignment',
            type: 'assignment',
            estimatedMinutes: 60,
            maxFiles: 3,
            maxFileSizeMB: 5,
            allowedFileTypes: const ['zip', 'dart', 'pdf'],
            requiredFiles: 1,
            dueDate: DateTime(2026, 7, 20),
          ),
        ],
      ),
    ],
    userStatus: ApplicationStatus.startMyExperience,
    progressPercentage: 0.40,
    registrationDate: DateTime(2026, 6, 20),
    lastAccessed: DateTime(2026, 7, 10),
  ),

  // 2. Sustainability Course — Completed
  Opportunity(
    id: 'opp_002',
    name: 'Sustainability, Technology & Environmental Systems Course',
    type: OpportunityType.course,
    imageUrl: 'assets/images/sustainability_card.png',
    shortDescription:
        'Explore how technology can build smarter, more sustainable systems. '
        'Analyze real-world scenarios and design practical solutions.',
    fullDescription:
        'Environmental challenges such as waste, pollution, and inefficient resource use '
        'affect everyday life, but solving them requires more than awareness. In this course, '
        'you will explore how technology can be used to build smarter, more sustainable systems. '
        'You will study how environmental systems function and where inefficiencies exist.\n\n'
        'Through guided activities, you will analyze real-world scenarios such as waste management, '
        'energy consumption, and resource distribution. Using simple tools and structured thinking, '
        'you will identify problems and design solutions that improve efficiency and reduce '
        'environmental impact. This course focuses on practical understanding—helping you think '
        'in terms of systems, patterns, and outcomes rather than isolated issues.',
    learningOutcomes: const [
      'Understand how environmental systems function and interact',
      'Identify inefficiencies in real-world sustainability challenges',
      'Apply technology-based thinking to improve systems',
      'Design practical solutions for environmental problems',
    ],
    sponsor: const Sponsor(
      name: 'Saint Louis University',
      logoUrl: 'assets/images/slu_logo.png',
    ),
    publisher: const Sponsor(
      name: 'Excelerate',
      logoUrl: 'assets/images/excelerate_logo.png',
    ),
    instructor: 'Excelerate',
    skills: const [
      Skill(name: 'Critical Thinking', points: 80),
      Skill(name: 'Creative Thinking', points: 70),
      Skill(name: 'Technology Literacy', points: 90),
      Skill(name: 'Initiative', points: 60),
    ],
    location: LocationType.virtual,
    eligibility: const ['8th to 10th Graders Only'],
    cohorts: [
      Cohort(
        startDate: DateTime(2026, 7, 13),
        lastDateToApply: DateTime(2027, 7, 7),
        endDate: DateTime(2027, 7, 14),
      ),
    ],
    fee: 0,
    currencyType: 'USD',
    scholarship: 50,
    rewards: const ['Badge', 'Certificate', 'Scholarship'],
    duration: 1,
    durationType: DurationType.years,
    modules: [],
    userStatus: ApplicationStatus.rewardsAwarded,
    progressPercentage: 1.0,
    registrationDate: DateTime(2026, 6, 1),
    // FIX 4: original was DateTime(2026, 9, 1) — future date for a completed
    // program. A completed program's lastAccessed must be in the past.
    lastAccessed: DateTime(2026, 7, 5),
  ),

  // 3. Data Science with Python — Not Started
  Opportunity(
    id: 'opp_003',
    name: 'Data Science with Python',
    type: OpportunityType.course,
    imageUrl: 'assets/images/datascience_card.png',
    shortDescription:
        'Master data analysis, visualization, and machine learning with Python. '
        'Clean data, create charts, and build predictive models.',
    fullDescription:
        'This 40-hour power skill course covers the complete data science workflow: '
        'data cleaning with Pandas, exploratory analysis, visualization with Matplotlib '
        'and Seaborn, and machine learning fundamentals with Scikit-learn. '
        'No prior data science experience required.',
    learningOutcomes: const [
      'Clean and manipulate data using Pandas',
      'Create visualizations with Matplotlib and Seaborn',
      'Build basic machine learning models',
      'Present data-driven insights effectively',
    ],
    sponsor: const Sponsor(
      name: 'DataCamp',
      logoUrl: 'assets/images/datacamp_logo.png',
    ),
    publisher: const Sponsor(
      name: 'Excelerate',
      logoUrl: 'assets/images/excelerate_logo.png',
    ),
    skills: const [
      Skill(name: 'Python', points: 150),
      Skill(name: 'Pandas', points: 120),
      Skill(name: 'NumPy', points: 100),
      Skill(name: 'Matplotlib', points: 80),
      Skill(name: 'Scikit-learn', points: 100),
    ],
    location: LocationType.virtual,
    eligibility: const ['No prior data science experience required'],
    cohorts: [
      Cohort(
        startDate: DateTime(2026, 8, 1),
        lastDateToApply: DateTime(2026, 7, 25),
      ),
      Cohort(
        startDate: DateTime(2026, 9, 1),
        lastDateToApply: DateTime(2026, 8, 25),
      ),
    ],
    fee: 0,
    currencyType: 'USD',
    scholarship: 250,
    rewards: const ['Course Certificate', 'Scholarship Award'],
    duration: 40,
    durationType: DurationType.hours,
    modules: [],
    userStatus: null,
    progressPercentage: 0.0,
  ),

  // 4. UI/UX Design Challenge — Not Started
  Opportunity(
    id: 'opp_004',
    name: 'UI/UX Design Challenge 2026',
    type: OpportunityType.competition,
    imageUrl: 'assets/images/design_card.png',
    shortDescription:
        'Redesign the Excelerate mobile experience and win prizes. '
        'Open to individuals and teams.',
    fullDescription:
        'Put your design skills to the test in this global competition. '
        'Redesign a key user flow for the Excelerate platform. Winners receive mentorship, '
        'a certificate, and a cash prize.',
    learningOutcomes: const [
      'Apply user-centered design principles',
      'Create high-fidelity prototypes in Figma',
      'Conduct usability testing',
      'Present design rationale to stakeholders',
    ],
    theme: 'Redesigning Education Technology',
    sponsor: const Sponsor(
      name: 'Figma',
      logoUrl: 'assets/images/figma_logo.png',
    ),
    publisher: const Sponsor(
      name: 'Excelerate',
      logoUrl: 'assets/images/excelerate_logo.png',
    ),
    skills: const [
      Skill(name: 'Figma', points: 100),
      Skill(name: 'UI Design', points: 100),
      Skill(name: 'UX Research', points: 80),
      Skill(name: 'Prototyping', points: 60),
    ],
    location: LocationType.remote,
    eligibility: const [
      'Open to all learners',
      'Individual or team participation (max 4 members)',
    ],
    cohorts: [
      Cohort(
        startDate: DateTime(2026, 9, 15),
        lastDateToApply: DateTime(2026, 9, 1),
        endDate: DateTime(2026, 9, 30),
      ),
    ],
    fee: 0,
    currencyType: 'USD',
    scholarship: 1000,
    rewards: const ['Cash Prize', 'Mentorship Session', 'Certificate'],
    duration: 2,
    durationType: DurationType.weeks,
    competitionAddOn: const CompetitionAddOn(
      teamSizeMin: 1,
      teamSizeMax: 4,
      numberOfRounds: 2,
    ),
    modules: [],
    userStatus: null,
    progressPercentage: 0.0,
  ),

  // 5. Global Leadership Summit — Completed
  Opportunity(
    id: 'opp_005',
    name: 'Global Leadership Summit 2026',
    type: OpportunityType.event,
    imageUrl: 'assets/images/leadership_card.png',
    shortDescription:
        'A one-day virtual summit featuring talks from global leaders on '
        'innovation, strategy, and personal growth.',
    fullDescription:
        'Join thousands of learners worldwide for this one-day virtual summit. '
        'Hear from CEOs, founders, and thought leaders on the future of work, innovation, '
        'and personal growth. Includes networking sessions and Q&A panels.',
    learningOutcomes: const [
      'Understand emerging leadership trends',
      'Develop strategic thinking skills',
      'Build a global professional network',
    ],
    sponsor: const Sponsor(
      name: 'Harvard Business School',
      logoUrl: 'assets/images/hbs_logo.png',
    ),
    publisher: const Sponsor(
      name: 'Excelerate',
      logoUrl: 'assets/images/excelerate_logo.png',
    ),
    skills: const [
      Skill(name: 'Leadership', points: 50),
      Skill(name: 'Communication', points: 30),
      Skill(name: 'Strategy', points: 40),
      Skill(name: 'Innovation', points: 20),
    ],
    location: LocationType.virtual,
    eligibility: const ['Open to all'],
    cohorts: [
      Cohort(
        startDate: DateTime(2026, 6, 15),
        lastDateToApply: DateTime(2026, 6, 10),
        endDate: DateTime(2026, 6, 15),
      ),
    ],
    fee: 0,
    currencyType: 'USD',
    scholarship: 0,
    rewards: const ['Participation Certificate'],
    duration: 1,
    durationType: DurationType.days,
    modules: [],
    userStatus: ApplicationStatus.rewardsAwarded,
    progressPercentage: 1.0,
    registrationDate: DateTime(2026, 5, 20),
    lastAccessed: DateTime(2026, 6, 16),
  ),
];

/// Convenience filter — opportunities the user has enrolled in.
/// Used by Home Screen "My Programs" section.
/// opp_001 (in progress) + opp_002 (completed) + opp_005 (completed) = 3 items.
final List<Opportunity> mockEnrolledOpportunities =
    mockOpportunities.where((o) => o.isEnrolled).toList();

// =============================================================
// MOCK USER — Home Screen greeting & stats
// =============================================================

const UserProfile mockUser = UserProfile(
  id: 'user_001',
  firstName: 'Alex',
  lastName: 'Rivera',
  email: 'alex.rivera@slu.edu',
  university: 'Saint Louis University',
  totalPoints: 890,
  badgesEarned: 3,
);

// =============================================================
// MOCK ANNOUNCEMENTS — Home Screen AnnouncementCard list
// =============================================================

final List<Announcement> mockAnnouncements = [
  // Unread — opportunity type (accent color: blue chip)
  Announcement(
    id: 'ann_001',
    title: 'New Cohort Now Open',
    body:
        'Applications for the August 2026 Flutter internship cohort are now open. '
        'Apply before July 25!',
    publishedAt: DateTime(2026, 7, 15),
    type: AnnouncementType.opportunity,
    isRead: false,
  ),
  // Read — general type
  Announcement(
    id: 'ann_002',
    title: 'Welcome to Excelerate Connect',
    body:
        'Explore programs, track your progress, and earn rewards — all in one place.',
    publishedAt: DateTime(2026, 7, 1),
    type: AnnouncementType.general,
    isRead: true,
  ),
  // Unread — system type (accent color: orange chip)
  Announcement(
    id: 'ann_003',
    title: 'Scheduled Maintenance',
    body:
        'The platform will be under maintenance on July 22, 2026 '
        'from 2:00 AM to 4:00 AM UTC.',
    publishedAt: DateTime(2026, 7, 18),
    type: AnnouncementType.system,
    isRead: false,
  ),
];

// =============================================================
// MOCK QUICK LINKS — Home Screen QuickLinkTile row (4 tiles)
// icon: Material Icons name — in UI, map to Icons.explore etc.
// =============================================================

const List<QuickLink> mockQuickLinks = [
  QuickLink(
    id: 'ql_001',
    label: 'Browse Programs',
    icon: 'explore',
    route: '/programs',
  ),
  QuickLink(
    id: 'ql_002',
    label: 'My Progress',
    icon: 'trending_up',
    route: '/progress',
  ),
  QuickLink(
    id: 'ql_003',
    label: 'Rewards',
    icon: 'emoji_events',
    route: '/rewards',
  ),
  QuickLink(
    id: 'ql_004',
    label: 'Support',
    icon: 'help_outline',
    route: '/support',
  ),
];
