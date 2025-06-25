import 'package:dio/dio.dart';
import '../models/generated_recipe_model.dart';
import '../../../../core/error/exceptions.dart';

class AiRecipeRemoteDataSource {
  final Dio _dio;
  final String _baseUrl = 'https://api.openai.com/v1/chat/completions';

  AiRecipeRemoteDataSource(this._dio);

  Future<GeneratedRecipeModel> generateRecipe(String prompt, String apiKey) async {
    try {
      final response = await _dio.post(
        _baseUrl,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $apiKey',
          },
        ),
        data: {
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content': 'أنت طاهٍ محترف متخصص في إنشاء وصفات طعام مفصلة وسهلة التنفيذ.'
            },
            {
              'role': 'user',
              'content': 'اقترح وصفة ل$prompt. قم بتنسيق الإجابة بالشكل التالي:\nالعنوان:\n\nالمكونات:\n\nطريقة التحضير:'
            }
          ],
          'temperature': 0.7,
        },
      );


      if (response.statusCode == 200) {
        final content = response.data['choices'][0]['message']['content'];
      
      // Parse the generated recipe content
      final recipeData = _parseRecipeContent(content);
      
      return GeneratedRecipeModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        prompt: prompt,
        title: recipeData['title'] ?? 'وصفة جديدة',
        ingredients: List<String>.from(recipeData['ingredients'] ?? []),
        instructions: List<String>.from(recipeData['instructions'] ?? []),
        generatedAt: DateTime.now(),
        likes: 0,
        isCached: false,
      );
      } else {
        throw ServerException();
      }
    } on DioException {
      throw ServerException();
    }
  }

  Map<String, dynamic> _parseRecipeContent(String content) {
    final Map<String, dynamic> result = {
      'title': '',
      'ingredients': <String>[],
      'instructions': <String>[],
    };

    final lines = content.split('\n');
    String currentSection = '';

    for (String line in lines) {
      line = line.trim();
      if (line.isEmpty) continue;

      if (line.contains('العنوان:') || line.contains('الوصفة:')) {
        result['title'] = line.split(':')[1].trim();
      } else if (line.contains('المكونات:')) {
        currentSection = 'ingredients';
      } else if (line.contains('التعليمات:') || line.contains('طريقة التحضير:')) {
        currentSection = 'instructions';
      } else {
        if (currentSection == 'ingredients' && line.startsWith('-')) {
          result['ingredients'].add(line.substring(1).trim());
        } else if (currentSection == 'instructions' && 
                  (line.startsWith('-') || line.startsWith('1') || line.startsWith('٢'))) {
          result['instructions'].add(line.replaceFirst(RegExp(r'^[-\d٠-٩]+\.?\s*'), '').trim());
        }
      }
    }

    return result;
  }
}