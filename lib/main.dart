import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_demo/bottomNavigation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:weather_demo/providers/search_history_provider.dart';

import 'package:go_router/go_router.dart';
import 'package:weather_demo/screens/info_tab.dart';
import 'package:weather_demo/screens/weather_details_screen.dart';
import 'package:weather_demo/screens/weather_search_tab.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'shell');

void main() async {
  await dotenv.load();
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => SearchHistoryModel())],
      child: MainApp()));
}

class MainApp extends StatelessWidget {
  MainApp({super.key});

  final GoRouter _router = GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/weather_search',
      routes: <RouteBase>[
        ShellRoute(
            navigatorKey: _shellNavigatorKey,
            builder: (context, state, child) =>
                ScaffoldWithNavBar(child: child),
            routes: <RouteBase>[
              GoRoute(
                  path: "/weather_search",
                  pageBuilder: (BuildContext context, GoRouterState state) {
                    return const NoTransitionPage(child: WeatherSearchTab());
                  }),
              GoRoute(
                path: "/info",
                pageBuilder: (BuildContext context, GoRouterState state) {
                  return const NoTransitionPage(child: InfoTab());
                },
              )
            ]),
        GoRoute(
          path: "/weather_result",
          builder: (BuildContext context, GoRouterState state) {
            return WeatherDetailsScreen(
                weatherLocationDescription:
                    state.uri.queryParameters['weatherLocationDescription']!,
                placeId: state.uri.queryParameters['placeId']!);
          },
        ),
      ]);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      theme: ThemeData.from(
          colorScheme: const ColorScheme.light(primary: Colors.black54)),
    );
  }
}

class ScaffoldWithNavBar extends StatelessWidget {
  /// Constructs an [ScaffoldWithNavBar].
  const ScaffoldWithNavBar({
    required this.child,
    super.key,
  });

  /// The widget to display in the body of the Scaffold.
  /// In this sample, it is a Navigator.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: child, bottomNavigationBar: const BottomNavigation());
  }
}
