import 'dart:io';
import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';
import '../config/environment.dart';

part 'database_service_native.g.dart';

class Patients extends Table {
  TextColumn get id => text()();
  TextColumn get tenantId => text()();
  TextColumn get patientNumber => text()();
  TextColumn get firstName => text()();
  TextColumn get lastName => text()();
  TextColumn get middleName => text().nullable()();
  DateTimeColumn get dateOfBirth => dateTime()();
  TextColumn get gender => text()();
  TextColumn get phone => text().nullable()();
  TextColumn get nationalId => text().nullable()();
  TextColumn get county => text().nullable()();
  TextColumn get address => text().nullable()();
  TextColumn get allergies => text().withDefault(const Constant('[]'))();
  TextColumn get chronicConditions => text().withDefault(const Constant('[]'))();
  TextColumn get sha => text().nullable()();
  TextColumn get insurance => text().nullable()();
  TextColumn get emergencyContact => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();

  @override
  Set<Column> get primaryKey => {id};
}

class Encounters extends Table {
  TextColumn get id => text()();
  TextColumn get tenantId => text()();
  TextColumn get encounterNumber => text()();
  TextColumn get patientId => text()();
  TextColumn get providerId => text()();
  TextColumn get visitType => text().withDefault(const Constant('new'))();
  TextColumn get status => text().withDefault(const Constant('pending_triage'))();
  TextColumn get chiefComplaint => text().nullable()();
  TextColumn get triage => text().nullable()();
  TextColumn get vitals => text().nullable()();
  TextColumn get soap => text().nullable()();
  TextColumn get diagnoses => text().withDefault(const Constant('[]'))();
  TextColumn get prescriptions => text().withDefault(const Constant('[]'))();
  TextColumn get labOrders => text().withDefault(const Constant('[]'))();
  TextColumn get disposition => text().nullable()();
  TextColumn get billing => text().nullable()();
  BoolColumn get isLocked => boolean().withDefault(const Constant(false))();
  DateTimeColumn get scheduledAt => dateTime().nullable()();
  DateTimeColumn get startedAt => dateTime().nullable()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();

  @override
  Set<Column> get primaryKey => {id};
}

class Billing extends Table {
  TextColumn get id => text()();
  TextColumn get tenantId => text()();
  TextColumn get invoiceNumber => text()();
  TextColumn get encounterId => text().nullable()();
  TextColumn get patientId => text()();
  TextColumn get type => text().withDefault(const Constant('consultation'))();
  TextColumn get status => text().withDefault(const Constant('draft'))();
  TextColumn get items => text().withDefault(const Constant('[]'))();
  RealColumn get subtotal => real().withDefault(const Constant(0))();
  RealColumn get discount => real().withDefault(const Constant(0))();
  RealColumn get total => real().withDefault(const Constant(0))();
  RealColumn get shaCover => real().withDefault(const Constant(0))();
  RealColumn get insuranceCover => real().withDefault(const Constant(0))();
  RealColumn get patientPay => real().withDefault(const Constant(0))();
  RealColumn get amountPaid => real().withDefault(const Constant(0))();
  RealColumn get balance => real().withDefault(const Constant(0))();
  TextColumn get payments => text().withDefault(const Constant('[]'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();

  @override
  Set<Column> get primaryKey => {id};
}

class Inventory extends Table {
  TextColumn get id => text()();
  TextColumn get tenantId => text()();
  TextColumn get itemCode => text()();
  TextColumn get name => text()();
  TextColumn get category => text().withDefault(const Constant('drug'))();
  TextColumn get unit => text().withDefault(const Constant('unit'))();
  RealColumn get unitPrice => real().withDefault(const Constant(0))();
  RealColumn get costPrice => real().withDefault(const Constant(0))();
  IntColumn get quantity => integer().withDefault(const Constant(0))();
  IntColumn get reorderLevel => integer().withDefault(const Constant(10))();
  TextColumn get batches => text().withDefault(const Constant('[]'))();
  BoolColumn get expiryTracking => boolean().withDefault(const Constant(false))();
  BoolColumn get controlledSubstance => boolean().withDefault(const Constant(false))();
  TextColumn get formulation => text().nullable()();
  TextColumn get strength => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('active'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();

  @override
  Set<Column> get primaryKey => {id};
}

class SyncQueue extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get action => text()();
  TextColumn get data => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();
}

@DriftDatabase(tables: [Patients, Encounters, Billing, Inventory, SyncQueue])
class DatabaseService extends _$DatabaseService {
  DatabaseService() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'openhealth_${Environment.tenantId}.sqlite'));
      return NativeDatabase.createInBackground(file);
    });
  }

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {},
    );
  }

  String generateId() => const Uuid().v4();

  Future<List<Patient>> getPatients({String? search, int limit = 50, int offset = 0}) async {
    final query = select(patients)
      ..where((p) => p.isActive.equals(true))
      ..limit(limit, offset: offset)
      ..orderBy([(p) => OrderingTerm.desc(p.createdAt)]);

    if (search != null && search.isNotEmpty) {
      query.where((p) =>
        p.firstName.like('%$search%') |
        p.lastName.like('%$search%') |
        p.phone.like('%$search%') |
        p.patientNumber.like('%$search%')
      );
    }

    return query.get();
  }

  Future<Patient?> getPatient(String id) async {
    return (select(patients)..where((p) => p.id.equals(id))).getSingleOrNull();
  }

  Future<void> savePatient(Map<String, dynamic> data) async {
    final id = data['id'] as String? ?? generateId();
    data['id'] = id;
    data['tenantId'] = Environment.tenantId;
    data['synced'] = false;
    data['syncStatus'] = 'pending';

    await into(patients).insertOnConflictUpdate(PatientsCompanion.insert(
      id: id,
      tenantId: data['tenantId'],
      patientNumber: data['patientNumber'],
      firstName: data['firstName'],
      lastName: data['lastName'],
      middleName: Value(data['middleName']),
      dateOfBirth: DateTime.parse(data['dateOfBirth']),
      gender: data['gender'],
      phone: Value(data['phone']),
      nationalId: Value(data['nationalId']),
      county: Value(data['county']),
      address: Value(data['address']),
      allergies: Value(jsonEncode(data['allergies'] ?? [])),
      chronicConditions: Value(jsonEncode(data['chronicConditions'] ?? [])),
      sha: Value(data['sha'] != null ? jsonEncode(data['sha']) : null),
      insurance: Value(data['insurance'] != null ? jsonEncode(data['insurance']) : null),
      emergencyContact: Value(data['emergencyContact'] != null ? jsonEncode(data['emergencyContact']) : null),
    ));

    await addToSyncQueue('patient', id, 'upsert', data);
  }

  Future<List<Encounter>> getEncounters({String? patientId, String? status, int limit = 50}) async {
    final query = select(encounters)..limit(limit)..orderBy([(e) => OrderingTerm.desc(e.createdAt)]);

    if (patientId != null) {
      query.where((e) => e.patientId.equals(patientId));
    }
    if (status != null) {
      query.where((e) => e.status.equals(status));
    }

    return query.get();
  }

  Future<Encounter?> getEncounter(String id) async {
    return (select(encounters)..where((e) => e.id.equals(id))).getSingleOrNull();
  }

  Future<void> saveEncounter(Map<String, dynamic> data) async {
    final id = data['id'] as String? ?? generateId();
    data['id'] = id;
    data['tenantId'] = Environment.tenantId;
    data['synced'] = false;
    data['syncStatus'] = 'pending';

    await into(encounters).insertOnConflictUpdate(EncountersCompanion.insert(
      id: id,
      tenantId: data['tenantId'],
      encounterNumber: data['encounterNumber'],
      patientId: data['patientId'],
      providerId: data['providerId'],
      visitType: Value(data['visitType'] ?? 'new'),
      status: Value(data['status'] ?? 'pending_triage'),
      chiefComplaint: Value(data['chiefComplaint']),
      triage: Value(data['triage'] != null ? jsonEncode(data['triage']) : null),
      vitals: Value(data['vitals'] != null ? jsonEncode(data['vitals']) : null),
      soap: Value(data['soap'] != null ? jsonEncode(data['soap']) : null),
      diagnoses: Value(jsonEncode(data['diagnoses'] ?? [])),
      prescriptions: Value(jsonEncode(data['prescriptions'] ?? [])),
      labOrders: Value(jsonEncode(data['labOrders'] ?? [])),
      disposition: Value(data['disposition'] != null ? jsonEncode(data['disposition']) : null),
      billing: Value(data['billing'] != null ? jsonEncode(data['billing']) : null),
      scheduledAt: Value(data['scheduledAt'] != null ? DateTime.parse(data['scheduledAt']) : null),
      startedAt: Value(data['startedAt'] != null ? DateTime.parse(data['startedAt']) : null),
      completedAt: Value(data['completedAt'] != null ? DateTime.parse(data['completedAt']) : null),
    ));

    await addToSyncQueue('encounter', id, 'upsert', data);
  }

  Future<List<BillingData>> getInvoices({String? patientId, String? status, int limit = 50}) async {
    final query = select(billing)..limit(limit)..orderBy([(b) => OrderingTerm.desc(b.createdAt)]);

    if (patientId != null) {
      query.where((b) => b.patientId.equals(patientId));
    }
    if (status != null) {
      query.where((b) => b.status.equals(status));
    }

    return query.get();
  }

  Future<void> saveInvoice(Map<String, dynamic> data) async {
    final id = data['id'] as String? ?? generateId();
    data['id'] = id;
    data['tenantId'] = Environment.tenantId;
    data['synced'] = false;
    data['syncStatus'] = 'pending';

    await into(billing).insertOnConflictUpdate(BillingCompanion.insert(
      id: id,
      tenantId: data['tenantId'],
      invoiceNumber: data['invoiceNumber'],
      encounterId: Value(data['encounterId']),
      patientId: data['patientId'],
      type: Value(data['type'] ?? 'consultation'),
      status: Value(data['status'] ?? 'draft'),
      items: Value(jsonEncode(data['items'] ?? [])),
      subtotal: Value((data['subtotal'] ?? 0).toDouble()),
      discount: Value((data['discount'] ?? 0).toDouble()),
      total: Value((data['total'] ?? 0).toDouble()),
      shaCover: Value((data['shaCover'] ?? 0).toDouble()),
      insuranceCover: Value((data['insuranceCover'] ?? 0).toDouble()),
      patientPay: Value((data['patientPay'] ?? 0).toDouble()),
      amountPaid: Value((data['amountPaid'] ?? 0).toDouble()),
      balance: Value((data['balance'] ?? 0).toDouble()),
      payments: Value(jsonEncode(data['payments'] ?? [])),
    ));

    await addToSyncQueue('billing', id, 'upsert', data);
  }

  Future<List<InventoryData>> getInventory({String? category, String? search, int limit = 100}) async {
    final query = select(inventory)..limit(limit)..orderBy([(i) => OrderingTerm.asc(i.name)]);

    if (category != null) {
      query.where((i) => i.category.equals(category));
    }
    if (search != null && search.isNotEmpty) {
      query.where((i) => i.name.like('%$search%') | i.itemCode.like('%$search%'));
    }

    return query.get();
  }

  Future<void> saveInventoryItem(Map<String, dynamic> data) async {
    final id = data['id'] as String? ?? generateId();
    data['id'] = id;
    data['tenantId'] = Environment.tenantId;
    data['synced'] = false;
    data['syncStatus'] = 'pending';

    await into(inventory).insertOnConflictUpdate(InventoryCompanion.insert(
      id: id,
      tenantId: data['tenantId'],
      itemCode: data['itemCode'],
      name: data['name'],
      category: Value(data['category'] ?? 'drug'),
      unit: Value(data['unit'] ?? 'unit'),
      unitPrice: Value((data['unitPrice'] ?? 0).toDouble()),
      costPrice: Value((data['costPrice'] ?? 0).toDouble()),
      quantity: Value(data['quantity'] ?? 0),
      reorderLevel: Value(data['reorderLevel'] ?? 10),
      batches: Value(jsonEncode(data['batches'] ?? [])),
      expiryTracking: Value(data['expiryTracking'] ?? false),
      controlledSubstance: Value(data['controlledSubstance'] ?? false),
      formulation: Value(data['formulation']),
      strength: Value(data['strength']),
      status: Value(data['status'] ?? 'active'),
    ));
  }

  Future<void> addToSyncQueue(String entityType, String entityId, String action, Map<String, dynamic> data) async {
    await into(syncQueue).insert(SyncQueueCompanion.insert(
      entityType: entityType,
      entityId: entityId,
      action: action,
      data: jsonEncode(data),
    ));
  }

  Future<List<SyncQueueData>> getPendingSyncItems({int limitParam = 100}) async {
    return (select(syncQueue)
      ..where((s) => s.retryCount.isSmallerThan(const Constant(3)))
      ..limit(limitParam)
      ..orderBy([(s) => OrderingTerm.asc(s.createdAt)]))
      .get();
  }

  Future<void> removeSyncQueueItem(int id) async {
    await (delete(syncQueue)..where((s) => s.id.equals(id))).go();
  }

  Future<void> incrementSyncRetry(int id, String error) async {
    await (update(syncQueue)..where((s) => s.id.equals(id))).write(
      SyncQueueCompanion(
        retryCount: const Value(1),
        lastError: Value(error),
      ),
    );
  }

  Future<Map<String, dynamic>> getSyncStats() async {
    final pendingPatients = await (select(patients)..where((p) => p.synced.equals(false))).get();
    final pendingEncounters = await (select(encounters)..where((e) => e.synced.equals(false))).get();
    final pendingBilling = await (select(billing)..where((b) => b.synced.equals(false))).get();
    final pendingInventory = await (select(inventory)..where((i) => i.synced.equals(false))).get();
    final pendingSyncQueue = await (select(syncQueue)..where((s) => s.retryCount.isSmallerThan(const Constant(3)))).get();

    return {
      'pendingPatients': pendingPatients.length,
      'pendingEncounters': pendingEncounters.length,
      'pendingBilling': pendingBilling.length,
      'pendingInventory': pendingInventory.length,
      'pendingSyncQueue': pendingSyncQueue.length,
      'total': pendingPatients.length + pendingEncounters.length + pendingBilling.length + pendingInventory.length,
    };
  }
}
