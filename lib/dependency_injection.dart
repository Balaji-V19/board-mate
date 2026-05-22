import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'config/environment/app_config.dart';
import 'config/environment/debug_config.dart';
import 'core/network/api_client.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/delete_account.dart';
import 'features/auth/domain/usecases/sign_in_with_apple.dart';
import 'features/auth/domain/usecases/sign_in_with_google.dart';
import 'features/auth/domain/usecases/sign_out.dart';
import 'features/auth/domain/usecases/watch_auth_state.dart';
import 'features/auth/presentation/providers/auth_notifier.dart';
import 'features/mascot/presentation/providers/mascot_notifier.dart';
import 'features/games/data/datasources/games_firestore_datasource.dart';
import 'features/games/data/datasources/progress_firestore_datasource.dart';
import 'features/games/data/repositories/games_repository_impl.dart';
import 'features/games/data/repositories/progress_repository_impl.dart';
import 'features/games/domain/repositories/games_repository.dart';
import 'features/games/domain/repositories/progress_repository.dart';
import 'features/games/domain/usecases/get_game_by_id.dart';
import 'features/games/domain/usecases/get_game_guide.dart';
import 'features/games/domain/usecases/get_games.dart';
import 'features/games/domain/usecases/search_games.dart';
import 'features/games/presentation/providers/games_notifier.dart';
import 'features/games/presentation/providers/progress_notifier.dart';
import 'features/requests/data/datasources/game_requests_firestore_datasource.dart';
import 'features/requests/data/repositories/game_requests_repository_impl.dart';
import 'features/requests/domain/repositories/game_requests_repository.dart';
import 'features/requests/presentation/providers/request_game_notifier.dart';
import 'features/saved_games/data/datasources/saved_games_firestore_datasource.dart';
import 'features/saved_games/data/repositories/saved_games_repository_impl.dart';
import 'features/saved_games/domain/repositories/saved_games_repository.dart';
import 'features/saved_games/presentation/providers/saved_games_notifier.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  // Config
  sl.registerLazySingleton<AppConfig>(() => debugConfig);

  // External SDKs
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  sl.registerLazySingleton<GoogleSignIn>(() => GoogleSignIn());
  sl.registerLazySingleton<ApiClient>(() => ApiClient(
        baseUrl: sl<AppConfig>().baseUrl,
        auth: sl<FirebaseAuth>(),
      ));

  // ── auth ──
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      auth: sl<FirebaseAuth>(),
      googleSignIn: sl<GoogleSignIn>(),
      firestore: sl<FirebaseFirestore>(),
    ),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl<AuthRemoteDataSource>()),
  );
  sl.registerLazySingleton(() => SignInWithGoogleUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => SignInWithAppleUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => SignOutUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => WatchAuthStateUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => DeleteAccountUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton<AuthNotifier>(() => AuthNotifier(
        watchAuthState: sl(),
        signInWithGoogle: sl(),
        signInWithApple: sl(),
        signOut: sl(),
        deleteAccount: sl(),
      ));

  // ── games ──
  sl.registerLazySingleton<GamesFirestoreDataSource>(
    () => GamesFirestoreDataSourceImpl(firestore: sl<FirebaseFirestore>()),
  );
  sl.registerLazySingleton<GamesRepository>(
    () => GamesRepositoryImpl(sl<GamesFirestoreDataSource>()),
  );
  sl.registerLazySingleton(() => GetGamesUseCase(sl<GamesRepository>()));
  sl.registerLazySingleton(() => GetGameByIdUseCase(sl<GamesRepository>()));
  sl.registerLazySingleton(() => GetGameGuideUseCase(sl<GamesRepository>()));
  sl.registerLazySingleton(() => SearchGamesUseCase(sl<GamesRepository>()));

  // Notifiers — list/browse stay singleton (shared); detail/guide are factories
  sl.registerLazySingleton<GamesListNotifier>(
      () => GamesListNotifier(getGames: sl()));
  sl.registerLazySingleton<BrowseNotifier>(() => BrowseNotifier(
        getGames: sl(),
        searchGames: sl(),
      ));
  sl.registerFactory<GameDetailNotifier>(
      () => GameDetailNotifier(getById: sl()));
  sl.registerFactory<GuideNotifier>(() => GuideNotifier(getGuide: sl()));

  // ── saved games ──
  sl.registerLazySingleton<SavedGamesFirestoreDataSource>(
    () => SavedGamesFirestoreDataSourceImpl(
      firestore: sl<FirebaseFirestore>(),
      auth: sl<FirebaseAuth>(),
    ),
  );
  sl.registerLazySingleton<SavedGamesRepository>(
    () => SavedGamesRepositoryImpl(sl<SavedGamesFirestoreDataSource>()),
  );
  sl.registerLazySingleton<SavedGamesNotifier>(
      () => SavedGamesNotifier(repository: sl<SavedGamesRepository>()));

  // ── game requests ──
  sl.registerLazySingleton<GameRequestsFirestoreDataSource>(
    () => GameRequestsFirestoreDataSourceImpl(
      firestore: sl<FirebaseFirestore>(),
      auth: sl<FirebaseAuth>(),
    ),
  );
  sl.registerLazySingleton<GameRequestsRepository>(
    () => GameRequestsRepositoryImpl(sl<GameRequestsFirestoreDataSource>()),
  );
  sl.registerLazySingleton<RequestGameNotifier>(
      () => RequestGameNotifier(repository: sl<GameRequestsRepository>()));

  // ── progress ──
  sl.registerLazySingleton<ProgressFirestoreDataSource>(
    () => ProgressFirestoreDataSourceImpl(
      firestore: sl<FirebaseFirestore>(),
      auth: sl<FirebaseAuth>(),
    ),
  );
  sl.registerLazySingleton<ProgressRepository>(
    () => ProgressRepositoryImpl(sl<ProgressFirestoreDataSource>()),
  );
  sl.registerLazySingleton<ProgressNotifier>(
      () => ProgressNotifier(repository: sl<ProgressRepository>()));

  // ── mascot ──
  sl.registerLazySingleton<MascotNotifier>(() => MascotNotifier());
}
