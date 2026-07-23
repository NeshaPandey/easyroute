import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/app_constants.dart';
import '../presentation/screens/auth/splash_screen.dart';
import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/auth/signup_screen.dart';
import '../presentation/screens/home/home_screen.dart';
import '../presentation/screens/route/search_screen.dart';
import '../presentation/screens/route/route_selection_screen.dart';
import '../presentation/screens/navigation/navigation_screen.dart';
import '../presentation/screens/profile/profile_screen.dart';
import '../presentation/screens/emergency/emergency_screen.dart';
import '../domain/entities/route_entity.dart';

class AppRouter {
  late final GoRouter config;

  AppRouter() {
    config = GoRouter(
      initialLocation: RouteNames.splash,
      debugLogDiagnostics: false,
      routes: [
        GoRoute(
          path: RouteNames.splash,
          builder: (_, __) => const SplashScreen(),
        ),
        GoRoute(
          path: RouteNames.login,
          builder: (_, __) => const LoginScreen(),
        ),
        GoRoute(
          path: RouteNames.signup,
          builder: (_, __) => const SignupScreen(),
        ),
        ShellRoute(
          builder: (context, state, child) =>
              MainShell(child: child, location: state.fullPath ?? ''),
          routes: [
            GoRoute(
              path: RouteNames.home,
              builder: (_, __) => const HomeScreen(),
            ),
            GoRoute(
              path: RouteNames.profile,
              builder: (_, __) => const ProfileScreen(),
            ),
            GoRoute(
              path: RouteNames.emergency,
              builder: (_, __) => const EmergencyScreen(),
            ),
          ],
        ),
        GoRoute(
          path: RouteNames.search,
          builder: (_, __) => const SearchScreen(),
        ),
        GoRoute(
          path: RouteNames.routeSelection,
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            return RouteSelectionScreen(
              origin: extra?['origin'] as PlaceEntity?,
              destination: extra?['destination'] as PlaceEntity?,
            );
          },
        ),
        GoRoute(
          path: RouteNames.navigation,
          builder: (context, state) {
            final route = state.extra as RouteEntity?;
            return NavigationScreen(route: route);
          },
        ),
      ],
    );
  }
}

class MainShell extends StatelessWidget {
  final Widget child;
  final String location;

  const MainShell({super.key, required this.child, required this.location});

  int _currentIndex(String loc) {
    if (loc.startsWith(RouteNames.home)) return 0;
    if (loc.startsWith(RouteNames.emergency)) return 1;
    if (loc.startsWith(RouteNames.profile)) return 2;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final idx = _currentIndex(location);
    final theme = Theme.of(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: theme.dividerColor, width: 1),
          ),
        ),
        child: NavigationBar(
          selectedIndex: idx,
          onDestinationSelected: (i) {
            switch (i) {
              case 0:
                context.go(RouteNames.home);
              case 1:
                context.go(RouteNames.emergency);
              case 2:
                context.go(RouteNames.profile);
            }
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.emergency_outlined),
              selectedIcon: Icon(Icons.emergency),
              label: 'SOS',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outlined),
              selectedIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
