import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/services/notification_service.dart';

/// Tracks whether the user wants to receive push notifications on this
/// device. Persists across launches via [SharedPreferences] and toggles the
/// FCM token registration through [NotificationService] when the user flips
/// the Settings switch.
class NotificationPreferenceNotifier extends ChangeNotifier {
  NotificationPreferenceNotifier() {
    _load();
  }

  static const _prefsKey = 'notifications_enabled_v1';

  bool _enabled = true;
  bool _loaded = false;

  bool get enabled => _enabled;
  bool get loaded => _loaded;

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _enabled = prefs.getBool(_prefsKey) ?? true;
    } catch (e) {
      if (kDebugMode) debugPrint('NotificationPref load failed: $e');
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> setEnabled(bool value) async {
    if (value == _enabled) return;
    _enabled = value;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefsKey, value);
    } catch (e) {
      if (kDebugMode) debugPrint('NotificationPref save failed: $e');
    }
    await NotificationService.instance.setSubscribed(value);
  }
}

final notificationPreferenceProvider =
    ChangeNotifierProvider<NotificationPreferenceNotifier>(
  (ref) => NotificationPreferenceNotifier(),
);
