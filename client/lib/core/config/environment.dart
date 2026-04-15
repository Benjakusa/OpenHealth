import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Environment {
  static const String appName = 'OpenHealth';
  static const String appVersion = '1.0.0';

  static String apiBaseUrl = 'https://api.openhealth.example.com';
  static String apiVersion = '/api/v1';

  static bool isProduction = false;
  static bool isDevelopment = true;

  static String tenantId = '';
  static String tenantName = '';

  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  static Future<void> init() async {
    if (kReleaseMode && !kIsWeb) {
      isProduction = true;
      apiBaseUrl = 'https://api.openhealth.example.com';
    } else {
      isDevelopment = true;
      // Use localhost even in release mode if running on web locally
      apiBaseUrl = 'http://localhost:3000';
    }
    await _loadEnvironment();
  }

  static Future<void> _loadEnvironment() async {
    final storedTenantId = await _secureStorage.read(key: 'tenant_id');
    if (storedTenantId != null) {
      tenantId = storedTenantId;
      tenantName = await _secureStorage.read(key: 'tenant_name') ?? '';
      facilityId = await _secureStorage.read(key: 'facility_id');
      facilityName = await _secureStorage.read(key: 'facility_name');
    }
  }

  static Future<void> setTenant(String id, String name) async {
    tenantId = id;
    tenantName = name;
    await _secureStorage.write(key: 'tenant_id', value: id);
    await _secureStorage.write(key: 'tenant_name', value: name);
  }

  static Future<void> setFacility(String? id, String? name) async {
    facilityId = id;
    facilityName = name;
    if (id != null) {
      await _secureStorage.write(key: 'facility_id', value: id);
    } else {
      await _secureStorage.delete(key: 'facility_id');
    }
    if (name != null) {
      await _secureStorage.write(key: 'facility_name', value: name);
    } else {
      await _secureStorage.delete(key: 'facility_name');
    }
  }

  static Future<void> clearTenant() async {
    tenantId = '';
    tenantName = '';
    facilityId = null;
    facilityName = null;
    await _secureStorage.delete(key: 'tenant_id');
    await _secureStorage.delete(key: 'tenant_name');
  }

  static String get apiUrl => '$apiBaseUrl$apiVersion';

  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (tenantId.isNotEmpty) 'X-Tenant-ID': tenantId,
  };
}

class AppConfig {
  static const Duration syncInterval = Duration(seconds: 30);
  static const Duration tokenRefreshInterval = Duration(hours: 23);
  static const int maxOfflineRecords = 10000;
  static const Duration cacheExpiry = Duration(hours: 24);

  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 5);

  static const List<String> supportedCounties = [
    'Nairobi', 'Mombasa', 'Kisumu', 'Nakuru', 'Eldoret', 'Kehancha',
    'Kakamega', 'Kericho', 'Bungoma', 'Kisii', 'Nyamira', 'Migori',
    'Homa Bay', 'Siaya', 'Busia', 'Vihiga', 'Nandi', 'Uasin Gishu',
    'Trans Nzoia', 'West Pokot', 'Samburu', 'Turkana', 'Marsabit',
    'Wajir', 'Mandera', 'Garissa', 'Isiolo', 'Meru', 'Tharaka-Nithi',
    'Embu', 'Kitui', 'Machakos', 'Makueni', 'Nyandarua', 'Laikipia',
    'Nyeri', 'Kirinyaga', 'Murang\'a', 'Kiambu', 'Kilifi', 'Kwale',
    'Lamu', 'Taita-Taveta', 'Tana River'
  ];

  static const Map<String, String> bloodGroups = {
    'A+': 'A Positive',
    'A-': 'A Negative',
    'B+': 'B Positive',
    'B-': 'B Negative',
    'AB+': 'AB Positive',
    'AB-': 'AB Negative',
    'O+': 'O Positive',
    'O-': 'O Negative',
    'unknown': 'Unknown',
  };

  static const Map<String, String> genders = {
    'male': 'Male',
    'female': 'Female',
    'other': 'Other',
    'unknown': 'Unknown',
  };

  static const Map<String, String> visitTypes = {
    'new': 'New Visit',
    'follow_up': 'Follow-up',
    'emergency': 'Emergency',
    'transfer_in': 'Transfer In',
    'transfer_out': 'Transfer Out',
    'ANC': 'Antenatal Clinic',
    'MCH': 'Maternal & Child Health',
    'child_welfare': 'Child Welfare Clinic',
    'OPD': 'Outpatient Department',
    'IPD': 'Inpatient Department',
  };

  static const Map<String, String> triageCategories = {
    'emergency': 'Emergency (Red)',
    'urgent': 'Urgent (Orange)',
    'semi_urgent': 'Semi-Urgent (Yellow)',
    'non_urgent': 'Non-Urgent (Green)',
  };
}
