import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../data/mock_data.dart';

/// Component Library 6.1 — reusable program card.
class ProgramCard extends StatelessWidget {
  final Opportunity program;
  final bool horizontal;
  final VoidCallback? onTap;

  const ProgramCard({
    super.key,
    required this.program,
    this.horizontal = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // We now use the exact same compact styling from the home page for all cards
    // to ensure consistency and perfect icon fitting.
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF9FAFB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Stack(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Home-screen style Thumbnail
                    CourseThumbnail(type: program.imageType, size: 84),
                    const SizedBox(width: 14),
                    
                    // Text and rating description
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            program.name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A1A),
                              letterSpacing: -0.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            program.shortDescription,
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: AppColors.textSecondary,
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
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                'Beginner', 
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
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
                                  ),
                                  children: [
                                    TextSpan(text: '${_getMockRatingValue()} '),
                                    TextSpan(
                                      text: '(${_getMockRatingCount()})',
                                      style: const TextStyle(
                                        color: AppColors.textSecondary,
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
                // Bookmark icon (static mockup)
                Positioned(
                  top: 0,
                  right: 0,
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
                    child: const Icon(
                      Icons.bookmark_border_outlined,
                      size: 14,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getMockRatingValue() {
    final hash = program.id.hashCode.abs();
    final rating = 4.0 + (hash % 11) / 10.0;
    return rating.toStringAsFixed(1);
  }

  String _getMockRatingCount() {
    final hash = program.id.hashCode.abs();
    final count = 50 + (hash % 300);
    return count.toString();
  }
}

// ----------------------------------------------------
// Embedded CourseThumbnail (from home screen style)
// ----------------------------------------------------

class CourseThumbnail extends StatelessWidget {
  final String type;
  final double size;

  const CourseThumbnail({super.key, required this.type, this.size = 84});

  @override
  Widget build(BuildContext context) {
    if (type == 'flutter') {
      return Container(
        width: size,
        height: size,
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
          width: size * 0.42,
          height: size * 0.8,
          decoration: BoxDecoration(
            color: const Color(0xFF0F1B3D),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
            border: Border.all(color: const Color(0xFF312E81), width: 1.5),
          ),
          child: Center(
            child: SizedBox(
              width: size * 0.19,
              height: size * 0.19,
              child: CustomPaint(painter: _FlutterLogoPainter()),
            ),
          ),
        ),
      );
    } else if (type == 'design') {
      return Container(
        width: size,
        height: size,
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
          width: size * 0.42,
          height: size * 0.8,
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
              Icon(
                Icons.palette_outlined,
                color: Colors.white,
                size: size * 0.16,
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: size * 0.06,
                    height: size * 0.06,
                    decoration: const BoxDecoration(color: Colors.amber, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 2),
                  Container(
                    width: size * 0.06,
                    height: size * 0.06,
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
        width: size,
        height: size,
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
          width: size * 0.42,
          height: size * 0.8,
          decoration: BoxDecoration(
            color: const Color(0xFF064E3B),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
            border: Border.all(color: const Color(0xFF065F46), width: 1.5),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.data_exploration_outlined,
                color: Colors.white,
                size: size * 0.16,
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(width: 4, height: 12, color: const Color(0xFF34D399)),
                  Container(width: 4, height: 20, color: const Color(0xFF34D399)),
                  Container(width: 4, height: 16, color: const Color(0xFF34D399)),
                ],
              )
            ],
          ),
        ),
      );
    } else {
      // Business fallback
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFFBEB), Color(0xFFFEF3C7)],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.bottomCenter,
        child: Container(
          width: size * 0.42,
          height: size * 0.8,
          decoration: BoxDecoration(
            color: const Color(0xFF92400E),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
            border: Border.all(color: const Color(0xFF78350F), width: 1.5),
          ),
          child: Center(
            child: Icon(
              Icons.trending_up,
              color: Colors.white,
              size: size * 0.22,
            ),
          ),
        ),
      );
    }
  }
}

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

