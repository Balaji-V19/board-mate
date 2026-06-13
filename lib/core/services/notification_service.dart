import 'dart:async';
import 'dart:io' show Platform;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/constants/api_constants.dart';

/// Top-level FCM background handler.
///
/// Must be a top-level (not closure) function and annotated with
/// `@pragma('vm:entry-point')` so the Dart background isolate can find it.
/// Runs in a fresh isolate when a message arrives while the app is
/// terminated or backgrounded — keep the work minimal.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // We intentionally don't show our own notification here — Firebase already
  // displays the `notification:` payload natively when the app isn't in the
  // foreground. Use this hook only for silent / data-only messages if you
  // later need to do background work.
  if (kDebugMode) {
    debugPrint('[FCM bg] ${message.messageId}: ${message.data}');
  }
}

/// Centralized notification plumbing.
///
/// One instance lives for the lifetime of the app. Initialize once from
/// `main()` after `Firebase.initializeApp` has resolved.
///
/// Responsibilities:
///   - Initialize `firebase_messaging` and `flutter_local_notifications`.
///   - Request notification permission at the right moment.
///   - Track the device's FCM token and persist it under
///     `users/{uid}/fcmTokens/{tokenId}` whenever a user is signed in.
///   - Bridge foreground FCM messages into a system-tray banner via
///     `flutter_local_notifications`.
///   - Surface tap-to-open events so the app can deep-link.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  static const _androidChannel = AndroidNotificationChannel(
    'boardmate_default',
    'BoardMate notifications',
    description: 'Reminders, new games, and updates from BoardMate.',
    importance: Importance.high,
  );

  static const _iosPushChannel = MethodChannel('boardmate/ios_push');

  static const _deviceIdPrefsKey = 'bm_device_id_v1';

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  String? _cachedToken;
  StreamSubscription<String>? _tokenRefreshSub;
  StreamSubscription<User?>? _authSub;
  StreamSubscription<RemoteMessage>? _foregroundSub;
  StreamSubscription<RemoteMessage>? _openedSub;

  /// Set by the router once it's available so taps on notifications can
  /// navigate. Wired in `main.dart` after the router is constructed.
  GoRouter? _router;

  /// One-time initialization. Safe to call multiple times — subsequent
  /// calls return immediately.
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    try {
      // ── 1. Background handler must be registered before any messages
      //       can arrive while the app is suspended.
      FirebaseMessaging.onBackgroundMessage(
        firebaseMessagingBackgroundHandler,
      );

      // ── 2. Local notifications plugin (used to display foreground FCM
      //       messages on iOS, and as a tap handler on Android).
      await _local.initialize(
        InitializationSettings(
          android: const AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: const DarwinInitializationSettings(
            // Permission is requested separately in `requestPermission()`
            // so the OS prompt fires at the moment we choose, not on app
            // launch.
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          ),
        ),
        onDidReceiveNotificationResponse: (resp) {
          _handlePayloadTap(resp.payload);
        },
      );

      // Android: create the notification channel up front so FCM messages
      // arriving while the app is killed land in the right importance tier.
      await _local
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_androidChannel);

      // ── 3. Wire up message + token + auth listeners.
      _foregroundSub =
          FirebaseMessaging.onMessage.listen(_showForegroundNotification);
      _openedSub = FirebaseMessaging.onMessageOpenedApp
          .listen(_handleNotificationOpen);
      _tokenRefreshSub = _fcm.onTokenRefresh.listen(_onTokenChanged);
      _authSub = FirebaseAuth.instance.authStateChanges().listen(_onAuthChanged);

      // ── 4. If the app was launched from a tapped notification, route
      //       to it after the first frame so GoRouter is ready.
      final initialMessage = await _fcm.getInitialMessage();
      if (initialMessage != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _handleNotificationOpen(initialMessage);
        });
      }
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('NotificationService.init failed: $e\n$st');
      }
    }
  }

  static const _notificationsEnabledPrefsKey = 'notifications_enabled_v1';

  /// Called once from `main()` — initializes listeners and re-registers the
  /// device token when the user already opted in to notifications.
  Future<void> bootstrap() async {
    await init();
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool(_notificationsEnabledPrefsKey) ?? true;
    if (enabled) {
      await syncIfEnabled(true);
    }
  }

  /// Lets the app pass the GoRouter in once it's constructed so tap-to-open
  /// can navigate. Idempotent.
  void attachRouter(GoRouter router) {
    _router = router;
  }

  /// Prompt the system permission and start collecting the FCM token. Call
  /// this once after sign-in (or earlier if you'd rather ask up front).
  Future<bool> requestPermission() async {
    try {
      if (Platform.isAndroid) {
        final android = _local
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();
        final granted =
            await android?.requestNotificationsPermission() ?? true;
        if (granted) {
          await _refreshToken();
        }
        return granted;
      }

      final settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      final granted =
          settings.authorizationStatus == AuthorizationStatus.authorized ||
              settings.authorizationStatus == AuthorizationStatus.provisional;
      if (granted) {
        await _refreshToken();
      }
      return granted;
    } catch (e) {
      if (kDebugMode) debugPrint('requestPermission failed: $e');
      return false;
    }
  }

  Future<bool> _hasNotificationPermission() async {
    if (Platform.isAndroid) {
      final android = _local
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      return await android?.areNotificationsEnabled() ?? true;
    }

    final settings = await _fcm.getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  /// On iOS, FCM refuses to return a token until APNs has delivered a device
  /// token. That callback is async, so poll briefly instead of failing on the
  /// first `getToken()` call.
  Future<String?> _waitForApnsToken({
    Duration timeout = const Duration(seconds: 15),
    Duration interval = const Duration(milliseconds: 500),
  }) async {
    if (!Platform.isIOS) return null;

    final deadline = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(deadline)) {
      final apnsToken = await _fcm.getAPNSToken();
      if (apnsToken != null) return apnsToken;
      await Future<void>.delayed(interval);
    }
    return null;
  }

  Future<void> _refreshToken() async {
    try {
      if (!await _hasNotificationPermission()) return;

      if (Platform.isIOS) {
        // Info.plist disables FCM auto-init; opt in once the user has granted
        // permission so token registration can proceed.
        await _fcm.setAutoInitEnabled(true);
        await _registerForRemoteNotifications();

        final apnsToken = await _waitForApnsToken();
        if (apnsToken == null) {
          if (kDebugMode) {
            debugPrint(
              'APNs token not ready yet — FCM token will arrive via '
              'onTokenRefresh when APNs registration completes.',
            );
          }
          return;
        }
      }

      final token = await _fcm.getToken();
      _cachedToken = token;
      if (token != null) {
        await _persistToken(token);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('refreshToken failed: $e');
    }
  }

  Future<void> _registerForRemoteNotifications() async {
    if (!Platform.isIOS) return;
    try {
      await _iosPushChannel.invokeMethod<void>('registerForRemoteNotifications');
    } catch (e) {
      if (kDebugMode) {
        debugPrint('registerForRemoteNotifications failed: $e');
      }
    }
  }

  Future<void> _onTokenChanged(String token) async {
    _cachedToken = token;
    await _persistToken(token);
  }

  Future<void> _onAuthChanged(User? user) async {
    if (user == null) return;
    if (!await _hasNotificationPermission()) return;
    if (_cachedToken == null) {
      await _refreshToken();
    } else {
      await _persistToken(_cachedToken!);
    }
  }

  /// Stores the device's FCM token under `users/{uid}/fcmTokens/{token}`.
  Future<void> _persistToken(String token) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final deviceId = await _deviceId();
      await FirebaseFirestore.instance
          .collection(FirestoreCollections.users)
          .doc(user.uid)
          .collection(FirestoreCollections.fcmTokens)
          .doc(token)
          .set(<String, dynamic>{
        'token': token,
        'deviceId': deviceId,
        'platform': Platform.isIOS ? 'ios' : 'android',
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      if (kDebugMode) debugPrint('persistToken failed: $e');
    }
  }

  Future<String> _deviceId() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_deviceIdPrefsKey);
    if (existing != null && existing.isNotEmpty) return existing;

    final generated =
        '${Platform.operatingSystem}_${DateTime.now().millisecondsSinceEpoch}';
    await prefs.setString(_deviceIdPrefsKey, generated);
    return generated;
  }

  /// Remove the device's FCM token from Firestore. Call from the sign-out
  /// flow so the previous account stops receiving pushes on this device.
  Future<void> removeCurrentDeviceToken() async {
    final user = FirebaseAuth.instance.currentUser;
    final token = _cachedToken;
    if (user == null || token == null) return;
    try {
      await FirebaseFirestore.instance
          .collection(FirestoreCollections.users)
          .doc(user.uid)
          .collection(FirestoreCollections.fcmTokens)
          .doc(token)
          .delete();
    } catch (e) {
      if (kDebugMode) debugPrint('removeCurrentDeviceToken failed: $e');
    }
  }

  /// Re-register this device's token if notifications are enabled. Safe to
  /// call on every cold start after preferences have loaded.
  Future<void> syncIfEnabled(bool enabled) async {
    if (!enabled) return;
    if (!await _hasNotificationPermission()) {
      await requestPermission();
      return;
    }
    await _refreshToken();
  }

  /// Drive the in-app subscription toggle. When `false`, the device's FCM
  /// token is deleted both locally and from Firestore, so the server stops
  /// targeting it. When `true`, permission is re-requested and the token
  /// is re-registered.
  Future<void> setSubscribed(bool subscribed) async {
    if (subscribed) {
      await requestPermission();
    } else {
      await removeCurrentDeviceToken();
      try {
        await _fcm.deleteToken();
      } catch (_) {}
      _cachedToken = null;
    }
  }

  void _showForegroundNotification(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    final payload = message.data.isEmpty
        ? null
        : message.data.entries.map((e) => '${e.key}=${e.value}').join('&');

    _local.show(
      message.messageId.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          channelDescription: _androidChannel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: payload,
    );
  }

  void _handleNotificationOpen(RemoteMessage message) {
    final path = message.data['route'];
    if (path is String && path.isNotEmpty) {
      _router?.go(path);
    }
  }

  void _handlePayloadTap(String? payload) {
    if (payload == null || payload.isEmpty) return;
    final parts = payload.split('&');
    for (final p in parts) {
      final i = p.indexOf('=');
      if (i <= 0) continue;
      final key = p.substring(0, i);
      final value = p.substring(i + 1);
      if (key == 'route' && value.isNotEmpty) {
        _router?.go(value);
        return;
      }
    }
  }

  Future<void> dispose() async {
    await _foregroundSub?.cancel();
    await _openedSub?.cancel();
    await _tokenRefreshSub?.cancel();
    await _authSub?.cancel();
  }
}
