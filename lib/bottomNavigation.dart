import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BottomNavigation extends StatelessWidget {
  const BottomNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      indicatorColor: Colors.amber[300],
      shadowColor: Colors.black,
      elevation: 20,
      backgroundColor: Colors.amber[100],
      destinations: const <Widget>[
        NavigationDestination(
          selectedIcon: Icon(Icons.sunny),
          icon: Icon(Icons.wb_sunny_outlined),
          label: 'Weather',
        ),
        NavigationDestination(
          selectedIcon: Icon(Icons.info),
          icon: Icon(Icons.info_outline),
          label: 'Info',
        ),
      ],
      selectedIndex: _calculateSelectedIndex(context),
      onDestinationSelected: (int idx) => _onItemTapped(idx, context),
    );
  }

  static int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/weather_search')) {
      return 0;
    }
    if (location.startsWith("/info")) {
      return 1;
    }
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        GoRouter.of(context).go('/weather_search');
      case 1:
        GoRouter.of(context).go("/info");
    }
  }
}
