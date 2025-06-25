import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';

abstract class IAuthLocalDataSource {
  Future<void> cacheUser(UserModel user);
  Future<UserModel> getCachedUser();
  Future<void> clearCachedUser();
  Future<bool> isUserCached();
}

class AuthLocalDataSource implements IAuthLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String CACHED_USER_KEY = 'CACHED_USER';

  AuthLocalDataSource({required this.sharedPreferences});

  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      await sharedPreferences.setString(
        CACHED_USER_KEY,
        json.encode(user.toJson()),
      );
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<UserModel> getCachedUser() async {
    try {
      final jsonString = sharedPreferences.getString(CACHED_USER_KEY);
      if (jsonString != null) {
        return UserModel.fromJson(json.decode(jsonString));
      } else {
        throw CacheException();
      }
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<void> clearCachedUser() async {
    try {
      await sharedPreferences.remove(CACHED_USER_KEY);
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<bool> isUserCached() async {
    try {
      return sharedPreferences.containsKey(CACHED_USER_KEY);
    } catch (e) {
      throw CacheException();
    }
  }
}