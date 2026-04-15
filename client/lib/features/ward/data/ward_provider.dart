import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/api_service.dart';

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

class Ward {
  final String id;
  final String name;
  final String code;
  final String type;
  final String? floor;
  final String? building;
  final String status;
  final int bedCount;
  final int availableBeds;

  Ward({
    required this.id,
    required this.name,
    required this.code,
    required this.type,
    this.floor,
    this.building,
    required this.status,
    required this.bedCount,
    required this.availableBeds,
  });

  factory Ward.fromJson(Map<String, dynamic> json) {
    return Ward(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      type: json['type'] ?? 'general',
      floor: json['floor'],
      building: json['building'],
      status: json['status'] ?? 'active',
      bedCount: json['bedCount'] ?? 0,
      availableBeds: json['availableBeds'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'code': code,
    'type': type,
    'floor': floor,
    'building': building,
    'status': status,
    'bedCount': bedCount,
    'availableBeds': availableBeds,
  };
}

class Bed {
  final String id;
  final String wardId;
  final String bedNumber;
  final String type;
  final String status;
  final Ward? ward;

  Bed({
    required this.id,
    required this.wardId,
    required this.bedNumber,
    required this.type,
    required this.status,
    this.ward,
  });

  factory Bed.fromJson(Map<String, dynamic> json) {
    return Bed(
      id: json['id'],
      wardId: json['wardId'] ?? '',
      bedNumber: json['bedNumber'],
      type: json['type'] ?? 'standard',
      status: json['status'] ?? 'available',
      ward: json['ward'] != null ? Ward.fromJson(json['ward']) : null,
    );
  }
}

class Admission {
  final String id;
  final String patientId;
  final String encounterId;
  final String wardId;
  final String bedId;
  final String admissionNumber;
  final String admissionType;
  final String admissionReason;
  final String presentingComplaint;
  final String provisionalDiagnosis;
  final DateTime admissionDate;
  final DateTime? dischargeDate;
  final String? dischargeReason;
  final String status;
  final Patient? patient;
  final Ward? ward;
  final Bed? bed;
  final Map<String, dynamic>? vitals;
  final List<String> specialRequirements;

  Admission({
    required this.id,
    required this.patientId,
    required this.encounterId,
    required this.wardId,
    required this.bedId,
    required this.admissionNumber,
    required this.admissionType,
    required this.admissionReason,
    this.presentingComplaint = '',
    this.provisionalDiagnosis = '',
    required this.admissionDate,
    this.dischargeDate,
    this.dischargeReason,
    required this.status,
    this.patient,
    this.ward,
    this.bed,
    this.vitals,
    required this.specialRequirements,
  });

  factory Admission.fromJson(Map<String, dynamic> json) {
    return Admission(
      id: json['id'],
      patientId: json['patientId'],
      encounterId: json['encounterId'],
      wardId: json['wardId'],
      bedId: json['bedId'],
      admissionNumber: json['admissionNumber'],
      admissionType: json['admissionType'] ?? 'emergency',
      admissionReason: json['admissionReason'],
      presentingComplaint: json['presentingComplaint'] ?? '',
      provisionalDiagnosis: json['provisionalDiagnosis'] ?? '',
      admissionDate: DateTime.parse(json['admissionDate']),
      dischargeDate: json['dischargeDate'] != null ? DateTime.parse(json['dischargeDate']) : null,
      dischargeReason: json['dischargeReason'],
      status: json['status'] ?? 'admitted',
      patient: json['patient'] != null ? Patient.fromJson(json['patient']) : null,
      ward: json['ward'] != null ? Ward.fromJson(json['ward']) : null,
      bed: json['bed'] != null ? Bed.fromJson(json['bed']) : null,
      vitals: json['vitals'],
      specialRequirements: List<String>.from(json['specialRequirements'] ?? []),
    );
  }
}

class NursingNote {
  final String id;
  final String admissionId;
  final String patientId;
  final String noteType;
  final String notes;
  final Map<String, dynamic>? vitals;
  final DateTime createdAt;
  final String? nurseName;

  NursingNote({
    required this.id,
    required this.admissionId,
    required this.patientId,
    required this.noteType,
    required this.notes,
    this.vitals,
    required this.createdAt,
    this.nurseName,
  });

  factory NursingNote.fromJson(Map<String, dynamic> json) {
    return NursingNote(
      id: json['id'],
      admissionId: json['admissionId'],
      patientId: json['patientId'],
      noteType: json['noteType'] ?? 'general',
      notes: json['notes'] ?? '',
      vitals: json['vitals'],
      createdAt: DateTime.parse(json['createdAt']),
      nurseName: json['nurse'] != null ? '${json['nurse']['firstName']} ${json['nurse']['lastName']}' : null,
    );
  }
}

class MedicationRecord {
  final String id;
  final String admissionId;
  final String patientId;
  final String medication;
  final String? dosage;
  final String? route;
  final String? frequency;
  final DateTime? scheduledTime;
  final DateTime? administeredAt;
  final DateTime? administeredTime;
  final String? site;
  final double? quantityGiven;
  final String status;
  final String? notes;
  final String? nurseName;

  MedicationRecord({
    required this.id,
    required this.admissionId,
    required this.patientId,
    required this.medication,
    this.dosage,
    this.route,
    this.frequency,
    this.scheduledTime,
    this.administeredAt,
    this.administeredTime,
    this.site,
    this.quantityGiven,
    required this.status,
    this.notes,
    this.nurseName,
  });

  factory MedicationRecord.fromJson(Map<String, dynamic> json) {
    return MedicationRecord(
      id: json['id'],
      admissionId: json['admissionId'],
      patientId: json['patientId'],
      medication: json['medication'] ?? '',
      dosage: json['dosage'],
      route: json['route'],
      frequency: json['frequency'],
      scheduledTime: json['scheduledTime'] != null ? DateTime.parse(json['scheduledTime']) : null,
      administeredAt: json['administeredAt'] != null ? DateTime.parse(json['administeredAt']) : null,
      administeredTime: json['administeredTime'] != null ? DateTime.parse(json['administeredTime']) : null,
      site: json['site'],
      quantityGiven: json['quantityGiven']?.toDouble(),
      status: json['status'] ?? 'scheduled',
      notes: json['notes'],
      nurseName: json['nurse'] != null ? '${json['nurse']['firstName']} ${json['nurse']['lastName']}' : null,
    );
  }
}

class Patient {
  final String id;
  final String firstName;
  final String lastName;
  final String? patientNumber;
  final DateTime? dateOfBirth;
  final String? gender;

  Patient({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.patientNumber,
    this.dateOfBirth,
    this.gender,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      patientNumber: json['patientNumber'],
      dateOfBirth: json['dateOfBirth'] != null ? DateTime.parse(json['dateOfBirth']) : null,
      gender: json['gender'],
    );
  }

  String get fullName => '$firstName $lastName';
}

final wardsProvider = FutureProvider<List<Ward>>((ref) async {
  final api = ref.read(apiServiceProvider);
  final response = await api.get('/ward/wards');
  final List<Ward> wards = (response.data['data'] as List).map((w) => Ward.fromJson(w)).toList();
  return wards;
});

final bedsProvider = FutureProvider.family<List<Bed>, String?>((ref, wardId) async {
  final api = ref.read(apiServiceProvider);
  final params = wardId != null ? {'wardId': wardId} : <String, dynamic>{};
  final response = await api.get('/ward/beds', queryParameters: params);
  final List<Bed> beds = (response.data['data'] as List).map((b) => Bed.fromJson(b)).toList();
  return beds;
});

final wardProvider = FutureProvider.family<Ward, String>((ref, id) async {
  final api = ref.read(apiServiceProvider);
  final response = await api.get('/ward/wards/$id');
  return Ward.fromJson(response.data['data']);
});

final admissionsProvider = FutureProvider.family<List<Admission>, Map<String, dynamic>?>((ref, filters) async {
  final api = ref.read(apiServiceProvider);
  final response = await api.get('/ward/admissions', queryParameters: filters ?? {});
  final List<Admission> admissions = (response.data['data'] as List).map((a) => Admission.fromJson(a)).toList();
  return admissions;
});

final admissionProvider = FutureProvider.family<Admission, String>((ref, id) async {
  final api = ref.read(apiServiceProvider);
  final response = await api.get('/ward/admissions/$id');
  return Admission.fromJson(response.data['data']);
});

final nursingNotesProvider = FutureProvider.family<List<NursingNote>, String>((ref, admissionId) async {
  final api = ref.read(apiServiceProvider);
  final response = await api.get('/ward/nursing-notes', queryParameters: {'admissionId': admissionId});
  final List<NursingNote> notes = (response.data['data'] as List).map((n) => NursingNote.fromJson(n)).toList();
  return notes;
});

final marProvider = FutureProvider.family<List<MedicationRecord>, Map<String, dynamic>>((ref, params) async {
  final api = ref.read(apiServiceProvider);
  final response = await api.get('/ward/mar', queryParameters: params);
  final List<MedicationRecord> records = (response.data['data'] as List).map((r) => MedicationRecord.fromJson(r)).toList();
  return records;
});

final wardDashboardProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, wardId) async {
  final api = ref.read(apiServiceProvider);
  final response = await api.get('/ward/wards/$wardId/dashboard');
  return response.data['data'];
});
