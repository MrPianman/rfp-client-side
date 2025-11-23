import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme/app_theme.dart';
import 'pages/dashboard_page.dart';
import 'pages/live_map_page.dart';
import 'pages/alerts_page.dart';
import 'pages/reports_page.dart';
import 'pages/settings_page.dart';
import 'pages/fleet_management_page.dart';
import 'theme/theme_controller.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.instance.mode,
      builder: (context, mode, _) {
        return ValueListenableBuilder<bool>(
          valueListenable: ThemeController.instance.grandmaMode,
          builder: (context, grandmaMode, _) {
            return MaterialApp(
              title: 'RFP',
              themeMode: mode,
              theme: AppTheme.light(grandmaMode: grandmaMode),
              darkTheme: AppTheme.dark(grandmaMode: grandmaMode),
              home: const RootShell(),
            );
          },
        );
      },
    );
  }
}

class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _currentIndex = 0;

  void _navigateToPage(int index) {
    setState(() => _currentIndex = index);
  }

  final _titles = const [
    'Dashboard',
    'Live Map',
    'Reports',
    'Alerts',
    'Fleet Management',
  ];

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
          if (_currentIndex == 1) // Live Map filter placeholder
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
          DashboardPage(onNavigateToAlerts: () => _navigateToPage(3)),
          const LiveMapPage(),
          const ReportsPage(),
          const AlertsPage(),
          const FleetManagementPage(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        height: 72,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
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
            icon: Icon(Icons.notifications_outlined, size: 28),
            selectedIcon: Icon(Icons.notifications, size: 28),
            label: 'Alerts',
          ),
          NavigationDestination(
            icon: Icon(Icons.business_center_outlined, size: 28),
            selectedIcon: Icon(Icons.business_center, size: 28),
            label: 'Fleet',
          ),
        ],
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}
