import 'package:flutter/material.dart';
import '../theme/theme_controller.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const Divider(),
          _SectionTitle('Appearance'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ValueListenableBuilder<bool>(
              valueListenable: ThemeController.instance.grandmaMode,
              builder: (context, grandmaMode, _) {
                return SwitchListTile(
                  value: grandmaMode,
                  onChanged: (val) => ThemeController.instance.setGrandmaMode(val),
                  title: const Text(
                    'GRANDMA MODE',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  secondary: Icon(
                    grandmaMode ? Icons.visibility : Icons.visibility_outlined,
                    size: Theme.of(context).iconTheme.size! * 1.3,
                  ),
                );
              },
            ),
          ),
          const Divider(),
          _SectionTitle('Theme'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ValueListenableBuilder<ThemeMode>(
              valueListenable: ThemeController.instance.mode,
              builder: (context, mode, _) {
                final segments = <ButtonSegment<ThemeMode>>[
                  const ButtonSegment(value: ThemeMode.system, label: Text('System'), icon: Icon(Icons.settings_suggest)),
                  const ButtonSegment(value: ThemeMode.light, label: Text('Light'), icon: Icon(Icons.light_mode)),
                  const ButtonSegment(value: ThemeMode.dark, label: Text('Dark'), icon: Icon(Icons.dark_mode)),
                ];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SegmentedButton<ThemeMode>(
                      segments: segments,
                      selected: {mode},
                      showSelectedIcon: false,
                      onSelectionChanged: (selection) {
                        if (selection.isNotEmpty) {
                          ThemeController.instance.setMode(selection.first);
                        }
                      },
                    ),
                  ],
                );
              },
            ),
          ),
          const Divider(),
          _SectionTitle('Dashboard'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ValueListenableBuilder<int>(
                  valueListenable: ThemeController.instance.dashboardChartLimit,
                  builder: (context, limit, _) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Historical Chart Window'),
                          subtitle: Text('Show the last $limit day(s) in dashboard charts'),
                        ),
                        Slider(
                          min: 3,
                          max: 30,
                          divisions: 27,
                          label: '$limit days',
                          value: limit.toDouble(),
                          onChanged: (value) => ThemeController.instance.setDashboardChartLimit(value.round()),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 8),
                ValueListenableBuilder<int>(
                  valueListenable: ThemeController.instance.chartTripsTarget,
                  builder: (context, target, _) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Daily Trips Minimum Target'),
                          subtitle: Text('Highlight when trips drop below $target per day'),
                        ),
                        Slider(
                          min: 5,
                          max: 30,
                          divisions: 25,
                          label: '$target trips',
                          value: target.toDouble(),
                          onChanged: (value) => ThemeController.instance.setChartTripsTarget(value.round()),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 8),
                ValueListenableBuilder<int>(
                  valueListenable: ThemeController.instance.chartProfitTarget,
                  builder: (context, target, _) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Daily Profit Minimum Target'),
                          subtitle: Text('Target at least \$${target.toStringAsFixed(0)} per day'),
                        ),
                        Slider(
                          min: 100,
                          max: 2000,
                          divisions: 38,
                          label: '\$$target',
                          value: target.toDouble(),
                          onChanged: (value) => ThemeController.instance.setChartProfitTarget(value.round()),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 8),
                ValueListenableBuilder<int>(
                  valueListenable: ThemeController.instance.normalTripSuccessPercent,
                  builder: (context, percent, _) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Normal Success Threshold'),
                          subtitle: Text('Flag deliveries below $percent% success rate'),
                        ),
                        Slider(
                          min: 30,
                          max: 100,
                          divisions: 14,
                          label: '$percent%',
                          value: percent.toDouble(),
                          onChanged: (value) => ThemeController.instance.setNormalTripSuccessPercent(value.round().clamp(30, 100)),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          const Divider(),
          _SectionTitle('Account'),
          const _Tile('Logout'),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        child: Text(text, style: Theme.of(context).textTheme.titleMedium),
      );
}

class _Tile extends StatelessWidget {
  final String text;
  const _Tile(this.text);

  @override
  Widget build(BuildContext context) => ListTile(
        title: Text(text),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {},
      );
}
