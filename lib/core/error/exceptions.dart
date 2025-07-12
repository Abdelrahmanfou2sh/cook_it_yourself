class ServerException implements Exception {
  final String message;
  ServerException([this.message = 'حدث خطأ في الاتصال بالخادم، يرجى التحقق من اتصال الإنترنت والمحاولة مرة أخرى']);
}

class CacheException implements Exception {
  final String message;
  CacheException([this.message = 'حدث خطأ في الوصول إلى التخزين المحلي، يرجى إعادة تشغيل التطبيق']);
}

class ApiKeyNotFoundException implements Exception {
  final String message;
  ApiKeyNotFoundException([this.message = 'لم يتم العثور على مفتاح API، يرجى إضافة المفتاح في إعدادات التطبيق']);
}

class DailyLimitExceededException implements Exception {
  final String message;
  DailyLimitExceededException([this.message = 'تم تجاوز الحد الأقصى للوصفات اليومية، يرجى المحاولة غداً']);
}