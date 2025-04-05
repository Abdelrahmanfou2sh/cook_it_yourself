import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio;
  static const String baseUrl = 'https://api.spoonacular.com/recipes';
  static const String apiKey = 'eddf8485d125447fa2ebccdae56dd0e7';

  ApiService() : _dio = Dio() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.queryParameters = {'apiKey': apiKey};

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          print('Sending request: ${options.uri}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print('Received response: ${response.statusCode}');
          return handler.next(response);
        },
        onError: (error, handler) {
          print('Error: ${error.message}');
          return handler.next(error);
        },
      ),
    );
  }

  Future<List<dynamic>> searchRecipes({
    String query = '',
    String cuisine = '',
    String diet = '',
    int number = 20,
    int offset = 0,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'apiKey': apiKey,
        'number': number,
        'offset': offset,
        'addRecipeInformation': true,
        'fillIngredients': true,
      };
      
      // Add parameters only if they're not empty
      if (query.isNotEmpty) queryParams['query'] = query;
      if (cuisine.isNotEmpty) queryParams['cuisine'] = cuisine;
      if (diet.isNotEmpty) queryParams['diet'] = diet;
      
      final response = await _dio.get(
        '/complexSearch',
        queryParameters: queryParams,
      );
      
      return response.data['results'];
    } catch (e) {
      print('Error in searchRecipes: $e');
      rethrow;
    }
  }

  // إضافة هذه الدوال في ApiService
  List<String> getDietTypes() {
    return [
      'Vegetarian',
      'Vegan',
      'Gluten Free',
      'Ketogenic',
      'Paleo',
      'Pescetarian',
    ];
  }

  List<String> getArabicCuisines() {
    return [
      'Middle Eastern',
      'Egyptian',
      'Lebanese',
      'Moroccan',
      'Mediterranean',
      'Turkish',
    ];
  }

  Future<Map<String, dynamic>> getRecipeDetails(int id) async {
    try {
      final response = await _dio.get('/$id/information');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('Connection timeout');
      case DioExceptionType.badResponse:
        return Exception('Server error: ${e.response?.statusCode}');
      case DioExceptionType.cancel:
        return Exception('Request cancelled');
      default:
        return Exception('Network error: ${e.message}');
    }
  }
}