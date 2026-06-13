import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'config/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/services/notification_service.dart';
import 'dependency_injection.dart';
import 'features/mascot/presentation/widgets/mascot_host.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (e, st) {
    if (kDebugMode) {
      debugPrint('Firebase init failed: $e\n$st');
    }
  }
  await initializeDependencies();
  unawaited(NotificationService.instance.bootstrap());
  runApp(const ProviderScope(child: BoardMateApp()));
}

class BoardMateApp extends ConsumerWidget {
  const BoardMateApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaQuery = MediaQuery.of(context);
    final size = mediaQuery.size;
    final isTablet = size.shortestSide >= 600;
    final designSize = isTablet ? size : const Size(393, 852);

    return ScreenUtilInit(
      designSize: designSize,
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, __) {
        final router = ref.watch(routerProvider);
        NotificationService.instance.attachRouter(router);
        return MaterialApp.router(
          title: 'BoardMate',
          theme: AppTheme.light,
          routerConfig: router,
          debugShowCheckedModeBanner: false,
          builder: (context, child) =>
              MascotHost(child: child ?? const SizedBox.shrink()),
        );
      },
    );
  }
}
