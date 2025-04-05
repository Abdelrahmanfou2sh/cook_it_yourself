import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:cook/cubit/theme_cubit.dart';
import 'package:cook/screens/recipes_screen.dart';
import 'package:cook/cubit/recipes_cubit.dart';
import 'package:cook/services/api_service.dart';

void main() {
  // الحفاظ على شاشة البداية حتى يتم تحميل التطبيق
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // إزالة شاشة البداية بعد بناء التطبيق
    FlutterNativeSplash.remove();
    
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => RecipesCubit(ApiService()),
        ),
        BlocProvider(
          create: (context) => ThemeCubit(),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            title: 'Cook It Yourself',
            themeMode: themeMode,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              colorScheme: ColorScheme.dark(
                primary: Colors.deepOrange,
                secondary: Colors.orangeAccent,
              ),
              useMaterial3: true,
            ),
            home: const RecipesScreen(),
          );
        },
      ),
    );
  }
}
