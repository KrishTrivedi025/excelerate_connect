import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/login/login_screen.dart';
import '../../screens/program_details/program_details_screen.dart';
import '../../screens/program_listing/program_listing_screen.dart';
import '../../screens/signup/signup_screen.dart';

class AppRouter {
  const AppRouter._();

  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String programListing = '/programs';
  static const String programDetails = '/program-details';

  /// Bottom-nav tab routes — these transition with a slide+fade instead of
  /// the default platform push, since switching tabs isn't a forward
  /// navigation. Checked by both onGenerateRoute (e.g. deep links) and
  /// goToTab (bottom nav taps), so the behavior is defined in one place.
  static const Set<String> _tabRoutes = {home, programListing};

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final builder = _builderForRoute(settings);
    if (builder == null) return _notFound(settings.name);
    return _tabRoutes.contains(settings.name)
        ? _tabPage(builder, settings)
        : _page(builder, settings);
  }

  /// Switches between bottom-nav tabs. Uses pushReplacement (tabs are peers,
  /// not a navigation stack) with the shared slide+fade transition.
  static void goToTab(BuildContext context, String routeName) {
    final settings = RouteSettings(name: routeName);
    final builder = _builderForRoute(settings);
    if (builder == null) return;
    Navigator.of(context).pushReplacement(_tabPage(builder, settings));
  }

  static WidgetBuilder? _builderForRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return (_) => const LoginScreen();
      case signup:
        return (_) => const SignupScreen();
      case home:
        return (_) => const HomeScreen();
      case programListing:
        return (_) => const ProgramListingScreen();
      case programDetails:
        if (settings.arguments is! Opportunity) return null;
        return (_) => ProgramDetailsScreen(
          opportunity: settings.arguments as Opportunity,
        );
      default:
        return null;
    }
  }

  static MaterialPageRoute<void> _page(
    WidgetBuilder builder,
    RouteSettings settings,
  ) => MaterialPageRoute(builder: builder, settings: settings);

  static PageRouteBuilder<void> _tabPage(
    WidgetBuilder builder,
    RouteSettings settings,
  ) {
    return PageRouteBuilder<void>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => builder(context),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position:
                Tween<Offset>(
                  begin: const Offset(0.04, 0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 260),
    );
  }

  static MaterialPageRoute<void> _notFound(String? name) => MaterialPageRoute(
    builder: (_) => Scaffold(
      body: Center(child: Text('Route not found: ${name ?? 'unknown'}')),
    ),
  );
}
