abstract class DatabaseService {
  Future<void> init();
  String generateId();
  Future<List<Map<String, dynamic>>> getPatients({String? search, int limit = 50, int offset = 0});
  Future<Map<String, dynamic>?> getPatient(String id);
  Future<void> savePatient(Map<String, dynamic> data);
  Future<List<Map<String, dynamic>>> getEncounters({String? patientId, String? status, int limit = 50});
  Future<Map<String, dynamic>?> getEncounter(String id);
  Future<void> saveEncounter(Map<String, dynamic> data);
  Future<List<Map<String, dynamic>>> getInvoices({String? patientId, String? status, int limit = 50});
  Future<void> saveInvoice(Map<String, dynamic> data);
  Future<List<Map<String, dynamic>>> getInventory({String? category, String? search, int limit = 100});
  Future<void> saveInventoryItem(Map<String, dynamic> data);
  Future<Map<String, dynamic>> getSyncStats();
  Future<List<Map<String, dynamic>>> getPendingSyncItems({int limit = 100});
  Future<void> removeSyncQueueItem(int id);
  Future<void> incrementSyncRetry(int id, String error);
}
