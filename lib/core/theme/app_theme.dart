import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_palette.dart';

/// Design tokens — Excelerate Connect Week 2 Design & Build Spec, Section 3.
/// Values are copied verbatim from the spec. Do not substitute similar-looking values.
///
/// Only brand-invariant colors live here — the same in light and dark. Every
/// token that needs to flip between themes (backgrounds, text, surfaces,
/// dividers, and the handful of derived colors like `wave`) lives in
/// [AppPalette] instead, accessed via `context.palette`.
class AppColors {
  const AppColors._();

  static const Color primary = Color(0xFFFF8C42);
  static const Color primaryDark = Color(0xFFE46A00);
  static const Color primaryLight = Color(0xFFFFB366);

  static const Color accent = Color(0xFFFFA726);

  // Kept const for FILLS (a red/green button reads the same in both themes).
  // Text/borders/icons drawn directly on the background should use
  // context.palette.errorText / successText instead — the plain hex here is
  // ~4.4:1 against the dark background, only marginally passing AA.
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);

  static const Color onPrimary = Colors.white;
}

/// Spacing scale — spec Section 3.3. Use these values only.
class AppSpacing {
  const AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double base = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;
}

/// Corner radius scale — spec Section 3.4.
class AppRadius {
  const AppRadius._();

  static const double button = 12;
  static const double card = 16;
  static const double textField = 12;
  static const double hero = 20;
}

class AppTheme {
  const AppTheme._();

  // static final, not a getter — this used to reconstruct ThemeData and
  // re-run GoogleFonts.poppinsTextTheme on every single access. Once
  // MaterialApp rebuilds per theme toggle (via ValueListenableBuilder),
  // that becomes a per-frame cost, and a fresh ThemeData instance on every
  // build defeats AnimatedTheme's identity check that skips redundant lerps.
  static final ThemeData light = _build(Brightness.light);
  static final ThemeData dark = _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final palette = brightness == Brightness.dark ? AppPalette.dark : AppPalette.light;

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme:
          ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            // brightness must be passed here too, not just to ThemeData
            // above — otherwise Material 3 builds a light ColorScheme
            // inside a dark ThemeData and produces a contradictory theme.
            brightness: brightness,
          ).copyWith(
            primary: AppColors.primary,
            onPrimary: AppColors.onPrimary,
            primaryContainer: AppColors.primaryLight,
            secondary: AppColors.primary,
            surface: palette.surface,
            onSurface: palette.textPrimary,
            onSurfaceVariant: palette.textSecondary,
            surfaceContainerHighest: palette.surfaceAlt,
            surfaceContainerHigh: palette.surfaceAlt,
            outline: palette.divider,
            outlineVariant: palette.divider,
            inverseSurface: palette.inverseSurface,
            onInverseSurface: palette.onInverseSurface,
            error: AppColors.error,
            onError: AppColors.onPrimary,
            scrim: palette.scrim,
            // M3 tints elevated surfaces (Card, Sheet, Dialog, AppBar) by
            // the seed color proportional to elevation. With an orange
            // seed that produces a muddy orange-brown wash on every
            // elevated surface in dark mode that reads as a rendering bug.
            surfaceTint: Colors.transparent,
          ),
      scaffoldBackgroundColor: palette.background,
      canvasColor: palette.background,
      dividerColor: palette.divider,
      shadowColor: const Color(0xFF000000),
      iconTheme: IconThemeData(color: palette.textPrimary),
      extensions: [palette],
    );

    final textTheme = _buildTextTheme(base.textTheme, palette);

    return base.copyWith(
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.headlineMedium?.copyWith(
          color: AppColors.onPrimary,
        ),
        iconTheme: const IconThemeData(color: AppColors.onPrimary),
        // The app bar is orange in both themes, so its icons/status-bar
        // overlay should always be light, regardless of app brightness.
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          disabledBackgroundColor: palette.divider,
          disabledForegroundColor: palette.textSecondary,
          elevation: 0,
          minimumSize: const Size(double.infinity, 52),
          tapTargetSize: MaterialTapTargetSize.padded,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: const Size(48, 48),
          textStyle: textTheme.labelLarge,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: palette.textPrimary,
          minimumSize: const Size(44, 44),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.fieldFill,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.textField),
          borderSide: BorderSide(color: palette.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.textField),
          borderSide: BorderSide(color: palette.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.textField),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.textField),
          borderSide: BorderSide(color: palette.errorText),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.textField),
          borderSide: BorderSide(color: palette.errorText, width: 2),
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(color: palette.textSecondary),
        labelStyle: textTheme.bodyMedium?.copyWith(color: palette.textSecondary),
        errorStyle: textTheme.labelSmall?.copyWith(color: palette.errorText),
      ),
      cardTheme: CardThemeData(
        color: palette.surfaceAlt,
        surfaceTintColor: Colors.transparent,
        shadowColor: palette.shadowSoft,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        margin: EdgeInsets.zero,
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: palette.surfaceAlt,
        selectedColor: AppColors.primary,
        labelStyle: textTheme.labelSmall,
        secondaryLabelStyle: textTheme.labelSmall?.copyWith(color: AppColors.onPrimary),
        shape: const StadiumBorder(),
        side: BorderSide(color: palette.divider),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      ),
      dividerTheme: DividerThemeData(
        color: palette.divider,
        thickness: 1,
        space: 1,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 3,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: palette.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: palette.navInactive,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: textTheme.labelSmall,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: palette.inverseSurface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: palette.onInverseSurface),
        actionTextColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: const StadiumBorder(),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: palette.surfaceAlt,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: palette.textSecondary),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: palette.surfaceAlt,
        modalBackgroundColor: palette.surfaceAlt,
        surfaceTintColor: Colors.transparent,
        dragHandleColor: palette.sheetHandle,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.hero)),
        ),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: palette.surfaceAlt,
        surfaceTintColor: Colors.transparent,
        headerBackgroundColor: AppColors.primary,
        headerForegroundColor: AppColors.onPrimary,
        todayForegroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.onPrimary
              : AppColors.primary,
        ),
        todayBorder: const BorderSide(color: AppColors.primary),
        dayForegroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.onPrimary
              : palette.textPrimary,
        ),
        dayBackgroundColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected) ? AppColors.primary : null,
        ),
        yearForegroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.onPrimary
              : palette.textPrimary,
        ),
        yearBackgroundColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected) ? AppColors.primary : null,
        ),
        dividerColor: palette.divider,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.primary,
        inactiveTrackColor: palette.divider,
        thumbColor: palette.thumbSurface,
        overlayColor: AppColors.primary.withValues(alpha: 0.12),
        valueIndicatorColor: palette.inverseSurface,
        valueIndicatorTextStyle: textTheme.labelSmall?.copyWith(
          color: palette.onInverseSurface,
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.primary
              : Colors.transparent,
        ),
        checkColor: const WidgetStatePropertyAll(AppColors.onPrimary),
        side: BorderSide(color: palette.divider, width: 1.5),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.primary
              : palette.surfaceAlt,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.primaryLight
              : palette.divider,
        ),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.primary
              : palette.divider,
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: palette.progressTrack,
        circularTrackColor: palette.progressTrack,
        refreshBackgroundColor: palette.surfaceAlt,
      ),
      listTileTheme: ListTileThemeData(
        textColor: palette.textPrimary,
        iconColor: palette.textSecondary,
        tileColor: Colors.transparent,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: palette.surfaceAlt,
        surfaceTintColor: Colors.transparent,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: palette.inverseSurface,
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: textTheme.labelSmall?.copyWith(color: palette.onInverseSurface),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: AppColors.primary,
        selectionColor: AppColors.primary.withValues(alpha: 0.28),
        selectionHandleColor: AppColors.primary,
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStatePropertyAll(palette.textSecondary.withValues(alpha: 0.4)),
      ),
    );
  }

  /// Type scale — spec Section 3.2. Poppins via google_fonts, sizes/weights
  /// set explicitly because Material 3's default type scale uses different
  /// sizes for these style names than the spec calls for.
  static TextTheme _buildTextTheme(TextTheme base, AppPalette palette) {
    final poppins = GoogleFonts.poppinsTextTheme(base);
    return poppins.copyWith(
      displayLarge: poppins.displayLarge?.copyWith(
        fontSize: 32,
        height: 40 / 32,
        fontWeight: FontWeight.w700,
        color: palette.textPrimary,
      ),
      headlineMedium: poppins.headlineMedium?.copyWith(
        fontSize: 24,
        height: 32 / 24,
        fontWeight: FontWeight.w700,
        color: palette.textPrimary,
      ),
      titleLarge: poppins.titleLarge?.copyWith(
        fontSize: 20,
        height: 28 / 20,
        fontWeight: FontWeight.w600,
        color: palette.textPrimary,
      ),
      titleMedium: poppins.titleMedium?.copyWith(
        fontSize: 16,
        height: 22 / 16,
        fontWeight: FontWeight.w600,
        color: palette.textPrimary,
      ),
      bodyLarge: poppins.bodyLarge?.copyWith(
        fontSize: 16,
        height: 24 / 16,
        fontWeight: FontWeight.w400,
        color: palette.textPrimary,
      ),
      bodyMedium: poppins.bodyMedium?.copyWith(
        fontSize: 14,
        height: 20 / 14,
        fontWeight: FontWeight.w400,
        color: palette.textPrimary,
      ),
      labelLarge: poppins.labelLarge?.copyWith(
        fontSize: 14,
        height: 20 / 14,
        fontWeight: FontWeight.w600,
        color: palette.textPrimary,
      ),
      labelSmall: poppins.labelSmall?.copyWith(
        fontSize: 12,
        height: 16 / 12,
        fontWeight: FontWeight.w500,
        color: palette.textSecondary,
      ),
    );
  }
}
