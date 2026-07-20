import 'package:flutter/material.dart';
import '../../data/mock_data.dart';

class ProgramDetailsScreen extends StatefulWidget {
  final Opportunity opportunity;

  const ProgramDetailsScreen({super.key, required this.opportunity});

  @override
  State<ProgramDetailsScreen> createState() => _ProgramDetailsScreenState();
}

class _ProgramDetailsScreenState extends State<ProgramDetailsScreen> {
  static const _primary = Color(0xFF1976D2);
  static const _textSecondary = Color(0xFF757575);
  static const _divider = Color(0xFFE0E0E0);

  late bool _isFavorited;

  @override
  void initState() {
    super.initState();
    _isFavorited = widget.opportunity.isFavorited;
  }

  void _toggleFavorite() {
    setState(() => _isFavorited = !_isFavorited);
  }

  void _onRegister() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) =>
                    ScaleTransition(scale: animation, child: child),
                child: const Icon(
                  Icons.check_circle,
                  color: Color(0xFF4CAF50),
                  size: 64,
                  key: ValueKey('registered_icon'),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Registered!',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'You are all set for ${widget.opportunity.name}.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: _textSecondary),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(sheetContext).pop();
                    Navigator.of(context).popUntil(
                      (route) => route.settings.name == '/programs' || route.isFirst,
                    );
                  },
                  child: const Text(
                    'Back to Programs',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeroBackground() {
    final opportunity = widget.opportunity;
    final isAsset = !opportunity.imageUrl.startsWith('http');
    return Stack(
      fit: StackFit.expand,
      children: [
        isAsset
            ? Image.asset(
                opportunity.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: _primary),
              )
            : Image.network(
                opportunity.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: _primary),
              ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.05),
                Colors.black.withValues(alpha: 0.45),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _metaChip(String label) {
    return Chip(
      label: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: _primary,
        ),
      ),
      backgroundColor: const Color(0xFFE3F2FD),
      shape: const StadiumBorder(),
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Color(0xFF212121),
      ),
    );
  }

  Widget _bulletList(List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: Icon(Icons.circle, size: 6, color: _primary),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(fontSize: 14, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _rewardChip(String label) {
    IconData icon;
    final lower = label.toLowerCase();
    if (lower.contains('badge')) {
      icon = Icons.military_tech_outlined;
    } else if (lower.contains('cert')) {
      icon = Icons.workspace_premium_outlined;
    } else if (lower.contains('\$') || lower.contains('scholarship') || lower.contains('cash')) {
      icon = Icons.attach_money;
    } else {
      icon = Icons.star_outline;
    }
    return Chip(
      avatar: Icon(icon, size: 16, color: _primary),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      backgroundColor: Colors.white,
      shape: StadiumBorder(side: const BorderSide(color: _divider)),
      visualDensity: VisualDensity.compact,
    );
  }

  @override
  Widget build(BuildContext context) {
    final opportunity = widget.opportunity;
    final cohort = opportunity.cohorts.isNotEmpty ? opportunity.cohorts.first : null;
    final rewards = opportunity.rewards ?? const [];
    final scheduleItems = <String>[
      if (cohort != null) 'Starts: ${cohort.startDate.toLocal().toString().split(' ').first}',
      if (cohort != null)
        'Last date to apply: ${cohort.lastDateToApply.toLocal().toString().split(' ').first}',
      if (cohort?.endDate != null)
        'Ends: ${cohort!.endDate!.toLocal().toString().split(' ').first}',
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 220,
                pinned: true,
                elevation: 0,
                backgroundColor: _primary,
                leading: Padding(
                  padding: const EdgeInsets.all(8),
                  child: CircleAvatar(
                    backgroundColor: Colors.black.withValues(alpha: 0.35),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Hero(
                    tag: opportunity.id,
                    child: _buildHeroBackground(),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        opportunity.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF212121),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _metaChip(opportunity.categoryLabel),
                          _metaChip(opportunity.durationLabel),
                          _metaChip(opportunity.locationLabel),
                          _metaChip(opportunity.feeDisplay),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _sectionTitle('About this program'),
                      const SizedBox(height: 12),
                      Text(
                        opportunity.fullDescription ?? opportunity.shortDescription,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.5,
                          color: Color(0xFF212121),
                        ),
                      ),
                      if (scheduleItems.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        _sectionTitle('Schedule'),
                        const SizedBox(height: 12),
                        _bulletList(scheduleItems),
                      ],
                      if (opportunity.eligibility.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        _sectionTitle('Eligibility'),
                        const SizedBox(height: 12),
                        _bulletList(opportunity.eligibility),
                      ],
                      if (rewards.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        _sectionTitle('Rewards'),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: rewards.map(_rewardChip).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: _divider)),
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    IconButton(
                      onPressed: _toggleFavorite,
                      icon: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        transitionBuilder: (child, animation) =>
                            ScaleTransition(scale: animation, child: child),
                        child: Icon(
                          _isFavorited ? Icons.favorite : Icons.favorite_border,
                          key: ValueKey(_isFavorited),
                          color: _isFavorited ? const Color(0xFFF44336) : const Color(0xFF212121),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _onRegister,
                          child: const Text(
                            'Register Now',
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
