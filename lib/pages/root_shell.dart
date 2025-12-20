import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dashboard_page.dart';
import 'live_map_page.dart';
import 'alerts_page.dart';
import 'reports_page.dart';
import 'settings_page.dart';
import 'fleet_management_page.dart';

class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _currentIndex = 0;

  static const _titles = [
    'Dashboard',
    'Live Map',
    'Reports',
    'Fleet Management',
    'Alerts',
  ];

  static const _destinations = <NavigationDestination>[
    NavigationDestination(
      icon: Icon(Icons.dashboard_outlined, size: 28),
      selectedIcon: Icon(Icons.dashboard, size: 28),
      label: 'Dashboard',
    ),
    NavigationDestination(
      icon: Icon(Icons.map_outlined, size: 28),
      selectedIcon: Icon(Icons.map, size: 28),
      label: 'Live Map',
    ),
    NavigationDestination(
      icon: Icon(Icons.insights_outlined, size: 28),
      selectedIcon: Icon(Icons.insights, size: 28),
      label: 'Reports',
    ),
    NavigationDestination(
      icon: Icon(Icons.business_center_outlined, size: 28),
      selectedIcon: Icon(Icons.business_center, size: 28),
      label: 'Fleet',
    ),
    NavigationDestination(
      icon: Icon(Icons.notifications_outlined, size: 28),
      selectedIcon: Icon(Icons.notifications, size: 28),
      label: 'Alerts',
    ),
  ];

  void _navigateToPage(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _titles[_currentIndex],
          style: GoogleFonts.baiJamjuree(fontSize: 22, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
            icon: const Icon(Icons.settings),
            iconSize: 28,
            tooltip: 'Settings',
          ),
          if (_currentIndex == 1)
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.filter_list),
              iconSize: 28,
              tooltip: 'Filter',
            )
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          DashboardPage(onNavigateToAlerts: () => _navigateToPage(4)),
          const LiveMapPage(),
          const ReportsPage(),
          const FleetManagementPage(),
          const AlertsPage(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        height: 72,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: _destinations,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}
