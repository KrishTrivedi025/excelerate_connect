import 'package:flutter/material.dart';

/// Loads an image asset without needing to know its exact extension ahead
/// of time — tries [baseName] with each extension in [extensions] in
/// order, falling through to the next on failure, and finally to
/// [fallback] if none of them exist. Lets an image be dropped into
/// assets/images/ as whichever format it happens to be (.png, .jpg, ...)
/// without the code and the file needing to agree on an exact name.
class FlexibleAssetImage extends StatelessWidget {
  final String baseName; // e.g. 'assets/images/home_hero' (no extension)
  final BoxFit fit;
  final Alignment alignment;
  final WidgetBuilder fallback;
  final List<String> extensions;

  const FlexibleAssetImage({
    super.key,
    required this.baseName,
    required this.fallback,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.extensions = const ['.png', '.jpg', '.jpeg', '.webp'],
  });

  @override
  Widget build(BuildContext context) => _tryExtension(0);

  Widget _tryExtension(int index) {
    if (index >= extensions.length) {
      return Builder(builder: fallback);
    }
    return Image.asset(
      '$baseName${extensions[index]}',
      fit: fit,
      alignment: alignment,
      errorBuilder: (context, error, stackTrace) => _tryExtension(index + 1),
    );
  }
}
