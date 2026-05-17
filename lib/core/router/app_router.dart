import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/sign_in_page.dart';
import '../../features/auth/presentation/providers/auth_notifier.dart';
import '../../features/browse/presentation/pages/browse_page.dart';
import '../../features/browse/presentation/pages/category_results_page.dart';
import '../../features/games/presentation/pages/game_detail_page.dart';
import '../../features/guides/presentation/pages/how_to_play_page.dart';
import '../../features/guides/presentation/pages/learn_mode_page.dart';
import '../../features/guides/presentation/pages/quick_reference_page.dart';
import '../../features/guides/presentation/pages/setup_guide_page.dart';
import '../../features/guides/presentation/pages/turn_flow_page.dart';
import '../../features/requests/presentation/pages/request_game_page.dart';
import '../../features/settings/presentation/pages/credits_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/onboarding/presentation/pages/splash_page.dart';
import '../../features/saved_games/presentation/pages/saved_games_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../widgets/main_scaffold.dart';

final _rootKey = GlobalKey<NavigatorState>();
final _shellHomeKey = GlobalKey<NavigatorState>();
final _shellBrowseKey = GlobalKey<NavigatorState>();
final _shellSavedKey = GlobalKey<NavigatorState>();
final _shellSettingsKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authNotifierProvider);

  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/splash',
    refreshListenable: auth,
    redirect: (context, state) {
      final loc = state.matchedLocation;
      final publicRoutes = {'/splash', '/onboarding', '/sign-in'};
      if (publicRoutes.contains(loc)) return null;
      if (!auth.isAuthenticated) return '/sign-in';
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (_, __) => const SplashPage(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (_, __) => const OnboardingPage(),
      ),
      GoRoute(
        path: '/sign-in',
        builder: (_, __) => const SignInPage(),
      ),
      GoRoute(
        path: '/category/:category',
        parentNavigatorKey: _rootKey,
        builder: (_, st) => CategoryResultsPage(
          category: st.pathParameters['category']!,
        ),
      ),
      GoRoute(
        path: '/request-game',
        parentNavigatorKey: _rootKey,
        builder: (_, __) => const RequestGamePage(),
      ),
      GoRoute(
        path: '/credits',
        parentNavigatorKey: _rootKey,
        builder: (_, __) => const CreditsPage(),
      ),
      GoRoute(
        path: '/game/:gameId',
        parentNavigatorKey: _rootKey,
        builder: (_, st) =>
            GameDetailPage(gameId: st.pathParameters['gameId']!),
        routes: [
          GoRoute(
            path: 'learn',
            parentNavigatorKey: _rootKey,
            builder: (_, st) =>
                LearnModePage(gameId: st.pathParameters['gameId']!),
          ),
          GoRoute(
            path: 'setup',
            parentNavigatorKey: _rootKey,
            builder: (_, st) =>
                SetupGuidePage(gameId: st.pathParameters['gameId']!),
          ),
          GoRoute(
            path: 'how-to-play',
            parentNavigatorKey: _rootKey,
            builder: (_, st) =>
                HowToPlayPage(gameId: st.pathParameters['gameId']!),
          ),
          GoRoute(
            path: 'turn-flow',
            parentNavigatorKey: _rootKey,
            builder: (_, st) =>
                TurnFlowPage(gameId: st.pathParameters['gameId']!),
          ),
          GoRoute(
            path: 'quick-reference',
            parentNavigatorKey: _rootKey,
            builder: (_, st) =>
                QuickReferencePage(gameId: st.pathParameters['gameId']!),
          ),
        ],
      ),
      StatefulShellRoute.indexedStack(
        builder: (_, __, shell) => MainScaffold(navigationShell: shell),
        branches: [
          StatefulShellBranch(
            navigatorKey: _shellHomeKey,
            routes: [
              GoRoute(
                path: '/home',
                builder: (_, __) => const HomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellBrowseKey,
            routes: [
              GoRoute(
                path: '/browse',
                builder: (_, st) => BrowsePage(
                  initialCategory: st.uri.queryParameters['category'],
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellSavedKey,
            routes: [
              GoRoute(
                path: '/saved',
                builder: (_, __) => const SavedGamesPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellSettingsKey,
            routes: [
              GoRoute(
                path: '/settings',
                builder: (_, __) => const SettingsPage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
