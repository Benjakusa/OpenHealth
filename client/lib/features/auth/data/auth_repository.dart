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
  final String? facilityCode;
  final String package;

  AuthUser({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.tenantId,
    required this.tenantName,
    this.facilityId,
    this.facilityName,
    this.facilityCode,
    required this.package,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>;
    final tenant = user['tenant'] as Map<String, dynamic>?;
    final facility = user['facility'] as Map<String, dynamic>?;
    return AuthUser(
      id: user['id'],
      email: user['email'],
      firstName: user['firstName'],
      lastName: user['lastName'],
      role: user['role'],
      tenantId: tenant?['id'] ?? '',
      tenantName: tenant?['name'] ?? '',
      facilityId: facility?['id'],
      facilityName: facility?['name'],
      facilityCode: user['facilityCode'],
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

  Future<bool> login(String email, String password, {String? facilityCode}) async {
    state = const AsyncValue.loading();

    try {
      final api = ref.read(apiServiceProvider);
      final response = await api.post('/auth/login', data: {
        'email': email,
        'password': password,
        'tenantId': Environment.tenantId,
        if (facilityCode != null) 'facilityCode': facilityCode,
      });

      if (response.statusCode == 200) {
        final user = AuthUser.fromJson(response.data);
        await api.setTokens(response.data['accessToken'], response.data['refreshToken']);
        await Environment.setTenant(user.tenantId, user.tenantName);
        state = AsyncValue.data(user);
        return true;
      }
      state = AsyncValue.error('Invalid credentials or facility code', StackTrace.current);
    } catch (e, st) {
      state = AsyncValue.error('Invalid credentials', st);
    }
    return false;
  }

  Future<bool> forgotPassword(String email) async {
    try {
      final api = ref.read(apiServiceProvider);
      final response = await api.post('/auth/forgot-password', data: {'email': email});
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> resetPassword(String token, String newPassword) async {
    try {
      final api = ref.read(apiServiceProvider);
      final response = await api.post('/auth/reset-password', data: {
        'token': token,
        'newPassword': newPassword,
      });
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
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

  Future<({bool success, String? error})> tenantRegister({
    required String organizationName,
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required int numberOfClinics,
    required List<Map<String, dynamic>> clinics,
  }) async {
    state = const AsyncValue.loading();

    try {
      final api = ref.read(apiServiceProvider);
      final response = await api.post('/auth/tenant-register', data: {
        'organizationName': organizationName,
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'password': password,
        'numberOfClinics': numberOfClinics,
        'clinics': clinics,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        final user = AuthUser.fromJson(response.data);
        await api.setTokens(response.data['accessToken'], response.data['refreshToken']);
        await Environment.setTenant(user.tenantId, user.tenantName);
        state = AsyncValue.data(user);
        return (success: true, error: null);
      }
      
      final String error = response.data['error'] ?? response.data['message'] ?? 'Registration failed';
      state = AsyncValue.error(error, StackTrace.current);
      return (success: false, error: error);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return (success: false, error: e.toString());
    }
  }

  Future<({bool success, String? error})> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String facilityCode,
    required String role,
  }) async {
    state = const AsyncValue.loading();

    try {
      final api = ref.read(apiServiceProvider);
      final response = await api.post('/auth/register', data: {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'password': password,
        'facilityCode': facilityCode,
        'role': role,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Staff registration usually leads to "pending_approval" status
        // So we might not get tokens back immediately if they can't login yet
        final bool isPending = response.data['status'] == 'pending_approval';
        
        if (isPending) {
          state = const AsyncValue.data(null);
          return (success: true, error: 'Registration successful! Please wait for approval from your organization admin.');
        }

        final user = AuthUser.fromJson(response.data);
        await api.setTokens(response.data['accessToken'], response.data['refreshToken']);
        await Environment.setTenant(user.tenantId, user.tenantName);
        state = AsyncValue.data(user);
        return (success: true, error: null);
      }
      
      final String error = response.data['error'] ?? response.data['message'] ?? 'Registration failed';
      state = AsyncValue.error(error, StackTrace.current);
      return (success: false, error: error);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return (success: false, error: e.toString());
    }
  }
  Future<List<Map<String, dynamic>>> getPendingUsers() async {
    try {
      final api = ref.read(apiServiceProvider);
      final response = await api.get('/auth/pending-users');
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<bool> approveUser(String userId, bool approved) async {
    try {
      final api = ref.read(apiServiceProvider);
      final response = await api.post('/auth/approve-user/$userId', data: {'approved': approved});
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getClinics() async {
    try {
      final api = ref.read(apiServiceProvider);
      final response = await api.get('/auth/clinics');
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getTenants() async {
    try {
      final api = ref.read(apiServiceProvider);
      final response = await api.get('/tenants');
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<bool> suspendTenant(String tenantId, bool suspend) async {
    try {
      final api = ref.read(apiServiceProvider);
      final endpoint = suspend ? '/tenants/$tenantId/suspend' : '/tenants/$tenantId/reactivate';
      final response = await api.post(endpoint);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

final authStateProvider = NotifierProvider<AuthNotifier, AsyncValue<AuthUser?>>(() => AuthNotifier());
