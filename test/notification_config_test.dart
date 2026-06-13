import 'dart:io';

import 'package:boardmate/core/utils/device_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Release checklist encoded as fast static tests — no Firebase device needed.
void main() {
  group('notification release config', () {
    test('android manifest channel id matches notification service', () {
      final manifest = File('android/app/src/main/AndroidManifest.xml')
          .readAsStringSync();
      expect(
        manifest.contains('android:value="boardmate_default"'),
        isTrue,
        reason: 'FCM default channel must match NotificationService channel id',
      );
    });

    test('android manifest declares POST_NOTIFICATIONS permission', () {
      final manifest = File('android/app/src/main/AndroidManifest.xml')
          .readAsStringSync();
      expect(
        manifest.contains('android.permission.POST_NOTIFICATIONS'),
        isTrue,
        reason: 'Android 13+ requires POST_NOTIFICATIONS in the manifest',
      );
    });

    test('ios has remote-notification background mode', () {
      final plist = File('ios/Runner/Info.plist').readAsStringSync();
      expect(plist.contains('remote-notification'), isTrue);
    });

    test('ios release entitlements use production apns environment', () {
      final entitlements =
          File('ios/Runner/RunnerRelease.entitlements').readAsStringSync();
      expect(entitlements.contains('<string>production</string>'), isTrue);
    });

    test('ios debug entitlements use development apns environment', () {
      final entitlements =
          File('ios/Runner/Runner.entitlements').readAsStringSync();
      expect(entitlements.contains('<string>development</string>'), isTrue);
    });

    test('device layout uses phone design dimensions', () {
      expect(DeviceLayout.phoneWidth, 393.0);
      expect(DeviceLayout.phoneHeight, 852.0);
    });
  });
}
