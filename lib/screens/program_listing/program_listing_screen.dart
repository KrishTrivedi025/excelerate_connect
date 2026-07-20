import 'package:flutter/material.dart';
import '../../core/routes/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../data/mock_data.dart';
import '../../widgets/primary_text_field.dart';
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
      appBar: AppBar(
        title: const Text('Programs'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: PrimaryTextField(
              hintText: 'Search programs...',
              prefixIcon: Icons.search,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value ?? '';
                });
              },
            ),
          ),
          
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
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
          
          // Program List
          Expanded(
            child: filteredList.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
                    onRefresh: _handleRefresh,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                      itemCount: filteredList.length,
                      separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.md),
                      itemBuilder: (context, index) {
                        final program = filteredList[index];
                        return ProgramCard(
                          program: program,
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AppRouter.programDetails,
                              arguments: program,
                            );
                          },
                        );
                      },
                    ),
                  ),
          ),
        ],
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
          Icon(
            Icons.search_off,
            size: 64,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: AppSpacing.md),
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
          const SizedBox(height: AppSpacing.lg),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _searchQuery = '';
                _selectedCategory = null;
              });
            },
            child: const Text('Clear Filters'),
          ),
        ],
      ),
    );
  }
}
