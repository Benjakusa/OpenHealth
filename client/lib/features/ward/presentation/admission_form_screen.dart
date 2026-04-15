import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/api_service.dart';
import '../../patients/data/patient_provider.dart';

class AdmissionFormScreen extends ConsumerStatefulWidget {
  final String wardId;
  final String? patientId;
  final String? encounterId;

  const AdmissionFormScreen({
    super.key,
    required this.wardId,
    this.patientId,
    this.encounterId,
  });

  @override
  ConsumerState<AdmissionFormScreen> createState() => _AdmissionFormScreenState();
}

class _AdmissionFormScreenState extends ConsumerState<AdmissionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _api = ApiService();

  String? _selectedPatientId;
  String? _selectedBedId;
  String _admissionType = 'emergency';
  String _admissionReason = '';
  String _presentingComplaint = '';
  String _provisionalDiagnosis = '';
  List<String> _specialRequirements = [];
  bool _isLoading = false;
  bool _isSearchingPatients = false;

  List<Patient> _searchResults = [];

  @override
  void initState() {
    super.initState();
    if (widget.patientId != null) {
      _selectedPatientId = widget.patientId;
    }
  }

  Future<void> _searchPatients(String query) async {
    if (query.length < 3) {
      setState(() => _searchResults = []);
      return;
    }

    setState(() => _isSearchingPatients = true);
    try {
      final response = await _api.get('/patients', queryParameters: {'search': query, 'limit': 10});
      final List<Patient> patients = (response.data['data'] as List)
          .map((p) => Patient.fromJson(p))
          .toList();
      setState(() {
        _searchResults = patients;
        _isSearchingPatients = false;
      });
    } catch (e) {
      setState(() => _isSearchingPatients = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPatientId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a patient')),
      );
      return;
    }
    if (_selectedBedId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a bed')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _api.post('/ward/admissions', data: {
        'patientId': _selectedPatientId,
        'encounterId': widget.encounterId ?? '',
        'wardId': widget.wardId,
        'bedId': _selectedBedId,
        'admissionType': _admissionType,
        'admissionReason': _admissionReason,
        'presentingComplaint': _presentingComplaint,
        'provisionalDiagnosis': _provisionalDiagnosis,
        'specialRequirements': _specialRequirements,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Patient admitted successfully')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admit Patient'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildPatientSelector(),
            const SizedBox(height: 24),
            _buildAdmissionTypeSelector(),
            const SizedBox(height: 16),
            _buildBedSelector(),
            const SizedBox(height: 16),
            _buildSpecialRequirements(),
            const SizedBox(height: 24),
            _buildReasonFields(),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Admit Patient'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Patient',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (_selectedPatientId != null)
          FutureBuilder(
            future: _api.get('/patients/$_selectedPatientId'),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const LinearProgressIndicator();
              }
              final patient = Patient.fromJson(snapshot.data!.data['data']);
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(patient.firstName.substring(0, 1)),
                  ),
                  title: Text(patient.fullName),
                  subtitle: Text(patient.patientNumber ?? ''),
                  trailing: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() => _selectedPatientId = null);
                    },
                  ),
                ),
              );
            },
          )
        else
          TextFormField(
            decoration: InputDecoration(
              hintText: 'Search patient by name or number',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _isSearchingPatients
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : null,
              border: const OutlineInputBorder(),
            ),
            onChanged: _searchPatients,
          ),
        if (_searchResults.isNotEmpty)
          Card(
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final patient = _searchResults[index];
                return ListTile(
                  leading: CircleAvatar(
                    child: Text(patient.firstName.substring(0, 1)),
                  ),
                  title: Text(patient.fullName),
                  subtitle: Text(patient.patientNumber ?? ''),
                  onTap: () {
                    setState(() {
                      _selectedPatientId = patient.id;
                      _searchResults = [];
                    });
                  },
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildAdmissionTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Admission Type',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            _AdmissionTypeChip(
              label: 'Emergency',
              value: 'emergency',
              selected: _admissionType == 'emergency',
              onSelected: (v) => setState(() => _admissionType = 'emergency'),
            ),
            _AdmissionTypeChip(
              label: 'Elective',
              value: 'elective',
              selected: _admissionType == 'elective',
              onSelected: (v) => setState(() => _admissionType = 'elective'),
            ),
            _AdmissionTypeChip(
              label: 'Transfer',
              value: 'transfer',
              selected: _admissionType == 'transfer',
              onSelected: (v) => setState(() => _admissionType = 'transfer'),
            ),
            _AdmissionTypeChip(
              label: 'Day Care',
              value: 'daycare',
              selected: _admissionType == 'daycare',
              onSelected: (v) => setState(() => _admissionType = 'daycare'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBedSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Bed',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        FutureBuilder(
          future: _api.get('/ward/beds', queryParameters: {'wardId': widget.wardId, 'status': 'available'}),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LinearProgressIndicator();
            }
            if (!snapshot.hasData) {
              return const Text('No data');
            }
            final beds = (snapshot.data!.data['data'] as List);
            if (beds.isEmpty) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.warning, color: Colors.orange[700]),
                      const SizedBox(width: 12),
                      const Text('No beds available in this ward'),
                    ],
                  ),
                ),
              );
            }
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: beds.map((bed) {
                final isSelected = _selectedBedId == bed['id'];
                return ChoiceChip(
                  label: Text('${bed['bedNumber']} (${bed['bedType']})'),
                  selected: isSelected,
                  onSelected: (v) {
                    setState(() => _selectedBedId = v ? bed['id'] : null);
                  },
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSpecialRequirements() {
    final options = ['Isolation', 'Fall Risk', 'NBM', 'IV Therapy', 'Oxygen', 'Suction'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Special Requirements',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final value = option.toUpperCase().replaceAll(' ', '_');
            final isSelected = _specialRequirements.contains(value);
            return FilterChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (v) {
                setState(() {
                  if (v) {
                    _specialRequirements.add(value);
                  } else {
                    _specialRequirements.remove(value);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildReasonFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Clinical Information',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Admission Reason *',
            border: OutlineInputBorder(),
          ),
          maxLines: 2,
          validator: (v) => v == null || v.isEmpty ? 'Required' : null,
          onChanged: (v) => _admissionReason = v,
        ),
        const SizedBox(height: 16),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Presenting Complaint',
            border: OutlineInputBorder(),
          ),
          maxLines: 2,
          onChanged: (v) => _presentingComplaint = v,
        ),
        const SizedBox(height: 16),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Provisional Diagnosis',
            border: OutlineInputBorder(),
          ),
          maxLines: 2,
          onChanged: (v) => _provisionalDiagnosis = v,
        ),
      ],
    );
  }
}

class _AdmissionTypeChip extends StatelessWidget {
  final String label;
  final String value;
  final bool selected;
  final Function(bool) onSelected;

  const _AdmissionTypeChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
    );
  }
}

class Patient {
  final String id;
  final String firstName;
  final String lastName;
  final String? patientNumber;

  Patient({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.patientNumber,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'],
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      patientNumber: json['patientNumber'],
    );
  }

  String get fullName => '$firstName $lastName';
}
