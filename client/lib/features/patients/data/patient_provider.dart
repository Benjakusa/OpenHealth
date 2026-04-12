import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/database_service.dart';

final databaseServiceProvider = Provider<DatabaseService>((ref) {
  throw UnimplementedError('DatabaseService must be overridden');
});

class PatientData {
  final String id;
  final String firstName;
  final String lastName;
  final String? middleName;
  final String patientNumber;
  final DateTime dateOfBirth;
  final String gender;
  final String? phone;
  final String? nationalId;
  final String? county;
  final String? address;
  final List<String> allergies;
  final List<String> chronicConditions;
  final bool isActive;
  final DateTime createdAt;

  PatientData({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.middleName,
    required this.patientNumber,
    required this.dateOfBirth,
    required this.gender,
    this.phone,
    this.nationalId,
    this.county,
    this.address,
    this.allergies = const [],
    this.chronicConditions = const [],
    this.isActive = true,
    required this.createdAt,
  });

  factory PatientData.fromMap(Map<String, dynamic> map) {
    return PatientData(
      id: map['id'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      middleName: map['middleName'],
      patientNumber: map['patientNumber'] ?? '',
      dateOfBirth: map['dateOfBirth'] is DateTime 
          ? map['dateOfBirth'] 
          : DateTime.tryParse(map['dateOfBirth']?.toString() ?? '') ?? DateTime.now(),
      gender: map['gender'] ?? '',
      phone: map['phone'],
      nationalId: map['nationalId'],
      county: map['county'],
      address: map['address'],
      allergies: _parseJsonList(map['allergies']),
      chronicConditions: _parseJsonList(map['chronicConditions']),
      isActive: map['isActive'] ?? true,
      createdAt: map['createdAt'] is DateTime 
          ? map['createdAt'] 
          : DateTime.tryParse(map['createdAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  static List<String> _parseJsonList(dynamic value) {
    if (value == null) return [];
    if (value is List) return value.cast<String>();
    if (value is String) {
      try {
        final decoded = value;
        return [];
      } catch (_) {
        return [];
      }
    }
    return [];
  }

  String get fullName => '$firstName $lastName'.trim();
  int get age => DateTime.now().difference(dateOfBirth).inDays ~/ 365;
}

class EncounterData {
  final String id;
  final String encounterNumber;
  final String patientId;
  final String providerId;
  final String visitType;
  final String status;
  final String? chiefComplaint;
  final Map<String, dynamic>? triage;
  final Map<String, dynamic>? vitals;
  final List<dynamic>? diagnoses;
  final List<dynamic>? prescriptions;
  final List<dynamic>? labOrders;
  final String? disposition;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime createdAt;

  EncounterData({
    required this.id,
    required this.encounterNumber,
    required this.patientId,
    required this.providerId,
    required this.visitType,
    required this.status,
    this.chiefComplaint,
    this.triage,
    this.vitals,
    this.diagnoses,
    this.prescriptions,
    this.labOrders,
    this.disposition,
    this.startedAt,
    this.completedAt,
    required this.createdAt,
  });

  factory EncounterData.fromMap(Map<String, dynamic> map) {
    return EncounterData(
      id: map['id'] ?? '',
      encounterNumber: map['encounterNumber'] ?? '',
      patientId: map['patientId'] ?? '',
      providerId: map['providerId'] ?? '',
      visitType: map['visitType'] ?? 'new',
      status: map['status'] ?? 'pending_triage',
      chiefComplaint: map['chiefComplaint'],
      triage: map['triage'] is Map<String, dynamic> ? map['triage'] : null,
      vitals: map['vitals'] is Map<String, dynamic> ? map['vitals'] : null,
      diagnoses: map['diagnoses'] is List ? map['diagnoses'] : null,
      prescriptions: map['prescriptions'] is List ? map['prescriptions'] : null,
      labOrders: map['labOrders'] is List ? map['labOrders'] : null,
      disposition: map['disposition'],
      startedAt: map['startedAt'] != null 
          ? (map['startedAt'] is DateTime 
              ? map['startedAt'] 
              : DateTime.tryParse(map['startedAt'].toString()))
          : null,
      completedAt: map['completedAt'] != null 
          ? (map['completedAt'] is DateTime 
              ? map['completedAt'] 
              : DateTime.tryParse(map['completedAt'].toString()))
          : null,
      createdAt: map['createdAt'] is DateTime 
          ? map['createdAt'] 
          : DateTime.tryParse(map['createdAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}

final patientListProvider = FutureProvider.family<List<PatientData>, PatientQuery>((ref, query) async {
  final database = ref.read(databaseServiceProvider);
  final results = await database.getPatients(
    search: query.search,
    limit: query.limit,
    offset: query.offset,
  );
  return results.map((m) => PatientData.fromMap(m)).toList();
});

final patientDetailProvider = FutureProvider.family<PatientData?, String>((ref, id) async {
  final database = ref.read(databaseServiceProvider);
  final result = await database.getPatient(id);
  return result != null ? PatientData.fromMap(result) : null;
});

final patientEncountersProvider = FutureProvider.family<List<EncounterData>, String>((ref, patientId) async {
  final database = ref.read(databaseServiceProvider);
  final results = await database.getEncounters(patientId: patientId);
  return results.map((m) => EncounterData.fromMap(m)).toList();
});

class PatientQuery {
  final String? search;
  final int limit;
  final int offset;

  PatientQuery({this.search, this.limit = 50, this.offset = 0});
}

class BillingData {
  final String id;
  final String invoiceNumber;
  final String patientId;
  final String? encounterId;
  final String type;
  final String status;
  final double subtotal;
  final double discount;
  final double total;
  final double shaCover;
  final double insuranceCover;
  final double patientPay;
  final double amountPaid;
  final double balance;
  final DateTime createdAt;

  BillingData({
    required this.id,
    required this.invoiceNumber,
    required this.patientId,
    this.encounterId,
    required this.type,
    required this.status,
    required this.subtotal,
    required this.discount,
    required this.total,
    required this.shaCover,
    required this.insuranceCover,
    required this.patientPay,
    required this.amountPaid,
    required this.balance,
    required this.createdAt,
  });

  factory BillingData.fromMap(Map<String, dynamic> map) {
    return BillingData(
      id: map['id'] ?? '',
      invoiceNumber: map['invoiceNumber'] ?? '',
      patientId: map['patientId'] ?? '',
      encounterId: map['encounterId'],
      type: map['type'] ?? 'consultation',
      status: map['status'] ?? 'draft',
      subtotal: (map['subtotal'] ?? 0).toDouble(),
      discount: (map['discount'] ?? 0).toDouble(),
      total: (map['total'] ?? 0).toDouble(),
      shaCover: (map['shaCover'] ?? 0).toDouble(),
      insuranceCover: (map['insuranceCover'] ?? 0).toDouble(),
      patientPay: (map['patientPay'] ?? 0).toDouble(),
      amountPaid: (map['amountPaid'] ?? 0).toDouble(),
      balance: (map['balance'] ?? 0).toDouble(),
      createdAt: map['createdAt'] is DateTime 
          ? map['createdAt'] 
          : DateTime.tryParse(map['createdAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}
