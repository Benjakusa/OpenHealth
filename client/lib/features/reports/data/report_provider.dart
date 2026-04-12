import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/api_service.dart';

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

class DashboardStats {
  final PatientStats patients;
  final RevenueStats revenue;
  final EncounterStats encounters;
  final PendingStats pending;
  final AdmissionStats admissions;

  DashboardStats({
    required this.patients,
    required this.revenue,
    required this.encounters,
    required this.pending,
    required this.admissions,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      patients: PatientStats.fromJson(json['patients'] ?? {}),
      revenue: RevenueStats.fromJson(json['revenue'] ?? {}),
      encounters: EncounterStats.fromJson(json['encounters'] ?? {}),
      pending: PendingStats.fromJson(json['pending'] ?? {}),
      admissions: AdmissionStats.fromJson(json['admissions'] ?? {}),
    );
  }
}

class PatientStats {
  final int today;
  final int thisMonth;

  PatientStats({required this.today, required this.thisMonth});

  factory PatientStats.fromJson(Map<String, dynamic> json) {
    return PatientStats(
      today: json['today'] ?? 0,
      thisMonth: json['thisMonth'] ?? 0,
    );
  }
}

class RevenueStats {
  final double today;
  final double thisMonth;

  RevenueStats({required this.today, required this.thisMonth});

  factory RevenueStats.fromJson(Map<String, dynamic> json) {
    return RevenueStats(
      today: (json['today'] ?? 0).toDouble(),
      thisMonth: (json['thisMonth'] ?? 0).toDouble(),
    );
  }
}

class EncounterStats {
  final int today;

  EncounterStats({required this.today});

  factory EncounterStats.fromJson(Map<String, dynamic> json) {
    return EncounterStats(today: json['today'] ?? 0);
  }
}

class PendingStats {
  final int lab;
  final int pharmacy;

  PendingStats({required this.lab, required this.pharmacy});

  factory PendingStats.fromJson(Map<String, dynamic> json) {
    return PendingStats(
      lab: json['lab'] ?? 0,
      pharmacy: json['pharmacy'] ?? 0,
    );
  }
}

class AdmissionStats {
  final int active;

  AdmissionStats({required this.active});

  factory AdmissionStats.fromJson(Map<String, dynamic> json) {
    return AdmissionStats(active: json['active'] ?? 0);
  }
}

class ReportTemplate {
  final String id;
  final String name;
  final String code;
  final String category;
  final String? description;
  final List<dynamic> parameters;
  final List<dynamic> columns;
  final String chartType;
  final bool isDefault;

  ReportTemplate({
    required this.id,
    required this.name,
    required this.code,
    required this.category,
    this.description,
    required this.parameters,
    required this.columns,
    required this.chartType,
    required this.isDefault,
  });

  factory ReportTemplate.fromJson(Map<String, dynamic> json) {
    return ReportTemplate(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      category: json['category'] ?? 'custom',
      description: json['description'],
      parameters: json['parameters'] ?? [],
      columns: json['columns'] ?? [],
      chartType: json['chartType'] ?? 'table',
      isDefault: json['isDefault'] ?? false,
    );
  }
}

class GeneratedReport {
  final String id;
  final String? templateId;
  final String name;
  final String category;
  final DateTime? periodStart;
  final DateTime? periodEnd;
  final Map<String, dynamic>? parameters;
  final dynamic data;
  final Map<String, dynamic>? summary;
  final String format;
  final String? fileUrl;
  final String status;
  final String? errorMessage;
  final DateTime createdAt;
  final String? generatorName;

  GeneratedReport({
    required this.id,
    this.templateId,
    required this.name,
    required this.category,
    this.periodStart,
    this.periodEnd,
    this.parameters,
    this.data,
    this.summary,
    required this.format,
    this.fileUrl,
    required this.status,
    this.errorMessage,
    required this.createdAt,
    this.generatorName,
  });

  factory GeneratedReport.fromJson(Map<String, dynamic> json) {
    return GeneratedReport(
      id: json['id'],
      templateId: json['templateId'],
      name: json['name'],
      category: json['category'] ?? 'custom',
      periodStart: json['periodStart'] != null ? DateTime.parse(json['periodStart']) : null,
      periodEnd: json['periodEnd'] != null ? DateTime.parse(json['periodEnd']) : null,
      parameters: json['parameters'],
      data: json['data'],
      summary: json['summary'],
      format: json['format'] ?? 'pdf',
      fileUrl: json['fileUrl'],
      status: json['status'] ?? 'completed',
      errorMessage: json['errorMessage'],
      createdAt: DateTime.parse(json['createdAt']),
      generatorName: json['generator'] != null ? '${json['generator']['firstName']} ${json['generator']['lastName']}' : null,
    );
  }
}

class RevenueReportData {
  final List<TimelineData> timeline;
  final List<DepartmentRevenue> byDepartment;
  final RevenueSummary summary;

  RevenueReportData({
    required this.timeline,
    required this.byDepartment,
    required this.summary,
  });

  factory RevenueReportData.fromJson(Map<String, dynamic> json) {
    return RevenueReportData(
      timeline: (json['timeline'] as List? ?? []).map((t) => TimelineData.fromJson(t)).toList(),
      byDepartment: (json['byDepartment'] as List? ?? []).map((d) => DepartmentRevenue.fromJson(d)).toList(),
      summary: RevenueSummary.fromJson(json['summary'] ?? {}),
    );
  }
}

class TimelineData {
  final DateTime date;
  final int transactionCount;
  final int patientCount;
  final double totalAmount;
  final double cashTotal;
  final double mpesaTotal;
  final double insuranceTotal;
  final double shaTotal;

  TimelineData({
    required this.date,
    required this.transactionCount,
    required this.patientCount,
    required this.totalAmount,
    required this.cashTotal,
    required this.mpesaTotal,
    required this.insuranceTotal,
    required this.shaTotal,
  });

  factory TimelineData.fromJson(Map<String, dynamic> json) {
    return TimelineData(
      date: DateTime.parse(json['date']),
      transactionCount: int.tryParse(json['transaction_count']?.toString() ?? '0') ?? 0,
      patientCount: int.tryParse(json['patient_count']?.toString() ?? '0') ?? 0,
      totalAmount: double.tryParse(json['total_amount']?.toString() ?? '0') ?? 0,
      cashTotal: double.tryParse(json['cash_total']?.toString() ?? '0') ?? 0,
      mpesaTotal: double.tryParse(json['mpesa_total']?.toString() ?? '0') ?? 0,
      insuranceTotal: double.tryParse(json['insurance_total']?.toString() ?? '0') ?? 0,
      shaTotal: double.tryParse(json['sha_total']?.toString() ?? '0') ?? 0,
    );
  }
}

class DepartmentRevenue {
  final String department;
  final int itemCount;
  final double total;

  DepartmentRevenue({
    required this.department,
    required this.itemCount,
    required this.total,
  });

  factory DepartmentRevenue.fromJson(Map<String, dynamic> json) {
    return DepartmentRevenue(
      department: json['department'] ?? 'Unknown',
      itemCount: int.tryParse(json['item_count']?.toString() ?? '0') ?? 0,
      total: double.tryParse(json['total']?.toString() ?? '0') ?? 0,
    );
  }
}

class RevenueSummary {
  final double totalRevenue;
  final int totalTransactions;
  final int uniquePatients;

  RevenueSummary({
    required this.totalRevenue,
    required this.totalTransactions,
    required this.uniquePatients,
  });

  factory RevenueSummary.fromJson(Map<String, dynamic> json) {
    return RevenueSummary(
      totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
      totalTransactions: json['totalTransactions'] ?? 0,
      uniquePatients: json['uniquePatients'] ?? 0,
    );
  }
}

final dashboardStatsProvider = FutureProvider<DashboardStats>((ref) async {
  final api = ref.read(apiServiceProvider);
  final response = await api.get('/reports/dashboard');
  return DashboardStats.fromJson(response.data['data']);
});

final reportTemplatesProvider = FutureProvider.family<List<ReportTemplate>, String?>((ref, category) async {
  final api = ref.read(apiServiceProvider);
  final params = category != null ? {'category': category} : <String, dynamic>{};
  final response = await api.get('/reports/templates', queryParameters: params);
  return (response.data['data'] as List).map((t) => ReportTemplate.fromJson(t)).toList();
});

final generatedReportsProvider = FutureProvider.family<List<GeneratedReport>, Map<String, dynamic>?>((ref, filters) async {
  final api = ref.read(apiServiceProvider);
  final response = await api.get('/reports', queryParameters: filters ?? {});
  return (response.data['data'] as List).map((r) => GeneratedReport.fromJson(r)).toList();
});

final reportProvider = FutureProvider.family<GeneratedReport, String>((ref, id) async {
  final api = ref.read(apiServiceProvider);
  final response = await api.get('/reports/$id');
  return GeneratedReport.fromJson(response.data['data']);
});

final revenueReportProvider = FutureProvider.family<RevenueReportData, Map<String, dynamic>>((ref, params) async {
  final api = ref.read(apiServiceProvider);
  final response = await api.get('/reports/revenue', queryParameters: params);
  return RevenueReportData.fromJson(response.data['data']);
});

final clinicalReportProvider = FutureProvider.family<Map<String, dynamic>, Map<String, dynamic>>((ref, params) async {
  final api = ref.read(apiServiceProvider);
  final response = await api.get('/reports/clinical', queryParameters: params);
  return response.data['data'] ?? {};
});

final patientReportProvider = FutureProvider.family<Map<String, dynamic>, Map<String, dynamic>>((ref, params) async {
  final api = ref.read(apiServiceProvider);
  final response = await api.get('/reports/patients', queryParameters: params);
  return response.data['data'] ?? {};
});

final inventoryReportProvider = FutureProvider.family<Map<String, dynamic>, Map<String, dynamic>>((ref, params) async {
  final api = ref.read(apiServiceProvider);
  final response = await api.get('/reports/inventory', queryParameters: params);
  return response.data['data'] ?? {};
});

final wardReportProvider = FutureProvider.family<Map<String, dynamic>, Map<String, dynamic>>((ref, params) async {
  final api = ref.read(apiServiceProvider);
  final response = await api.get('/reports/ward', queryParameters: params);
  return response.data['data'] ?? {};
});
