import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openhealth/core/services/api_service.dart';

final paymentProvider = StateNotifierProvider<PaymentNotifier, PaymentState>((ref) {
  return PaymentNotifier(ref.read(apiServiceProvider));
});

final paymentStatsProvider = FutureProvider<PaymentStats>((ref) async {
  final api = ref.read(apiServiceProvider);
  return api.get('/payments/stats').then((r) => PaymentStats.fromJson(r.data as Map<String, dynamic>));
});

class PaymentNotifier extends StateNotifier<PaymentState> {
  final ApiService _api;

  PaymentNotifier(this._api) : super(PaymentState());

  Future<MpesaPaymentResult> initiateMpesaPayment({
    required String invoiceId,
    required String phoneNumber,
    double? amount,
  }) async {
    state = state.copyWith(loading: true, error: null);

    try {
      final response = await _api.post('/payments/mpesa/initiate', data: {
        'invoiceId': invoiceId,
        'phoneNumber': phoneNumber,
        if (amount != null) 'amount': amount,
      });

      state = state.copyWith(loading: false);
      final data = response.data as Map<String, dynamic>;

      return MpesaPaymentResult(
        success: true,
        checkoutRequestId: data['checkoutRequestId'],
        merchantRequestId: data['merchantRequestId'],
        amount: (data['amount'] as num?)?.toDouble() ?? 0,
      );
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
      return MpesaPaymentResult(success: false, error: e.toString());
    }
  }

  Future<MpesaPaymentStatus> checkMpesaStatus(String checkoutRequestId) async {
    try {
      final response = await _api.get('/payments/mpesa/status/$checkoutRequestId');
      final data = response.data as Map<String, dynamic>;
      return MpesaPaymentStatus(
        status: data['status'] ?? 'pending',
        resultCode: data['resultCode']?.toString(),
        resultDesc: data['resultDesc'],
        receiptNumber: data['receiptNumber'],
      );
    } catch (e) {
      return MpesaPaymentStatus(status: 'error', error: e.toString());
    }
  }

  Future<bool> recordCashPayment({
    required String invoiceId,
    required double amount,
    String? collectedBy,
    String? notes,
  }) async {
    try {
      await _api.post('/payments/cash', data: {
        'invoiceId': invoiceId,
        'amount': amount,
        if (collectedBy != null) 'collectedBy': collectedBy,
        if (notes != null) 'notes': notes,
      });
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> recordCardPayment({
    required String invoiceId,
    required double amount,
    required String cardType,
    required String lastFourDigits,
    String? authorizationCode,
    String? notes,
  }) async {
    try {
      await _api.post('/payments/card', data: {
        'invoiceId': invoiceId,
        'amount': amount,
        'cardType': cardType,
        'lastFourDigits': lastFourDigits,
        if (authorizationCode != null) 'authorizationCode': authorizationCode,
        if (notes != null) 'notes': notes,
      });
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<List<Payment>> getPayments({
    String? invoiceId,
    String? patientId,
    String? status,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final params = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      if (invoiceId != null) params['invoiceId'] = invoiceId;
      if (patientId != null) params['patientId'] = patientId;
      if (status != null) params['status'] = status;

      final response = await _api.get('/payments', queryParameters: params);
      final data = response.data as Map<String, dynamic>;
      final payments = (data['payments'] as List)
          .map((p) => Payment.fromJson(p as Map<String, dynamic>))
          .toList();
      return payments;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return [];
    }
  }

  Future<Payment?> getPaymentById(String id) async {
    try {
      final response = await _api.get('/payments/$id');
      return Payment.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }
}

class PaymentState {
  final bool loading;
  final String? error;

  PaymentState({this.loading = false, this.error});

  PaymentState copyWith({bool? loading, String? error}) {
    return PaymentState(
      loading: loading ?? this.loading,
      error: error,
    );
  }
}

class MpesaPaymentResult {
  final bool success;
  final String? checkoutRequestId;
  final String? merchantRequestId;
  final double amount;
  final String? error;

  MpesaPaymentResult({
    required this.success,
    this.checkoutRequestId,
    this.merchantRequestId,
    this.amount = 0,
    this.error,
  });
}

class MpesaPaymentStatus {
  final String status;
  final String? resultCode;
  final String? resultDesc;
  final String? receiptNumber;
  final String? error;

  MpesaPaymentStatus({
    required this.status,
    this.resultCode,
    this.resultDesc,
    this.receiptNumber,
    this.error,
  });

  bool get isCompleted => status == 'completed';
  bool get isPending => status == 'pending';
  bool get isFailed => status == 'failed' || status == 'cancelled';
}

class Payment {
  final String id;
  final String? invoiceId;
  final String? patientId;
  final double amount;
  final String paymentMethod;
  final String? reference;
  final String status;
  final String? receiptNumber;
  final DateTime createdAt;
  final DateTime? completedAt;
  final PatientSummary? patient;
  final InvoiceSummary? invoice;

  Payment({
    required this.id,
    this.invoiceId,
    this.patientId,
    required this.amount,
    required this.paymentMethod,
    this.reference,
    required this.status,
    this.receiptNumber,
    required this.createdAt,
    this.completedAt,
    this.patient,
    this.invoice,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      invoiceId: json['invoiceId'],
      patientId: json['patientId'],
      amount: (json['amount'] is String)
          ? double.parse(json['amount'])
          : (json['amount']?.toDouble() ?? 0),
      paymentMethod: json['paymentMethod'] ?? 'cash',
      reference: json['reference'],
      status: json['status'] ?? 'pending',
      receiptNumber: json['receiptNumber'],
      createdAt: DateTime.parse(json['createdAt']),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
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
  final String status;

  InvoiceSummary({
    required this.id,
    this.invoiceNumber,
    required this.totalAmount,
    required this.status,
  });

  factory InvoiceSummary.fromJson(Map<String, dynamic> json) {
    return InvoiceSummary(
      id: json['id'],
      invoiceNumber: json['invoiceNumber'],
      totalAmount: (json['totalAmount'] is String)
          ? double.parse(json['totalAmount'])
          : (json['totalAmount']?.toDouble() ?? 0),
      status: json['status'] ?? 'pending',
    );
  }
}

class PaymentStats {
  final double totalCollection;
  final double refunds;
  final double netCollection;
  final int pendingPayments;
  final List<PaymentMethodSummary> byMethod;

  PaymentStats({
    required this.totalCollection,
    required this.refunds,
    required this.netCollection,
    required this.pendingPayments,
    required this.byMethod,
  });

  factory PaymentStats.fromJson(Map<String, dynamic> json) {
    return PaymentStats(
      totalCollection: (json['totalCollection'] ?? 0).toDouble(),
      refunds: (json['refunds'] ?? 0).toDouble(),
      netCollection: (json['netCollection'] ?? 0).toDouble(),
      pendingPayments: json['pendingPayments'] ?? 0,
      byMethod: (json['byMethod'] as List? ?? [])
          .map((m) => PaymentMethodSummary.fromJson(m))
          .toList(),
    );
  }
}

class PaymentMethodSummary {
  final String method;
  final double total;
  final int count;

  PaymentMethodSummary({
    required this.method,
    required this.total,
    required this.count,
  });

  factory PaymentMethodSummary.fromJson(Map<String, dynamic> json) {
    return PaymentMethodSummary(
      method: json['method'] ?? 'unknown',
      total: (json['total'] ?? 0).toDouble(),
      count: json['count'] ?? 0,
    );
  }
}
