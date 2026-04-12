import 'dart:convert';
import 'database_service_stub.dart';

class WebDatabaseService implements DatabaseService {
  final Map<String, List<Map<String, dynamic>>> _tables = {
    'patients': [],
    'encounters': [],
    'invoices': [],
    'inventory': [],
  };

  @override
  Future<void> init() async {}

  String generateId() => DateTime.now().millisecondsSinceEpoch.toString();

  @override
  Future<List<Map<String, dynamic>>> getPatients({String? search, int limit = 50, int offset = 0}) async {
    var patients = List<Map<String, dynamic>>.from(_tables['patients']!);
    patients = patients.where((p) => p['isActive'] == true).toList();
    if (search != null && search.isNotEmpty) {
      final searchLower = search.toLowerCase();
      patients = patients.where((p) =>
        (p['firstName'] as String).toLowerCase().contains(searchLower) ||
        (p['lastName'] as String).toLowerCase().contains(searchLower) ||
        ((p['phone'] as String?) ?? '').contains(search) ||
        ((p['patientNumber'] as String?) ?? '').contains(search)
      ).toList();
    }
    patients.sort((a, b) => (b['createdAt'] as DateTime).compareTo(a['createdAt'] as DateTime));
    return patients.skip(offset).take(limit).toList();
  }

  @override
  Future<Map<String, dynamic>?> getPatient(String id) async {
    try {
      return _tables['patients']!.firstWhere((p) => p['id'] == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> savePatient(Map<String, dynamic> data) async {
    final id = data['id'] ?? generateId();
    data['id'] = id;
    data['synced'] = false;
    data['syncStatus'] = 'pending';
    data['createdAt'] = DateTime.now();
    data['updatedAt'] = DateTime.now();
    
    final existingIndex = _tables['patients']!.indexWhere((p) => p['id'] == id);
    if (existingIndex >= 0) {
      _tables['patients']![existingIndex] = data;
    } else {
      _tables['patients']!.add(data);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getEncounters({String? patientId, String? status, int limit = 50}) async {
    var encounters = List<Map<String, dynamic>>.from(_tables['encounters']!);
    if (patientId != null) {
      encounters = encounters.where((e) => e['patientId'] == patientId).toList();
    }
    if (status != null) {
      encounters = encounters.where((e) => e['status'] == status).toList();
    }
    encounters.sort((a, b) => (b['createdAt'] as DateTime).compareTo(a['createdAt'] as DateTime));
    return encounters.take(limit).toList();
  }

  @override
  Future<Map<String, dynamic>?> getEncounter(String id) async {
    try {
      return _tables['encounters']!.firstWhere((e) => e['id'] == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveEncounter(Map<String, dynamic> data) async {
    final id = data['id'] ?? generateId();
    data['id'] = id;
    data['synced'] = false;
    data['syncStatus'] = 'pending';
    data['createdAt'] = DateTime.now();
    data['updatedAt'] = DateTime.now();
    
    final existingIndex = _tables['encounters']!.indexWhere((e) => e['id'] == id);
    if (existingIndex >= 0) {
      _tables['encounters']![existingIndex] = data;
    } else {
      _tables['encounters']!.add(data);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getInvoices({String? patientId, String? status, int limit = 50}) async {
    var invoices = List<Map<String, dynamic>>.from(_tables['invoices']!);
    if (patientId != null) {
      invoices = invoices.where((i) => i['patientId'] == patientId).toList();
    }
    if (status != null) {
      invoices = invoices.where((i) => i['status'] == status).toList();
    }
    invoices.sort((a, b) => (b['createdAt'] as DateTime).compareTo(a['createdAt'] as DateTime));
    return invoices.take(limit).toList();
  }

  @override
  Future<void> saveInvoice(Map<String, dynamic> data) async {
    final id = data['id'] ?? generateId();
    data['id'] = id;
    data['synced'] = false;
    data['syncStatus'] = 'pending';
    data['createdAt'] = DateTime.now();
    data['updatedAt'] = DateTime.now();
    
    final existingIndex = _tables['invoices']!.indexWhere((i) => i['id'] == id);
    if (existingIndex >= 0) {
      _tables['invoices']![existingIndex] = data;
    } else {
      _tables['invoices']!.add(data);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getInventory({String? category, String? search, int limit = 100}) async {
    var inventory = List<Map<String, dynamic>>.from(_tables['inventory']!);
    if (category != null) {
      inventory = inventory.where((i) => i['category'] == category).toList();
    }
    if (search != null && search.isNotEmpty) {
      final searchLower = search.toLowerCase();
      inventory = inventory.where((i) =>
        (i['name'] as String).toLowerCase().contains(searchLower) ||
        ((i['itemCode'] as String?) ?? '').toLowerCase().contains(searchLower)
      ).toList();
    }
    inventory.sort((a, b) => (a['name'] as String).compareTo(b['name'] as String));
    return inventory.take(limit).toList();
  }

  @override
  Future<void> saveInventoryItem(Map<String, dynamic> data) async {
    final id = data['id'] ?? generateId();
    data['id'] = id;
    data['synced'] = false;
    data['syncStatus'] = 'pending';
    data['createdAt'] = DateTime.now();
    data['updatedAt'] = DateTime.now();
    
    final existingIndex = _tables['inventory']!.indexWhere((i) => i['id'] == id);
    if (existingIndex >= 0) {
      _tables['inventory']![existingIndex] = data;
    } else {
      _tables['inventory']!.add(data);
    }
  }

  @override
  Future<Map<String, dynamic>> getSyncStats() async {
    final pendingPatients = (_tables['patients']!).where((p) => p['synced'] != true).length;
    final pendingEncounters = (_tables['encounters']!).where((e) => e['synced'] != true).length;
    final pendingBilling = (_tables['invoices']!).where((i) => i['synced'] != true).length;
    final pendingInventory = (_tables['inventory']!).where((i) => i['synced'] != true).length;

    return {
      'pendingPatients': pendingPatients,
      'pendingEncounters': pendingEncounters,
      'pendingBilling': pendingBilling,
      'pendingInventory': pendingInventory,
      'total': pendingPatients + pendingEncounters + pendingBilling + pendingInventory,
    };
  }

  @override
  Future<List<Map<String, dynamic>>> getPendingSyncItems({int limit = 100}) async {
    final List<Map<String, dynamic>> pending = [];
    for (final patient in (_tables['patients']!).where((p) => p['synced'] != true)) {
      pending.add({'id': 0, 'entityType': 'patient', 'entityId': patient['id'], 'action': 'upsert', 'data': patient});
    }
    return pending.take(limit).toList();
  }

  @override
  Future<void> removeSyncQueueItem(int id) async {}

  @override
  Future<void> incrementSyncRetry(int id, String error) async {}
}

DatabaseService createDatabaseService() => WebDatabaseService();
