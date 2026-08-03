import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// App-wide light/dark/system preference. A singleton ValueNotifier rather
/// than an InheritedWidget or a state-management package — the only
/// consumer of the *mode itself* is ExcelerateApp; every other widget reads
/// the already-resolved Theme.of(context).brightness, which is correctly
/// scoped and rebuild-tracked on its own.
class ThemeController extends ValueNotifier<ThemeMode> {
  ThemeController._() : super(ThemeMode.system);

  static final ThemeController instance = ThemeController._();

  static const _key = 'theme_mode';

  /// Call once before runApp. Any storage failure silently leaves
  /// ThemeMode.system — this must never throw and block app startup.
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final name = prefs.getString(_key);
      value = ThemeMode.values.firstWhere(
        (m) => m.name == name,
        orElse: () => ThemeMode.system,
      );
    } catch (_) {
      // Keep the ThemeMode.system default.
    }
  }

  void setMode(ThemeMode mode) {
    if (value == mode) return;
    value = mode;
    unawaited(_persist(mode));
  }

  /// Flips off whatever brightness is actually on screen right now, so
  /// "system mode + device happens to be dark" toggles to an explicit
  /// light rather than back to system (which would look like a no-op).
  void toggleFrom(Brightness current) =>
      setMode(current == Brightness.dark ? ThemeMode.light : ThemeMode.dark);

  Future<void> _persist(ThemeMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, mode.name);
    } catch (_) {
      // Non-fatal — the choice just won't survive a restart this time.
    }
  }
}
