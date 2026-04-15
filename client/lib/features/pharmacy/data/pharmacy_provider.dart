import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/api_service.dart';

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

final pharmacyProvider = StateNotifierProvider<PharmacyNotifier, PharmacyState>((ref) {
  return PharmacyNotifier(ref.read(apiServiceProvider));
});

final pharmacyQueueProvider = FutureProvider.family<List<Prescription>, String?>((ref, status) async {
  final api = ref.read(apiServiceProvider);
  final params = status != null ? {'status': status} : <String, dynamic>{};
  final response = await api.get('/pharmacy/prescriptions', queryParameters: params);
  return (response.data['prescriptions'] as List)
      .map((p) => Prescription.fromJson(p))
      .toList();
});

class PharmacyNotifier extends StateNotifier<PharmacyState> {
  final ApiService _api;

  PharmacyNotifier(this._api) : super(PharmacyState());

  Future<List<Prescription>> getPrescriptions({
    String? status,
    String? patientId,
    int page = 1,
  }) async {
    try {
      final params = <String, dynamic>{'page': page};
      if (status != null) params['status'] = status;
      if (patientId != null) params['patientId'] = patientId;

      final response = await _api.get('/pharmacy/prescriptions', queryParameters: params);
      return (response.data['prescriptions'] as List)
          .map((p) => Prescription.fromJson(p))
          .toList();
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return [];
    }
  }

  Future<Prescription?> getPrescriptionById(String id) async {
    try {
      final response = await _api.get('/pharmacy/prescriptions/$id');
      return Prescription.fromJson(response.data);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  Future<List<BatchStock>> getAvailableBatches(String drugId) async {
    try {
      final response = await _api.get('/inventory/drugs/$drugId/batches');
      return (response.data['batches'] as List)
          .map((b) => BatchStock.fromJson(b))
          .toList();
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return [];
    }
  }

  Future<DispenseResult> dispensePrescription({
    required String prescriptionId,
    required List<DispenseItem> items,
    String? notes,
  }) async {
    state = state.copyWith(loading: true, error: null);

    try {
      final response = await _api.post('/pharmacy/dispense', data: {
        'prescriptionId': prescriptionId,
        'items': items.map((i) => i.toJson()).toList(),
        if (notes != null) 'notes': notes,
      });

      state = state.copyWith(loading: false);

      return DispenseResult(
        success: true,
        dispenseId: response.data['dispenseId'],
        prescriptionId: prescriptionId,
        dispensedAt: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
      return DispenseResult(success: false, error: e.toString());
    }
  }

  Future<bool> putOnHold(String prescriptionId, String reason) async {
    try {
      await _api.put('/pharmacy/prescriptions/$prescriptionId', data: {
        'status': 'on_hold',
        'holdReason': reason,
      });
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<List<Drug>> searchDrugs(String query) async {
    try {
      final response = await _api.get('/inventory/drugs', queryParameters: {
        'search': query,
        'inStock': 'true',
      });
      return (response.data['drugs'] as List)
          .map((d) => Drug.fromJson(d))
          .toList();
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return [];
    }
  }
}

class PharmacyState {
  final bool loading;
  final String? error;

  PharmacyState({this.loading = false, this.error});

  PharmacyState copyWith({bool? loading, String? error}) {
    return PharmacyState(
      loading: loading ?? this.loading,
      error: error,
    );
  }
}

class Prescription {
  final String id;
  final String prescriptionNumber;
  final String patientId;
  final String? encounterId;
  final String prescriberId;
  final String? prescriberName;
  final String status;
  final DateTime prescribedAt;
  final DateTime? expiresAt;
  final DateTime? dispensedAt;
  final String? patientName;
  final String? patientNumber;
  final String? patientAge;
  final List<PrescriptionItem> items;
  final String? notes;
  final String? diagnosis;
  final bool isUrgent;

  Prescription({
    required this.id,
    required this.prescriptionNumber,
    required this.patientId,
    this.encounterId,
    required this.prescriberId,
    this.prescriberName,
    required this.status,
    required this.prescribedAt,
    this.expiresAt,
    this.dispensedAt,
    this.patientName,
    this.patientNumber,
    this.patientAge,
    required this.items,
    this.notes,
    this.diagnosis,
    this.isUrgent = false,
  });

  factory Prescription.fromJson(Map<String, dynamic> json) {
    return Prescription(
      id: json['id'],
      prescriptionNumber: json['prescriptionNumber'],
      patientId: json['patientId'],
      encounterId: json['encounterId'],
      prescriberId: json['prescriberId'],
      prescriberName: json['prescriberName'],
      status: json['status'] ?? 'pending',
      prescribedAt: DateTime.parse(json['prescribedAt']),
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'])
          : null,
      dispensedAt: json['dispensedAt'] != null
          ? DateTime.parse(json['dispensedAt'])
          : null,
      patientName: json['patient']?['name'],
      patientNumber: json['patient']?['patientNumber'],
      patientAge: json['patient']?['age']?.toString(),
      items: (json['items'] as List? ?? [])
          .map((i) => PrescriptionItem.fromJson(i))
          .toList(),
      notes: json['notes'],
      diagnosis: json['diagnosis'],
      isUrgent: json['urgent'] ?? false,
    );
  }

  bool get isPending => status == 'pending';
  bool get isDispensed => status == 'dispensed';
  bool get isOnHold => status == 'on_hold';
  bool get isCancelled => status == 'cancelled';
  bool get isExpired =>
      expiresAt != null && DateTime.now().isAfter(expiresAt!);

  bool get allItemsDispensed =>
      items.isNotEmpty && items.every((item) => item.isDispensed);

  int get pendingItemsCount =>
      items.where((item) => !item.isDispensed).length;
}

class PrescriptionItem {
  final String id;
  final String drugId;
  final String drugCode;
  final String drugName;
  final String? genericName;
  final double quantity;
  final double dispensedQuantity;
  final String dosage;
  final String frequency;
  final String? route;
  final int duration;
  final String? durationUnit;
  final String? instructions;
  final bool isDispensed;
  final bool isSubstituted;
  final String? substitutionNote;

  PrescriptionItem({
    required this.id,
    required this.drugId,
    required this.drugCode,
    required this.drugName,
    this.genericName,
    required this.quantity,
    this.dispensedQuantity = 0,
    required this.dosage,
    required this.frequency,
    this.route,
    required this.duration,
    this.durationUnit,
    this.instructions,
    this.isDispensed = false,
    this.isSubstituted = false,
    this.substitutionNote,
  });

  factory PrescriptionItem.fromJson(Map<String, dynamic> json) {
    return PrescriptionItem(
      id: json['id'],
      drugId: json['drugId'],
      drugCode: json['drugCode'],
      drugName: json['drugName'],
      genericName: json['genericName'],
      quantity: (json['quantity'] is String)
          ? double.parse(json['quantity'])
          : (json['quantity']?.toDouble() ?? 0),
      dispensedQuantity: (json['dispensedQuantity'] is String)
          ? double.parse(json['dispensedQuantity'])
          : (json['dispensedQuantity']?.toDouble() ?? 0),
      dosage: json['dosage'] ?? '',
      frequency: json['frequency'] ?? '',
      route: json['route'],
      duration: json['duration'] ?? 1,
      durationUnit: json['durationUnit'] ?? 'days',
      instructions: json['instructions'],
      isDispensed: json['isDispensed'] ?? false,
      isSubstituted: json['isSubstituted'] ?? false,
      substitutionNote: json['substitutionNote'],
    );
  }

  bool get isFullyDispensed => dispensedQuantity >= quantity;
  double get remainingQuantity => quantity - dispensedQuantity;
}

class DispenseItem {
  final String prescriptionItemId;
  final String drugId;
  final String batchId;
  final double quantity;
  final double unitPrice;
  final bool isSubstituted;
  final String? substitutionNote;

  DispenseItem({
    required this.prescriptionItemId,
    required this.drugId,
    required this.batchId,
    required this.quantity,
    required this.unitPrice,
    this.isSubstituted = false,
    this.substitutionNote,
  });

  Map<String, dynamic> toJson() => {
        'prescriptionItemId': prescriptionItemId,
        'drugId': drugId,
        'batchId': batchId,
        'quantity': quantity,
        'unitPrice': unitPrice,
        'isSubstituted': isSubstituted,
        if (substitutionNote != null) 'substitutionNote': substitutionNote,
      };

  double get total => quantity * unitPrice;
}

class BatchStock {
  final String id;
  final String batchNumber;
  final DateTime expiryDate;
  final double quantity;
  final double availableQuantity;
  final double unitPrice;
  final String? supplier;

  BatchStock({
    required this.id,
    required this.batchNumber,
    required this.expiryDate,
    required this.quantity,
    required this.availableQuantity,
    required this.unitPrice,
    this.supplier,
  });

  bool get isExpired => DateTime.now().isAfter(expiryDate);
  bool get isNearExpiry => expiryDate.isBefore(DateTime.now().add(const Duration(days: 90)));

  factory BatchStock.fromJson(Map<String, dynamic> json) {
    final expiry = DateTime.parse(json['expiryDate']);
    final now = DateTime.now();
    return BatchStock(
      id: json['id'],
      batchNumber: json['batchNumber'],
      expiryDate: expiry,
      quantity: (json['quantity'] is String)
          ? double.parse(json['quantity'])
          : (json['quantity']?.toDouble() ?? 0),
      availableQuantity: (json['availableQuantity'] is String)
          ? double.parse(json['availableQuantity'])
          : (json['availableQuantity']?.toDouble() ?? 0),
      unitPrice: (json['unitPrice'] is String)
          ? double.parse(json['unitPrice'])
          : (json['unitPrice']?.toDouble() ?? 0),
      supplier: json['supplier'],
    );
  }

  int get daysToExpiry => expiryDate.difference(DateTime.now()).inDays;
}

class DispenseResult {
  final bool success;
  final String? dispenseId;
  final String? prescriptionId;
  final DateTime? dispensedAt;
  final String? error;

  DispenseResult({
    required this.success,
    this.dispenseId,
    this.prescriptionId,
    this.dispensedAt,
    this.error,
  });
}

class Drug {
  final String id;
  final String code;
  final String name;
  final String? genericName;
  final String category;
  final String? form;
  final String? strength;
  final double? unitPrice;
  final double? currentStock;
  final bool requiresPrescription;

  Drug({
    required this.id,
    required this.code,
    required this.name,
    this.genericName,
    required this.category,
    this.form,
    this.strength,
    this.unitPrice,
    this.currentStock,
    this.requiresPrescription = true,
  });

  factory Drug.fromJson(Map<String, dynamic> json) {
    return Drug(
      id: json['id'],
      code: json['code'],
      name: json['name'],
      genericName: json['genericName'],
      category: json['category'] ?? 'General',
      form: json['form'],
      strength: json['strength'],
      unitPrice: json['unitPrice']?.toDouble(),
      currentStock: json['currentStock']?.toDouble(),
      requiresPrescription: json['requiresPrescription'] ?? true,
    );
  }

  bool get inStock => (currentStock ?? 0) > 0;
}
