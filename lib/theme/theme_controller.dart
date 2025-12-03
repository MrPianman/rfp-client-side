import 'package:flutter/material.dart';

class ThemeController {
  ThemeController._();
  static final ThemeController instance = ThemeController._();

  final ValueNotifier<ThemeMode> mode = ValueNotifier(ThemeMode.system);
  final ValueNotifier<bool> grandmaMode = ValueNotifier(false);
  final ValueNotifier<int> dashboardChartLimit = ValueNotifier(7);
  final ValueNotifier<int> chartTripsTarget = ValueNotifier(10);
  final ValueNotifier<int> chartProfitTarget = ValueNotifier(500);
  final ValueNotifier<int> normalTripSuccessPercent = ValueNotifier(60);

  void setMode(ThemeMode newMode) {
    if (mode.value != newMode) mode.value = newMode;
  }

  void setGrandmaMode(bool enabled) {
    if (grandmaMode.value != enabled) grandmaMode.value = enabled;
  }

  void setDashboardChartLimit(int days) {
    if (dashboardChartLimit.value != days) {
      dashboardChartLimit.value = days;
    }
  }

  void setChartTripsTarget(int value) {
    if (chartTripsTarget.value != value) {
      chartTripsTarget.value = value;
    }
  }

  void setChartProfitTarget(int value) {
    if (chartProfitTarget.value != value) {
      chartProfitTarget.value = value;
    }
  }

  void setNormalTripSuccessPercent(int value) {
    final clamped = value.clamp(10, 100);
    if (normalTripSuccessPercent.value != clamped) {
      normalTripSuccessPercent.value = clamped;
    }
  }
}
