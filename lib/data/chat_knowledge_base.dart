/// Local knowledge base for the Excelerate AI Guide chatbot.
///
/// Deliberately simple: no ML, no network call. Each [ChatEntry] lists the
/// keyword phrases a question should contain to trigger it; ChatService
/// scores every entry by how many of its keywords appear in the question and
/// returns the best match. Content here is sourced from this project's own
/// README progress checklist and mockOpportunities (see mock_data.dart) —
/// not invented, so answers stay consistent with the rest of the app.
///
/// Knowledge is deep for the Flutter internship (what this app itself is
/// built for) and brief for the other four programs, so the bot never looks
/// blank when asked about them.
library;

class ChatEntry {
  final List<String> keywords;
  final String answer;

  const ChatEntry({required this.keywords, required this.answer});
}

final List<ChatEntry> chatKnowledgeBase = [
  // ---------------------------------------------------------------
  // Greeting
  // ---------------------------------------------------------------
  const ChatEntry(
    keywords: ['hello', 'hi', 'hey', 'good morning', 'good evening', 'yo'],
    answer:
        "Hey there! 👋 I'm your Excelerate AI Guide.\n\n"
        "Ask me about the Mobile App Development with Flutter internship — "
        "what it covers, what's due each week, or anything else about your "
        "programs.",
  ),

  // ---------------------------------------------------------------
  // Flutter internship — deep knowledge
  // ---------------------------------------------------------------
  const ChatEntry(
    keywords: [
      'what is mobile app development with flutter',
      'what is the flutter internship',
      'about the flutter internship',
      'tell me about flutter',
      'what is flutter internship',
      'flutter internship overview',
    ],
    answer:
        'Mobile App Development with Flutter\n\n'
        '• A 6-week remote internship where you build a real, working '
        'Flutter app from scratch\n'
        '• You\'ll learn widget composition, state management, REST API '
        'integration, and app deployment\n'
        '• Delivered through hands-on projects, not just theory\n'
        '• Skills covered: Flutter, Dart, Firebase, REST APIs, Git\n'
        '• Rewards: Certificate of Completion, LinkedIn Badge, and a \$500 '
        'scholarship',
  ),

  const ChatEntry(
    keywords: [
      'week 1',
      'week one',
      '1st week',
      'first week',
    ],
    answer:
        'Week 1 — Getting Started\n\n'
        '• Define your app proposal and target users\n'
        '• Create low-fidelity wireframes for Login, Home, Program Listing, '
        'and Program Details/Profile\n'
        '• Set up your GitHub repository for the project\n\n'
        'This is the planning week — nothing gets built in Flutter yet, '
        'it\'s all about the idea and the wireframes.',
  ),

  const ChatEntry(
    keywords: [
      'week 2',
      'week two',
      '2nd week',
      'second week',
    ],
    answer:
        'Week 2 — Core Screens\n\n'
        '• Build the core screens in Flutter: Login, Sign-Up, Home, Program '
        'Listing, and Program Details\n'
        '• Apply consistent branding across every screen\n'
        '• Wire up navigation so all five screens connect end to end\n\n'
        'By the end of this week the app should look and feel complete, '
        'even though the data is still static.',
  ),

  const ChatEntry(
    keywords: [
      'week 3',
      'week three',
      '3rd week',
      'third week',
    ],
    answer:
        'Week 3 — Feature Integration\n\n'
        '• Connect your screens to a mock API instead of static data\n'
        '• Add real loading and error/retry states, plus pull-to-refresh\n'
        '• Add at least one working form (feedback or registration) with '
        'validation\n\n'
        'This is where the app stops being a static mockup and starts '
        'behaving like a real, data-driven product.',
  ),

  const ChatEntry(
    keywords: [
      'week 4',
      'week four',
      '4th week',
      'final week',
      'last week',
    ],
    answer:
        'Week 4 — Testing & Polish\n\n'
        '• Polish the UI/UX and fix any remaining bugs\n'
        '• Test navigation, form validation, and responsive layouts across '
        'devices\n'
        '• Write a polished GitHub README: setup instructions, screenshots, '
        'and a contribution log\n'
        '• Record a short demo video and a reflection video on your '
        'internship journey\n'
        '• Complete the 360° evaluation (self, peer, and managerial) — a '
        'minimum 70% peer score is required to finish the internship\n\n'
        'This is the final week — by the end you\'ll have a complete app, '
        'documentation, and a portfolio-ready project.',
  ),

  const ChatEntry(
    keywords: [
      'all weeks',
      'week by week',
      'weekly breakdown',
      'overview of the internship',
      'roadmap',
      'what happens each week',
      'how many weeks',
    ],
    answer:
        'The Flutter internship runs 4 weeks:\n\n'
        '• Week 1 — Proposal, target users, wireframes, GitHub setup\n'
        '• Week 2 — Build the core screens in Flutter\n'
        '• Week 3 — Connect screens to a mock API, add a working form\n'
        '• Week 4 — Polish, testing, documentation, demo + reflection video\n\n'
        'Ask me about any specific week for the full breakdown.',
  ),

  const ChatEntry(
    keywords: [
      'what do i submit',
      'what do i have to submit',
      'deliverables',
      'what should i turn in',
      'final deliverable',
    ],
    answer:
        'By the end of the internship you submit:\n\n'
        '• The complete Flutter app — all key screens working, with '
        'consistent branding and navigation\n'
        '• An updated GitHub repository with a polished README (overview, '
        'setup instructions, screenshots, contribution log)\n'
        '• An optional 2–3 minute demo video walking through the app\n'
        '• A reflection video or write-up on your internship journey',
  ),

  const ChatEntry(
    keywords: [
      'what skills will i learn',
      'what will i learn',
      'skills covered',
      'what do i learn',
    ],
    answer:
        'In the Flutter internship you\'ll pick up:\n\n'
        '• Flutter & Dart fundamentals — widgets, layout, navigation\n'
        '• State management\n'
        '• REST API integration (via a mock async service)\n'
        '• Firebase basics\n'
        '• Git & GitHub — commits, pull requests, documentation',
  ),

  const ChatEntry(
    keywords: [
      'is it paid',
      'scholarship',
      'is there a fee',
      'does it cost',
      'free',
    ],
    answer:
        'The Flutter internship is free to join (\$0 fee) and comes with a '
        '\$500 scholarship award on completion, plus a Certificate of '
        'Completion and a LinkedIn badge.',
  ),

  const ChatEntry(
    keywords: [
      'how long is it',
      'how long is the internship',
      'duration',
      'how many weeks is the internship',
    ],
    answer:
        'The Mobile App Development with Flutter internship runs 6 weeks '
        'total, fully remote.',
  ),

  // ---------------------------------------------------------------
  // General Excelerate questions
  // ---------------------------------------------------------------
  const ChatEntry(
    keywords: [
      'what is excelerate',
      'about excelerate',
      'who is excelerate',
    ],
    answer:
        'Excelerate is a virtual internship and learning platform — it '
        'connects learners with internships, courses, competitions, and '
        'events from real sponsors and organizations, all completed '
        'remotely and delivered through this app.',
  ),

  const ChatEntry(
    keywords: [
      'upcoming courses',
      'upcoming internships',
      'what programs are available',
      'what courses do you have',
      'what internships are available',
      'other programs',
      'what programs',
    ],
    answer:
        'Here\'s what\'s currently available:\n\n'
        '• Mobile App Development with Flutter — internship, 6 weeks\n'
        '• Sustainability, Technology & Environmental Systems Course\n'
        '• Data Science with Python\n'
        '• UI/UX Design Challenge 2026 — competition\n'
        '• Global Leadership Summit 2026 — one-day virtual event\n\n'
        'Ask me about any one of these by name for more detail.',
  ),

  const ChatEntry(
    keywords: ['how do i register', 'how do i apply', 'how to register', 'sign up for a program'],
    answer:
        'Open a program from Program Listing, go to its Program Details '
        'page, and tap Register Now — fill in the short form (name, DOB, '
        'email, and how you heard about it) and submit.',
  ),

  const ChatEntry(
    keywords: ['how do i give feedback', 'feedback form', 'how to leave feedback'],
    answer:
        'Once you\'ve registered for a program, its details page shows a '
        '"Give Feedback" button — it opens a short form with a mood slider, '
        'what helped most, and an optional comment.',
  ),

  // ---------------------------------------------------------------
  // Other programs — brief only
  // ---------------------------------------------------------------
  const ChatEntry(
    keywords: ['sustainability', 'environmental systems'],
    answer:
        'Sustainability, Technology & Environmental Systems Course\n\n'
        'Explore how technology can build smarter, more sustainable '
        'systems — analyze real-world scenarios and design practical '
        'solutions. Run with Saint Louis University, delivered virtually.',
  ),

  const ChatEntry(
    keywords: ['data science', 'python course'],
    answer:
        'Data Science with Python\n\n'
        'Master data analysis, visualization, and machine learning with '
        'Python — clean data, create charts, and build predictive models. '
        'Delivered virtually with DataCamp.',
  ),

  const ChatEntry(
    keywords: ['ui/ux design challenge', 'design challenge', 'ux design competition'],
    answer:
        'UI/UX Design Challenge 2026\n\n'
        'Redesign the Excelerate mobile experience and win prizes — open '
        'to individuals and teams, run remotely with Figma.',
  ),

  const ChatEntry(
    keywords: ['leadership summit', 'global leadership'],
    answer:
        'Global Leadership Summit 2026\n\n'
        'A one-day virtual summit featuring talks from global leaders on '
        'innovation, strategy, and personal growth — run with Harvard '
        'Business School.',
  ),
];

/// The clickable suggestion chips shown before the first message.
final List<String> suggestedPrompts = [
  'What is Mobile App Development with Flutter?',
  'What do I have to do in Week 1?',
  'What do I submit at the end?',
  'What are the upcoming courses?',
];
