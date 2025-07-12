import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/ai_recipes_cubit.dart';
import '../cubit/ai_recipes_state.dart';
import 'settings_screen.dart';

class AiRecipeGeneratorScreen extends StatefulWidget {
  const AiRecipeGeneratorScreen({super.key});

  @override
  State<AiRecipeGeneratorScreen> createState() => _AiRecipeGeneratorScreenState();
}

class _AiRecipeGeneratorScreenState extends State<AiRecipeGeneratorScreen> {
  final _promptController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<AiRecipesCubit>().checkApiKey();
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('توليد وصفة جديدة'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<AiRecipesCubit, AiRecipesState>(
        listener: (context, state) {
          if (state is AiRecipesError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.failure.message),
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.all(16),
                duration: const Duration(seconds: 5),
                action: state.failure.message.contains('API') ?
                  SnackBarAction(
                    label: 'الإعدادات',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SettingsScreen(),
                        ),
                      );
                    },
                  ) : null,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ApiKeyStatus && !state.isSet) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.api_rounded, size: 64, color: Colors.orange),
                  const SizedBox(height: 16),
                  const Text(
                    'يجب إضافة مفتاح API أولاً',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SettingsScreen(),
                        ),
                      );
                    },
                    child: const Text('إضافة مفتاح API'),
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                if (state is AiRecipesLoaded)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      'متبقي: ${state.remainingGenerations.toInt()} وصفات',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _promptController,
                      decoration: const InputDecoration(
                        labelText: 'وصف الوصفة',
                        hintText: 'اكتب وصفاً للوصفة التي تريد توليدها',
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'أمثلة للوصف:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: InkWell(
                        onTap: () {
                          _promptController.text = 'وصفة كيكة شوكولاتة سهلة وسريعة';
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('تم نسخ المثال')),
                          );
                        },
                        child: const Text(
                          '• وصفة كيكة شوكولاتة سهلة وسريعة',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: InkWell(
                        onTap: () {
                          _promptController.text = 'طريقة عمل مكرونة بالبشاميل';
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('تم نسخ المثال')),
                          );
                        },
                        child: const Text(
                          '• طريقة عمل مكرونة بالبشاميل',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: InkWell(
                        onTap: () {
                          _promptController.text = 'وصفة سلطة صيفية منعشة';
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('تم نسخ المثال')),
                          );
                        },
                        child: const Text(
                          '• وصفة سلطة صيفية منعشة',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: InkWell(
                        onTap: () {
                          _promptController.text = 'طريقة تحضير شوربة خضار صحية';
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('تم نسخ المثال')),
                          );
                        },
                        child: const Text(
                          '• طريقة تحضير شوربة خضار صحية',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: state is AiRecipesLoading
                      ? null
                      : () {
                          final prompt = _promptController.text.trim();
                          if (prompt.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('يرجى إدخال وصف للوصفة'),
                                behavior: SnackBarBehavior.floating,
                                margin: EdgeInsets.all(16),
                              ),
                            );
                            return;
                          }
                          if (prompt.length < 3) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('يرجى إدخال وصف أطول للوصفة'),
                                behavior: SnackBarBehavior.floating,
                                margin: EdgeInsets.all(16),
                              ),
                            );
                            return;
                          }
                          context.read<AiRecipesCubit>().generateRecipe(prompt);
                        },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: state is AiRecipesLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('توليد وصفة'),
                ),
                const SizedBox(height: 16),
                if (state is AiRecipesLoaded)
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.recipe.title,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'المكونات:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          ...state.recipe.ingredients.map(
                            (ingredient) => Padding(
                              padding: const EdgeInsets.only(right: 16, top: 4),
                              child: Text('• $ingredient'),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'طريقة التحضير:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          ...state.recipe.instructions.asMap().entries.map(
                                (entry) => Padding(
                                  padding:
                                      const EdgeInsets.only(right: 16, top: 8),
                                  child: Text('${entry.key + 1}. ${entry.value}'),
                                ),
                              ),
                          if (state.recipe.isCached)
                            Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: Row(
                                children: const [
                                  Icon(Icons.cached, color: Colors.blue),
                                  SizedBox(width: 8),
                                  Text(
                                    'وصفة مخزنة مسبقاً',
                                    style: TextStyle(color: Colors.blue),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}