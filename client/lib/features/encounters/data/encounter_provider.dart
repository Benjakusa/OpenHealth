import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/api_service.dart';
import '../../../core/config/environment.dart';

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

class EncounterQuery {
  final String? status;
  final String? search;
  final int page;

  EncounterQuery({this.status, this.search, this.page = 1});
}

class EncounterData {
  final String id;
  final String encounterNumber;
  final String patientId;
  final String? patientName;
  final String providerId;
  final String visitType;
  final String status;
  final Map<String, dynamic>? triage;
  final Map<String, dynamic>? vitals;
  final String? chiefComplaint;
  final Map<String, dynamic>? history;
  final Map<String, dynamic>? soap;
  final List<Map<String, dynamic>> diagnoses;
  final List<Map<String, dynamic>> prescriptions;
  final List<Map<String, dynamic>> labOrders;
  final DateTime createdAt;
  final DateTime updatedAt;

  EncounterData({
    required this.id,
    required this.encounterNumber,
    required this.patientId,
    this.patientName,
    required this.providerId,
    required this.visitType,
    required this.status,
    this.triage,
    this.vitals,
    this.chiefComplaint,
    this.history,
    this.soap,
    this.diagnoses = const [],
    this.prescriptions = const [],
    this.labOrders = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory EncounterData.fromMap(Map<String, dynamic> map) {
    return EncounterData(
      id: map['id'] ?? '',
      encounterNumber: map['encounterNumber'] ?? '',
      patientId: map['patientId'] ?? '',
      patientName: map['patientName'],
      providerId: map['providerId'] ?? '',
      visitType: map['visitType'] ?? 'new',
      status: map['status'] ?? 'pending_triage',
      triage: map['triage'],
      vitals: map['vitals'],
      chiefComplaint: map['chiefComplaint'],
      history: map['history'],
      soap: map['soap'],
      diagnoses: List<Map<String, dynamic>>.from(map['diagnoses'] ?? []),
      prescriptions: List<Map<String, dynamic>>.from(map['prescriptions'] ?? []),
      labOrders: List<Map<String, dynamic>>.from(map['labOrders'] ?? []),
      createdAt: map['createdAt'] is DateTime 
          ? map['createdAt'] 
          : DateTime.tryParse(map['createdAt']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: map['updatedAt'] is DateTime 
          ? map['updatedAt'] 
          : DateTime.tryParse(map['updatedAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}

final encounterListProvider = FutureProvider.family<List<EncounterData>, EncounterQuery>((ref, query) async {
  final api = ref.read(apiServiceProvider);
  final params = <String, dynamic>{'page': query.page};
  if (query.status != null) params['status'] = query.status;
  if (query.search != null && query.search!.isNotEmpty) params['search'] = query.search;

  final response = await api.get('/encounters', queryParameters: params);
  return (response.data['encounters'] as List)
      .map((e) => EncounterData.fromMap(e))
      .toList();
});

final encounterDetailProvider = FutureProvider.family<EncounterData?, String>((ref, encounterId) async {
  final api = ref.read(apiServiceProvider);
  try {
    final response = await api.get('/encounters/$encounterId');
    return EncounterData.fromMap(response.data);
  } catch (e) {
    return null;
  }
});

class EncounterNotifier extends StateNotifier<EncounterState> {
  final ApiService _api;

  EncounterNotifier(this._api) : super(EncounterState());

  Future<List<EncounterData>> getEncounters({
    String? status,
    String? search,
    int page = 1,
  }) async {
    try {
      final params = <String, dynamic>{'page': page};
      if (status != null) params['status'] = status;
      if (search != null) params['search'] = search;

      setLoading(true);
      final response = await _api.get('/encounters', queryParameters: params);
      final encounters = (response.data['encounters'] as List)
          .map((e) => EncounterData.fromMap(e))
          .toList();
      state = state.copyWith(encounters: encounters, loading: false);
      return encounters;
    } catch (e) {
      state = state.copyWith(error: e.toString(), loading: false);
      return [];
    }
  }

  Future<EncounterData?> getEncounterById(String id) async {
    try {
      setLoading(true);
      final response = await _api.get('/encounters/$id');
      final encounter = EncounterData.fromMap(response.data);
      state = state.copyWith(currentEncounter: encounter, loading: false);
      return encounter;
    } catch (e) {
      state = state.copyWith(error: e.toString(), loading: false);
      return null;
    }
  }

  Future<bool> createEncounter(Map<String, dynamic> data) async {
    try {
      setLoading(true);
      await _api.post('/encounters', data: data);
      state = state.copyWith(loading: false);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString(), loading: false);
      return false;
    }
  }

  Future<bool> updateEncounter(String id, Map<String, dynamic> data) async {
    try {
      setLoading(true);
      await _api.put('/encounters/$id', data: data);
      state = state.copyWith(loading: false);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString(), loading: false);
      return false;
    }
  }

  void setLoading(bool loading) {
    state = state.copyWith(loading: loading);
  }
}

class EncounterState {
  final List<EncounterData> encounters;
  final EncounterData? currentEncounter;
  final bool loading;
  final String? error;

  EncounterState({
    this.encounters = const [],
    this.currentEncounter,
    this.loading = false,
    this.error,
  });

  EncounterState copyWith({
    List<EncounterData>? encounters,
    EncounterData? currentEncounter,
    bool? loading,
    String? error,
  }) {
    return EncounterState(
      encounters: encounters ?? this.encounters,
      currentEncounter: currentEncounter ?? this.currentEncounter,
      loading: loading ?? this.loading,
      error: error,
    );
  }
}