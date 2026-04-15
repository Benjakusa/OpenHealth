import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/api_service.dart';

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

final labProvider = StateNotifierProvider<LabNotifier, LabState>((ref) {
  return LabNotifier(ref.read(apiServiceProvider));
});

final labQueueProvider = FutureProvider<List<LabOrder>>((ref) async {
  final api = ref.read(apiServiceProvider);
  final response = await api.get('/lab/orders', queryParameters: {'status': 'pending'});
  return (response.data['orders'] as List).map((o) => LabOrder.fromJson(o)).toList();
});

class LabNotifier extends StateNotifier<LabState> {
  final ApiService _api;

  LabNotifier(this._api) : super(LabState());

  Future<List<LabOrder>> getLabOrders({
    String? status,
    String? patientId,
    int page = 1,
  }) async {
    try {
      final params = <String, dynamic>{'page': page};
      if (status != null) params['status'] = status;
      if (patientId != null) params['patientId'] = patientId;

      final response = await _api.get('/lab/orders', queryParameters: params);
      return (response.data['orders'] as List)
          .map((o) => LabOrder.fromJson(o))
          .toList();
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return [];
    }
  }

  Future<LabOrder?> getOrderById(String id) async {
    try {
      final response = await _api.get('/lab/orders/$id');
      return LabOrder.fromJson(response.data);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  Future<bool> updateOrderStatus(String orderId, String status) async {
    try {
      await _api.put('/lab/orders/$orderId', data: {'status': status});
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> submitResults({
    required String orderId,
    required List<LabResultInput> results,
    String? notes,
    String? conclusion,
  }) async {
    state = state.copyWith(loading: true, error: null);

    try {
      await _api.post('/lab/results', data: {
        'orderId': orderId,
        'results': results.map((r) => r.toJson()).toList(),
        if (notes != null) 'notes': notes,
        if (conclusion != null) 'conclusion': conclusion,
      });

      state = state.copyWith(loading: false);
      return true;
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
      return false;
    }
  }

  Future<List<LabTestResult>> getPatientResults(String patientId) async {
    try {
      final response = await _api.get('/lab/results/patient/$patientId');
      return (response.data['results'] as List)
          .map((r) => LabTestResult.fromJson(r))
          .toList();
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return [];
    }
  }

  Future<List<LabTest>> getAvailableTests() async {
    try {
      final response = await _api.get('/lab/tests');
      return (response.data['tests'] as List)
          .map((t) => LabTest.fromJson(t))
          .toList();
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return [];
    }
  }

  Future<bool> collectSample(String orderId) async {
    try {
      await _api.put('/lab/orders/$orderId', data: {
        'status': 'collected',
        'collectedAt': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }
}

class LabState {
  final bool loading;
  final String? error;

  LabState({this.loading = false, this.error});

  LabState copyWith({bool? loading, String? error}) {
    return LabState(
      loading: loading ?? this.loading,
      error: error,
    );
  }
}

class LabOrder {
  final String id;
  final String orderNumber;
  final String patientId;
  final String? encounterId;
  final String testCode;
  final String testName;
  final String status;
  final String priority;
  final DateTime orderedAt;
  final DateTime? collectedAt;
  final DateTime? resultedAt;
  final String? orderedBy;
  final String? patientName;
  final String? patientNumber;
  final String? notes;
  final List<String>? specimens;

  LabOrder({
    required this.id,
    required this.orderNumber,
    required this.patientId,
    this.encounterId,
    required this.testCode,
    required this.testName,
    required this.status,
    this.priority = 'normal',
    required this.orderedAt,
    this.collectedAt,
    this.resultedAt,
    this.orderedBy,
    this.patientName,
    this.patientNumber,
    this.notes,
    this.specimens,
  });

  factory LabOrder.fromJson(Map<String, dynamic> json) {
    return LabOrder(
      id: json['id'],
      orderNumber: json['orderNumber'],
      patientId: json['patientId'],
      encounterId: json['encounterId'],
      testCode: json['testCode'],
      testName: json['testName'],
      status: json['status'] ?? 'pending',
      priority: json['priority'] ?? 'normal',
      orderedAt: DateTime.parse(json['orderedAt']),
      collectedAt: json['collectedAt'] != null
          ? DateTime.parse(json['collectedAt'])
          : null,
      resultedAt: json['resultedAt'] != null
          ? DateTime.parse(json['resultedAt'])
          : null,
      orderedBy: json['orderedBy'],
      patientName: json['patient']?['name'],
      patientNumber: json['patient']?['patientNumber'],
      notes: json['notes'],
      specimens: json['specimens'] != null
          ? List<String>.from(json['specimens'])
          : null,
    );
  }

  bool get isPending => status == 'pending';
  bool get isCollected => status == 'collected';
  bool get isProcessing => status == 'processing';
  bool get isCompleted => status == 'completed' || status == 'resulted';
  bool get isUrgent => priority == 'urgent' || priority == 'stat';
}

class LabResultInput {
  final String testCode;
  final String testName;
  final String? value;
  final String? unit;
  final String? normalRange;
  final String? resultStatus;
  final String? method;
  final String? notes;

  LabResultInput({
    required this.testCode,
    required this.testName,
    this.value,
    this.unit,
    this.normalRange,
    this.resultStatus,
    this.method,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'testCode': testCode,
        'testName': testName,
        if (value != null) 'value': value,
        if (unit != null) 'unit': unit,
        if (normalRange != null) 'normalRange': normalRange,
        if (resultStatus != null) 'resultStatus': resultStatus,
        if (method != null) 'method': method,
        if (notes != null) 'notes': notes,
      };

  bool get isAbnormal =>
      resultStatus == 'high' ||
      resultStatus == 'low' ||
      resultStatus == 'critical';
}

class LabTestResult {
  final String id;
  final String orderId;
  final String patientId;
  final String testCode;
  final String testName;
  final String? value;
  final String? unit;
  final String? normalRange;
  final String? resultStatus;
  final DateTime resultedAt;
  final String? resultedBy;
  final String? method;
  final String? notes;

  LabTestResult({
    required this.id,
    required this.orderId,
    required this.patientId,
    required this.testCode,
    required this.testName,
    this.value,
    this.unit,
    this.normalRange,
    this.resultStatus,
    required this.resultedAt,
    this.resultedBy,
    this.method,
    this.notes,
  });

  factory LabTestResult.fromJson(Map<String, dynamic> json) {
    return LabTestResult(
      id: json['id'],
      orderId: json['orderId'],
      patientId: json['patientId'],
      testCode: json['testCode'],
      testName: json['testName'],
      value: json['value'],
      unit: json['unit'],
      normalRange: json['normalRange'],
      resultStatus: json['resultStatus'],
      resultedAt: DateTime.parse(json['resultedAt']),
      resultedBy: json['resultedBy'],
      method: json['method'],
      notes: json['notes'],
    );
  }

  bool get isAbnormal =>
      resultStatus == 'high' ||
      resultStatus == 'low' ||
      resultStatus == 'critical';

  bool get isCritical => resultStatus == 'critical';
}

class LabTest {
  final String code;
  final String name;
  final String category;
  final String? description;
  final String? specimen;
  final String? method;
  final String? normalRange;
  final String? unit;
  final double? price;
  final bool active;

  LabTest({
    required this.code,
    required this.name,
    required this.category,
    this.description,
    this.specimen,
    this.method,
    this.normalRange,
    this.unit,
    this.price,
    this.active = true,
  });

  factory LabTest.fromJson(Map<String, dynamic> json) {
    return LabTest(
      code: json['code'],
      name: json['name'],
      category: json['category'] ?? 'General',
      description: json['description'],
      specimen: json['specimen'],
      method: json['method'],
      normalRange: json['normalRange'],
      unit: json['unit'],
      price: json['price']?.toDouble(),
      active: json['active'] ?? true,
    );
  }
}
