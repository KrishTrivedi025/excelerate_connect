import 'package:flutter/material.dart';

/// Tokens that flip between light and dark — everything from AppColors that
/// isn't brand-invariant (primary/accent/onPrimary stay put; those remain
/// plain static const in AppColors). Registered on ThemeData via
/// `extensions: [AppPalette.light/dark]` so MaterialApp's built-in
/// AnimatedTheme cross-fades every one of these alongside colorScheme,
/// instead of the app hard-cutting between themes.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  final Color background;
  final Color surface;
  final Color surfaceAlt;
  final Color fieldFill;
  final Color divider;
  final Color textPrimary;
  final Color textSecondary;
  final Color navInactive;
  final Color wave;
  final Color knowMoreAction;
  final Color onKnowMoreAction;
  final Color listingAction;
  final Color warmSurface;
  final Color warmSurfaceBorder;
  final Color warmRowFill;
  final Color warmRowBorder;
  final Color emptyIconBg;
  final Color infoSurface;
  final Color onInfoSurface;
  final Color selectedSurface;
  final Color inverseSurface;
  final Color onInverseSurface;
  final Color progressTrack;
  final Color glassBase;
  final Color glassBorder;
  final Color navRing;
  final Color shadowSoft;
  final Color shadowStrong;
  final Color scrim;
  final Color sheetHandle;
  final Color thumbSurface;
  final Color errorText;
  final Color successText;
  final Color logoPlate;

  const AppPalette({
    required this.background,
    required this.surface,
    required this.surfaceAlt,
    required this.fieldFill,
    required this.divider,
    required this.textPrimary,
    required this.textSecondary,
    required this.navInactive,
    required this.wave,
    required this.knowMoreAction,
    required this.onKnowMoreAction,
    required this.listingAction,
    required this.warmSurface,
    required this.warmSurfaceBorder,
    required this.warmRowFill,
    required this.warmRowBorder,
    required this.emptyIconBg,
    required this.infoSurface,
    required this.onInfoSurface,
    required this.selectedSurface,
    required this.inverseSurface,
    required this.onInverseSurface,
    required this.progressTrack,
    required this.glassBase,
    required this.glassBorder,
    required this.navRing,
    required this.shadowSoft,
    required this.shadowStrong,
    required this.scrim,
    required this.sheetHandle,
    required this.thumbSurface,
    required this.errorText,
    required this.successText,
    required this.logoPlate,
  });

  static const AppPalette light = AppPalette(
    background: Color(0xFFFFFFFF),
    surface: Color(0xFFFFFFFF),
    surfaceAlt: Color(0xFFFFFFFF),
    fieldFill: Color(0xFFFFFFFF),
    divider: Color(0xFFE5E7EB),
    textPrimary: Color(0xFF1F2937),
    textSecondary: Color(0xFF6B7280),
    navInactive: Color(0xFF6B7280),
    wave: Color(0xFFFFE5D0),
    knowMoreAction: Color(0xFF4456E8),
    onKnowMoreAction: Color(0xFFFFFFFF),
    listingAction: Color(0xFF1E3A5F),
    warmSurface: Color(0xFFFDEDE1),
    warmSurfaceBorder: Color(0x66FFB366),
    warmRowFill: Color(0xFFFFFDFB),
    warmRowBorder: Color(0xFFFFEDD5),
    emptyIconBg: Color(0xFFFFF7ED),
    infoSurface: Color(0xFFE3F2FD),
    onInfoSurface: Color(0xFF000000),
    selectedSurface: Color(0xFFFFF5EC),
    inverseSurface: Color(0xFF1F2937),
    onInverseSurface: Color(0xFFFFFFFF),
    progressTrack: Color(0xFFFFFFFF),
    glassBase: Color(0xFFFFFFFF),
    glassBorder: Color(0xFFFFFFFF),
    navRing: Color(0xFFFFFFFF),
    shadowSoft: Color(0x0D000000),
    shadowStrong: Color(0x14000000),
    scrim: Color(0x73000000),
    sheetHandle: Color(0xFFEEEEEE),
    thumbSurface: Color(0xFFFFFFFF),
    errorText: Color(0xFFE53935),
    successText: Color(0xFF4CAF50),
    logoPlate: Color(0x00000000),
  );

  static const AppPalette dark = AppPalette(
    background: Color(0xFF0E1013),
    surface: Color(0xFF171A1F),
    surfaceAlt: Color(0xFF1F232A),
    fieldFill: Color(0xFF191D23),
    divider: Color(0xFF2A2F37),
    textPrimary: Color(0xFFF2F4F7),
    textSecondary: Color(0xFFA2AAB6),
    navInactive: Color(0xFF9AA3AF),
    wave: Color(0xFF3A2A1C),
    knowMoreAction: Color(0xFF8C97FF),
    onKnowMoreAction: Color(0xFF0E1013),
    listingAction: Color(0xFF9FC0E8),
    warmSurface: Color(0xFF2A1E15),
    warmSurfaceBorder: Color(0x38FF8C42),
    warmRowFill: Color(0xFF221913),
    warmRowBorder: Color(0xFF4A3524),
    emptyIconBg: Color(0xFF2A2018),
    infoSurface: Color(0xFF16283A),
    onInfoSurface: Color(0xFFCFE3F5),
    selectedSurface: Color(0xFF33241A),
    inverseSurface: Color(0xFFE8EAEE),
    onInverseSurface: Color(0xFF14161A),
    progressTrack: Color(0xFF3A2A1E),
    glassBase: Color(0xFF101317),
    glassBorder: Color(0x14FFFFFF),
    navRing: Color(0xFF14171C),
    shadowSoft: Color(0x73000000),
    shadowStrong: Color(0x99000000),
    scrim: Color(0xA6000000),
    sheetHandle: Color(0xFF3A404B),
    thumbSurface: Color(0xFFE8EAEE),
    errorText: Color(0xFFFF6B6B),
    successText: Color(0xFF5CC463),
    logoPlate: Color(0xFFF7F7F5),
  );

  @override
  AppPalette copyWith({
    Color? background,
    Color? surface,
    Color? surfaceAlt,
    Color? fieldFill,
    Color? divider,
    Color? textPrimary,
    Color? textSecondary,
    Color? navInactive,
    Color? wave,
    Color? knowMoreAction,
    Color? onKnowMoreAction,
    Color? listingAction,
    Color? warmSurface,
    Color? warmSurfaceBorder,
    Color? warmRowFill,
    Color? warmRowBorder,
    Color? emptyIconBg,
    Color? infoSurface,
    Color? onInfoSurface,
    Color? selectedSurface,
    Color? inverseSurface,
    Color? onInverseSurface,
    Color? progressTrack,
    Color? glassBase,
    Color? glassBorder,
    Color? navRing,
    Color? shadowSoft,
    Color? shadowStrong,
    Color? scrim,
    Color? sheetHandle,
    Color? thumbSurface,
    Color? errorText,
    Color? successText,
    Color? logoPlate,
  }) {
    return AppPalette(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceAlt: surfaceAlt ?? this.surfaceAlt,
      fieldFill: fieldFill ?? this.fieldFill,
      divider: divider ?? this.divider,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      navInactive: navInactive ?? this.navInactive,
      wave: wave ?? this.wave,
      knowMoreAction: knowMoreAction ?? this.knowMoreAction,
      onKnowMoreAction: onKnowMoreAction ?? this.onKnowMoreAction,
      listingAction: listingAction ?? this.listingAction,
      warmSurface: warmSurface ?? this.warmSurface,
      warmSurfaceBorder: warmSurfaceBorder ?? this.warmSurfaceBorder,
      warmRowFill: warmRowFill ?? this.warmRowFill,
      warmRowBorder: warmRowBorder ?? this.warmRowBorder,
      emptyIconBg: emptyIconBg ?? this.emptyIconBg,
      infoSurface: infoSurface ?? this.infoSurface,
      onInfoSurface: onInfoSurface ?? this.onInfoSurface,
      selectedSurface: selectedSurface ?? this.selectedSurface,
      inverseSurface: inverseSurface ?? this.inverseSurface,
      onInverseSurface: onInverseSurface ?? this.onInverseSurface,
      progressTrack: progressTrack ?? this.progressTrack,
      glassBase: glassBase ?? this.glassBase,
      glassBorder: glassBorder ?? this.glassBorder,
      navRing: navRing ?? this.navRing,
      shadowSoft: shadowSoft ?? this.shadowSoft,
      shadowStrong: shadowStrong ?? this.shadowStrong,
      scrim: scrim ?? this.scrim,
      sheetHandle: sheetHandle ?? this.sheetHandle,
      thumbSurface: thumbSurface ?? this.thumbSurface,
      errorText: errorText ?? this.errorText,
      successText: successText ?? this.successText,
      logoPlate: logoPlate ?? this.logoPlate,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceAlt: Color.lerp(surfaceAlt, other.surfaceAlt, t)!,
      fieldFill: Color.lerp(fieldFill, other.fieldFill, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      navInactive: Color.lerp(navInactive, other.navInactive, t)!,
      wave: Color.lerp(wave, other.wave, t)!,
      knowMoreAction: Color.lerp(knowMoreAction, other.knowMoreAction, t)!,
      onKnowMoreAction: Color.lerp(onKnowMoreAction, other.onKnowMoreAction, t)!,
      listingAction: Color.lerp(listingAction, other.listingAction, t)!,
      warmSurface: Color.lerp(warmSurface, other.warmSurface, t)!,
      warmSurfaceBorder: Color.lerp(warmSurfaceBorder, other.warmSurfaceBorder, t)!,
      warmRowFill: Color.lerp(warmRowFill, other.warmRowFill, t)!,
      warmRowBorder: Color.lerp(warmRowBorder, other.warmRowBorder, t)!,
      emptyIconBg: Color.lerp(emptyIconBg, other.emptyIconBg, t)!,
      infoSurface: Color.lerp(infoSurface, other.infoSurface, t)!,
      onInfoSurface: Color.lerp(onInfoSurface, other.onInfoSurface, t)!,
      selectedSurface: Color.lerp(selectedSurface, other.selectedSurface, t)!,
      inverseSurface: Color.lerp(inverseSurface, other.inverseSurface, t)!,
      onInverseSurface: Color.lerp(onInverseSurface, other.onInverseSurface, t)!,
      progressTrack: Color.lerp(progressTrack, other.progressTrack, t)!,
      glassBase: Color.lerp(glassBase, other.glassBase, t)!,
      glassBorder: Color.lerp(glassBorder, other.glassBorder, t)!,
      navRing: Color.lerp(navRing, other.navRing, t)!,
      shadowSoft: Color.lerp(shadowSoft, other.shadowSoft, t)!,
      shadowStrong: Color.lerp(shadowStrong, other.shadowStrong, t)!,
      scrim: Color.lerp(scrim, other.scrim, t)!,
      sheetHandle: Color.lerp(sheetHandle, other.sheetHandle, t)!,
      thumbSurface: Color.lerp(thumbSurface, other.thumbSurface, t)!,
      errorText: Color.lerp(errorText, other.errorText, t)!,
      successText: Color.lerp(successText, other.successText, t)!,
      logoPlate: Color.lerp(logoPlate, other.logoPlate, t)!,
    );
  }
}

/// Access point for the flipping tokens — `context.palette.textPrimary`
/// instead of `AppColors.textPrimary`. Falls back to [AppPalette.light]
/// rather than asserting, since the dev harnesses in lib/dev/ and
/// test/widget_test.dart build MaterialApps that may not register this
/// extension.
extension AppPaletteX on BuildContext {
  AppPalette get palette => Theme.of(this).extension<AppPalette>() ?? AppPalette.light;

  bool get isDarkTheme => Theme.of(this).brightness == Brightness.dark;
}
