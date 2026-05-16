import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'config/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'dependency_injection.dart';
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
  runApp(const ProviderScope(child: BoardMateApp()));
}

class BoardMateApp extends ConsumerWidget {
  const BoardMateApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ScreenUtilInit(
      designSize: const Size(393, 852),
      minTextAdapt: true,
      builder: (_, __) {
        final router = ref.watch(routerProvider);
        return MaterialApp.router(
          title: 'BoardMate',
          theme: AppTheme.light,
          routerConfig: router,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
