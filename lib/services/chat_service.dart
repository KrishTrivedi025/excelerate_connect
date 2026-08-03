import '../data/chat_knowledge_base.dart';

/// Thrown when no knowledge-base entry scores above the match threshold.
class ChatUnknownException implements Exception {
  final String message;
  ChatUnknownException(this.message);

  @override
  String toString() => message;
}

/// Mock "AI" layer for the Excelerate AI Guide chatbot — same shape as
/// OpportunityService (static methods, simulated delay, a debugForceError
/// toggle) but answering from the local chatKnowledgeBase instead of
/// mockOpportunities.
class ChatService {
  ChatService._();

  static bool debugForceError = false;

  /// Minimum keyword hits before a match counts as confident enough to
  /// answer — without this, a single stray word overlap could return a
  /// wrong topic instead of admitting it doesn't know.
  static const int _minScore = 1;

  static Future<String> ask(String question) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));

    if (debugForceError) {
      throw ChatUnknownException(
        'I haven\'t been trained on that yet 🙏 — I\'m still learning. '
        'Right now I know all about the Mobile App Development with '
        'Flutter internship: what it covers, what you\'ll build, and '
        'what\'s due each week. Try asking me about Week 1, or tap a '
        'suggestion below.',
      );
    }

    final normalized = question.toLowerCase().trim();

    ChatEntry? bestEntry;
    var bestScore = 0;

    for (final entry in chatKnowledgeBase) {
      var score = 0;
      for (final keyword in entry.keywords) {
        if (normalized.contains(keyword)) {
          score++;
        }
      }
      if (score > bestScore) {
        bestScore = score;
        bestEntry = entry;
      }
    }

    if (bestEntry == null || bestScore < _minScore) {
      throw ChatUnknownException(
        'I haven\'t been trained on that yet 🙏 — I\'m still learning. '
        'Right now I know all about the Mobile App Development with '
        'Flutter internship: what it covers, what you\'ll build, and '
        'what\'s due each week. Try asking me about Week 1, or tap a '
        'suggestion below.',
      );
    }

    return bestEntry.answer;
  }
}
