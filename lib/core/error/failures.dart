import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure([this.message = '']);

  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([String message = '']) : super(message);
}

class CacheFailure extends Failure {
  const CacheFailure([String message = '']) : super(message);
}

class ApiKeyNotFoundFailure extends Failure {
  const ApiKeyNotFoundFailure() : super('مفتاح API غير موجود');
}

class DailyLimitExceededFailure extends Failure {
  const DailyLimitExceededFailure() : super('تم تجاوز الحد اليومي للوصفات المولدة');
}

class AuthFailure extends Failure {
  const AuthFailure([String message = '']) : super(message);
}