import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/storage/daily_challenge_store.dart';
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/observe_auth_state.dart';
import 'features/auth/domain/usecases/sign_in_with_email.dart';
import 'features/auth/domain/usecases/sign_in_with_google.dart';
import 'features/auth/domain/usecases/sign_out.dart';
import 'features/auth/domain/usecases/sign_up_with_email.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/onboarding/data/datasources/onboarding_local_data_source.dart';
import 'features/onboarding/data/datasources/onboarding_remote_data_source.dart';
import 'features/onboarding/data/repositories/onboarding_repository_impl.dart';
import 'features/onboarding/domain/repositories/onboarding_repository.dart';
import 'features/onboarding/domain/usecases/complete_onboarding.dart';
import 'features/onboarding/domain/usecases/get_runtime_levels.dart';
import 'features/onboarding/domain/usecases/get_stack_tracks.dart';
import 'features/onboarding/domain/usecases/sync_profile_to_remote.dart';
import 'features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'features/practice/data/datasources/practice_remote_data_source.dart';
import 'features/practice/data/repositories/practice_repository_impl.dart';
import 'features/practice/domain/repositories/practice_repository.dart';
import 'features/practice/domain/usecases/get_practice_questions.dart';
import 'features/practice/presentation/bloc/practice_session_bloc.dart';
import 'features/progress/data/datasources/progress_local_data_source.dart';
import 'features/progress/data/repositories/progress_repository_impl.dart';
import 'features/progress/domain/repositories/progress_repository.dart';
import 'features/progress/domain/usecases/get_progress_overview.dart';
import 'features/progress/domain/usecases/mark_module_viewed.dart';
import 'features/progress/domain/usecases/record_attempt.dart';
import 'features/progress/presentation/cubit/progress_cubit.dart';
import 'features/topics/data/datasources/topic_remote_data_source.dart';
import 'features/topics/data/repositories/topic_repository_impl.dart';
import 'features/topics/domain/repositories/topic_repository.dart';
import 'features/topics/presentation/cubit/topic_cubit.dart';

final sl = GetIt.instance;

Future<void> configureDependencies() async {
  // External
  final prefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  sl.registerSingleton<SharedPreferences>(prefs);

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(firebaseAuth: sl(), firestore: sl()),
  );
  sl.registerLazySingleton<OnboardingLocalDataSource>(
    () => OnboardingLocalDataSourceImpl(prefs: sl()),
  );
  sl.registerLazySingleton<OnboardingRemoteDataSource>(
    () => OnboardingRemoteDataSourceImpl(firebaseAuth: sl(), firestore: sl()),
  );
  sl.registerLazySingleton<PracticeRemoteDataSource>(
    () => PracticeFirestoreDataSourceImpl(firestore: sl()),
  );
  sl.registerLazySingleton(() => TopicRemoteDataSource(firestore: sl()));
  sl.registerLazySingleton(
    () => ProgressFirestoreDataSource(firestore: sl(), firebaseAuth: sl()),
  );
  sl.registerLazySingleton(() => DailyChallengeStore(prefs: sl()));

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<OnboardingRepository>(
    () =>
        OnboardingRepositoryImpl(localDataSource: sl(), remoteDataSource: sl()),
  );
  sl.registerLazySingleton<PracticeRepository>(
    () => PracticeRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<TopicRepository>(
    () => TopicRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<ProgressRepository>(
    () => ProgressRepositoryImpl(remoteDataSource: sl()),
  );

  // Use cases — auth
  sl.registerLazySingleton(() => ObserveAuthState(sl()));
  sl.registerLazySingleton(() => SignInWithEmail(sl()));
  sl.registerLazySingleton(() => SignUpWithEmail(sl()));
  sl.registerLazySingleton(() => SignInWithGoogle(sl()));
  sl.registerLazySingleton(() => SignOut(sl()));

  // Use cases — onboarding
  sl.registerLazySingleton(() => GetStackTracks(sl()));
  sl.registerLazySingleton(() => GetRuntimeLevels(sl()));
  sl.registerLazySingleton(() => CompleteOnboarding(sl()));
  sl.registerLazySingleton(() => SyncProfileToRemote(sl()));

  // Use cases — practice / progress
  sl.registerLazySingleton(() => GetPracticeQuestions(sl()));
  sl.registerLazySingleton(() => GetProgressOverview(repository: sl()));
  sl.registerLazySingleton(() => RecordAttempt(repository: sl()));
  sl.registerLazySingleton(() => MarkModuleViewed(repository: sl()));

  // Blocs & cubits
  sl.registerFactory(
    () => AuthBloc(
      observeAuthState: sl(),
      signInWithEmail: sl(),
      signUpWithEmail: sl(),
      signInWithGoogle: sl(),
      signOut: sl(),
    ),
  );
  sl.registerFactory(
    () => OnboardingCubit(
      getStackTracks: sl(),
      getRuntimeLevels: sl(),
      completeOnboarding: sl(),
      syncProfileToRemote: sl(),
      localDataSource: sl(),
    ),
  );
  sl.registerFactory(() => TopicCubit(repository: sl()));
  sl.registerFactory(
    () => ProgressCubit(
      getProgressOverview: sl(),
      repository: sl(),
      getStackTracks: sl(),
    ),
  );
  sl.registerFactory(
    () => PracticeSessionBloc(
      getPracticeQuestions: sl(),
      recordAttempt: sl(),
      dailyChallengeStore: sl(),
    ),
  );
}
