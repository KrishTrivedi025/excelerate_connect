import '../data/mock_data.dart';

class OpportunityFetchException implements Exception {
  final String message;
  OpportunityFetchException(this.message);

  @override
  String toString() => message;
}

class OpportunityService {
  /// Toggle to simulate a network error.
  /// Must default to false. Documented in Week 3 changelog.
  static bool debugForceError = false;

  /// Simulates fetching a list of opportunities with an artificial delay.
  static Future<List<Opportunity>> fetchOpportunities() async {
    await Future.delayed(const Duration(milliseconds: 900));

    if (debugForceError) {
      throw OpportunityFetchException(
        'Failed to load opportunities. Please try again.',
      );
    }

    return List.unmodifiable(mockOpportunities);
  }

  /// Simulates fetching a single opportunity by ID.
  static Future<Opportunity> fetchOpportunityById(String id) async {
    await Future.delayed(const Duration(milliseconds: 700));

    if (debugForceError) {
      throw OpportunityFetchException(
        'Failed to load program details. Please try again.',
      );
    }

    return mockOpportunities.firstWhere(
      (opp) => opp.id == id,
      orElse: () =>
          throw OpportunityFetchException('Program with ID $id not found.'),
    );
  }
}
