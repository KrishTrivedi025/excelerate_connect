import 'package:flutter/material.dart';

import '../core/theme/app_palette.dart';
import '../core/theme/app_theme.dart';

/// Excelerate's own branded loading indicator — used in place of a generic
/// [CircularProgressIndicator] for every loading state in the app (Login,
/// Program Listing, Program Details, ...). One shared widget so the app's
/// loading state is visually consistent everywhere and only needs to change
/// in one place.
class BrandedLoader extends StatelessWidget {
  /// The GIF's real content is a wide band (~500:361), not a square — this
  /// sizes by width and derives height from that ratio so it always renders
  /// at a legible, undistorted size instead of shrinking to illegible
  /// slivers inside a small square box.
  final double width;

  const BrandedLoader({super.key, this.width = 100});

  static const double _aspectRatio = 500 / 361;

  @override
  Widget build(BuildContext context) {
    final height = width / _aspectRatio;
    final fallback = Center(
      child: SizedBox(
        width: height * 0.7,
        height: height * 0.7,
        child: const CircularProgressIndicator(
          color: AppColors.primary,
          strokeWidth: 3,
        ),
      ),
    );

    // The GIF's own canvas is a white-background render — legible on every
    // light-mode screen, but a stark white rectangle on dark ones. Reuse
    // the existing error fallback (the plain branded spinner) for dark
    // mode instead of shipping a second asset.
    if (context.isDarkTheme) {
      return SizedBox(width: width, height: height, child: fallback);
    }

    return SizedBox(
      width: width,
      height: height,
      child: Image.asset(
        'assets/images/excelerate_spinner.gif',
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => fallback,
      ),
    );
  }
}
