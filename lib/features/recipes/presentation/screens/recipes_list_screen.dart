import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/theme_provider.dart';
import '../cubit/recipes_cubit.dart';
import '../cubit/recipes_state.dart';
import '../widgets/recipe_card.dart';
import 'recipe_detail_screen.dart';

class RecipesListScreen extends StatelessWidget {
  const RecipesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipes'),
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
      body: BlocBuilder<RecipesCubit, RecipesState>(
        builder: (context, state) {
          return switch (state) {
            RecipesInitial() => _buildInitialState(context),
            RecipesLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
            RecipesLoaded() => _buildRecipesList(context, state.recipes),
            FavoriteRecipes() => _buildRecipesList(context, state.recipes),
            RecipesByCategory() => _buildRecipesList(context, state.recipes),
            RecipesError() => Center(child: Text(state.message)),
            _ => const SizedBox(),
          };
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement add new recipe
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildInitialState(BuildContext context) {
    context.read<RecipesCubit>().loadRecipes();
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildRecipesList(BuildContext context, recipes) {
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
            );
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
