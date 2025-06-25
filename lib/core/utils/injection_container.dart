import 'package:cook/features/auth/domain/usecases/get_current_user.dart';
import 'package:cook/features/auth/domain/usecases/is_signed_in.dart';
import 'package:cook/features/auth/domain/usecases/reset_password.dart';
import 'package:cook/features/auth/domain/usecases/sign_in.dart';
import 'package:cook/features/auth/domain/usecases/sign_out.dart';
import 'package:cook/features/auth/domain/usecases/sign_up.dart';
import 'package:cook/features/auth/domain/usecases/update_password.dart';
import 'package:cook/features/auth/domain/usecases/update_profile.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/theme_provider.dart';
import '../../features/recipes/data/datasources/local_data_source.dart';
import '../../features/recipes/data/datasources/remote_data_source.dart';
import '../../features/recipes/data/repositories/recipe_repository_impl.dart';
import '../../features/recipes/domain/repositories/i_recipe_repository.dart';
import '../../features/recipes/domain/usecases/get_recipes.dart';
import '../../features/recipes/domain/usecases/get_recipe_by_id.dart';
import '../../features/recipes/domain/usecases/get_recipes_by_category.dart';
import '../../features/recipes/domain/usecases/manage_favorites.dart';
import '../../features/recipes/domain/usecases/manage_recipes.dart';
import '../../features/recipes/presentation/cubit/recipes_cubit.dart';

// Auth imports
import '../../features/auth/data/datasources/local_data_source.dart';
import '../../features/auth/data/datasources/remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/i_auth_repository.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Cubits
  sl.registerFactory(
    () => RecipesCubit(
      getRecipes: sl(),
      getRecipeById: sl(),
      getRecipesByCategory: sl(),
      toggleFavorite: sl(),
      getFavoriteRecipes: sl(),
      toggleLike: sl(),
      saveRecipe: sl(),
      deleteRecipe: sl(),
    ),
  );

  sl.registerFactory(
    () => AuthCubit(
      signUp: sl(),
      signIn: sl(),
      signOut: sl(),
      getCurrentUser: sl(),
      updateProfile: sl(),
      updatePassword: sl(),
      resetPassword: sl(),
      isSignedIn: sl(),
    ),
  );

  // Recipe Use cases
  sl.registerLazySingleton(() => GetRecipes(sl()));
  sl.registerLazySingleton(() => GetRecipeById(sl()));
  sl.registerLazySingleton(() => GetRecipesByCategory(sl()));
  sl.registerLazySingleton(() => ToggleFavorite(sl()));
  sl.registerLazySingleton(() => GetFavoriteRecipes(sl()));
  sl.registerLazySingleton(() => ToggleLike(sl()));
  sl.registerLazySingleton(() => SaveRecipe(sl()));
  sl.registerLazySingleton(() => DeleteRecipe(sl()));

  // Auth Use cases
  sl.registerLazySingleton(() => SignUp(sl()));
  sl.registerLazySingleton(() => SignIn(sl()));
  sl.registerLazySingleton(() => SignOut(sl()));
  sl.registerLazySingleton(() => GetCurrentUser(sl()));
  sl.registerLazySingleton(() => UpdateProfile(sl()));
  sl.registerLazySingleton(() => UpdatePassword(sl()));
  sl.registerLazySingleton(() => ResetPassword(sl()));
  sl.registerLazySingleton(() => IsSignedIn(sl()));

  // Repositories
  sl.registerLazySingleton<IRecipeRepository>(
    () => RecipeRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()),
  );
  sl.registerLazySingleton<IAuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<IRecipeRemoteDataSource>(
    () => RecipeRemoteDataSource(dio: sl()),
  );
  sl.registerLazySingleton<IRecipeLocalDataSource>(
    () => RecipeLocalDataSource(sharedPreferences: sl()),
  );
  sl.registerLazySingleton<IAuthRemoteDataSource>(
    () => AuthRemoteDataSource(
      firebaseAuth: sl(),
      firestore: sl(),
    ),
  );
  sl.registerLazySingleton<IAuthLocalDataSource>(
    () => AuthLocalDataSource(sharedPreferences: sl()),
  );

  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => Dio());
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);

  // Theme
  sl.registerLazySingleton(() => ThemeProvider(sl()));
}
