import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Loaded before the first frame so there's no flash of the wrong theme.
  await ThemeController.instance.load();
  runApp(const ExcelerateApp());
}

class ExcelerateApp extends StatelessWidget {
  const ExcelerateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.instance,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'Excelerate Connect',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: mode,
          // Matches ThemeToggleButton's own icon-transition duration so the
          // icon morph and the whole-screen recolor land on the same frame
          // — one gesture, not two unrelated animations.
          themeAnimationDuration: const Duration(milliseconds: 350),
          themeAnimationCurve: Curves.easeInOutCubic,
          // MaterialApp invokes `builder` as a descendant of its own
          // AnimatedTheme, so Theme.of(context) here resolves to the
          // *animating* theme — exactly what the status bar/nav bar need,
          // and it flips correctly regardless of which brightness AiChat's
          // own nested AnnotatedRegion (which stays hardcoded light) is
          // currently overriding above it.
          builder: (context, child) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final overlay = isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark;
            return AnnotatedRegion<SystemUiOverlayStyle>(
              value: overlay.copyWith(
                statusBarColor: Colors.transparent,
                // Without this Android draws a white gesture/nav bar under
                // a dark app — the classic "one element stayed light" bug.
                systemNavigationBarColor: Theme.of(context).scaffoldBackgroundColor,
                systemNavigationBarIconBrightness:
                    isDark ? Brightness.light : Brightness.dark,
              ),
              child: child!,
            );
          },
          onGenerateRoute: AppRouter.onGenerateRoute,
          // Flutter's default initial-route handling treats a leading-slash
          // route name as a path and silently pushes an extra "/" route
          // beneath it (see Navigator.defaultGenerateInitialRoutes). Since
          // nothing is registered for "/", that phantom route surfaces as
          // "Route not found: /" the moment the stack is ever popped back to
          // it. Overriding this pushes exactly one initial route instead.
          onGenerateInitialRoutes: (initialRouteName) => [
            AppRouter.onGenerateRoute(const RouteSettings(name: AppRouter.login)),
          ],
        );
      },
    );
  }
}
