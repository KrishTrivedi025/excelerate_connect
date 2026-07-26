import 'package:flutter/material.dart';

/// Component Library 6.5 — hero banner (Home and Program Listing top
/// section). Full width, just the image (no overlaid text/CTA — the hero
/// images themselves carry their own marketing copy), with a modest
/// bottom-corner curve per the reference design.
class HeroBanner extends StatelessWidget {
  final Widget image;
  final double height;

  const HeroBanner({
    super.key,
    required this.image,
    this.height = 230,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(28),
        bottomRight: Radius.circular(28),
      ),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: image,
      ),
    );
  }
}
