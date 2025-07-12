import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../ai_recipes/presentation/screens/ai_recipe_generator_screen.dart';
import '../cubit/recipes_cubit.dart';
import '../cubit/recipes_state.dart';
import '../widgets/recipe_card.dart';
import 'recipe_detail_screen.dart';

class RecipesListScreen extends StatelessWidget {
  const RecipesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RecipesCubit, RecipesState>(
      listener: (context, state) {
        if (state is RecipeActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(state is FavoriteRecipes ? 'المفضلة' : 'الوصفات'),
            leading: state is FavoriteRecipes
                ? IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      context.read<RecipesCubit>().loadRecipes();
                    },
                  )
                : null,
            actions: [
              IconButton(
                icon: Icon(
                  context.watch<ThemeProvider>().isDarkMode
                      ? Icons.light_mode
                      : Icons.dark_mode,
                ),
                onPressed: () {
                  context.read<ThemeProvider>().toggleTheme();
                },
              ),
              IconButton(
                icon: const Icon(Icons.favorite),
                onPressed: () {
                  context.read<RecipesCubit>().loadFavoriteRecipes();
                },
              ),
            ],
          ),
          body: switch (state) {
            RecipesInitial() => _buildInitialState(context),
            RecipesLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
            RecipesLoaded() => _buildRecipesList(context, state.recipes),
            FavoriteRecipes() => _buildRecipesList(context, state.recipes),
            RecipesByCategory() => _buildRecipesList(context, state.recipes),
            RecipesError() => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.error,
                          ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<RecipesCubit>().loadRecipes();
                      },
                      child: const Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              ),
            _ => const SizedBox(),
          },
          floatingActionButton: state is! FavoriteRecipes
              ? FloatingActionButton.extended(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AiRecipeGeneratorScreen(),
                      ),
                    ).then((_) {
                      // تحديث قائمة الوصفات عند العودة من صفحة AI Recipe
                      context.read<RecipesCubit>().loadRecipes();
                    });
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('وصفة جديدة'),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                )
              : null,
        );
      },
    );
  }

  Widget _buildInitialState(BuildContext context) {
    context.read<RecipesCubit>().loadRecipes();
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildRecipesList(BuildContext context, recipes) {
    if (recipes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.no_meals,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد وصفات',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'اضغط على زر + لإضافة وصفة جديدة',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: recipes.length,
      itemBuilder: (context, index) {
        final recipe = recipes[index];
        return RecipeCard(
          recipe: recipe,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RecipeDetailScreen(recipe: recipe),
              ),
            ).then((_) {
              // تحديث قائمة الوصفات عند العودة من صفحة التفاصيل
              context.read<RecipesCubit>().loadRecipes();
            });
          },
          onFavoritePressed: () {
            context.read<RecipesCubit>().handleToggleFavorite(recipe.id);
          },
          onLikePressed: () {
            context.read<RecipesCubit>().handleToggleLike(recipe.id);
          },
        );
      },
    );
  }
}
