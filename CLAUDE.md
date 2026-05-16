# BoardMate — AI / contributor guide

**BoardMate** is a Flutter app that helps users learn how to play **physical board games**. It does **not** let users play board games digitally inside the app. Instead, it provides structured setup guides, step-by-step instructions, quick rule references, scoring help, common mistakes, and missing-game requests.

This document describes how the codebase should be organized, what conventions to follow, and how AI/code contributors should make changes safely and consistently.

---

## Product direction

BoardMate should feel like a **board game learning companion**, not a digital board game platform.

Core user promise:

> “I have a physical board game in front of me. Help me set it up, understand the rules, and quickly check rules while playing.”

### Product rules

- Do **not** build digital gameplay screens where users play the board game inside the app.
- Focus on learning, setup, rules, scoring, quick references, and table-side guidance.
- Keep instructions short, scannable, and beginner-friendly.
- Avoid long manual-style paragraphs.
- Use structured content: objective, components, setup, turn flow, actions, scoring, winning, FAQ, and quick reference.
- Prefer visual, step-by-step explanations over dense text.
- Every game guide should be usable while users are sitting at a real table with friends/family.

### Content and legal safety

- Do not copy official rulebooks word-for-word.
- Write original explanations and simplified summaries.
- Do not use copyrighted board game box art, logos, publisher artwork, rulebook scans, or official assets unless licensed.
- Use royalty-free, CC0, public domain, or properly licensed images only.
- Acceptable image sources include Unsplash, Pexels, Pixabay, or equivalent licensed sources.
- For named games, use generic representative images where official art is not licensed:
  - Chess: chess pieces/photo
  - Card games: generic playing cards
  - Strategy games: generic board tiles, dice, meeples, tokens
  - Party games: friends around a table

---

## Tech stack (authoritative)

Use the same app architecture/configuration style as the existing Flutter project.

| Area | Choice |
|------|--------|
| UI | Flutter with Material 3 via `AppTheme` |
| State | **flutter_riverpod** only |
| DI | **get_it** via `lib/dependency_injection.dart`, accessor `sl` |
| Navigation | **go_router** via `routerProvider` in `lib/core/router/app_router.dart` |
| Immutable UI state | **freezed** using `@freezed` + generated `*.freezed.dart` |
| Domain / errors | **fpdart** (`Either` / `fold` from use cases), **equatable** for domain entities |
| Remote API | **http** + `ApiClient` with Firebase ID token when authenticated |
| Responsive layout | **flutter_screenutil** via `ScreenUtilInit` in `main.dart` |
| Auth | Firebase Auth, optional for MVP unless sync/account features require it |
| Analytics/crash | Follow existing Firebase pattern if added |

Do not introduce another competing state-management, navigation, dependency-injection, or networking framework unless explicitly requested.

---

## Architecture

The app uses **feature-first clean architecture**.

Each feature under `lib/features/<feature>/` should have three layers:

1. **`domain/`**  
   Pure Dart only. Contains entities, repository interfaces, and use cases.  
   No Flutter imports.

2. **`data/`**  
   Contains remote/local data sources, models, DTOs, JSON serialization, and repository implementations.

3. **`presentation/`**  
   Contains pages, widgets, providers, notifiers, and UI state.

Dependency direction:

```text
Presentation
  → Use cases
  → Repository interfaces
  → Repository implementations
  → Data sources
  → ApiClient / Firebase / local cache
```

Cross-cutting code belongs in:

```text
lib/core/
lib/config/
```

Do not place shared utilities inside a random feature unless they are truly feature-specific.

---

## Suggested folder structure

```text
lib/
├── main.dart
├── firebase_options.dart
├── dependency_injection.dart
├── config/
│   ├── constants/
│   │   ├── app_colors.dart
│   │   ├── app_strings.dart
│   │   ├── app_textstyle.dart
│   │   ├── app_spacing.dart
│   │   └── api_constants.dart
│   ├── environment/
│   │   ├── app_config.dart
│   │   ├── debug_config.dart
│   │   └── release_config.dart
│   └── theme/
│       └── app_theme.dart
├── core/
│   ├── error/
│   │   ├── exceptions.dart
│   │   └── failures.dart
│   ├── network/
│   │   └── api_client.dart
│   ├── router/
│   │   └── app_router.dart
│   ├── services/
│   │   ├── image_service.dart
│   │   └── offline_cache_service.dart
│   ├── utils/
│   └── widgets/
│       ├── bm_app_bar.dart
│       ├── bm_bottom_nav.dart
│       ├── bm_button.dart
│       ├── bm_game_card.dart
│       ├── bm_search_bar.dart
│       ├── bm_chip.dart
│       ├── bm_progress_bar.dart
│       ├── bm_checklist_row.dart
│       └── main_scaffold.dart
└── features/
    ├── auth/
    ├── onboarding/
    ├── home/
    ├── browse/
    ├── games/
    ├── guides/
    ├── saved_games/
    ├── offline/
    ├── requests/
    ├── feedback/
    └── settings/
```

Each feature should repeat this structure where needed:

```text
features/<feature>/
├── data/
│   ├── datasources/
│   ├── models/
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
└── presentation/
    ├── pages/
    ├── widgets/
    └── providers/
```

---

## Feature ownership

### `auth/`

Handles optional sign-in, auth stream, user session, and account sync.

MVP should not require login unless needed for:
- syncing saved games
- submitting feedback
- tracking user requests
- premium/offline features

### `onboarding/`

Contains splash and onboarding screens.

Screens:
- Splash
- Onboarding 1: learn games without long manuals
- Onboarding 2: setup the board step by step
- Onboarding 3: quick rules while playing

### `home/`

Contains discovery experience.

Responsibilities:
- Continue learning
- Popular games
- Browse by category
- Quick picks
- Recently viewed
- Saved shortcuts

### `browse/`

Contains search, filters, and category results.

Responsibilities:
- Search games
- Filter by player count, time, difficulty, category, age
- Sort results
- Empty state with request-missing-game CTA

### `games/`

Contains game detail and game metadata.

Responsibilities:
- Game detail page
- Game stats
- Objective
- Components
- Available learning modes
- Save/download actions

### `guides/`

Contains the actual learning experience.

Responsibilities:
- Learn mode selection
- Setup guide
- How to play guide
- Turn flow
- Scoring and winning
- Common mistakes / FAQ
- Quick reference

### `saved_games/`

Contains saved/favorite games and recently viewed games.

Responsibilities:
- Saved game list
- Offline badges
- Quick open to guide/reference
- Empty state

### `offline/`

Contains offline guide download and cache management.

Responsibilities:
- Download guide data
- Store guide content locally
- Show downloaded status
- Clear offline data
- Handle unavailable offline content gracefully

### `requests/`

Contains missing game requests.

Responsibilities:
- Request missing game form
- Submit request
- Show submitted state
- Prioritize clear input and simple success/error UI

### `feedback/`

Contains wrong rule reports and user feedback.

Responsibilities:
- Report incorrect rule
- Report unclear guide
- Send general feedback

### `settings/`

Contains preferences and support.

Responsibilities:
- Language
- Theme
- Text size
- Downloaded guides
- Clear offline data
- Request a game
- Send feedback
- Privacy/terms/app version

---

## Core data model

Use this as the base shape for domain entities and API contracts. Adjust as implementation needs evolve, but keep the same conceptual structure.

```dart
class BoardGameEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final String objective;
  final List<String> categories;
  final int minPlayers;
  final int maxPlayers;
  final int minMinutes;
  final int maxMinutes;
  final String difficulty;
  final String ageRange;
  final String imageUrl;
  final bool isSaved;
  final bool isDownloaded;
}
```

Guide content should be structured, not stored as one large article.

```dart
class GameGuideEntity extends Equatable {
  final String gameId;
  final List<ComponentEntity> components;
  final List<GuideStepEntity> setupSteps;
  final List<GuideStepEntity> howToPlaySteps;
  final List<TurnFlowStepEntity> turnFlow;
  final ScoringGuideEntity scoring;
  final List<FaqEntity> faq;
  final QuickReferenceEntity quickReference;
}
```

Recommended guide sections:

```text
Game
 ├── Objective
 ├── Components
 ├── Setup Steps
 ├── Turn Flow
 ├── Player Actions
 ├── Special Rules
 ├── Scoring
 ├── Game End
 ├── Tie Breaker
 ├── Common Mistakes
 ├── FAQ
 └── Quick Reference
```

---

## State management (strict)

### Single stack: Riverpod only

- All app and feature state must go through `flutter_riverpod`.
- Use `ChangeNotifierProvider`, `Provider`, `FutureProvider`, or related Riverpod primitives.
- `ChangeNotifier` is allowed only as the notifier implementation and must be exposed through Riverpod.
- Do not introduce Bloc/Cubit, GetX, MobX, Redux, Signals, or the separate `provider` package for app state.
- Do not rely on ad-hoc `setState` for shared or cross-screen feature state.

### Notifier pattern

Follow this pattern:

```dart
class GamesNotifier extends ChangeNotifier {
  GamesState _state = const GamesState.initial();

  GamesState get state => _state;

  void _setState(GamesState newState) {
    _state = newState;
    notifyListeners();
  }
}
```

Use `freezed` for UI state:

```dart
@freezed
class GamesState with _$GamesState {
  const factory GamesState.initial() = _Initial;
  const factory GamesState.loading() = _Loading;
  const factory GamesState.loaded(List<BoardGameEntity> games) = _Loaded;
  const factory GamesState.error(String message) = _Error;
}
```

Provider example:

```dart
final gamesNotifierProvider =
    ChangeNotifierProvider<GamesNotifier>((ref) {
  return sl<GamesNotifier>();
});
```

### If new state is needed

1. Add or extend a `*State` using `freezed`.
2. Add or update a `*Notifier`.
3. Expose it through Riverpod.
4. Resolve use cases through `sl<YourUseCase>()`.
5. Register notifier/use case/repository/data source in `dependency_injection.dart`.

---

## Navigation

Use only `go_router`.

- `lib/core/router/app_router.dart` owns `routerProvider`.
- Use a centralized route table.
- Main tabs should use `StatefulShellRoute.indexedStack` with `MainScaffold`.
- Auth redirects should depend on `authNotifierProvider` / `AuthState`.
- Do not create separate nested routers unless required by `go_router`.

Suggested route names:

```text
/splash
/onboarding
/home
/browse
/category/:categoryId
/game/:gameId
/game/:gameId/learn
/game/:gameId/setup
/game/:gameId/how-to-play
/game/:gameId/turn-flow
/game/:gameId/quick-reference
/saved
/settings
/request-game
/feedback
```

Main tab shell:

```text
Home | Browse | Saved | Settings
```

---

## UI and design system

Use the BoardMate palette consistently.

### Colors

```dart
static const primaryGold = Color(0xFFB8860B);
static const secondaryNavy = Color(0xFF0F172A);
static const tertiaryIvory = Color(0xFFFFFFF0);
static const background = Color(0xFFFFFFF0);
static const surfaceDefault = Color(0xFFFFFFFF);
static const success = Color(0xFF15803D);
static const warning = Color(0xFFCA8A04);
static const error = Color(0xFFDC2626);
static const info = Color(0xFF0369A1);
```

Usage:

- `Primary Gold #B8860B`: primary actions, active states, progress bars, selected chips, accent lines.
- `Secondary Navy #0F172A`: headings, strong text, primary icons.
- `Tertiary Ivory #FFFFF0`: app background and subtle fills.
- `Surface Default #FFFFFF`: cards, input fields, bottom nav, list rows.
- `Success #15803D`: completed checklist, saved/downloaded success states.
- `Warning #CA8A04`: reminders, tips, caution states.
- `Error #DC2626`: destructive actions and errors.
- `Info #0369A1`: helper notes and informational states.

For opacity-based neutrals, prefer `secondaryNavy.withOpacity(...)`.

### Typography

Use `AppTextStyle` or theme text styles. Keep hierarchy consistent:

```text
Large page title: 30 px, bold, line height 38
Screen title: 26 px, bold, line height 34
Section title: 20 px, semibold, line height 28
Card title: 17 px, semibold, line height 24
Body text: 15 px, regular, line height 23
Helper text: 13 px, regular, line height 18
Label text: 12 px, semibold, uppercase where useful
Button text: 16 px, semibold
```

### Spacing

Use an 8-point spacing system where possible.

```text
Screen horizontal padding: 20 px
Card padding: 16 px or 20 px
Section spacing: 28 px
Card gap: 12–16 px
Title/subtitle gap: 6–8 px
Button height: 52 px
Search bar height: 50 px
Filter chip height: 36 px
Bottom nav height: 76 px
Card radius: 20–24 px
Button radius: 16 px
Icon button: 40–44 px
```

### UI rules

- No unintentional element overlap.
- Never let bottom navigation cover scrollable content.
- Add at least 100–110 px bottom padding to scrollable tab screens.
- Keep all touch targets at least 44 px high/wide where possible.
- Use short text and scannable layouts.
- Prefer cards, checklists, chips, accordions, and progress indicators.
- Use native icons:
  - Flutter Material Symbols / Material Icons
  - iOS-style SF Symbol equivalents when appropriate
- Keep icon style consistent: rounded, simple, mostly outline.

### Shared widget naming

Use `Bm` / `bm_` prefix for shared BoardMate widgets:

```text
BmButton
BmSearchBar
BmGameCard
BmCategoryCard
BmProgressBar
BmChecklistRow
BmAccordion
BmBottomNav
BmInfoBox
BmBadge
```

Do not duplicate shared UI patterns inside feature widgets if a reusable core widget already exists.

---

## MVP screens

The MVP should include these screens:

1. Splash Screen
2. Onboarding Screens
3. Home Screen
4. Browse/Search Screen
5. Category Results Screen
6. Game Detail Screen
7. Learn Mode Selection Screen
8. Setup Guide Screen
9. How to Play Guide Screen
10. Turn Flow Screen
11. Quick Reference Screen
12. Saved Games Screen
13. Settings Screen
14. Request Missing Game Screen

### Most important MVP screens

Prioritize quality on:

```text
Home
Browse/Search
Game Detail
Setup Guide
How to Play Guide
Quick Reference
```

These screens define whether the app feels useful.

---

## Networking and Firebase

### ApiClient

Use `ApiClient` for backend HTTP calls.

- Attach `Authorization: Bearer <idToken>` when `FirebaseAuth.currentUser` exists.
- Handle unauthenticated requests when endpoints are public.
- Convert API errors to typed failures.
- Do not call `http` directly from presentation or use cases.

### Environment

Use `AppConfig` for environment-specific settings:

```text
debug baseUrl
release baseUrl
feature flags if needed
```

Register config in `initializeDependencies()`.

### Suggested API domains

Exact endpoints can vary, but keep responsibilities clear:

```text
GET    /games
GET    /games/:id
GET    /games/:id/guide
GET    /games/:id/quick-reference
POST   /game-requests
POST   /feedback
POST   /reports/wrong-rule
```

If saved games are synced:

```text
GET    /users/me/saved-games
POST   /users/me/saved-games/:gameId
DELETE /users/me/saved-games/:gameId
```

If offline data uses a manifest:

```text
GET /games/:id/offline-manifest
```

---

## Error handling

Use `Failure` classes from `core/error`.

Common failures:

```text
NetworkFailure
ServerFailure
AuthFailure
NotFoundFailure
ValidationFailure
CacheFailure
UnknownFailure
```

Use cases should return:

```dart
Future<Either<Failure, T>>
```

Presentation notifiers should `fold` results into UI state:

```dart
result.fold(
  (failure) => _setState(GamesState.error(failure.message)),
  (data) => _setState(GamesState.loaded(data)),
);
```

Never throw raw exceptions into UI code.

---

## Dependency injection

All services, data sources, repositories, use cases, and notifiers should be registered in:

```text
lib/dependency_injection.dart
```

Prefer `registerLazySingleton` unless there is a clear reason for a different lifecycle.

Example registration shape:

```dart
// Data sources
sl.registerLazySingleton<GamesRemoteDataSource>(
  () => GamesRemoteDataSourceImpl(apiClient: sl()),
);

// Repositories
sl.registerLazySingleton<GamesRepository>(
  () => GamesRepositoryImpl(remoteDataSource: sl()),
);

// Use cases
sl.registerLazySingleton(() => GetGamesUseCase(sl()));
sl.registerLazySingleton(() => GetGameGuideUseCase(sl()));

// Notifiers
sl.registerFactory(() => GamesNotifier(getGamesUseCase: sl()));
```

Keep DI centralized. Do not instantiate repositories/use cases directly in widgets.

---

## Code generation

The project uses `freezed`.

After changing any `@freezed` state/model, run:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Use watch mode during active development if helpful:

```bash
dart run build_runner watch --delete-conflicting-outputs
```

Do not manually edit generated `*.freezed.dart` files.

---

## Code quality and consistency

1. Use `flutter_lints` and keep `flutter analyze` clean.
2. Do not introduce unused dependencies.
3. Do not add a second state-management solution.
4. Do not add a second router.
5. Do not bypass `ApiClient`.
6. Do not hardcode colors if `AppColors` exists.
7. Do not hardcode repeated strings if `AppStrings` exists.
8. Do not use official copyrighted game images unless licensed.
9. Do not copy full official manuals/rulebooks.
10. Do not perform large drive-by refactors.
11. Change only what the task requires.
12. Match naming, formatting, imports, and abstraction level of nearby files.
13. Keep domain layer Flutter-free.
14. Keep presentation logic in notifiers, not widgets.
15. Keep widgets small and reusable.

---

## Quick reference commands

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
```

For iOS simulator builds, use project-specific schemes when available.

---

## Agent checklist before making changes

Before implementing:

- Confirm the feature belongs to the correct module.
- Check whether a shared widget already exists.
- Check whether a use case/repository already exists.
- Check whether the route already exists in `app_router.dart`.
- Check whether DI registration is needed.
- Check whether `freezed` regeneration is needed.
- Check whether the screen needs bottom padding for bottom navigation.
- Check whether images/assets are licensed correctly.

After implementing:

- Run code generation if needed.
- Run `flutter analyze`.
- Run relevant tests.
- Verify navigation path.
- Verify loading, empty, success, and error states.
- Verify no UI overlap on 393 x 852 mobile size.
- Verify bottom nav does not cover content.

---

## Summary for agents

- **Product:** BoardMate teaches users how to play physical board games; it is not a digital board game platform.
- **Architecture:** Feature-first clean architecture with `data / domain / presentation`.
- **State:** Riverpod only. `ChangeNotifier` is allowed only through `ChangeNotifierProvider`.
- **DI:** get_it via `dependency_injection.dart`.
- **Navigation:** go_router only, centralized in `app_router.dart`.
- **Design:** Warm premium palette using Primary Gold `#B8860B`, Secondary Navy `#0F172A`, Ivory `#FFFFF0`, and white surfaces.
- **Content:** Original simplified guides only. Do not copy copyrighted rulebooks or use unlicensed official board game assets.
- **Quality:** `freezed`, `fpdart`, `equatable`, `flutter_lints`, codegen after state changes, no drive-by refactors.
