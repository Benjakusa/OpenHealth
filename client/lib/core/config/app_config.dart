class AppConfig {
  static const Map<String, String> genders = {
    'male': 'Male',
    'female': 'Female',
    'other': 'Other',
  };

  static const Map<String, String> visitTypes = {
    'new': 'New Visit',
    'follow_up': 'Follow-up',
    'emergency': 'Emergency',
    'prenatal': 'Prenatal',
    'well_child': 'Well Child',
  };

  static const List<String> supportedCounties = [
    'Nairobi',
    'Mombasa',
    'Kisumu',
    'Nakuru',
    'Eldoret',
    'Kehancha',
    'Kakamega',
    'Nyeri',
    'Machakos',
    'Kiambu',
    'Bungoma',
    'Kisii',
    'Kericho',
    'Homa Bay',
    'Migori',
    'Nanyuki',
    'Garissa',
    'Kisumu',
    'Mombasa',
    'Nairobi',
    'Nakuru',
    'Naivasha',
    'Kitale',
    'Malindi',
    'Kitui',
    'Meru',
    'Embu',
    'Thika',
    'Limuru',
    'Narok',
    'Kajiado',
    'Lamu',
    'Kilifi',
    'Tana River',
    'Taita Taveta',
    'Vihiga',
    'Busia',
    'Siaya',
    'Nyamira',
    'Trans Nzoia',
    'Uasin Gishu',
    'Nandi',
    'Elgeyo Marakwet',
    'Baringo',
    'Laikipia',
    'Samburu',
    'Isiolo',
    'Marsabit',
    'Moyale',
    'Wajir',
    'Mandera',
    'Somalia',
  ];

  static const List<String> departments = [
    'Registration',
    'Triage',
    'Consultation',
    'Laboratory',
    'Pharmacy',
    'Radiology',
    'Dental',
    'Optical',
    'Physiotherapy',
    'Maternity',
    'Pediatrics',
    'Surgery',
    'Emergency',
    'ICU',
    'Pharmacy',
    'Billing',
    'Records',
  ];

  static const Map<String, String> relationshipTypes = {
    'spouse': 'Spouse',
    'parent': 'Parent',
    'child': 'Child',
    'sibling': 'Sibling',
    'relative': 'Relative',
    'friend': 'Friend',
    'guardian': 'Guardian',
  };

  static const Map<String, String> paymentMethods = {
    'cash': 'Cash',
    'mpesa': 'M-Pesa',
    'card': 'Card',
    'insurance': 'Insurance',
    'sha': 'SHA',
    'bank': 'Bank Transfer',
  };

  static const Map<String, String> claimStatuses = {
    'draft': 'Draft',
    'submitted': 'Submitted',
    'pending': 'Pending Review',
    'approved': 'Approved',
    'rejected': 'Rejected',
    'paid': 'Paid',
    'partial': 'Partially Paid',
  };

  static const Map<String, String> labStatusLabels = {
    'pending': 'Pending Collection',
    'collected': 'Sample Collected',
    'processing': 'Processing',
    'completed': 'Completed',
    'cancelled': 'Cancelled',
    'resulted': 'Results Ready',
  };

  static const Map<String, String> prescriptionStatuses = {
    'pending': 'Pending',
    'verified': 'Verified',
    'dispensed': 'Dispensed',
    'partial': 'Partially Dispensed',
    'on_hold': 'On Hold',
    'cancelled': 'Cancelled',
  };

  static const Map<String, String> admissionStatuses = {
    'admitted': 'Admitted',
    'discharged': 'Discharged',
    'transferred': 'Transferred',
    'absconded': 'Absconded',
    'deceased': 'Deceased',
  };

  static const Map<String, String> bedStatuses = {
    'available': 'Available',
    'occupied': 'Occupied',
    'reserved': 'Reserved',
    'maintenance': 'Under Maintenance',
    'cleaning': 'Being Cleaned',
  };

  static const Map<String, String> vitalsUnits = {
    'temperature': '°C',
    'pulse': 'bpm',
    'bp_systolic': 'mmHg',
    'bp_diastolic': 'mmHg',
    'respiratory_rate': '/min',
    'spo2': '%',
    'weight': 'kg',
    'height': 'cm',
    'bmi': 'kg/m²',
    'glucose': 'mg/dL',
  };

  static const Map<String, String> vitalsLabels = {
    'temperature': 'Temperature',
    'pulse': 'Pulse Rate',
    'bp_systolic': 'BP Systolic',
    'bp_diastolic': 'BP Diastolic',
    'respiratory_rate': 'Respiratory Rate',
    'spo2': 'SpO2',
    'weight': 'Weight',
    'height': 'Height',
    'bmi': 'BMI',
    'glucose': 'Blood Glucose',
  };
}
