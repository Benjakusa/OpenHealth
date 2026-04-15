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

class AuthNotifier extends Notifier<AsyncValue<AuthUser?>> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  @override
  AsyncValue<AuthUser?> build() {
    _checkAuth();
    return const AsyncValue.data(null);
  }

  Future<void> _checkAuth() async {
    state = const AsyncValue.loading();

    try {
      final token = await _storage.read(key: 'access_token');
      if (token != null) {
        final api = ref.read(apiServiceProvider);
        final response = await api.get('/auth/me');
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
          state = AsyncValue.data(user);
          await Environment.setTenant(user.tenantId, user.tenantName);
          return;
        }
      }
    } catch (e, st) {
      await _storage.delete(key: 'access_token');
      await _storage.delete(key: 'refresh_token');
      state = AsyncValue.error(e, st);
    }

    state = const AsyncValue.data(null);
  }

  Future<bool> setupTenant(String tenantId) async {
    state = const AsyncValue.loading();

    try {
      final api = ref.read(apiServiceProvider);
      final response = await api.get('/tenants/$tenantId');
      if (response.statusCode == 200) {
        await Environment.setTenant(
          response.data['id'],
          response.data['name'],
        );
        state = const AsyncValue.data(null);
        return true;
      }
      state = AsyncValue.error('Invalid Tenant ID', StackTrace.current);
      return false;
    } catch (e, st) {
      state = AsyncValue.error('Connection failed', st);
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    state = const AsyncValue.loading();

    try {
      final api = ref.read(apiServiceProvider);
      final response = await api.post('/auth/login', data: {
        'email': email,
        'password': password,
        'tenantId': Environment.tenantId,
      });

      if (response.statusCode == 200) {
        final user = AuthUser.fromJson(response.data);
        await api.setTokens(response.data['accessToken'], response.data['refreshToken']);
        await Environment.setTenant(user.tenantId, user.tenantName);
        state = AsyncValue.data(user);
        return true;
      }
      state = AsyncValue.error('Invalid credentials', StackTrace.current);
    } catch (e, st) {
      state = AsyncValue.error('Invalid credentials', st);
    }
    return false;
  }

  Future<void> logout() async {
    try {
      final api = ref.read(apiServiceProvider);
      await api.post('/auth/logout');
    } catch (e) {
    } finally {
      final api = ref.read(apiServiceProvider);
      await api.clearTokens();
      await Environment.clearTenant();
      state = const AsyncValue.data(null);
    }
  }

  Future<({bool success, String? error, String? tenantId})> register({
    required String tenantName,
    required String tenantCode,
    required String tenantEmail,
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();

    try {
      final api = ref.read(apiServiceProvider);

      // 1. Create tenant
      final tenantResponse = await api.post('/tenants', data: {
        'name': tenantName,
        'code': tenantCode,
        'email': tenantEmail,
      });

      if (tenantResponse.statusCode != 200 && tenantResponse.statusCode != 201) {
        final String error = tenantResponse.data['message']?.toString() ?? 'Failed to create tenant';
        state = AsyncValue.error(error, StackTrace.current);
        return (success: false, error: error, tenantId: null);
      }

      final String tenantId = tenantResponse.data['tenant']['id'].toString();

      // 2. Register user
      final registerResponse = await api.post('/auth/register', data: {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'password': password,
        'tenantId': tenantId,
        'role': 'owner',
      });

      if (registerResponse.statusCode != 200 && registerResponse.statusCode != 201) {
        final String error = registerResponse.data['message']?.toString() ?? 'Failed to create user';
        state = AsyncValue.error(error, StackTrace.current);
        return (success: false, error: error, tenantId: null);
      }

      // 3. Auto login
      final loginResponse = await api.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      if (loginResponse.statusCode == 200) {
        final user = AuthUser.fromJson(loginResponse.data);
        await api.setTokens(loginResponse.data['accessToken'], loginResponse.data['refreshToken']);
        await Environment.setTenant(user.tenantId, user.tenantName);
        state = AsyncValue.data(user);
        return (success: true, error: null, tenantId: tenantId);
      }

      return (success: true, error: null, tenantId: tenantId);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return (success: false, error: e.toString(), tenantId: null);
    }
  }
}

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

final authStateProvider = NotifierProvider<AuthNotifier, AsyncValue<AuthUser?>>(() => AuthNotifier());
