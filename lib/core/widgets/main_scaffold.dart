import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'bm_bottom_nav.dart';

class MainScaffold extends StatelessWidget {
  const MainScaffold({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const items = [
    BmBottomNavItem(label: 'Home', icon: Icons.home_rounded),
    BmBottomNavItem(label: 'Browse', icon: Icons.search_rounded),
    BmBottomNavItem(label: 'Saved', icon: Icons.favorite_rounded),
    BmBottomNavItem(label: 'Settings', icon: Icons.settings_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BmBottomNav(
        items: items,
        currentIndex: navigationShell.currentIndex,
        onTap: (i) => navigationShell.goBranch(
          i,
          initialLocation: i == navigationShell.currentIndex,
        ),
      ),
    );
  }
}
