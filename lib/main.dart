import 'package:flutter/material.dart';
import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(const ExcelerateApp());
}

class ExcelerateApp extends StatelessWidget {
  const ExcelerateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Excelerate Connect',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
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
  }
}
