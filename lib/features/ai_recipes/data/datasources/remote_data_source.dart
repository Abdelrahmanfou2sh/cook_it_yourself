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
          validateStatus: (status) => status != null && status < 500,
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
        if (response.data == null) {
          throw ServerException('لم يتم استلام أي بيانات من الخادم');
        }
        
        if (response.data['choices'] == null || response.data['choices'].isEmpty) {
          throw ServerException('لم يتم توليد أي محتوى من الخادم');
        }

        final content = response.data['choices'][0]['message']['content'];
        if (content == null || content.trim().isEmpty) {
          throw ServerException('المحتوى المستلم من الخادم فارغ');
        }
        
        // Parse the generated recipe content
        final recipeData = _parseRecipeContent(content);
        
        // Validate recipe data
        if (recipeData['title'].isEmpty) {
          throw ServerException('لم يتم استلام عنوان الوصفة');
        }
        
        if (recipeData['ingredients'].isEmpty) {
          throw ServerException('لم يتم استلام مكونات الوصفة');
        }
        
        if (recipeData['instructions'].isEmpty) {
          throw ServerException('لم يتم استلام خطوات تحضير الوصفة');
        }
        
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
      } else if (response.statusCode == 401) {
        throw ServerException('مفتاح API غير صالح أو منتهي الصلاحية');
      } else if (response.statusCode == 429) {
        throw ServerException('تم تجاوز حد الاستخدام، يرجى المحاولة لاحقاً');
      } else {
        throw ServerException('فشل الاتصال بالخادم: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout || 
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw ServerException('انتهت مهلة الاتصال، يرجى التحقق من اتصال الإنترنت والمحاولة مرة أخرى');
      } else if (e.type == DioExceptionType.connectionError) {
        throw ServerException('تعذر الاتصال بالخادم، يرجى التحقق من اتصال الإنترنت والمحاولة مرة أخرى');
      } else if (e.type == DioExceptionType.badResponse) {
        throw ServerException('استجابة غير صالحة من الخادم، يرجى المحاولة مرة أخرى');
      }
      throw ServerException('حدث خطأ أثناء الاتصال بالخادم، يرجى المحاولة مرة أخرى');
    } catch (e) {
      throw ServerException('حدث خطأ غير متوقع، يرجى المحاولة مرة أخرى');
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
    bool foundTitle = false;

    for (String line in lines) {
      line = line.trim();
      if (line.isEmpty) continue;

      if (!foundTitle && (line.contains('العنوان:') || line.contains('الوصفة:'))) {
        final titleParts = line.split(':');
        if (titleParts.length > 1) {
          result['title'] = titleParts[1].trim();
          foundTitle = true;
        }
      } else if (line.contains('المكونات:')) {
        currentSection = 'ingredients';
      } else if (line.contains('التعليمات:') || line.contains('طريقة التحضير:')) {
        currentSection = 'instructions';
      } else {
        if (currentSection == 'ingredients' && 
            (line.startsWith('-') || line.startsWith('•') || RegExp(r'^\d+\.').hasMatch(line))) {
          final ingredient = line.replaceFirst(RegExp(r'^[-•\d]+\.?\s*'), '').trim();
          if (ingredient.isNotEmpty) {
            result['ingredients'].add(ingredient);
          }
        } else if (currentSection == 'instructions' && 
            (line.startsWith('-') || line.startsWith('•') || RegExp(r'^[\d٠-٩]+\.').hasMatch(line))) {
          final instruction = line.replaceFirst(RegExp(r'^[-•\d٠-٩]+\.?\s*'), '').trim();
          if (instruction.isNotEmpty) {
            result['instructions'].add(instruction);
          }
        }
      }
    }

    // إذا لم نجد عنواناً، نستخدم أول سطر غير فارغ
    if (result['title'].isEmpty && lines.isNotEmpty) {
      for (String line in lines) {
        line = line.trim();
        if (line.isNotEmpty && 
            !line.contains('المكونات:') && 
            !line.contains('التعليمات:') && 
            !line.contains('طريقة التحضير:')) {
          result['title'] = line;
          break;
        }
      }
    }

    return result;
  }
}