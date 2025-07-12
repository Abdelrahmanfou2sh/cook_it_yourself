import 'package:cook/features/auth/presentation/cubit/auth_state.dart';
import 'package:cook/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'features/recipes/presentation/cubit/recipes_cubit.dart';
import 'features/recipes/presentation/screens/recipes_list_screen.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/ai_recipes/presentation/cubit/ai_recipes_cubit.dart';
import 'core/utils/injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => di.sl<RecipesCubit>()..getRecipes()),
        BlocProvider(create: (context) => di.sl<AuthCubit>()..getCurrentUser()),
        BlocProvider(create: (context) => di.sl<AiRecipesCubit>()),
        ChangeNotifierProvider(create: (context) => di.sl<ThemeProvider>()),
      ],
      child: Consumer<ThemeProvider>(
        builder:
            (context, themeProvider, child) => MaterialApp(
              title: 'Cook App',
              debugShowCheckedModeBanner: false,
              theme:
                  themeProvider.isDarkMode ? AppTheme.dark() : AppTheme.light(),
              home: BlocBuilder<AuthCubit, AuthState>(
                builder: (context, state) {
                  if (state is Authenticated) {
                    return const RecipesListScreen();
                  }
                  return const LoginScreen();
                },
              ),
            ),
      ),
    );
  }
}
