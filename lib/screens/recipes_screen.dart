import 'package:cook/screens/recipe_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import '../cubit/recipes_cubit.dart';
import '../cubit/recipes_state.dart';
import '../data/reciepe_model.dart';
import '../cubit/theme_cubit.dart';

class RecipesScreen extends StatefulWidget {
  const RecipesScreen({super.key});

  @override
  State<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen> {
  static const _pageSize = 20;

  // Replace the PagingController initialization
  final PagingController<int, Recipe> _pagingController =
      PagingController<int, Recipe>(
        // Use firstPageKey parameter
        firstPageKey: 0,
      );

  @override
  void initState() {
    super.initState();

    // Replace the listener setup
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });

    // Initial load from cubit
    context.read<RecipesCubit>().loadRecipes();
  }

  // Update the _fetchPage method
  Future<void> _fetchPage(int pageKey) async {
    try {
      final newItems = await context.read<RecipesCubit>().fetchRecipesPage(
        pageKey,
        _pageSize,
      );

      final isLastPage = newItems.length < _pageSize;

      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + 1;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('وصفات الطبخ'), 
        centerTitle: true,
        actions: [
          // زر تبديل السمة
          IconButton(
            icon: Icon(isDarkMode ? Icons.wb_sunny : Icons.nightlight_round),
            tooltip: isDarkMode ? 'الوضع الفاتح' : 'الوضع المظلم',
            onPressed: () {
              context.read<ThemeCubit>().toggleTheme();
            },
          ),
        ],
      ),
      body: BlocConsumer<RecipesCubit, RecipesState>(
        listener: (context, state) {
          if (state is RecipesLoaded) {
            // عند تغيير الفلتر، نقوم بإعادة تعيين وحدة التحكم في التمرير وتحميل البيانات الجديدة
            _pagingController.refresh();
          }
        },
        builder: (context, state) {
          // عرض مؤشر التحميل فقط عند التحميل الأولي وليس عند تحديث الفلاتر
          if (state is RecipesLoading && !(state is RecipesLoaded)) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is RecipesError && !(state is RecipesLoaded)) {
            return Center(child: Text('خطأ: ${state.message}'));
          }

          // استخدام الحالة الحالية حتى لو كانت تحت التحميل
          if (state is RecipesLoaded) {
            return Column(
              children: [
                // Search field
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'ابحث عن وصفة...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (query) {
                      if (query.isNotEmpty) {
                        context.read<RecipesCubit>().searchRecipes(query);
                      } else {
                        context.read<RecipesCubit>().clearFilters();
                      }
                    },
                  ),
                ),

                // زر الاقتراحات الذكية
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _showAiSuggestionsDialog(context);
                    },
                    icon: const Icon(Icons.lightbulb_outline),
                    label: const Text('اقتراحات ذكية'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple[100],
                      foregroundColor: Colors.deepPurple[800],
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
                ),

                // Cuisine types list
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'المطبخ:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 50,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: state.cuisineTypes.length,
                          itemBuilder: (context, index) {
                            final cuisine = state.cuisineTypes[index];
                            final isSelected = cuisine == state.selectedCuisine;

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              child: FilterChip(
                                label: Text(_translateCuisine(cuisine)),
                                selected: isSelected,
                                selectedColor: Colors.orange[100],
                                checkmarkColor: Colors.deepOrange,
                                avatar:
                                    isSelected
                                        ? const Icon(Icons.check, size: 18)
                                        : null,
                                labelStyle: TextStyle(
                                  fontWeight:
                                      isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                  color: isSelected ? Colors.deepOrange : null,
                                ),
                                onSelected: (selected) {
                                  if (selected) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'جاري تحميل وصفات المطبخ...',
                                        ),
                                        duration: Duration(seconds: 1),
                                      ),
                                    );
                                    context
                                        .read<RecipesCubit>()
                                        .filterByCuisine(cuisine);
                                  } else {
                                    context.read<RecipesCubit>().clearFilters();
                                  }
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // Diet types list
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'نوع الحمية:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 50,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: state.dietTypes.length,
                          itemBuilder: (context, index) {
                            final diet = state.dietTypes[index];
                            final isSelected = diet == state.selectedDiet;

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              child: FilterChip(
                                label: Text(_translateDiet(diet)),
                                selected: isSelected,
                                selectedColor: Colors.green[100],
                                checkmarkColor: Colors.green,
                                avatar:
                                    isSelected
                                        ? const Icon(Icons.check, size: 18)
                                        : null,
                                labelStyle: TextStyle(
                                  fontWeight:
                                      isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                  color: isSelected ? Colors.green[800] : null,
                                ),
                                onSelected: (selected) {
                                  if (selected) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'جاري تحميل وصفات الحمية...',
                                        ),
                                        duration: Duration(seconds: 1),
                                      ),
                                    );
                                    context.read<RecipesCubit>().filterByDiet(
                                      diet,
                                    );
                                  } else {
                                    context.read<RecipesCubit>().clearFilters();
                                  }
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // Recipe list with pagination
                Expanded(
                  child: RefreshIndicator(
                    onRefresh:
                        () => Future.sync(() => _pagingController.refresh()),
                    child: PagedListView<int, Recipe>.separated(
                      pagingController: _pagingController,
                      separatorBuilder: (context, index) => const Divider(),
                      builderDelegate: PagedChildBuilderDelegate<Recipe>(
                        itemBuilder: (context, recipe, index) {
                          return RecipeCard(recipe: recipe);
                        },
                        firstPageErrorIndicatorBuilder:
                            (context) => Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text('حدث خطأ أثناء تحميل الوصفات'),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed:
                                        () => _pagingController.refresh(),
                                    child: const Text('إعادة المحاولة'),
                                  ),
                                ],
                              ),
                            ),
                        noItemsFoundIndicatorBuilder:
                            (context) =>
                                const Center(child: Text('لا توجد وصفات')),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  // Translation methods
  String _translateDiet(String diet) {
    switch (diet.toLowerCase()) {
      case 'vegetarian':
        return 'نباتي';
      case 'vegan':
        return 'نباتي صرف';
      case 'gluten free':
        return 'خالي من الغلوتين';
      case 'ketogenic':
        return 'كيتو';
      case 'paleo':
        return 'باليو';
      case 'pescetarian':
        return 'سمكي نباتي';
      default:
        return diet;
    }
  }

  String _translateCuisine(String cuisine) {
    switch (cuisine.toLowerCase()) {
      case 'middle eastern':
        return 'شرق أوسطي';
      case 'egyptian':
        return 'مصري';
      case 'lebanese':
        return 'لبناني';
      case 'moroccan':
        return 'مغربي';
      case 'mediterranean':
        return 'متوسطي';
      case 'turkish':
        return 'تركي';
      default:
        return cuisine;
    }
  }

  void _showAiSuggestionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('اقتراحات ذكية'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // اقتراحات حسب الوقت من اليوم
                  _buildTimeBasedSuggestions(),
                  const Divider(),

                  // اقتراحات عامة
                  ListTile(
                    leading: const Icon(
                      Icons.restaurant_menu,
                      color: Colors.orange,
                    ),
                    title: const Text('وصفات صحية سريعة'),
                    onTap: () {
                      Navigator.pop(context);
                      context.read<RecipesCubit>().searchRecipes(
                        'healthy quick',
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.breakfast_dining,
                      color: Colors.blue,
                    ),
                    title: const Text('أفكار لوجبة الإفطار'),
                    onTap: () {
                      Navigator.pop(context);
                      context.read<RecipesCubit>().searchRecipes(
                        'breakfast ideas',
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.dinner_dining,
                      color: Colors.green,
                    ),
                    title: const Text('وجبات عشاء للعائلة'),
                    onTap: () {
                      Navigator.pop(context);
                      context.read<RecipesCubit>().searchRecipes(
                        'family dinner',
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.cake, color: Colors.pink),
                    title: const Text('حلويات سهلة'),
                    onTap: () {
                      Navigator.pop(context);
                      context.read<RecipesCubit>().searchRecipes(
                        'easy desserts',
                      );
                    },
                  ),

                  // اقتراحات مطابخ عالمية
                  const Divider(),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'مطابخ عالمية',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildCuisineChip('مصري', 'egyptian'),
                      _buildCuisineChip('إيطالي', 'italian'),
                      _buildCuisineChip('هندي', 'indian'),
                      _buildCuisineChip('صيني', 'chinese'),
                      _buildCuisineChip('مكسيكي', 'mexican'),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إغلاق'),
              ),
            ],
          ),
    );
  }

  // إنشاء اقتراحات بناءً على الوقت من اليوم
  Widget _buildTimeBasedSuggestions() {
    final hour = DateTime.now().hour;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    String title;
    String query;
    IconData icon;
    Color color;

    if (hour >= 5 && hour < 10) {
      title = 'وصفات إفطار صباحية';
      query = 'breakfast recipes';
      icon = Icons.wb_sunny;
      color = isDarkMode ? Colors.amber[700]! : Colors.amber;
    } else if (hour >= 10 && hour < 14) {
      title = 'وصفات غداء سريعة';
      query = 'quick lunch recipes';
      icon = Icons.lunch_dining;
      color = isDarkMode ? Colors.deepOrange[700]! : Colors.orange;
    } else if (hour >= 14 && hour < 18) {
      title = 'وجبات خفيفة للعصر';
      query = 'afternoon snacks';
      icon = Icons.coffee;
      color = isDarkMode ? Colors.brown[600]! : Colors.brown;
    } else {
      title = 'وصفات عشاء شهية';
      query = 'dinner recipes';
      icon = Icons.nightlight_round;
      color = isDarkMode ? Colors.indigo[400]! : Colors.indigo;
    }

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title),
      subtitle: const Text('اقتراح مناسب للوقت الحالي'),
      tileColor: color.withOpacity(isDarkMode ? 0.2 : 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: color.withOpacity(0.3)),
      ),
      onTap: () {
        Navigator.pop(context);
        context.read<RecipesCubit>().searchRecipes(query);
      },
    );
  }

  // إنشاء رقاقة للمطابخ العالمية
  Widget _buildCuisineChip(String label, String query) {
    return ActionChip(
      label: Text(label),
      avatar: const Icon(Icons.restaurant, size: 18),
      onPressed: () {
        Navigator.pop(context);
        context.read<RecipesCubit>().searchRecipes(query);
      },
    );
  }
}
