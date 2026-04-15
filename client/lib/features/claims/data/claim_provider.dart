import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openhealth/core/services/api_service.dart';

final claimProvider = StateNotifierProvider<ClaimNotifier, ClaimState>((ref) {
  return ClaimNotifier(ref.read(apiServiceProvider));
});

class ClaimNotifier extends StateNotifier<ClaimState> {
  final ApiService _api;

  ClaimNotifier(this._api) : super(ClaimState());

  Future<ClaimSubmitResult> submitShaClaim({
    required String invoiceId,
    String? encounterId,
    List<DiagnosisCode>? diagnosisCodes,
    List<ProcedureCode>? procedureCodes,
    List<ServiceItem>? serviceItems,
    String? notes,
  }) async {
    state = state.copyWith(loading: true, error: null);

    try {
      final response = await _api.post('/claims/sha', data: {
        'invoiceId': invoiceId,
        if (encounterId != null) 'encounterId': encounterId,
        if (diagnosisCodes != null)
          'diagnosisCodes': diagnosisCodes.map((d) => d.toJson()).toList(),
        if (procedureCodes != null)
          'procedureCodes': procedureCodes.map((p) => p.toJson()).toList(),
        if (serviceItems != null)
          'serviceItems': serviceItems.map((s) => s.toJson()).toList(),
        if (notes != null) 'notes': notes,
      });

      state = state.copyWith(loading: false);
      final data = response.data as Map<String, dynamic>;

      return ClaimSubmitResult(
        success: true,
        claimId: data['claimId'],
        claimReference: data['claimReference'],
        shaReference: data['shaReference'],
        status: data['status'],
      );
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
      return ClaimSubmitResult(success: false, error: e.toString());
    }
  }

  Future<PreAuthResult> submitPreAuthorization({
    required String invoiceId,
    required List<PreAuthService> services,
    String? notes,
  }) async {
    try {
      final response = await _api.post('/claims/pre-authorization', data: {
        'invoiceId': invoiceId,
        'services': services.map((s) => s.toJson()).toList(),
        if (notes != null) 'notes': notes,
      });
      final data = response.data as Map<String, dynamic>;

      return PreAuthResult(
        success: true,
        preAuthId: data['preAuthId'],
        preAuthReference: data['preAuthReference'],
        status: data['status'],
        estimatedAmount: (data['estimatedAmount'] as num?)?.toDouble() ?? 0,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return PreAuthResult(success: false, error: e.toString());
    }
  }

  Future<InsuranceVerificationResult> verifyInsurance({
    required String memberNumber,
    String? cardNumber,
    String? patientId,
  }) async {
    try {
      final response = await _api.get('/claims/verify-insurance', queryParameters: {
        'memberNumber': memberNumber,
        if (cardNumber != null) 'cardNumber': cardNumber,
        if (patientId != null) 'patientId': patientId,
      });

      return InsuranceVerificationResult.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return InsuranceVerificationResult(valid: false, error: e.toString());
    }
  }

  Future<ClaimStatusResult> checkClaimStatus(String claimReference) async {
    try {
      final response = await _api.get('/claims/status/$claimReference');

      return ClaimStatusResult.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return ClaimStatusResult(
        claimReference: claimReference,
        status: 'error',
        error: e.toString(),
      );
    }
  }

  Future<List<Claim>> getClaims({
    String? patientId,
    String? status,
    String? claimType,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final params = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      if (patientId != null) params['patientId'] = patientId;
      if (status != null) params['status'] = status;
      if (claimType != null) params['claimType'] = claimType;

      final response = await _api.get('/claims', queryParameters: params);
      final data = response.data as Map<String, dynamic>;
      final claims = (data['claims'] as List)
          .map((c) => Claim.fromJson(c as Map<String, dynamic>))
          .toList();
      return claims;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return [];
    }
  }

  Future<Claim?> getClaimById(String id) async {
    try {
      final response = await _api.get('/claims/$id');
      return Claim.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }
}

class ClaimState {
  final bool loading;
  final String? error;

  ClaimState({this.loading = false, this.error});

  ClaimState copyWith({bool? loading, String? error}) {
    return ClaimState(
      loading: loading ?? this.loading,
      error: error,
    );
  }
}

class DiagnosisCode {
  final String code;
  final String description;
  final String? type;

  DiagnosisCode({
    required this.code,
    required this.description,
    this.type,
  });

  Map<String, dynamic> toJson() => {
        'code': code,
        'description': description,
        if (type != null) 'type': type,
      };
}

class ProcedureCode {
  final String code;
  final String description;
  final DateTime? performedDate;
  final String? bodySite;

  ProcedureCode({
    required this.code,
    required this.description,
    this.performedDate,
    this.bodySite,
  });

  Map<String, dynamic> toJson() => {
        'code': code,
        'description': description,
        if (performedDate != null) 'performedDate': performedDate!.toIso8601String(),
        if (bodySite != null) 'bodySite': bodySite,
      };
}

class ServiceItem {
  final String code;
  final String description;
  final int quantity;
  final double unitPrice;
  final String? category;

  ServiceItem({
    required this.code,
    required this.description,
    required this.quantity,
    required this.unitPrice,
    this.category,
  });

  double get total => quantity * unitPrice;

  Map<String, dynamic> toJson() => {
        'code': code,
        'description': description,
        'quantity': quantity,
        'unitPrice': unitPrice,
        if (category != null) 'category': category,
      };
}

class PreAuthService {
  final String code;
  final String description;
  final int quantity;
  final double estimatedCost;

  PreAuthService({
    required this.code,
    required this.description,
    required this.quantity,
    required this.estimatedCost,
  });

  Map<String, dynamic> toJson() => {
        'code': code,
        'description': description,
        'quantity': quantity,
        'estimatedCost': estimatedCost,
      };
}

class ClaimSubmitResult {
  final bool success;
  final String? claimId;
  final String? claimReference;
  final String? shaReference;
  final String? status;
  final String? error;

  ClaimSubmitResult({
    required this.success,
    this.claimId,
    this.claimReference,
    this.shaReference,
    this.status,
    this.error,
  });
}

class PreAuthResult {
  final bool success;
  final String? preAuthId;
  final String? preAuthReference;
  final String? status;
  final double estimatedAmount;
  final String? error;

  PreAuthResult({
    required this.success,
    this.preAuthId,
    this.preAuthReference,
    this.status,
    this.estimatedAmount = 0,
    this.error,
  });
}

class InsuranceVerificationResult {
  final bool valid;
  final InsuranceMemberInfo? member;
  final InsuranceCoverage? coverage;
  final List<InsuranceBenefit>? benefits;
  final String? error;

  InsuranceVerificationResult({
    required this.valid,
    this.member,
    this.coverage,
    this.benefits,
    this.error,
  });

  factory InsuranceVerificationResult.fromJson(Map<String, dynamic> json) {
    return InsuranceVerificationResult(
      valid: json['valid'] ?? false,
      member: json['member'] != null
          ? InsuranceMemberInfo.fromJson(json['member'])
          : null,
      coverage: json['coverage'] != null
          ? InsuranceCoverage.fromJson(json['coverage'])
          : null,
      benefits: (json['benefits'] as List?)
          ?.map((b) => InsuranceBenefit.fromJson(b))
          .toList(),
      error: json['error'],
    );
  }
}

class InsuranceMemberInfo {
  final String name;
  final String memberNumber;
  final String? idNumber;
  final String relationship;
  final DateTime? dateOfBirth;

  InsuranceMemberInfo({
    required this.name,
    required this.memberNumber,
    this.idNumber,
    required this.relationship,
    this.dateOfBirth,
  });

  factory InsuranceMemberInfo.fromJson(Map<String, dynamic> json) {
    return InsuranceMemberInfo(
      name: json['name'] ?? '',
      memberNumber: json['memberNumber'] ?? '',
      idNumber: json['idNumber'],
      relationship: json['relationship'] ?? 'self',
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'])
          : null,
    );
  }
}

class InsuranceCoverage {
  final String type;
  final double coveragePercent;
  final double? limit;
  final DateTime? expiryDate;
  final String status;

  InsuranceCoverage({
    required this.type,
    required this.coveragePercent,
    this.limit,
    this.expiryDate,
    required this.status,
  });

  factory InsuranceCoverage.fromJson(Map<String, dynamic> json) {
    return InsuranceCoverage(
      type: json['type'] ?? 'SHA',
      coveragePercent: (json['coveragePercent'] ?? 0).toDouble(),
      limit: json['limit']?.toDouble(),
      expiryDate: json['expiryDate'] != null
          ? DateTime.parse(json['expiryDate'])
          : null,
      status: json['status'] ?? 'active',
    );
  }
}

class InsuranceBenefit {
  final String code;
  final String name;
  final bool covered;
  final double? copay;
  final String? waitingPeriod;

  InsuranceBenefit({
    required this.code,
    required this.name,
    required this.covered,
    this.copay,
    this.waitingPeriod,
  });

  factory InsuranceBenefit.fromJson(Map<String, dynamic> json) {
    return InsuranceBenefit(
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      covered: json['covered'] ?? false,
      copay: json['copay']?.toDouble(),
      waitingPeriod: json['waitingPeriod'],
    );
  }
}

class ClaimStatusResult {
  final String claimReference;
  final String? shaReference;
  final String status;
  final String? shaStatus;
  final String? outcome;
  final double? approvedAmount;
  final double totalAmount;
  final String? error;

  ClaimStatusResult({
    required this.claimReference,
    this.shaReference,
    required this.status,
    this.shaStatus,
    this.outcome,
    this.approvedAmount,
    this.totalAmount = 0,
    this.error,
  });

  factory ClaimStatusResult.fromJson(Map<String, dynamic> json) {
    return ClaimStatusResult(
      claimReference: json['claimReference'] ?? '',
      shaReference: json['shaReference'],
      status: json['status'] ?? 'unknown',
      shaStatus: json['shaStatus'],
      outcome: json['outcome'],
      approvedAmount: json['approvedAmount']?.toDouble(),
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      error: json['error'],
    );
  }
}

class Claim {
  final String id;
  final String claimId;
  final String? invoiceId;
  final String patientId;
  final String claimType;
  final String status;
  final String? externalReference;
  final double totalAmount;
  final double submittedAmount;
  final double? approvedAmount;
  final String? failureReason;
  final DateTime createdAt;
  final DateTime? submittedAt;
  final PatientSummary? patient;
  final InvoiceSummary? invoice;

  Claim({
    required this.id,
    required this.claimId,
    this.invoiceId,
    required this.patientId,
    required this.claimType,
    required this.status,
    this.externalReference,
    required this.totalAmount,
    required this.submittedAmount,
    this.approvedAmount,
    this.failureReason,
    required this.createdAt,
    this.submittedAt,
    this.patient,
    this.invoice,
  });

  factory Claim.fromJson(Map<String, dynamic> json) {
    return Claim(
      id: json['id'],
      claimId: json['claimId'],
      invoiceId: json['invoiceId'],
      patientId: json['patientId'],
      claimType: json['claimType'] ?? 'sha',
      status: json['status'] ?? 'draft',
      externalReference: json['externalReference'],
      totalAmount: (json['totalAmount'] is String)
          ? double.parse(json['totalAmount'])
          : (json['totalAmount']?.toDouble() ?? 0),
      submittedAmount: (json['submittedAmount'] is String)
          ? double.parse(json['submittedAmount'])
          : (json['submittedAmount']?.toDouble() ?? 0),
      approvedAmount: json['approvedAmount'] != null
          ? (json['approvedAmount'] is String
              ? double.parse(json['approvedAmount'])
              : json['approvedAmount']?.toDouble())
          : null,
      failureReason: json['failureReason'],
      createdAt: DateTime.parse(json['createdAt']),
      submittedAt: json['submittedAt'] != null
          ? DateTime.parse(json['submittedAt'])
          : null,
      patient: json['patient'] != null
          ? PatientSummary.fromJson(json['patient'])
          : null,
      invoice: json['invoice'] != null
          ? InvoiceSummary.fromJson(json['invoice'])
          : null,
    );
  }
}

class PatientSummary {
  final String id;
  final String? patientNumber;
  final String? firstName;
  final String? lastName;
  final String? phone;

  PatientSummary({
    required this.id,
    this.patientNumber,
    this.firstName,
    this.lastName,
    this.phone,
  });

  factory PatientSummary.fromJson(Map<String, dynamic> json) {
    return PatientSummary(
      id: json['id'],
      patientNumber: json['patientNumber'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      phone: json['phone'],
    );
  }

  String get fullName => '${firstName ?? ''} ${lastName ?? ''}'.trim();
}

class InvoiceSummary {
  final String id;
  final String? invoiceNumber;
  final double totalAmount;

  InvoiceSummary({
    required this.id,
    this.invoiceNumber,
    required this.totalAmount,
  });

  factory InvoiceSummary.fromJson(Map<String, dynamic> json) {
    return InvoiceSummary(
      id: json['id'],
      invoiceNumber: json['invoiceNumber'],
      totalAmount: (json['totalAmount'] is String)
          ? double.parse(json['totalAmount'])
          : (json['totalAmount']?.toDouble() ?? 0),
    );
  }
}
