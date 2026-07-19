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

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return _page(const LoginScreen());
      case signup:
        return _page(const SignupScreen());
      case home:
        return _page(const HomeScreen());
      case programListing:
        return _page(const ProgramListingScreen());
      case programDetails:
        if (settings.arguments is! Opportunity) {
          return _notFound(settings.name);
        }
        return _page(
          ProgramDetailsScreen(
            opportunity: settings.arguments as Opportunity,
          ),
        );
      default:
        return _notFound(settings.name);
    }
  }

  static MaterialPageRoute<void> _page(Widget child) =>
      MaterialPageRoute(builder: (_) => child);

  static MaterialPageRoute<void> _notFound(String? name) =>
      MaterialPageRoute(
        builder: (_) => Scaffold(
          body: Center(
            child: Text('Route not found: ${name ?? 'unknown'}'),
          ),
        ),
      );
}
