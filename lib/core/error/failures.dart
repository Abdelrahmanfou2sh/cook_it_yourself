import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure([this.message = '']);

  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([String message = 'حدث خطأ في الاتصال بالخادم']) : super(message);
}

class CacheFailure extends Failure {
  const CacheFailure([String message = 'حدث خطأ في التخزين المحلي']) : super(message);
}

class ApiKeyNotFoundFailure extends Failure {
  const ApiKeyNotFoundFailure([String message = 'يرجى إضافة مفتاح API أولاً']) : super(message);
}

class DailyLimitExceededFailure extends Failure {
  const DailyLimitExceededFailure([String message = 'لقد وصلت إلى الحد الأقصى للوصفات اليومية']) : super(message);
}

class AuthFailure extends Failure {
  const AuthFailure([String message = 'حدث خطأ في المصادقة']) : super(message);
}