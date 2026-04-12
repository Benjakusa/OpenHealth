import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/services/api_service.dart';
import '../../../core/config/environment.dart';

class AuthUser {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String role;
  final String tenantId;
  final String tenantName;
  final String package;

  AuthUser({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.tenantId,
    required this.tenantName,
    required this.package,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>;
    final tenant = user['tenant'] as Map<String, dynamic>?;
    return AuthUser(
      id: user['id'],
      email: user['email'],
      firstName: user['firstName'],
      lastName: user['lastName'],
      role: user['role'],
      tenantId: tenant?['id'] ?? '',
      tenantName: tenant?['name'] ?? '',
      package: tenant?['package'] ?? 'DAWA',
    );
  }
}

class AuthState {
  final bool isLoading;
  final AuthUser? user;
  final String? error;

  AuthState({
    this.isLoading = false,
    this.user,
    this.error,
  });

  AuthState copyWith({
    bool? isLoading,
    AuthUser? user,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final ApiService _api;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  AuthNotifier(this._api) : super(AuthState()) {
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    state = state.copyWith(isLoading: true);

    try {
      final token = await _storage.read(key: 'access_token');
      if (token != null) {
        final response = await _api.get('/auth/me');
        if (response.statusCode == 200) {
          final user = AuthUser(
            id: response.data['id'],
            email: response.data['email'],
            firstName: response.data['firstName'],
            lastName: response.data['lastName'],
            role: response.data['role'],
            tenantId: response.data['tenant']?['id'] ?? '',
            tenantName: response.data['tenant']?['name'] ?? '',
            package: response.data['tenant']?['package'] ?? 'DAWA',
          );
          state = AuthState(user: user);
          await Environment.setTenant(user.tenantId, user.tenantName);
          return;
        }
      }
    } catch (e) {
      await _storage.delete(key: 'access_token');
      await _storage.delete(key: 'refresh_token');
    }

    state = AuthState();
  }

  Future<bool> setupTenant(String tenantId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _api.get('/tenants/$tenantId');
      if (response.statusCode == 200) {
        await Environment.setTenant(
          response.data['id'],
          response.data['name'],
        );
        state = state.copyWith(isLoading: false);
        return true;
      }
      state = state.copyWith(isLoading: false, error: 'Invalid Tenant ID');
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Connection failed');
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _api.post('/auth/login', data: {
        'email': email,
        'password': password,
        'tenantId': Environment.tenantId,
      });

      if (response.statusCode == 200) {
        final user = AuthUser.fromJson(response.data);
        await _api.setTokens(response.data['accessToken'], response.data['refreshToken']);
        await Environment.setTenant(user.tenantId, user.tenantName);
        state = AuthState(user: user);
        return true;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Invalid credentials',
      );
    }
    return false;
  }

  Future<void> logout() async {
    try {
      await _api.post('/auth/logout');
    } catch (e) {
    } finally {
      await _api.clearTokens();
      await Environment.clearTenant();
      state = AuthState();
    }
  }
}

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

final authStateProvider = StateNotifierProvider<AuthNotifier, AsyncValue<AuthUser?>>((ref) {
  return AuthNotifier(ref.read(apiServiceProvider));
});
