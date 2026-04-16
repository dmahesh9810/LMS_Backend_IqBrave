import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import '../models/user_model.dart';
import '../core/network/api_client.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final authProvider = AsyncNotifierProvider<AuthNotifier, UserModel?>(() {
  return AuthNotifier();
});

class AuthNotifier extends AsyncNotifier<UserModel?> {
  @override
  Future<UserModel?> build() async {
    return _checkLoginStatus();
  }

  Future<UserModel?> _checkLoginStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token != null) {
        final dio = ref.read(apiClientProvider).dio;
        // Fetch profile to verify token
        final response = await dio.get('/user/profile');
        if (response.statusCode == 200) {
          return UserModel.fromJson(response.data['user']);
        }
      }
      return null;
    } catch (e) {
      // Token expired or invalid
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      return null;
    }
  }

  Future<bool> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final dio = ref.read(apiClientProvider).dio;
      final response = await dio.post('/login', data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        final token = response.data['token'];
        final user = UserModel.fromJson(response.data['user']);

        // Save Token
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);

        state = AsyncValue.data(user);
        return true;
      }
      return false;
    } on DioException catch (e) {
      state = AsyncValue.error(
        e.response?.data['message'] ?? 'Login failed. Please check your credentials.',
        StackTrace.current,
      );
      return false;
    } catch (e, st) {
      state = AsyncValue.error('An unexpected error occurred.', st);
      return false;
    }
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    try {
      final dio = ref.read(apiClientProvider).dio;
      await dio.post('/logout');
    } catch (e) {
      // Ignore network errors on logout
    } finally {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      state = const AsyncValue.data(null);
    }
  }
}
