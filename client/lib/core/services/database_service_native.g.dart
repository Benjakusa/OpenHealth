// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database_service_native.dart';

// ignore_for_file: type=lint
class $PatientsTable extends Patients with TableInfo<$PatientsTable, Patient> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PatientsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tenantIdMeta =
      const VerificationMeta('tenantId');
  @override
  late final GeneratedColumn<String> tenantId = GeneratedColumn<String>(
      'tenant_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _patientNumberMeta =
      const VerificationMeta('patientNumber');
  @override
  late final GeneratedColumn<String> patientNumber = GeneratedColumn<String>(
      'patient_number', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _firstNameMeta =
      const VerificationMeta('firstName');
  @override
  late final GeneratedColumn<String> firstName = GeneratedColumn<String>(
      'first_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _lastNameMeta =
      const VerificationMeta('lastName');
  @override
  late final GeneratedColumn<String> lastName = GeneratedColumn<String>(
      'last_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _middleNameMeta =
      const VerificationMeta('middleName');
  @override
  late final GeneratedColumn<String> middleName = GeneratedColumn<String>(
      'middle_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _dateOfBirthMeta =
      const VerificationMeta('dateOfBirth');
  @override
  late final GeneratedColumn<DateTime> dateOfBirth = GeneratedColumn<DateTime>(
      'date_of_birth', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _genderMeta = const VerificationMeta('gender');
  @override
  late final GeneratedColumn<String> gender = GeneratedColumn<String>(
      'gender', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
      'phone', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _nationalIdMeta =
      const VerificationMeta('nationalId');
  @override
  late final GeneratedColumn<String> nationalId = GeneratedColumn<String>(
      'national_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _countyMeta = const VerificationMeta('county');
  @override
  late final GeneratedColumn<String> county = GeneratedColumn<String>(
      'county', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _addressMeta =
      const VerificationMeta('address');
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
      'address', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _allergiesMeta =
      const VerificationMeta('allergies');
  @override
  late final GeneratedColumn<String> allergies = GeneratedColumn<String>(
      'allergies', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _chronicConditionsMeta =
      const VerificationMeta('chronicConditions');
  @override
  late final GeneratedColumn<String> chronicConditions =
      GeneratedColumn<String>('chronic_conditions', aliasedName, false,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          defaultValue: const Constant('[]'));
  static const VerificationMeta _shaMeta = const VerificationMeta('sha');
  @override
  late final GeneratedColumn<String> sha = GeneratedColumn<String>(
      'sha', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _insuranceMeta =
      const VerificationMeta('insurance');
  @override
  late final GeneratedColumn<String> insurance = GeneratedColumn<String>(
      'insurance', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _emergencyContactMeta =
      const VerificationMeta('emergencyContact');
  @override
  late final GeneratedColumn<String> emergencyContact = GeneratedColumn<String>(
      'emergency_contact', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
      'synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        tenantId,
        patientNumber,
        firstName,
        lastName,
        middleName,
        dateOfBirth,
        gender,
        phone,
        nationalId,
        county,
        address,
        allergies,
        chronicConditions,
        sha,
        insurance,
        emergencyContact,
        isActive,
        createdAt,
        updatedAt,
        synced,
        syncStatus
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'patients';
  @override
  VerificationContext validateIntegrity(Insertable<Patient> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('tenant_id')) {
      context.handle(_tenantIdMeta,
          tenantId.isAcceptableOrUnknown(data['tenant_id']!, _tenantIdMeta));
    } else if (isInserting) {
      context.missing(_tenantIdMeta);
    }
    if (data.containsKey('patient_number')) {
      context.handle(
          _patientNumberMeta,
          patientNumber.isAcceptableOrUnknown(
              data['patient_number']!, _patientNumberMeta));
    } else if (isInserting) {
      context.missing(_patientNumberMeta);
    }
    if (data.containsKey('first_name')) {
      context.handle(_firstNameMeta,
          firstName.isAcceptableOrUnknown(data['first_name']!, _firstNameMeta));
    } else if (isInserting) {
      context.missing(_firstNameMeta);
    }
    if (data.containsKey('last_name')) {
      context.handle(_lastNameMeta,
          lastName.isAcceptableOrUnknown(data['last_name']!, _lastNameMeta));
    } else if (isInserting) {
      context.missing(_lastNameMeta);
    }
    if (data.containsKey('middle_name')) {
      context.handle(
          _middleNameMeta,
          middleName.isAcceptableOrUnknown(
              data['middle_name']!, _middleNameMeta));
    }
    if (data.containsKey('date_of_birth')) {
      context.handle(
          _dateOfBirthMeta,
          dateOfBirth.isAcceptableOrUnknown(
              data['date_of_birth']!, _dateOfBirthMeta));
    } else if (isInserting) {
      context.missing(_dateOfBirthMeta);
    }
    if (data.containsKey('gender')) {
      context.handle(_genderMeta,
          gender.isAcceptableOrUnknown(data['gender']!, _genderMeta));
    } else if (isInserting) {
      context.missing(_genderMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
          _phoneMeta, phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta));
    }
    if (data.containsKey('national_id')) {
      context.handle(
          _nationalIdMeta,
          nationalId.isAcceptableOrUnknown(
              data['national_id']!, _nationalIdMeta));
    }
    if (data.containsKey('county')) {
      context.handle(_countyMeta,
          county.isAcceptableOrUnknown(data['county']!, _countyMeta));
    }
    if (data.containsKey('address')) {
      context.handle(_addressMeta,
          address.isAcceptableOrUnknown(data['address']!, _addressMeta));
    }
    if (data.containsKey('allergies')) {
      context.handle(_allergiesMeta,
          allergies.isAcceptableOrUnknown(data['allergies']!, _allergiesMeta));
    }
    if (data.containsKey('chronic_conditions')) {
      context.handle(
          _chronicConditionsMeta,
          chronicConditions.isAcceptableOrUnknown(
              data['chronic_conditions']!, _chronicConditionsMeta));
    }
    if (data.containsKey('sha')) {
      context.handle(
          _shaMeta, sha.isAcceptableOrUnknown(data['sha']!, _shaMeta));
    }
    if (data.containsKey('insurance')) {
      context.handle(_insuranceMeta,
          insurance.isAcceptableOrUnknown(data['insurance']!, _insuranceMeta));
    }
    if (data.containsKey('emergency_contact')) {
      context.handle(
          _emergencyContactMeta,
          emergencyContact.isAcceptableOrUnknown(
              data['emergency_contact']!, _emergencyContactMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('synced')) {
      context.handle(_syncedMeta,
          synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Patient map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Patient(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      tenantId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tenant_id'])!,
      patientNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}patient_number'])!,
      firstName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}first_name'])!,
      lastName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_name'])!,
      middleName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}middle_name']),
      dateOfBirth: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}date_of_birth'])!,
      gender: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}gender'])!,
      phone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone']),
      nationalId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}national_id']),
      county: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}county']),
      address: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}address']),
      allergies: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}allergies'])!,
      chronicConditions: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}chronic_conditions'])!,
      sha: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sha']),
      insurance: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}insurance']),
      emergencyContact: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}emergency_contact']),
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      synced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}synced'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
    );
  }

  @override
  $PatientsTable createAlias(String alias) {
    return $PatientsTable(attachedDatabase, alias);
  }
}

class Patient extends DataClass implements Insertable<Patient> {
  final String id;
  final String tenantId;
  final String patientNumber;
  final String firstName;
  final String lastName;
  final String? middleName;
  final DateTime dateOfBirth;
  final String gender;
  final String? phone;
  final String? nationalId;
  final String? county;
  final String? address;
  final String allergies;
  final String chronicConditions;
  final String? sha;
  final String? insurance;
  final String? emergencyContact;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool synced;
  final String syncStatus;
  const Patient(
      {required this.id,
      required this.tenantId,
      required this.patientNumber,
      required this.firstName,
      required this.lastName,
      this.middleName,
      required this.dateOfBirth,
      required this.gender,
      this.phone,
      this.nationalId,
      this.county,
      this.address,
      required this.allergies,
      required this.chronicConditions,
      this.sha,
      this.insurance,
      this.emergencyContact,
      required this.isActive,
      required this.createdAt,
      required this.updatedAt,
      required this.synced,
      required this.syncStatus});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['tenant_id'] = Variable<String>(tenantId);
    map['patient_number'] = Variable<String>(patientNumber);
    map['first_name'] = Variable<String>(firstName);
    map['last_name'] = Variable<String>(lastName);
    if (!nullToAbsent || middleName != null) {
      map['middle_name'] = Variable<String>(middleName);
    }
    map['date_of_birth'] = Variable<DateTime>(dateOfBirth);
    map['gender'] = Variable<String>(gender);
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || nationalId != null) {
      map['national_id'] = Variable<String>(nationalId);
    }
    if (!nullToAbsent || county != null) {
      map['county'] = Variable<String>(county);
    }
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    map['allergies'] = Variable<String>(allergies);
    map['chronic_conditions'] = Variable<String>(chronicConditions);
    if (!nullToAbsent || sha != null) {
      map['sha'] = Variable<String>(sha);
    }
    if (!nullToAbsent || insurance != null) {
      map['insurance'] = Variable<String>(insurance);
    }
    if (!nullToAbsent || emergencyContact != null) {
      map['emergency_contact'] = Variable<String>(emergencyContact);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['synced'] = Variable<bool>(synced);
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  PatientsCompanion toCompanion(bool nullToAbsent) {
    return PatientsCompanion(
      id: Value(id),
      tenantId: Value(tenantId),
      patientNumber: Value(patientNumber),
      firstName: Value(firstName),
      lastName: Value(lastName),
      middleName: middleName == null && nullToAbsent
          ? const Value.absent()
          : Value(middleName),
      dateOfBirth: Value(dateOfBirth),
      gender: Value(gender),
      phone:
          phone == null && nullToAbsent ? const Value.absent() : Value(phone),
      nationalId: nationalId == null && nullToAbsent
          ? const Value.absent()
          : Value(nationalId),
      county:
          county == null && nullToAbsent ? const Value.absent() : Value(county),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      allergies: Value(allergies),
      chronicConditions: Value(chronicConditions),
      sha: sha == null && nullToAbsent ? const Value.absent() : Value(sha),
      insurance: insurance == null && nullToAbsent
          ? const Value.absent()
          : Value(insurance),
      emergencyContact: emergencyContact == null && nullToAbsent
          ? const Value.absent()
          : Value(emergencyContact),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      synced: Value(synced),
      syncStatus: Value(syncStatus),
    );
  }

  factory Patient.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Patient(
      id: serializer.fromJson<String>(json['id']),
      tenantId: serializer.fromJson<String>(json['tenantId']),
      patientNumber: serializer.fromJson<String>(json['patientNumber']),
      firstName: serializer.fromJson<String>(json['firstName']),
      lastName: serializer.fromJson<String>(json['lastName']),
      middleName: serializer.fromJson<String?>(json['middleName']),
      dateOfBirth: serializer.fromJson<DateTime>(json['dateOfBirth']),
      gender: serializer.fromJson<String>(json['gender']),
      phone: serializer.fromJson<String?>(json['phone']),
      nationalId: serializer.fromJson<String?>(json['nationalId']),
      county: serializer.fromJson<String?>(json['county']),
      address: serializer.fromJson<String?>(json['address']),
      allergies: serializer.fromJson<String>(json['allergies']),
      chronicConditions: serializer.fromJson<String>(json['chronicConditions']),
      sha: serializer.fromJson<String?>(json['sha']),
      insurance: serializer.fromJson<String?>(json['insurance']),
      emergencyContact: serializer.fromJson<String?>(json['emergencyContact']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      synced: serializer.fromJson<bool>(json['synced']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tenantId': serializer.toJson<String>(tenantId),
      'patientNumber': serializer.toJson<String>(patientNumber),
      'firstName': serializer.toJson<String>(firstName),
      'lastName': serializer.toJson<String>(lastName),
      'middleName': serializer.toJson<String?>(middleName),
      'dateOfBirth': serializer.toJson<DateTime>(dateOfBirth),
      'gender': serializer.toJson<String>(gender),
      'phone': serializer.toJson<String?>(phone),
      'nationalId': serializer.toJson<String?>(nationalId),
      'county': serializer.toJson<String?>(county),
      'address': serializer.toJson<String?>(address),
      'allergies': serializer.toJson<String>(allergies),
      'chronicConditions': serializer.toJson<String>(chronicConditions),
      'sha': serializer.toJson<String?>(sha),
      'insurance': serializer.toJson<String?>(insurance),
      'emergencyContact': serializer.toJson<String?>(emergencyContact),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'synced': serializer.toJson<bool>(synced),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  Patient copyWith(
          {String? id,
          String? tenantId,
          String? patientNumber,
          String? firstName,
          String? lastName,
          Value<String?> middleName = const Value.absent(),
          DateTime? dateOfBirth,
          String? gender,
          Value<String?> phone = const Value.absent(),
          Value<String?> nationalId = const Value.absent(),
          Value<String?> county = const Value.absent(),
          Value<String?> address = const Value.absent(),
          String? allergies,
          String? chronicConditions,
          Value<String?> sha = const Value.absent(),
          Value<String?> insurance = const Value.absent(),
          Value<String?> emergencyContact = const Value.absent(),
          bool? isActive,
          DateTime? createdAt,
          DateTime? updatedAt,
          bool? synced,
          String? syncStatus}) =>
      Patient(
        id: id ?? this.id,
        tenantId: tenantId ?? this.tenantId,
        patientNumber: patientNumber ?? this.patientNumber,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        middleName: middleName.present ? middleName.value : this.middleName,
        dateOfBirth: dateOfBirth ?? this.dateOfBirth,
        gender: gender ?? this.gender,
        phone: phone.present ? phone.value : this.phone,
        nationalId: nationalId.present ? nationalId.value : this.nationalId,
        county: county.present ? county.value : this.county,
        address: address.present ? address.value : this.address,
        allergies: allergies ?? this.allergies,
        chronicConditions: chronicConditions ?? this.chronicConditions,
        sha: sha.present ? sha.value : this.sha,
        insurance: insurance.present ? insurance.value : this.insurance,
        emergencyContact: emergencyContact.present
            ? emergencyContact.value
            : this.emergencyContact,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        synced: synced ?? this.synced,
        syncStatus: syncStatus ?? this.syncStatus,
      );
  Patient copyWithCompanion(PatientsCompanion data) {
    return Patient(
      id: data.id.present ? data.id.value : this.id,
      tenantId: data.tenantId.present ? data.tenantId.value : this.tenantId,
      patientNumber: data.patientNumber.present
          ? data.patientNumber.value
          : this.patientNumber,
      firstName: data.firstName.present ? data.firstName.value : this.firstName,
      lastName: data.lastName.present ? data.lastName.value : this.lastName,
      middleName:
          data.middleName.present ? data.middleName.value : this.middleName,
      dateOfBirth:
          data.dateOfBirth.present ? data.dateOfBirth.value : this.dateOfBirth,
      gender: data.gender.present ? data.gender.value : this.gender,
      phone: data.phone.present ? data.phone.value : this.phone,
      nationalId:
          data.nationalId.present ? data.nationalId.value : this.nationalId,
      county: data.county.present ? data.county.value : this.county,
      address: data.address.present ? data.address.value : this.address,
      allergies: data.allergies.present ? data.allergies.value : this.allergies,
      chronicConditions: data.chronicConditions.present
          ? data.chronicConditions.value
          : this.chronicConditions,
      sha: data.sha.present ? data.sha.value : this.sha,
      insurance: data.insurance.present ? data.insurance.value : this.insurance,
      emergencyContact: data.emergencyContact.present
          ? data.emergencyContact.value
          : this.emergencyContact,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      synced: data.synced.present ? data.synced.value : this.synced,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Patient(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('patientNumber: $patientNumber, ')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName, ')
          ..write('middleName: $middleName, ')
          ..write('dateOfBirth: $dateOfBirth, ')
          ..write('gender: $gender, ')
          ..write('phone: $phone, ')
          ..write('nationalId: $nationalId, ')
          ..write('county: $county, ')
          ..write('address: $address, ')
          ..write('allergies: $allergies, ')
          ..write('chronicConditions: $chronicConditions, ')
          ..write('sha: $sha, ')
          ..write('insurance: $insurance, ')
          ..write('emergencyContact: $emergencyContact, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('synced: $synced, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        tenantId,
        patientNumber,
        firstName,
        lastName,
        middleName,
        dateOfBirth,
        gender,
        phone,
        nationalId,
        county,
        address,
        allergies,
        chronicConditions,
        sha,
        insurance,
        emergencyContact,
        isActive,
        createdAt,
        updatedAt,
        synced,
        syncStatus
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Patient &&
          other.id == this.id &&
          other.tenantId == this.tenantId &&
          other.patientNumber == this.patientNumber &&
          other.firstName == this.firstName &&
          other.lastName == this.lastName &&
          other.middleName == this.middleName &&
          other.dateOfBirth == this.dateOfBirth &&
          other.gender == this.gender &&
          other.phone == this.phone &&
          other.nationalId == this.nationalId &&
          other.county == this.county &&
          other.address == this.address &&
          other.allergies == this.allergies &&
          other.chronicConditions == this.chronicConditions &&
          other.sha == this.sha &&
          other.insurance == this.insurance &&
          other.emergencyContact == this.emergencyContact &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.synced == this.synced &&
          other.syncStatus == this.syncStatus);
}

class PatientsCompanion extends UpdateCompanion<Patient> {
  final Value<String> id;
  final Value<String> tenantId;
  final Value<String> patientNumber;
  final Value<String> firstName;
  final Value<String> lastName;
  final Value<String?> middleName;
  final Value<DateTime> dateOfBirth;
  final Value<String> gender;
  final Value<String?> phone;
  final Value<String?> nationalId;
  final Value<String?> county;
  final Value<String?> address;
  final Value<String> allergies;
  final Value<String> chronicConditions;
  final Value<String?> sha;
  final Value<String?> insurance;
  final Value<String?> emergencyContact;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> synced;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const PatientsCompanion({
    this.id = const Value.absent(),
    this.tenantId = const Value.absent(),
    this.patientNumber = const Value.absent(),
    this.firstName = const Value.absent(),
    this.lastName = const Value.absent(),
    this.middleName = const Value.absent(),
    this.dateOfBirth = const Value.absent(),
    this.gender = const Value.absent(),
    this.phone = const Value.absent(),
    this.nationalId = const Value.absent(),
    this.county = const Value.absent(),
    this.address = const Value.absent(),
    this.allergies = const Value.absent(),
    this.chronicConditions = const Value.absent(),
    this.sha = const Value.absent(),
    this.insurance = const Value.absent(),
    this.emergencyContact = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PatientsCompanion.insert({
    required String id,
    required String tenantId,
    required String patientNumber,
    required String firstName,
    required String lastName,
    this.middleName = const Value.absent(),
    required DateTime dateOfBirth,
    required String gender,
    this.phone = const Value.absent(),
    this.nationalId = const Value.absent(),
    this.county = const Value.absent(),
    this.address = const Value.absent(),
    this.allergies = const Value.absent(),
    this.chronicConditions = const Value.absent(),
    this.sha = const Value.absent(),
    this.insurance = const Value.absent(),
    this.emergencyContact = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        tenantId = Value(tenantId),
        patientNumber = Value(patientNumber),
        firstName = Value(firstName),
        lastName = Value(lastName),
        dateOfBirth = Value(dateOfBirth),
        gender = Value(gender);
  static Insertable<Patient> custom({
    Expression<String>? id,
    Expression<String>? tenantId,
    Expression<String>? patientNumber,
    Expression<String>? firstName,
    Expression<String>? lastName,
    Expression<String>? middleName,
    Expression<DateTime>? dateOfBirth,
    Expression<String>? gender,
    Expression<String>? phone,
    Expression<String>? nationalId,
    Expression<String>? county,
    Expression<String>? address,
    Expression<String>? allergies,
    Expression<String>? chronicConditions,
    Expression<String>? sha,
    Expression<String>? insurance,
    Expression<String>? emergencyContact,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? synced,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tenantId != null) 'tenant_id': tenantId,
      if (patientNumber != null) 'patient_number': patientNumber,
      if (firstName != null) 'first_name': firstName,
      if (lastName != null) 'last_name': lastName,
      if (middleName != null) 'middle_name': middleName,
      if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
      if (gender != null) 'gender': gender,
      if (phone != null) 'phone': phone,
      if (nationalId != null) 'national_id': nationalId,
      if (county != null) 'county': county,
      if (address != null) 'address': address,
      if (allergies != null) 'allergies': allergies,
      if (chronicConditions != null) 'chronic_conditions': chronicConditions,
      if (sha != null) 'sha': sha,
      if (insurance != null) 'insurance': insurance,
      if (emergencyContact != null) 'emergency_contact': emergencyContact,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (synced != null) 'synced': synced,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PatientsCompanion copyWith(
      {Value<String>? id,
      Value<String>? tenantId,
      Value<String>? patientNumber,
      Value<String>? firstName,
      Value<String>? lastName,
      Value<String?>? middleName,
      Value<DateTime>? dateOfBirth,
      Value<String>? gender,
      Value<String?>? phone,
      Value<String?>? nationalId,
      Value<String?>? county,
      Value<String?>? address,
      Value<String>? allergies,
      Value<String>? chronicConditions,
      Value<String?>? sha,
      Value<String?>? insurance,
      Value<String?>? emergencyContact,
      Value<bool>? isActive,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<bool>? synced,
      Value<String>? syncStatus,
      Value<int>? rowid}) {
    return PatientsCompanion(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      patientNumber: patientNumber ?? this.patientNumber,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      middleName: middleName ?? this.middleName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      phone: phone ?? this.phone,
      nationalId: nationalId ?? this.nationalId,
      county: county ?? this.county,
      address: address ?? this.address,
      allergies: allergies ?? this.allergies,
      chronicConditions: chronicConditions ?? this.chronicConditions,
      sha: sha ?? this.sha,
      insurance: insurance ?? this.insurance,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      synced: synced ?? this.synced,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tenantId.present) {
      map['tenant_id'] = Variable<String>(tenantId.value);
    }
    if (patientNumber.present) {
      map['patient_number'] = Variable<String>(patientNumber.value);
    }
    if (firstName.present) {
      map['first_name'] = Variable<String>(firstName.value);
    }
    if (lastName.present) {
      map['last_name'] = Variable<String>(lastName.value);
    }
    if (middleName.present) {
      map['middle_name'] = Variable<String>(middleName.value);
    }
    if (dateOfBirth.present) {
      map['date_of_birth'] = Variable<DateTime>(dateOfBirth.value);
    }
    if (gender.present) {
      map['gender'] = Variable<String>(gender.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (nationalId.present) {
      map['national_id'] = Variable<String>(nationalId.value);
    }
    if (county.present) {
      map['county'] = Variable<String>(county.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (allergies.present) {
      map['allergies'] = Variable<String>(allergies.value);
    }
    if (chronicConditions.present) {
      map['chronic_conditions'] = Variable<String>(chronicConditions.value);
    }
    if (sha.present) {
      map['sha'] = Variable<String>(sha.value);
    }
    if (insurance.present) {
      map['insurance'] = Variable<String>(insurance.value);
    }
    if (emergencyContact.present) {
      map['emergency_contact'] = Variable<String>(emergencyContact.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PatientsCompanion(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('patientNumber: $patientNumber, ')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName, ')
          ..write('middleName: $middleName, ')
          ..write('dateOfBirth: $dateOfBirth, ')
          ..write('gender: $gender, ')
          ..write('phone: $phone, ')
          ..write('nationalId: $nationalId, ')
          ..write('county: $county, ')
          ..write('address: $address, ')
          ..write('allergies: $allergies, ')
          ..write('chronicConditions: $chronicConditions, ')
          ..write('sha: $sha, ')
          ..write('insurance: $insurance, ')
          ..write('emergencyContact: $emergencyContact, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('synced: $synced, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EncountersTable extends Encounters
    with TableInfo<$EncountersTable, Encounter> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EncountersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tenantIdMeta =
      const VerificationMeta('tenantId');
  @override
  late final GeneratedColumn<String> tenantId = GeneratedColumn<String>(
      'tenant_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _encounterNumberMeta =
      const VerificationMeta('encounterNumber');
  @override
  late final GeneratedColumn<String> encounterNumber = GeneratedColumn<String>(
      'encounter_number', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _patientIdMeta =
      const VerificationMeta('patientId');
  @override
  late final GeneratedColumn<String> patientId = GeneratedColumn<String>(
      'patient_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _providerIdMeta =
      const VerificationMeta('providerId');
  @override
  late final GeneratedColumn<String> providerId = GeneratedColumn<String>(
      'provider_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _visitTypeMeta =
      const VerificationMeta('visitType');
  @override
  late final GeneratedColumn<String> visitType = GeneratedColumn<String>(
      'visit_type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('new'));
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending_triage'));
  static const VerificationMeta _chiefComplaintMeta =
      const VerificationMeta('chiefComplaint');
  @override
  late final GeneratedColumn<String> chiefComplaint = GeneratedColumn<String>(
      'chief_complaint', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _triageMeta = const VerificationMeta('triage');
  @override
  late final GeneratedColumn<String> triage = GeneratedColumn<String>(
      'triage', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _vitalsMeta = const VerificationMeta('vitals');
  @override
  late final GeneratedColumn<String> vitals = GeneratedColumn<String>(
      'vitals', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _soapMeta = const VerificationMeta('soap');
  @override
  late final GeneratedColumn<String> soap = GeneratedColumn<String>(
      'soap', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _diagnosesMeta =
      const VerificationMeta('diagnoses');
  @override
  late final GeneratedColumn<String> diagnoses = GeneratedColumn<String>(
      'diagnoses', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _prescriptionsMeta =
      const VerificationMeta('prescriptions');
  @override
  late final GeneratedColumn<String> prescriptions = GeneratedColumn<String>(
      'prescriptions', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _labOrdersMeta =
      const VerificationMeta('labOrders');
  @override
  late final GeneratedColumn<String> labOrders = GeneratedColumn<String>(
      'lab_orders', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _dispositionMeta =
      const VerificationMeta('disposition');
  @override
  late final GeneratedColumn<String> disposition = GeneratedColumn<String>(
      'disposition', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _billingMeta =
      const VerificationMeta('billing');
  @override
  late final GeneratedColumn<String> billing = GeneratedColumn<String>(
      'billing', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isLockedMeta =
      const VerificationMeta('isLocked');
  @override
  late final GeneratedColumn<bool> isLocked = GeneratedColumn<bool>(
      'is_locked', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_locked" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _scheduledAtMeta =
      const VerificationMeta('scheduledAt');
  @override
  late final GeneratedColumn<DateTime> scheduledAt = GeneratedColumn<DateTime>(
      'scheduled_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _startedAtMeta =
      const VerificationMeta('startedAt');
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
      'started_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _completedAtMeta =
      const VerificationMeta('completedAt');
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
      'completed_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
      'synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        tenantId,
        encounterNumber,
        patientId,
        providerId,
        visitType,
        status,
        chiefComplaint,
        triage,
        vitals,
        soap,
        diagnoses,
        prescriptions,
        labOrders,
        disposition,
        billing,
        isLocked,
        scheduledAt,
        startedAt,
        completedAt,
        createdAt,
        updatedAt,
        synced,
        syncStatus
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'encounters';
  @override
  VerificationContext validateIntegrity(Insertable<Encounter> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('tenant_id')) {
      context.handle(_tenantIdMeta,
          tenantId.isAcceptableOrUnknown(data['tenant_id']!, _tenantIdMeta));
    } else if (isInserting) {
      context.missing(_tenantIdMeta);
    }
    if (data.containsKey('encounter_number')) {
      context.handle(
          _encounterNumberMeta,
          encounterNumber.isAcceptableOrUnknown(
              data['encounter_number']!, _encounterNumberMeta));
    } else if (isInserting) {
      context.missing(_encounterNumberMeta);
    }
    if (data.containsKey('patient_id')) {
      context.handle(_patientIdMeta,
          patientId.isAcceptableOrUnknown(data['patient_id']!, _patientIdMeta));
    } else if (isInserting) {
      context.missing(_patientIdMeta);
    }
    if (data.containsKey('provider_id')) {
      context.handle(
          _providerIdMeta,
          providerId.isAcceptableOrUnknown(
              data['provider_id']!, _providerIdMeta));
    } else if (isInserting) {
      context.missing(_providerIdMeta);
    }
    if (data.containsKey('visit_type')) {
      context.handle(_visitTypeMeta,
          visitType.isAcceptableOrUnknown(data['visit_type']!, _visitTypeMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('chief_complaint')) {
      context.handle(
          _chiefComplaintMeta,
          chiefComplaint.isAcceptableOrUnknown(
              data['chief_complaint']!, _chiefComplaintMeta));
    }
    if (data.containsKey('triage')) {
      context.handle(_triageMeta,
          triage.isAcceptableOrUnknown(data['triage']!, _triageMeta));
    }
    if (data.containsKey('vitals')) {
      context.handle(_vitalsMeta,
          vitals.isAcceptableOrUnknown(data['vitals']!, _vitalsMeta));
    }
    if (data.containsKey('soap')) {
      context.handle(
          _soapMeta, soap.isAcceptableOrUnknown(data['soap']!, _soapMeta));
    }
    if (data.containsKey('diagnoses')) {
      context.handle(_diagnosesMeta,
          diagnoses.isAcceptableOrUnknown(data['diagnoses']!, _diagnosesMeta));
    }
    if (data.containsKey('prescriptions')) {
      context.handle(
          _prescriptionsMeta,
          prescriptions.isAcceptableOrUnknown(
              data['prescriptions']!, _prescriptionsMeta));
    }
    if (data.containsKey('lab_orders')) {
      context.handle(_labOrdersMeta,
          labOrders.isAcceptableOrUnknown(data['lab_orders']!, _labOrdersMeta));
    }
    if (data.containsKey('disposition')) {
      context.handle(
          _dispositionMeta,
          disposition.isAcceptableOrUnknown(
              data['disposition']!, _dispositionMeta));
    }
    if (data.containsKey('billing')) {
      context.handle(_billingMeta,
          billing.isAcceptableOrUnknown(data['billing']!, _billingMeta));
    }
    if (data.containsKey('is_locked')) {
      context.handle(_isLockedMeta,
          isLocked.isAcceptableOrUnknown(data['is_locked']!, _isLockedMeta));
    }
    if (data.containsKey('scheduled_at')) {
      context.handle(
          _scheduledAtMeta,
          scheduledAt.isAcceptableOrUnknown(
              data['scheduled_at']!, _scheduledAtMeta));
    }
    if (data.containsKey('started_at')) {
      context.handle(_startedAtMeta,
          startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta));
    }
    if (data.containsKey('completed_at')) {
      context.handle(
          _completedAtMeta,
          completedAt.isAcceptableOrUnknown(
              data['completed_at']!, _completedAtMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('synced')) {
      context.handle(_syncedMeta,
          synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Encounter map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Encounter(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      tenantId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tenant_id'])!,
      encounterNumber: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}encounter_number'])!,
      patientId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}patient_id'])!,
      providerId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}provider_id'])!,
      visitType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}visit_type'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      chiefComplaint: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}chief_complaint']),
      triage: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}triage']),
      vitals: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}vitals']),
      soap: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}soap']),
      diagnoses: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}diagnoses'])!,
      prescriptions: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}prescriptions'])!,
      labOrders: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}lab_orders'])!,
      disposition: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}disposition']),
      billing: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}billing']),
      isLocked: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_locked'])!,
      scheduledAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}scheduled_at']),
      startedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}started_at']),
      completedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}completed_at']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      synced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}synced'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
    );
  }

  @override
  $EncountersTable createAlias(String alias) {
    return $EncountersTable(attachedDatabase, alias);
  }
}

class Encounter extends DataClass implements Insertable<Encounter> {
  final String id;
  final String tenantId;
  final String encounterNumber;
  final String patientId;
  final String providerId;
  final String visitType;
  final String status;
  final String? chiefComplaint;
  final String? triage;
  final String? vitals;
  final String? soap;
  final String diagnoses;
  final String prescriptions;
  final String labOrders;
  final String? disposition;
  final String? billing;
  final bool isLocked;
  final DateTime? scheduledAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool synced;
  final String syncStatus;
  const Encounter(
      {required this.id,
      required this.tenantId,
      required this.encounterNumber,
      required this.patientId,
      required this.providerId,
      required this.visitType,
      required this.status,
      this.chiefComplaint,
      this.triage,
      this.vitals,
      this.soap,
      required this.diagnoses,
      required this.prescriptions,
      required this.labOrders,
      this.disposition,
      this.billing,
      required this.isLocked,
      this.scheduledAt,
      this.startedAt,
      this.completedAt,
      required this.createdAt,
      required this.updatedAt,
      required this.synced,
      required this.syncStatus});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['tenant_id'] = Variable<String>(tenantId);
    map['encounter_number'] = Variable<String>(encounterNumber);
    map['patient_id'] = Variable<String>(patientId);
    map['provider_id'] = Variable<String>(providerId);
    map['visit_type'] = Variable<String>(visitType);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || chiefComplaint != null) {
      map['chief_complaint'] = Variable<String>(chiefComplaint);
    }
    if (!nullToAbsent || triage != null) {
      map['triage'] = Variable<String>(triage);
    }
    if (!nullToAbsent || vitals != null) {
      map['vitals'] = Variable<String>(vitals);
    }
    if (!nullToAbsent || soap != null) {
      map['soap'] = Variable<String>(soap);
    }
    map['diagnoses'] = Variable<String>(diagnoses);
    map['prescriptions'] = Variable<String>(prescriptions);
    map['lab_orders'] = Variable<String>(labOrders);
    if (!nullToAbsent || disposition != null) {
      map['disposition'] = Variable<String>(disposition);
    }
    if (!nullToAbsent || billing != null) {
      map['billing'] = Variable<String>(billing);
    }
    map['is_locked'] = Variable<bool>(isLocked);
    if (!nullToAbsent || scheduledAt != null) {
      map['scheduled_at'] = Variable<DateTime>(scheduledAt);
    }
    if (!nullToAbsent || startedAt != null) {
      map['started_at'] = Variable<DateTime>(startedAt);
    }
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['synced'] = Variable<bool>(synced);
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  EncountersCompanion toCompanion(bool nullToAbsent) {
    return EncountersCompanion(
      id: Value(id),
      tenantId: Value(tenantId),
      encounterNumber: Value(encounterNumber),
      patientId: Value(patientId),
      providerId: Value(providerId),
      visitType: Value(visitType),
      status: Value(status),
      chiefComplaint: chiefComplaint == null && nullToAbsent
          ? const Value.absent()
          : Value(chiefComplaint),
      triage:
          triage == null && nullToAbsent ? const Value.absent() : Value(triage),
      vitals:
          vitals == null && nullToAbsent ? const Value.absent() : Value(vitals),
      soap: soap == null && nullToAbsent ? const Value.absent() : Value(soap),
      diagnoses: Value(diagnoses),
      prescriptions: Value(prescriptions),
      labOrders: Value(labOrders),
      disposition: disposition == null && nullToAbsent
          ? const Value.absent()
          : Value(disposition),
      billing: billing == null && nullToAbsent
          ? const Value.absent()
          : Value(billing),
      isLocked: Value(isLocked),
      scheduledAt: scheduledAt == null && nullToAbsent
          ? const Value.absent()
          : Value(scheduledAt),
      startedAt: startedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(startedAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      synced: Value(synced),
      syncStatus: Value(syncStatus),
    );
  }

  factory Encounter.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Encounter(
      id: serializer.fromJson<String>(json['id']),
      tenantId: serializer.fromJson<String>(json['tenantId']),
      encounterNumber: serializer.fromJson<String>(json['encounterNumber']),
      patientId: serializer.fromJson<String>(json['patientId']),
      providerId: serializer.fromJson<String>(json['providerId']),
      visitType: serializer.fromJson<String>(json['visitType']),
      status: serializer.fromJson<String>(json['status']),
      chiefComplaint: serializer.fromJson<String?>(json['chiefComplaint']),
      triage: serializer.fromJson<String?>(json['triage']),
      vitals: serializer.fromJson<String?>(json['vitals']),
      soap: serializer.fromJson<String?>(json['soap']),
      diagnoses: serializer.fromJson<String>(json['diagnoses']),
      prescriptions: serializer.fromJson<String>(json['prescriptions']),
      labOrders: serializer.fromJson<String>(json['labOrders']),
      disposition: serializer.fromJson<String?>(json['disposition']),
      billing: serializer.fromJson<String?>(json['billing']),
      isLocked: serializer.fromJson<bool>(json['isLocked']),
      scheduledAt: serializer.fromJson<DateTime?>(json['scheduledAt']),
      startedAt: serializer.fromJson<DateTime?>(json['startedAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      synced: serializer.fromJson<bool>(json['synced']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tenantId': serializer.toJson<String>(tenantId),
      'encounterNumber': serializer.toJson<String>(encounterNumber),
      'patientId': serializer.toJson<String>(patientId),
      'providerId': serializer.toJson<String>(providerId),
      'visitType': serializer.toJson<String>(visitType),
      'status': serializer.toJson<String>(status),
      'chiefComplaint': serializer.toJson<String?>(chiefComplaint),
      'triage': serializer.toJson<String?>(triage),
      'vitals': serializer.toJson<String?>(vitals),
      'soap': serializer.toJson<String?>(soap),
      'diagnoses': serializer.toJson<String>(diagnoses),
      'prescriptions': serializer.toJson<String>(prescriptions),
      'labOrders': serializer.toJson<String>(labOrders),
      'disposition': serializer.toJson<String?>(disposition),
      'billing': serializer.toJson<String?>(billing),
      'isLocked': serializer.toJson<bool>(isLocked),
      'scheduledAt': serializer.toJson<DateTime?>(scheduledAt),
      'startedAt': serializer.toJson<DateTime?>(startedAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'synced': serializer.toJson<bool>(synced),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  Encounter copyWith(
          {String? id,
          String? tenantId,
          String? encounterNumber,
          String? patientId,
          String? providerId,
          String? visitType,
          String? status,
          Value<String?> chiefComplaint = const Value.absent(),
          Value<String?> triage = const Value.absent(),
          Value<String?> vitals = const Value.absent(),
          Value<String?> soap = const Value.absent(),
          String? diagnoses,
          String? prescriptions,
          String? labOrders,
          Value<String?> disposition = const Value.absent(),
          Value<String?> billing = const Value.absent(),
          bool? isLocked,
          Value<DateTime?> scheduledAt = const Value.absent(),
          Value<DateTime?> startedAt = const Value.absent(),
          Value<DateTime?> completedAt = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt,
          bool? synced,
          String? syncStatus}) =>
      Encounter(
        id: id ?? this.id,
        tenantId: tenantId ?? this.tenantId,
        encounterNumber: encounterNumber ?? this.encounterNumber,
        patientId: patientId ?? this.patientId,
        providerId: providerId ?? this.providerId,
        visitType: visitType ?? this.visitType,
        status: status ?? this.status,
        chiefComplaint:
            chiefComplaint.present ? chiefComplaint.value : this.chiefComplaint,
        triage: triage.present ? triage.value : this.triage,
        vitals: vitals.present ? vitals.value : this.vitals,
        soap: soap.present ? soap.value : this.soap,
        diagnoses: diagnoses ?? this.diagnoses,
        prescriptions: prescriptions ?? this.prescriptions,
        labOrders: labOrders ?? this.labOrders,
        disposition: disposition.present ? disposition.value : this.disposition,
        billing: billing.present ? billing.value : this.billing,
        isLocked: isLocked ?? this.isLocked,
        scheduledAt: scheduledAt.present ? scheduledAt.value : this.scheduledAt,
        startedAt: startedAt.present ? startedAt.value : this.startedAt,
        completedAt: completedAt.present ? completedAt.value : this.completedAt,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        synced: synced ?? this.synced,
        syncStatus: syncStatus ?? this.syncStatus,
      );
  Encounter copyWithCompanion(EncountersCompanion data) {
    return Encounter(
      id: data.id.present ? data.id.value : this.id,
      tenantId: data.tenantId.present ? data.tenantId.value : this.tenantId,
      encounterNumber: data.encounterNumber.present
          ? data.encounterNumber.value
          : this.encounterNumber,
      patientId: data.patientId.present ? data.patientId.value : this.patientId,
      providerId:
          data.providerId.present ? data.providerId.value : this.providerId,
      visitType: data.visitType.present ? data.visitType.value : this.visitType,
      status: data.status.present ? data.status.value : this.status,
      chiefComplaint: data.chiefComplaint.present
          ? data.chiefComplaint.value
          : this.chiefComplaint,
      triage: data.triage.present ? data.triage.value : this.triage,
      vitals: data.vitals.present ? data.vitals.value : this.vitals,
      soap: data.soap.present ? data.soap.value : this.soap,
      diagnoses: data.diagnoses.present ? data.diagnoses.value : this.diagnoses,
      prescriptions: data.prescriptions.present
          ? data.prescriptions.value
          : this.prescriptions,
      labOrders: data.labOrders.present ? data.labOrders.value : this.labOrders,
      disposition:
          data.disposition.present ? data.disposition.value : this.disposition,
      billing: data.billing.present ? data.billing.value : this.billing,
      isLocked: data.isLocked.present ? data.isLocked.value : this.isLocked,
      scheduledAt:
          data.scheduledAt.present ? data.scheduledAt.value : this.scheduledAt,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      completedAt:
          data.completedAt.present ? data.completedAt.value : this.completedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      synced: data.synced.present ? data.synced.value : this.synced,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Encounter(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('encounterNumber: $encounterNumber, ')
          ..write('patientId: $patientId, ')
          ..write('providerId: $providerId, ')
          ..write('visitType: $visitType, ')
          ..write('status: $status, ')
          ..write('chiefComplaint: $chiefComplaint, ')
          ..write('triage: $triage, ')
          ..write('vitals: $vitals, ')
          ..write('soap: $soap, ')
          ..write('diagnoses: $diagnoses, ')
          ..write('prescriptions: $prescriptions, ')
          ..write('labOrders: $labOrders, ')
          ..write('disposition: $disposition, ')
          ..write('billing: $billing, ')
          ..write('isLocked: $isLocked, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('synced: $synced, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        tenantId,
        encounterNumber,
        patientId,
        providerId,
        visitType,
        status,
        chiefComplaint,
        triage,
        vitals,
        soap,
        diagnoses,
        prescriptions,
        labOrders,
        disposition,
        billing,
        isLocked,
        scheduledAt,
        startedAt,
        completedAt,
        createdAt,
        updatedAt,
        synced,
        syncStatus
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Encounter &&
          other.id == this.id &&
          other.tenantId == this.tenantId &&
          other.encounterNumber == this.encounterNumber &&
          other.patientId == this.patientId &&
          other.providerId == this.providerId &&
          other.visitType == this.visitType &&
          other.status == this.status &&
          other.chiefComplaint == this.chiefComplaint &&
          other.triage == this.triage &&
          other.vitals == this.vitals &&
          other.soap == this.soap &&
          other.diagnoses == this.diagnoses &&
          other.prescriptions == this.prescriptions &&
          other.labOrders == this.labOrders &&
          other.disposition == this.disposition &&
          other.billing == this.billing &&
          other.isLocked == this.isLocked &&
          other.scheduledAt == this.scheduledAt &&
          other.startedAt == this.startedAt &&
          other.completedAt == this.completedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.synced == this.synced &&
          other.syncStatus == this.syncStatus);
}

class EncountersCompanion extends UpdateCompanion<Encounter> {
  final Value<String> id;
  final Value<String> tenantId;
  final Value<String> encounterNumber;
  final Value<String> patientId;
  final Value<String> providerId;
  final Value<String> visitType;
  final Value<String> status;
  final Value<String?> chiefComplaint;
  final Value<String?> triage;
  final Value<String?> vitals;
  final Value<String?> soap;
  final Value<String> diagnoses;
  final Value<String> prescriptions;
  final Value<String> labOrders;
  final Value<String?> disposition;
  final Value<String?> billing;
  final Value<bool> isLocked;
  final Value<DateTime?> scheduledAt;
  final Value<DateTime?> startedAt;
  final Value<DateTime?> completedAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> synced;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const EncountersCompanion({
    this.id = const Value.absent(),
    this.tenantId = const Value.absent(),
    this.encounterNumber = const Value.absent(),
    this.patientId = const Value.absent(),
    this.providerId = const Value.absent(),
    this.visitType = const Value.absent(),
    this.status = const Value.absent(),
    this.chiefComplaint = const Value.absent(),
    this.triage = const Value.absent(),
    this.vitals = const Value.absent(),
    this.soap = const Value.absent(),
    this.diagnoses = const Value.absent(),
    this.prescriptions = const Value.absent(),
    this.labOrders = const Value.absent(),
    this.disposition = const Value.absent(),
    this.billing = const Value.absent(),
    this.isLocked = const Value.absent(),
    this.scheduledAt = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EncountersCompanion.insert({
    required String id,
    required String tenantId,
    required String encounterNumber,
    required String patientId,
    required String providerId,
    this.visitType = const Value.absent(),
    this.status = const Value.absent(),
    this.chiefComplaint = const Value.absent(),
    this.triage = const Value.absent(),
    this.vitals = const Value.absent(),
    this.soap = const Value.absent(),
    this.diagnoses = const Value.absent(),
    this.prescriptions = const Value.absent(),
    this.labOrders = const Value.absent(),
    this.disposition = const Value.absent(),
    this.billing = const Value.absent(),
    this.isLocked = const Value.absent(),
    this.scheduledAt = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        tenantId = Value(tenantId),
        encounterNumber = Value(encounterNumber),
        patientId = Value(patientId),
        providerId = Value(providerId);
  static Insertable<Encounter> custom({
    Expression<String>? id,
    Expression<String>? tenantId,
    Expression<String>? encounterNumber,
    Expression<String>? patientId,
    Expression<String>? providerId,
    Expression<String>? visitType,
    Expression<String>? status,
    Expression<String>? chiefComplaint,
    Expression<String>? triage,
    Expression<String>? vitals,
    Expression<String>? soap,
    Expression<String>? diagnoses,
    Expression<String>? prescriptions,
    Expression<String>? labOrders,
    Expression<String>? disposition,
    Expression<String>? billing,
    Expression<bool>? isLocked,
    Expression<DateTime>? scheduledAt,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? completedAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? synced,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tenantId != null) 'tenant_id': tenantId,
      if (encounterNumber != null) 'encounter_number': encounterNumber,
      if (patientId != null) 'patient_id': patientId,
      if (providerId != null) 'provider_id': providerId,
      if (visitType != null) 'visit_type': visitType,
      if (status != null) 'status': status,
      if (chiefComplaint != null) 'chief_complaint': chiefComplaint,
      if (triage != null) 'triage': triage,
      if (vitals != null) 'vitals': vitals,
      if (soap != null) 'soap': soap,
      if (diagnoses != null) 'diagnoses': diagnoses,
      if (prescriptions != null) 'prescriptions': prescriptions,
      if (labOrders != null) 'lab_orders': labOrders,
      if (disposition != null) 'disposition': disposition,
      if (billing != null) 'billing': billing,
      if (isLocked != null) 'is_locked': isLocked,
      if (scheduledAt != null) 'scheduled_at': scheduledAt,
      if (startedAt != null) 'started_at': startedAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (synced != null) 'synced': synced,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EncountersCompanion copyWith(
      {Value<String>? id,
      Value<String>? tenantId,
      Value<String>? encounterNumber,
      Value<String>? patientId,
      Value<String>? providerId,
      Value<String>? visitType,
      Value<String>? status,
      Value<String?>? chiefComplaint,
      Value<String?>? triage,
      Value<String?>? vitals,
      Value<String?>? soap,
      Value<String>? diagnoses,
      Value<String>? prescriptions,
      Value<String>? labOrders,
      Value<String?>? disposition,
      Value<String?>? billing,
      Value<bool>? isLocked,
      Value<DateTime?>? scheduledAt,
      Value<DateTime?>? startedAt,
      Value<DateTime?>? completedAt,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<bool>? synced,
      Value<String>? syncStatus,
      Value<int>? rowid}) {
    return EncountersCompanion(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      encounterNumber: encounterNumber ?? this.encounterNumber,
      patientId: patientId ?? this.patientId,
      providerId: providerId ?? this.providerId,
      visitType: visitType ?? this.visitType,
      status: status ?? this.status,
      chiefComplaint: chiefComplaint ?? this.chiefComplaint,
      triage: triage ?? this.triage,
      vitals: vitals ?? this.vitals,
      soap: soap ?? this.soap,
      diagnoses: diagnoses ?? this.diagnoses,
      prescriptions: prescriptions ?? this.prescriptions,
      labOrders: labOrders ?? this.labOrders,
      disposition: disposition ?? this.disposition,
      billing: billing ?? this.billing,
      isLocked: isLocked ?? this.isLocked,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      synced: synced ?? this.synced,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tenantId.present) {
      map['tenant_id'] = Variable<String>(tenantId.value);
    }
    if (encounterNumber.present) {
      map['encounter_number'] = Variable<String>(encounterNumber.value);
    }
    if (patientId.present) {
      map['patient_id'] = Variable<String>(patientId.value);
    }
    if (providerId.present) {
      map['provider_id'] = Variable<String>(providerId.value);
    }
    if (visitType.present) {
      map['visit_type'] = Variable<String>(visitType.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (chiefComplaint.present) {
      map['chief_complaint'] = Variable<String>(chiefComplaint.value);
    }
    if (triage.present) {
      map['triage'] = Variable<String>(triage.value);
    }
    if (vitals.present) {
      map['vitals'] = Variable<String>(vitals.value);
    }
    if (soap.present) {
      map['soap'] = Variable<String>(soap.value);
    }
    if (diagnoses.present) {
      map['diagnoses'] = Variable<String>(diagnoses.value);
    }
    if (prescriptions.present) {
      map['prescriptions'] = Variable<String>(prescriptions.value);
    }
    if (labOrders.present) {
      map['lab_orders'] = Variable<String>(labOrders.value);
    }
    if (disposition.present) {
      map['disposition'] = Variable<String>(disposition.value);
    }
    if (billing.present) {
      map['billing'] = Variable<String>(billing.value);
    }
    if (isLocked.present) {
      map['is_locked'] = Variable<bool>(isLocked.value);
    }
    if (scheduledAt.present) {
      map['scheduled_at'] = Variable<DateTime>(scheduledAt.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EncountersCompanion(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('encounterNumber: $encounterNumber, ')
          ..write('patientId: $patientId, ')
          ..write('providerId: $providerId, ')
          ..write('visitType: $visitType, ')
          ..write('status: $status, ')
          ..write('chiefComplaint: $chiefComplaint, ')
          ..write('triage: $triage, ')
          ..write('vitals: $vitals, ')
          ..write('soap: $soap, ')
          ..write('diagnoses: $diagnoses, ')
          ..write('prescriptions: $prescriptions, ')
          ..write('labOrders: $labOrders, ')
          ..write('disposition: $disposition, ')
          ..write('billing: $billing, ')
          ..write('isLocked: $isLocked, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('synced: $synced, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BillingTable extends Billing with TableInfo<$BillingTable, BillingData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BillingTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tenantIdMeta =
      const VerificationMeta('tenantId');
  @override
  late final GeneratedColumn<String> tenantId = GeneratedColumn<String>(
      'tenant_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _invoiceNumberMeta =
      const VerificationMeta('invoiceNumber');
  @override
  late final GeneratedColumn<String> invoiceNumber = GeneratedColumn<String>(
      'invoice_number', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _encounterIdMeta =
      const VerificationMeta('encounterId');
  @override
  late final GeneratedColumn<String> encounterId = GeneratedColumn<String>(
      'encounter_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _patientIdMeta =
      const VerificationMeta('patientId');
  @override
  late final GeneratedColumn<String> patientId = GeneratedColumn<String>(
      'patient_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('consultation'));
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('draft'));
  static const VerificationMeta _itemsMeta = const VerificationMeta('items');
  @override
  late final GeneratedColumn<String> items = GeneratedColumn<String>(
      'items', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _subtotalMeta =
      const VerificationMeta('subtotal');
  @override
  late final GeneratedColumn<double> subtotal = GeneratedColumn<double>(
      'subtotal', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _discountMeta =
      const VerificationMeta('discount');
  @override
  late final GeneratedColumn<double> discount = GeneratedColumn<double>(
      'discount', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _totalMeta = const VerificationMeta('total');
  @override
  late final GeneratedColumn<double> total = GeneratedColumn<double>(
      'total', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _shaCoverMeta =
      const VerificationMeta('shaCover');
  @override
  late final GeneratedColumn<double> shaCover = GeneratedColumn<double>(
      'sha_cover', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _insuranceCoverMeta =
      const VerificationMeta('insuranceCover');
  @override
  late final GeneratedColumn<double> insuranceCover = GeneratedColumn<double>(
      'insurance_cover', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _patientPayMeta =
      const VerificationMeta('patientPay');
  @override
  late final GeneratedColumn<double> patientPay = GeneratedColumn<double>(
      'patient_pay', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _amountPaidMeta =
      const VerificationMeta('amountPaid');
  @override
  late final GeneratedColumn<double> amountPaid = GeneratedColumn<double>(
      'amount_paid', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _balanceMeta =
      const VerificationMeta('balance');
  @override
  late final GeneratedColumn<double> balance = GeneratedColumn<double>(
      'balance', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _paymentsMeta =
      const VerificationMeta('payments');
  @override
  late final GeneratedColumn<String> payments = GeneratedColumn<String>(
      'payments', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
      'synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        tenantId,
        invoiceNumber,
        encounterId,
        patientId,
        type,
        status,
        items,
        subtotal,
        discount,
        total,
        shaCover,
        insuranceCover,
        patientPay,
        amountPaid,
        balance,
        payments,
        createdAt,
        updatedAt,
        synced,
        syncStatus
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'billing';
  @override
  VerificationContext validateIntegrity(Insertable<BillingData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('tenant_id')) {
      context.handle(_tenantIdMeta,
          tenantId.isAcceptableOrUnknown(data['tenant_id']!, _tenantIdMeta));
    } else if (isInserting) {
      context.missing(_tenantIdMeta);
    }
    if (data.containsKey('invoice_number')) {
      context.handle(
          _invoiceNumberMeta,
          invoiceNumber.isAcceptableOrUnknown(
              data['invoice_number']!, _invoiceNumberMeta));
    } else if (isInserting) {
      context.missing(_invoiceNumberMeta);
    }
    if (data.containsKey('encounter_id')) {
      context.handle(
          _encounterIdMeta,
          encounterId.isAcceptableOrUnknown(
              data['encounter_id']!, _encounterIdMeta));
    }
    if (data.containsKey('patient_id')) {
      context.handle(_patientIdMeta,
          patientId.isAcceptableOrUnknown(data['patient_id']!, _patientIdMeta));
    } else if (isInserting) {
      context.missing(_patientIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('items')) {
      context.handle(
          _itemsMeta, items.isAcceptableOrUnknown(data['items']!, _itemsMeta));
    }
    if (data.containsKey('subtotal')) {
      context.handle(_subtotalMeta,
          subtotal.isAcceptableOrUnknown(data['subtotal']!, _subtotalMeta));
    }
    if (data.containsKey('discount')) {
      context.handle(_discountMeta,
          discount.isAcceptableOrUnknown(data['discount']!, _discountMeta));
    }
    if (data.containsKey('total')) {
      context.handle(
          _totalMeta, total.isAcceptableOrUnknown(data['total']!, _totalMeta));
    }
    if (data.containsKey('sha_cover')) {
      context.handle(_shaCoverMeta,
          shaCover.isAcceptableOrUnknown(data['sha_cover']!, _shaCoverMeta));
    }
    if (data.containsKey('insurance_cover')) {
      context.handle(
          _insuranceCoverMeta,
          insuranceCover.isAcceptableOrUnknown(
              data['insurance_cover']!, _insuranceCoverMeta));
    }
    if (data.containsKey('patient_pay')) {
      context.handle(
          _patientPayMeta,
          patientPay.isAcceptableOrUnknown(
              data['patient_pay']!, _patientPayMeta));
    }
    if (data.containsKey('amount_paid')) {
      context.handle(
          _amountPaidMeta,
          amountPaid.isAcceptableOrUnknown(
              data['amount_paid']!, _amountPaidMeta));
    }
    if (data.containsKey('balance')) {
      context.handle(_balanceMeta,
          balance.isAcceptableOrUnknown(data['balance']!, _balanceMeta));
    }
    if (data.containsKey('payments')) {
      context.handle(_paymentsMeta,
          payments.isAcceptableOrUnknown(data['payments']!, _paymentsMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('synced')) {
      context.handle(_syncedMeta,
          synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BillingData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BillingData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      tenantId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tenant_id'])!,
      invoiceNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}invoice_number'])!,
      encounterId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}encounter_id']),
      patientId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}patient_id'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      items: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}items'])!,
      subtotal: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}subtotal'])!,
      discount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}discount'])!,
      total: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}total'])!,
      shaCover: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}sha_cover'])!,
      insuranceCover: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}insurance_cover'])!,
      patientPay: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}patient_pay'])!,
      amountPaid: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount_paid'])!,
      balance: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}balance'])!,
      payments: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payments'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      synced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}synced'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
    );
  }

  @override
  $BillingTable createAlias(String alias) {
    return $BillingTable(attachedDatabase, alias);
  }
}

class BillingData extends DataClass implements Insertable<BillingData> {
  final String id;
  final String tenantId;
  final String invoiceNumber;
  final String? encounterId;
  final String patientId;
  final String type;
  final String status;
  final String items;
  final double subtotal;
  final double discount;
  final double total;
  final double shaCover;
  final double insuranceCover;
  final double patientPay;
  final double amountPaid;
  final double balance;
  final String payments;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool synced;
  final String syncStatus;
  const BillingData(
      {required this.id,
      required this.tenantId,
      required this.invoiceNumber,
      this.encounterId,
      required this.patientId,
      required this.type,
      required this.status,
      required this.items,
      required this.subtotal,
      required this.discount,
      required this.total,
      required this.shaCover,
      required this.insuranceCover,
      required this.patientPay,
      required this.amountPaid,
      required this.balance,
      required this.payments,
      required this.createdAt,
      required this.updatedAt,
      required this.synced,
      required this.syncStatus});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['tenant_id'] = Variable<String>(tenantId);
    map['invoice_number'] = Variable<String>(invoiceNumber);
    if (!nullToAbsent || encounterId != null) {
      map['encounter_id'] = Variable<String>(encounterId);
    }
    map['patient_id'] = Variable<String>(patientId);
    map['type'] = Variable<String>(type);
    map['status'] = Variable<String>(status);
    map['items'] = Variable<String>(items);
    map['subtotal'] = Variable<double>(subtotal);
    map['discount'] = Variable<double>(discount);
    map['total'] = Variable<double>(total);
    map['sha_cover'] = Variable<double>(shaCover);
    map['insurance_cover'] = Variable<double>(insuranceCover);
    map['patient_pay'] = Variable<double>(patientPay);
    map['amount_paid'] = Variable<double>(amountPaid);
    map['balance'] = Variable<double>(balance);
    map['payments'] = Variable<String>(payments);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['synced'] = Variable<bool>(synced);
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  BillingCompanion toCompanion(bool nullToAbsent) {
    return BillingCompanion(
      id: Value(id),
      tenantId: Value(tenantId),
      invoiceNumber: Value(invoiceNumber),
      encounterId: encounterId == null && nullToAbsent
          ? const Value.absent()
          : Value(encounterId),
      patientId: Value(patientId),
      type: Value(type),
      status: Value(status),
      items: Value(items),
      subtotal: Value(subtotal),
      discount: Value(discount),
      total: Value(total),
      shaCover: Value(shaCover),
      insuranceCover: Value(insuranceCover),
      patientPay: Value(patientPay),
      amountPaid: Value(amountPaid),
      balance: Value(balance),
      payments: Value(payments),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      synced: Value(synced),
      syncStatus: Value(syncStatus),
    );
  }

  factory BillingData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BillingData(
      id: serializer.fromJson<String>(json['id']),
      tenantId: serializer.fromJson<String>(json['tenantId']),
      invoiceNumber: serializer.fromJson<String>(json['invoiceNumber']),
      encounterId: serializer.fromJson<String?>(json['encounterId']),
      patientId: serializer.fromJson<String>(json['patientId']),
      type: serializer.fromJson<String>(json['type']),
      status: serializer.fromJson<String>(json['status']),
      items: serializer.fromJson<String>(json['items']),
      subtotal: serializer.fromJson<double>(json['subtotal']),
      discount: serializer.fromJson<double>(json['discount']),
      total: serializer.fromJson<double>(json['total']),
      shaCover: serializer.fromJson<double>(json['shaCover']),
      insuranceCover: serializer.fromJson<double>(json['insuranceCover']),
      patientPay: serializer.fromJson<double>(json['patientPay']),
      amountPaid: serializer.fromJson<double>(json['amountPaid']),
      balance: serializer.fromJson<double>(json['balance']),
      payments: serializer.fromJson<String>(json['payments']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      synced: serializer.fromJson<bool>(json['synced']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tenantId': serializer.toJson<String>(tenantId),
      'invoiceNumber': serializer.toJson<String>(invoiceNumber),
      'encounterId': serializer.toJson<String?>(encounterId),
      'patientId': serializer.toJson<String>(patientId),
      'type': serializer.toJson<String>(type),
      'status': serializer.toJson<String>(status),
      'items': serializer.toJson<String>(items),
      'subtotal': serializer.toJson<double>(subtotal),
      'discount': serializer.toJson<double>(discount),
      'total': serializer.toJson<double>(total),
      'shaCover': serializer.toJson<double>(shaCover),
      'insuranceCover': serializer.toJson<double>(insuranceCover),
      'patientPay': serializer.toJson<double>(patientPay),
      'amountPaid': serializer.toJson<double>(amountPaid),
      'balance': serializer.toJson<double>(balance),
      'payments': serializer.toJson<String>(payments),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'synced': serializer.toJson<bool>(synced),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  BillingData copyWith(
          {String? id,
          String? tenantId,
          String? invoiceNumber,
          Value<String?> encounterId = const Value.absent(),
          String? patientId,
          String? type,
          String? status,
          String? items,
          double? subtotal,
          double? discount,
          double? total,
          double? shaCover,
          double? insuranceCover,
          double? patientPay,
          double? amountPaid,
          double? balance,
          String? payments,
          DateTime? createdAt,
          DateTime? updatedAt,
          bool? synced,
          String? syncStatus}) =>
      BillingData(
        id: id ?? this.id,
        tenantId: tenantId ?? this.tenantId,
        invoiceNumber: invoiceNumber ?? this.invoiceNumber,
        encounterId: encounterId.present ? encounterId.value : this.encounterId,
        patientId: patientId ?? this.patientId,
        type: type ?? this.type,
        status: status ?? this.status,
        items: items ?? this.items,
        subtotal: subtotal ?? this.subtotal,
        discount: discount ?? this.discount,
        total: total ?? this.total,
        shaCover: shaCover ?? this.shaCover,
        insuranceCover: insuranceCover ?? this.insuranceCover,
        patientPay: patientPay ?? this.patientPay,
        amountPaid: amountPaid ?? this.amountPaid,
        balance: balance ?? this.balance,
        payments: payments ?? this.payments,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        synced: synced ?? this.synced,
        syncStatus: syncStatus ?? this.syncStatus,
      );
  BillingData copyWithCompanion(BillingCompanion data) {
    return BillingData(
      id: data.id.present ? data.id.value : this.id,
      tenantId: data.tenantId.present ? data.tenantId.value : this.tenantId,
      invoiceNumber: data.invoiceNumber.present
          ? data.invoiceNumber.value
          : this.invoiceNumber,
      encounterId:
          data.encounterId.present ? data.encounterId.value : this.encounterId,
      patientId: data.patientId.present ? data.patientId.value : this.patientId,
      type: data.type.present ? data.type.value : this.type,
      status: data.status.present ? data.status.value : this.status,
      items: data.items.present ? data.items.value : this.items,
      subtotal: data.subtotal.present ? data.subtotal.value : this.subtotal,
      discount: data.discount.present ? data.discount.value : this.discount,
      total: data.total.present ? data.total.value : this.total,
      shaCover: data.shaCover.present ? data.shaCover.value : this.shaCover,
      insuranceCover: data.insuranceCover.present
          ? data.insuranceCover.value
          : this.insuranceCover,
      patientPay:
          data.patientPay.present ? data.patientPay.value : this.patientPay,
      amountPaid:
          data.amountPaid.present ? data.amountPaid.value : this.amountPaid,
      balance: data.balance.present ? data.balance.value : this.balance,
      payments: data.payments.present ? data.payments.value : this.payments,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      synced: data.synced.present ? data.synced.value : this.synced,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BillingData(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('invoiceNumber: $invoiceNumber, ')
          ..write('encounterId: $encounterId, ')
          ..write('patientId: $patientId, ')
          ..write('type: $type, ')
          ..write('status: $status, ')
          ..write('items: $items, ')
          ..write('subtotal: $subtotal, ')
          ..write('discount: $discount, ')
          ..write('total: $total, ')
          ..write('shaCover: $shaCover, ')
          ..write('insuranceCover: $insuranceCover, ')
          ..write('patientPay: $patientPay, ')
          ..write('amountPaid: $amountPaid, ')
          ..write('balance: $balance, ')
          ..write('payments: $payments, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('synced: $synced, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        tenantId,
        invoiceNumber,
        encounterId,
        patientId,
        type,
        status,
        items,
        subtotal,
        discount,
        total,
        shaCover,
        insuranceCover,
        patientPay,
        amountPaid,
        balance,
        payments,
        createdAt,
        updatedAt,
        synced,
        syncStatus
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BillingData &&
          other.id == this.id &&
          other.tenantId == this.tenantId &&
          other.invoiceNumber == this.invoiceNumber &&
          other.encounterId == this.encounterId &&
          other.patientId == this.patientId &&
          other.type == this.type &&
          other.status == this.status &&
          other.items == this.items &&
          other.subtotal == this.subtotal &&
          other.discount == this.discount &&
          other.total == this.total &&
          other.shaCover == this.shaCover &&
          other.insuranceCover == this.insuranceCover &&
          other.patientPay == this.patientPay &&
          other.amountPaid == this.amountPaid &&
          other.balance == this.balance &&
          other.payments == this.payments &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.synced == this.synced &&
          other.syncStatus == this.syncStatus);
}

class BillingCompanion extends UpdateCompanion<BillingData> {
  final Value<String> id;
  final Value<String> tenantId;
  final Value<String> invoiceNumber;
  final Value<String?> encounterId;
  final Value<String> patientId;
  final Value<String> type;
  final Value<String> status;
  final Value<String> items;
  final Value<double> subtotal;
  final Value<double> discount;
  final Value<double> total;
  final Value<double> shaCover;
  final Value<double> insuranceCover;
  final Value<double> patientPay;
  final Value<double> amountPaid;
  final Value<double> balance;
  final Value<String> payments;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> synced;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const BillingCompanion({
    this.id = const Value.absent(),
    this.tenantId = const Value.absent(),
    this.invoiceNumber = const Value.absent(),
    this.encounterId = const Value.absent(),
    this.patientId = const Value.absent(),
    this.type = const Value.absent(),
    this.status = const Value.absent(),
    this.items = const Value.absent(),
    this.subtotal = const Value.absent(),
    this.discount = const Value.absent(),
    this.total = const Value.absent(),
    this.shaCover = const Value.absent(),
    this.insuranceCover = const Value.absent(),
    this.patientPay = const Value.absent(),
    this.amountPaid = const Value.absent(),
    this.balance = const Value.absent(),
    this.payments = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BillingCompanion.insert({
    required String id,
    required String tenantId,
    required String invoiceNumber,
    this.encounterId = const Value.absent(),
    required String patientId,
    this.type = const Value.absent(),
    this.status = const Value.absent(),
    this.items = const Value.absent(),
    this.subtotal = const Value.absent(),
    this.discount = const Value.absent(),
    this.total = const Value.absent(),
    this.shaCover = const Value.absent(),
    this.insuranceCover = const Value.absent(),
    this.patientPay = const Value.absent(),
    this.amountPaid = const Value.absent(),
    this.balance = const Value.absent(),
    this.payments = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        tenantId = Value(tenantId),
        invoiceNumber = Value(invoiceNumber),
        patientId = Value(patientId);
  static Insertable<BillingData> custom({
    Expression<String>? id,
    Expression<String>? tenantId,
    Expression<String>? invoiceNumber,
    Expression<String>? encounterId,
    Expression<String>? patientId,
    Expression<String>? type,
    Expression<String>? status,
    Expression<String>? items,
    Expression<double>? subtotal,
    Expression<double>? discount,
    Expression<double>? total,
    Expression<double>? shaCover,
    Expression<double>? insuranceCover,
    Expression<double>? patientPay,
    Expression<double>? amountPaid,
    Expression<double>? balance,
    Expression<String>? payments,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? synced,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tenantId != null) 'tenant_id': tenantId,
      if (invoiceNumber != null) 'invoice_number': invoiceNumber,
      if (encounterId != null) 'encounter_id': encounterId,
      if (patientId != null) 'patient_id': patientId,
      if (type != null) 'type': type,
      if (status != null) 'status': status,
      if (items != null) 'items': items,
      if (subtotal != null) 'subtotal': subtotal,
      if (discount != null) 'discount': discount,
      if (total != null) 'total': total,
      if (shaCover != null) 'sha_cover': shaCover,
      if (insuranceCover != null) 'insurance_cover': insuranceCover,
      if (patientPay != null) 'patient_pay': patientPay,
      if (amountPaid != null) 'amount_paid': amountPaid,
      if (balance != null) 'balance': balance,
      if (payments != null) 'payments': payments,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (synced != null) 'synced': synced,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BillingCompanion copyWith(
      {Value<String>? id,
      Value<String>? tenantId,
      Value<String>? invoiceNumber,
      Value<String?>? encounterId,
      Value<String>? patientId,
      Value<String>? type,
      Value<String>? status,
      Value<String>? items,
      Value<double>? subtotal,
      Value<double>? discount,
      Value<double>? total,
      Value<double>? shaCover,
      Value<double>? insuranceCover,
      Value<double>? patientPay,
      Value<double>? amountPaid,
      Value<double>? balance,
      Value<String>? payments,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<bool>? synced,
      Value<String>? syncStatus,
      Value<int>? rowid}) {
    return BillingCompanion(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      encounterId: encounterId ?? this.encounterId,
      patientId: patientId ?? this.patientId,
      type: type ?? this.type,
      status: status ?? this.status,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      discount: discount ?? this.discount,
      total: total ?? this.total,
      shaCover: shaCover ?? this.shaCover,
      insuranceCover: insuranceCover ?? this.insuranceCover,
      patientPay: patientPay ?? this.patientPay,
      amountPaid: amountPaid ?? this.amountPaid,
      balance: balance ?? this.balance,
      payments: payments ?? this.payments,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      synced: synced ?? this.synced,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tenantId.present) {
      map['tenant_id'] = Variable<String>(tenantId.value);
    }
    if (invoiceNumber.present) {
      map['invoice_number'] = Variable<String>(invoiceNumber.value);
    }
    if (encounterId.present) {
      map['encounter_id'] = Variable<String>(encounterId.value);
    }
    if (patientId.present) {
      map['patient_id'] = Variable<String>(patientId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (items.present) {
      map['items'] = Variable<String>(items.value);
    }
    if (subtotal.present) {
      map['subtotal'] = Variable<double>(subtotal.value);
    }
    if (discount.present) {
      map['discount'] = Variable<double>(discount.value);
    }
    if (total.present) {
      map['total'] = Variable<double>(total.value);
    }
    if (shaCover.present) {
      map['sha_cover'] = Variable<double>(shaCover.value);
    }
    if (insuranceCover.present) {
      map['insurance_cover'] = Variable<double>(insuranceCover.value);
    }
    if (patientPay.present) {
      map['patient_pay'] = Variable<double>(patientPay.value);
    }
    if (amountPaid.present) {
      map['amount_paid'] = Variable<double>(amountPaid.value);
    }
    if (balance.present) {
      map['balance'] = Variable<double>(balance.value);
    }
    if (payments.present) {
      map['payments'] = Variable<String>(payments.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BillingCompanion(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('invoiceNumber: $invoiceNumber, ')
          ..write('encounterId: $encounterId, ')
          ..write('patientId: $patientId, ')
          ..write('type: $type, ')
          ..write('status: $status, ')
          ..write('items: $items, ')
          ..write('subtotal: $subtotal, ')
          ..write('discount: $discount, ')
          ..write('total: $total, ')
          ..write('shaCover: $shaCover, ')
          ..write('insuranceCover: $insuranceCover, ')
          ..write('patientPay: $patientPay, ')
          ..write('amountPaid: $amountPaid, ')
          ..write('balance: $balance, ')
          ..write('payments: $payments, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('synced: $synced, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InventoryTable extends Inventory
    with TableInfo<$InventoryTable, InventoryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InventoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tenantIdMeta =
      const VerificationMeta('tenantId');
  @override
  late final GeneratedColumn<String> tenantId = GeneratedColumn<String>(
      'tenant_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _itemCodeMeta =
      const VerificationMeta('itemCode');
  @override
  late final GeneratedColumn<String> itemCode = GeneratedColumn<String>(
      'item_code', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('drug'));
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
      'unit', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('unit'));
  static const VerificationMeta _unitPriceMeta =
      const VerificationMeta('unitPrice');
  @override
  late final GeneratedColumn<double> unitPrice = GeneratedColumn<double>(
      'unit_price', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _costPriceMeta =
      const VerificationMeta('costPrice');
  @override
  late final GeneratedColumn<double> costPrice = GeneratedColumn<double>(
      'cost_price', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _quantityMeta =
      const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
      'quantity', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _reorderLevelMeta =
      const VerificationMeta('reorderLevel');
  @override
  late final GeneratedColumn<int> reorderLevel = GeneratedColumn<int>(
      'reorder_level', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(10));
  static const VerificationMeta _batchesMeta =
      const VerificationMeta('batches');
  @override
  late final GeneratedColumn<String> batches = GeneratedColumn<String>(
      'batches', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _expiryTrackingMeta =
      const VerificationMeta('expiryTracking');
  @override
  late final GeneratedColumn<bool> expiryTracking = GeneratedColumn<bool>(
      'expiry_tracking', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("expiry_tracking" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _controlledSubstanceMeta =
      const VerificationMeta('controlledSubstance');
  @override
  late final GeneratedColumn<bool> controlledSubstance = GeneratedColumn<bool>(
      'controlled_substance', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("controlled_substance" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _formulationMeta =
      const VerificationMeta('formulation');
  @override
  late final GeneratedColumn<String> formulation = GeneratedColumn<String>(
      'formulation', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _strengthMeta =
      const VerificationMeta('strength');
  @override
  late final GeneratedColumn<String> strength = GeneratedColumn<String>(
      'strength', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('active'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
      'synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        tenantId,
        itemCode,
        name,
        category,
        unit,
        unitPrice,
        costPrice,
        quantity,
        reorderLevel,
        batches,
        expiryTracking,
        controlledSubstance,
        formulation,
        strength,
        status,
        createdAt,
        updatedAt,
        synced,
        syncStatus
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'inventory';
  @override
  VerificationContext validateIntegrity(Insertable<InventoryData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('tenant_id')) {
      context.handle(_tenantIdMeta,
          tenantId.isAcceptableOrUnknown(data['tenant_id']!, _tenantIdMeta));
    } else if (isInserting) {
      context.missing(_tenantIdMeta);
    }
    if (data.containsKey('item_code')) {
      context.handle(_itemCodeMeta,
          itemCode.isAcceptableOrUnknown(data['item_code']!, _itemCodeMeta));
    } else if (isInserting) {
      context.missing(_itemCodeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    }
    if (data.containsKey('unit')) {
      context.handle(
          _unitMeta, unit.isAcceptableOrUnknown(data['unit']!, _unitMeta));
    }
    if (data.containsKey('unit_price')) {
      context.handle(_unitPriceMeta,
          unitPrice.isAcceptableOrUnknown(data['unit_price']!, _unitPriceMeta));
    }
    if (data.containsKey('cost_price')) {
      context.handle(_costPriceMeta,
          costPrice.isAcceptableOrUnknown(data['cost_price']!, _costPriceMeta));
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta,
          quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    }
    if (data.containsKey('reorder_level')) {
      context.handle(
          _reorderLevelMeta,
          reorderLevel.isAcceptableOrUnknown(
              data['reorder_level']!, _reorderLevelMeta));
    }
    if (data.containsKey('batches')) {
      context.handle(_batchesMeta,
          batches.isAcceptableOrUnknown(data['batches']!, _batchesMeta));
    }
    if (data.containsKey('expiry_tracking')) {
      context.handle(
          _expiryTrackingMeta,
          expiryTracking.isAcceptableOrUnknown(
              data['expiry_tracking']!, _expiryTrackingMeta));
    }
    if (data.containsKey('controlled_substance')) {
      context.handle(
          _controlledSubstanceMeta,
          controlledSubstance.isAcceptableOrUnknown(
              data['controlled_substance']!, _controlledSubstanceMeta));
    }
    if (data.containsKey('formulation')) {
      context.handle(
          _formulationMeta,
          formulation.isAcceptableOrUnknown(
              data['formulation']!, _formulationMeta));
    }
    if (data.containsKey('strength')) {
      context.handle(_strengthMeta,
          strength.isAcceptableOrUnknown(data['strength']!, _strengthMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('synced')) {
      context.handle(_syncedMeta,
          synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InventoryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InventoryData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      tenantId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tenant_id'])!,
      itemCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}item_code'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      unit: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}unit'])!,
      unitPrice: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}unit_price'])!,
      costPrice: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}cost_price'])!,
      quantity: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}quantity'])!,
      reorderLevel: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}reorder_level'])!,
      batches: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}batches'])!,
      expiryTracking: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}expiry_tracking'])!,
      controlledSubstance: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}controlled_substance'])!,
      formulation: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}formulation']),
      strength: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}strength']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      synced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}synced'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
    );
  }

  @override
  $InventoryTable createAlias(String alias) {
    return $InventoryTable(attachedDatabase, alias);
  }
}

class InventoryData extends DataClass implements Insertable<InventoryData> {
  final String id;
  final String tenantId;
  final String itemCode;
  final String name;
  final String category;
  final String unit;
  final double unitPrice;
  final double costPrice;
  final int quantity;
  final int reorderLevel;
  final String batches;
  final bool expiryTracking;
  final bool controlledSubstance;
  final String? formulation;
  final String? strength;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool synced;
  final String syncStatus;
  const InventoryData(
      {required this.id,
      required this.tenantId,
      required this.itemCode,
      required this.name,
      required this.category,
      required this.unit,
      required this.unitPrice,
      required this.costPrice,
      required this.quantity,
      required this.reorderLevel,
      required this.batches,
      required this.expiryTracking,
      required this.controlledSubstance,
      this.formulation,
      this.strength,
      required this.status,
      required this.createdAt,
      required this.updatedAt,
      required this.synced,
      required this.syncStatus});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['tenant_id'] = Variable<String>(tenantId);
    map['item_code'] = Variable<String>(itemCode);
    map['name'] = Variable<String>(name);
    map['category'] = Variable<String>(category);
    map['unit'] = Variable<String>(unit);
    map['unit_price'] = Variable<double>(unitPrice);
    map['cost_price'] = Variable<double>(costPrice);
    map['quantity'] = Variable<int>(quantity);
    map['reorder_level'] = Variable<int>(reorderLevel);
    map['batches'] = Variable<String>(batches);
    map['expiry_tracking'] = Variable<bool>(expiryTracking);
    map['controlled_substance'] = Variable<bool>(controlledSubstance);
    if (!nullToAbsent || formulation != null) {
      map['formulation'] = Variable<String>(formulation);
    }
    if (!nullToAbsent || strength != null) {
      map['strength'] = Variable<String>(strength);
    }
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['synced'] = Variable<bool>(synced);
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  InventoryCompanion toCompanion(bool nullToAbsent) {
    return InventoryCompanion(
      id: Value(id),
      tenantId: Value(tenantId),
      itemCode: Value(itemCode),
      name: Value(name),
      category: Value(category),
      unit: Value(unit),
      unitPrice: Value(unitPrice),
      costPrice: Value(costPrice),
      quantity: Value(quantity),
      reorderLevel: Value(reorderLevel),
      batches: Value(batches),
      expiryTracking: Value(expiryTracking),
      controlledSubstance: Value(controlledSubstance),
      formulation: formulation == null && nullToAbsent
          ? const Value.absent()
          : Value(formulation),
      strength: strength == null && nullToAbsent
          ? const Value.absent()
          : Value(strength),
      status: Value(status),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      synced: Value(synced),
      syncStatus: Value(syncStatus),
    );
  }

  factory InventoryData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InventoryData(
      id: serializer.fromJson<String>(json['id']),
      tenantId: serializer.fromJson<String>(json['tenantId']),
      itemCode: serializer.fromJson<String>(json['itemCode']),
      name: serializer.fromJson<String>(json['name']),
      category: serializer.fromJson<String>(json['category']),
      unit: serializer.fromJson<String>(json['unit']),
      unitPrice: serializer.fromJson<double>(json['unitPrice']),
      costPrice: serializer.fromJson<double>(json['costPrice']),
      quantity: serializer.fromJson<int>(json['quantity']),
      reorderLevel: serializer.fromJson<int>(json['reorderLevel']),
      batches: serializer.fromJson<String>(json['batches']),
      expiryTracking: serializer.fromJson<bool>(json['expiryTracking']),
      controlledSubstance:
          serializer.fromJson<bool>(json['controlledSubstance']),
      formulation: serializer.fromJson<String?>(json['formulation']),
      strength: serializer.fromJson<String?>(json['strength']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      synced: serializer.fromJson<bool>(json['synced']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tenantId': serializer.toJson<String>(tenantId),
      'itemCode': serializer.toJson<String>(itemCode),
      'name': serializer.toJson<String>(name),
      'category': serializer.toJson<String>(category),
      'unit': serializer.toJson<String>(unit),
      'unitPrice': serializer.toJson<double>(unitPrice),
      'costPrice': serializer.toJson<double>(costPrice),
      'quantity': serializer.toJson<int>(quantity),
      'reorderLevel': serializer.toJson<int>(reorderLevel),
      'batches': serializer.toJson<String>(batches),
      'expiryTracking': serializer.toJson<bool>(expiryTracking),
      'controlledSubstance': serializer.toJson<bool>(controlledSubstance),
      'formulation': serializer.toJson<String?>(formulation),
      'strength': serializer.toJson<String?>(strength),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'synced': serializer.toJson<bool>(synced),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  InventoryData copyWith(
          {String? id,
          String? tenantId,
          String? itemCode,
          String? name,
          String? category,
          String? unit,
          double? unitPrice,
          double? costPrice,
          int? quantity,
          int? reorderLevel,
          String? batches,
          bool? expiryTracking,
          bool? controlledSubstance,
          Value<String?> formulation = const Value.absent(),
          Value<String?> strength = const Value.absent(),
          String? status,
          DateTime? createdAt,
          DateTime? updatedAt,
          bool? synced,
          String? syncStatus}) =>
      InventoryData(
        id: id ?? this.id,
        tenantId: tenantId ?? this.tenantId,
        itemCode: itemCode ?? this.itemCode,
        name: name ?? this.name,
        category: category ?? this.category,
        unit: unit ?? this.unit,
        unitPrice: unitPrice ?? this.unitPrice,
        costPrice: costPrice ?? this.costPrice,
        quantity: quantity ?? this.quantity,
        reorderLevel: reorderLevel ?? this.reorderLevel,
        batches: batches ?? this.batches,
        expiryTracking: expiryTracking ?? this.expiryTracking,
        controlledSubstance: controlledSubstance ?? this.controlledSubstance,
        formulation: formulation.present ? formulation.value : this.formulation,
        strength: strength.present ? strength.value : this.strength,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        synced: synced ?? this.synced,
        syncStatus: syncStatus ?? this.syncStatus,
      );
  InventoryData copyWithCompanion(InventoryCompanion data) {
    return InventoryData(
      id: data.id.present ? data.id.value : this.id,
      tenantId: data.tenantId.present ? data.tenantId.value : this.tenantId,
      itemCode: data.itemCode.present ? data.itemCode.value : this.itemCode,
      name: data.name.present ? data.name.value : this.name,
      category: data.category.present ? data.category.value : this.category,
      unit: data.unit.present ? data.unit.value : this.unit,
      unitPrice: data.unitPrice.present ? data.unitPrice.value : this.unitPrice,
      costPrice: data.costPrice.present ? data.costPrice.value : this.costPrice,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      reorderLevel: data.reorderLevel.present
          ? data.reorderLevel.value
          : this.reorderLevel,
      batches: data.batches.present ? data.batches.value : this.batches,
      expiryTracking: data.expiryTracking.present
          ? data.expiryTracking.value
          : this.expiryTracking,
      controlledSubstance: data.controlledSubstance.present
          ? data.controlledSubstance.value
          : this.controlledSubstance,
      formulation:
          data.formulation.present ? data.formulation.value : this.formulation,
      strength: data.strength.present ? data.strength.value : this.strength,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      synced: data.synced.present ? data.synced.value : this.synced,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InventoryData(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('itemCode: $itemCode, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('unit: $unit, ')
          ..write('unitPrice: $unitPrice, ')
          ..write('costPrice: $costPrice, ')
          ..write('quantity: $quantity, ')
          ..write('reorderLevel: $reorderLevel, ')
          ..write('batches: $batches, ')
          ..write('expiryTracking: $expiryTracking, ')
          ..write('controlledSubstance: $controlledSubstance, ')
          ..write('formulation: $formulation, ')
          ..write('strength: $strength, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('synced: $synced, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      tenantId,
      itemCode,
      name,
      category,
      unit,
      unitPrice,
      costPrice,
      quantity,
      reorderLevel,
      batches,
      expiryTracking,
      controlledSubstance,
      formulation,
      strength,
      status,
      createdAt,
      updatedAt,
      synced,
      syncStatus);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InventoryData &&
          other.id == this.id &&
          other.tenantId == this.tenantId &&
          other.itemCode == this.itemCode &&
          other.name == this.name &&
          other.category == this.category &&
          other.unit == this.unit &&
          other.unitPrice == this.unitPrice &&
          other.costPrice == this.costPrice &&
          other.quantity == this.quantity &&
          other.reorderLevel == this.reorderLevel &&
          other.batches == this.batches &&
          other.expiryTracking == this.expiryTracking &&
          other.controlledSubstance == this.controlledSubstance &&
          other.formulation == this.formulation &&
          other.strength == this.strength &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.synced == this.synced &&
          other.syncStatus == this.syncStatus);
}

class InventoryCompanion extends UpdateCompanion<InventoryData> {
  final Value<String> id;
  final Value<String> tenantId;
  final Value<String> itemCode;
  final Value<String> name;
  final Value<String> category;
  final Value<String> unit;
  final Value<double> unitPrice;
  final Value<double> costPrice;
  final Value<int> quantity;
  final Value<int> reorderLevel;
  final Value<String> batches;
  final Value<bool> expiryTracking;
  final Value<bool> controlledSubstance;
  final Value<String?> formulation;
  final Value<String?> strength;
  final Value<String> status;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> synced;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const InventoryCompanion({
    this.id = const Value.absent(),
    this.tenantId = const Value.absent(),
    this.itemCode = const Value.absent(),
    this.name = const Value.absent(),
    this.category = const Value.absent(),
    this.unit = const Value.absent(),
    this.unitPrice = const Value.absent(),
    this.costPrice = const Value.absent(),
    this.quantity = const Value.absent(),
    this.reorderLevel = const Value.absent(),
    this.batches = const Value.absent(),
    this.expiryTracking = const Value.absent(),
    this.controlledSubstance = const Value.absent(),
    this.formulation = const Value.absent(),
    this.strength = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InventoryCompanion.insert({
    required String id,
    required String tenantId,
    required String itemCode,
    required String name,
    this.category = const Value.absent(),
    this.unit = const Value.absent(),
    this.unitPrice = const Value.absent(),
    this.costPrice = const Value.absent(),
    this.quantity = const Value.absent(),
    this.reorderLevel = const Value.absent(),
    this.batches = const Value.absent(),
    this.expiryTracking = const Value.absent(),
    this.controlledSubstance = const Value.absent(),
    this.formulation = const Value.absent(),
    this.strength = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        tenantId = Value(tenantId),
        itemCode = Value(itemCode),
        name = Value(name);
  static Insertable<InventoryData> custom({
    Expression<String>? id,
    Expression<String>? tenantId,
    Expression<String>? itemCode,
    Expression<String>? name,
    Expression<String>? category,
    Expression<String>? unit,
    Expression<double>? unitPrice,
    Expression<double>? costPrice,
    Expression<int>? quantity,
    Expression<int>? reorderLevel,
    Expression<String>? batches,
    Expression<bool>? expiryTracking,
    Expression<bool>? controlledSubstance,
    Expression<String>? formulation,
    Expression<String>? strength,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? synced,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tenantId != null) 'tenant_id': tenantId,
      if (itemCode != null) 'item_code': itemCode,
      if (name != null) 'name': name,
      if (category != null) 'category': category,
      if (unit != null) 'unit': unit,
      if (unitPrice != null) 'unit_price': unitPrice,
      if (costPrice != null) 'cost_price': costPrice,
      if (quantity != null) 'quantity': quantity,
      if (reorderLevel != null) 'reorder_level': reorderLevel,
      if (batches != null) 'batches': batches,
      if (expiryTracking != null) 'expiry_tracking': expiryTracking,
      if (controlledSubstance != null)
        'controlled_substance': controlledSubstance,
      if (formulation != null) 'formulation': formulation,
      if (strength != null) 'strength': strength,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (synced != null) 'synced': synced,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InventoryCompanion copyWith(
      {Value<String>? id,
      Value<String>? tenantId,
      Value<String>? itemCode,
      Value<String>? name,
      Value<String>? category,
      Value<String>? unit,
      Value<double>? unitPrice,
      Value<double>? costPrice,
      Value<int>? quantity,
      Value<int>? reorderLevel,
      Value<String>? batches,
      Value<bool>? expiryTracking,
      Value<bool>? controlledSubstance,
      Value<String?>? formulation,
      Value<String?>? strength,
      Value<String>? status,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<bool>? synced,
      Value<String>? syncStatus,
      Value<int>? rowid}) {
    return InventoryCompanion(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      itemCode: itemCode ?? this.itemCode,
      name: name ?? this.name,
      category: category ?? this.category,
      unit: unit ?? this.unit,
      unitPrice: unitPrice ?? this.unitPrice,
      costPrice: costPrice ?? this.costPrice,
      quantity: quantity ?? this.quantity,
      reorderLevel: reorderLevel ?? this.reorderLevel,
      batches: batches ?? this.batches,
      expiryTracking: expiryTracking ?? this.expiryTracking,
      controlledSubstance: controlledSubstance ?? this.controlledSubstance,
      formulation: formulation ?? this.formulation,
      strength: strength ?? this.strength,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      synced: synced ?? this.synced,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tenantId.present) {
      map['tenant_id'] = Variable<String>(tenantId.value);
    }
    if (itemCode.present) {
      map['item_code'] = Variable<String>(itemCode.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (unitPrice.present) {
      map['unit_price'] = Variable<double>(unitPrice.value);
    }
    if (costPrice.present) {
      map['cost_price'] = Variable<double>(costPrice.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (reorderLevel.present) {
      map['reorder_level'] = Variable<int>(reorderLevel.value);
    }
    if (batches.present) {
      map['batches'] = Variable<String>(batches.value);
    }
    if (expiryTracking.present) {
      map['expiry_tracking'] = Variable<bool>(expiryTracking.value);
    }
    if (controlledSubstance.present) {
      map['controlled_substance'] = Variable<bool>(controlledSubstance.value);
    }
    if (formulation.present) {
      map['formulation'] = Variable<String>(formulation.value);
    }
    if (strength.present) {
      map['strength'] = Variable<String>(strength.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InventoryCompanion(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('itemCode: $itemCode, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('unit: $unit, ')
          ..write('unitPrice: $unitPrice, ')
          ..write('costPrice: $costPrice, ')
          ..write('quantity: $quantity, ')
          ..write('reorderLevel: $reorderLevel, ')
          ..write('batches: $batches, ')
          ..write('expiryTracking: $expiryTracking, ')
          ..write('controlledSubstance: $controlledSubstance, ')
          ..write('formulation: $formulation, ')
          ..write('strength: $strength, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('synced: $synced, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncQueueTable extends SyncQueue
    with TableInfo<$SyncQueueTable, SyncQueueData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncQueueTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _entityTypeMeta =
      const VerificationMeta('entityType');
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
      'entity_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entityIdMeta =
      const VerificationMeta('entityId');
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
      'entity_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
      'action', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<String> data = GeneratedColumn<String>(
      'data', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _retryCountMeta =
      const VerificationMeta('retryCount');
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
      'retry_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _lastErrorMeta =
      const VerificationMeta('lastError');
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
      'last_error', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        entityType,
        entityId,
        action,
        data,
        createdAt,
        retryCount,
        lastError
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_queue';
  @override
  VerificationContext validateIntegrity(Insertable<SyncQueueData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('entity_type')) {
      context.handle(
          _entityTypeMeta,
          entityType.isAcceptableOrUnknown(
              data['entity_type']!, _entityTypeMeta));
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(_entityIdMeta,
          entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta));
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('action')) {
      context.handle(_actionMeta,
          action.isAcceptableOrUnknown(data['action']!, _actionMeta));
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('data')) {
      context.handle(
          _dataMeta, this.data.isAcceptableOrUnknown(data['data']!, _dataMeta));
    } else if (isInserting) {
      context.missing(_dataMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('retry_count')) {
      context.handle(
          _retryCountMeta,
          retryCount.isAcceptableOrUnknown(
              data['retry_count']!, _retryCountMeta));
    }
    if (data.containsKey('last_error')) {
      context.handle(_lastErrorMeta,
          lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncQueueData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncQueueData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      entityType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_type'])!,
      entityId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_id'])!,
      action: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}action'])!,
      data: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}data'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      retryCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}retry_count'])!,
      lastError: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_error']),
    );
  }

  @override
  $SyncQueueTable createAlias(String alias) {
    return $SyncQueueTable(attachedDatabase, alias);
  }
}

class SyncQueueData extends DataClass implements Insertable<SyncQueueData> {
  final int id;
  final String entityType;
  final String entityId;
  final String action;
  final String data;
  final DateTime createdAt;
  final int retryCount;
  final String? lastError;
  const SyncQueueData(
      {required this.id,
      required this.entityType,
      required this.entityId,
      required this.action,
      required this.data,
      required this.createdAt,
      required this.retryCount,
      this.lastError});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['action'] = Variable<String>(action);
    map['data'] = Variable<String>(data);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['retry_count'] = Variable<int>(retryCount);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    return map;
  }

  SyncQueueCompanion toCompanion(bool nullToAbsent) {
    return SyncQueueCompanion(
      id: Value(id),
      entityType: Value(entityType),
      entityId: Value(entityId),
      action: Value(action),
      data: Value(data),
      createdAt: Value(createdAt),
      retryCount: Value(retryCount),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
    );
  }

  factory SyncQueueData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncQueueData(
      id: serializer.fromJson<int>(json['id']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      action: serializer.fromJson<String>(json['action']),
      data: serializer.fromJson<String>(json['data']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      lastError: serializer.fromJson<String?>(json['lastError']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'action': serializer.toJson<String>(action),
      'data': serializer.toJson<String>(data),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'retryCount': serializer.toJson<int>(retryCount),
      'lastError': serializer.toJson<String?>(lastError),
    };
  }

  SyncQueueData copyWith(
          {int? id,
          String? entityType,
          String? entityId,
          String? action,
          String? data,
          DateTime? createdAt,
          int? retryCount,
          Value<String?> lastError = const Value.absent()}) =>
      SyncQueueData(
        id: id ?? this.id,
        entityType: entityType ?? this.entityType,
        entityId: entityId ?? this.entityId,
        action: action ?? this.action,
        data: data ?? this.data,
        createdAt: createdAt ?? this.createdAt,
        retryCount: retryCount ?? this.retryCount,
        lastError: lastError.present ? lastError.value : this.lastError,
      );
  SyncQueueData copyWithCompanion(SyncQueueCompanion data) {
    return SyncQueueData(
      id: data.id.present ? data.id.value : this.id,
      entityType:
          data.entityType.present ? data.entityType.value : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      action: data.action.present ? data.action.value : this.action,
      data: data.data.present ? data.data.value : this.data,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      retryCount:
          data.retryCount.present ? data.retryCount.value : this.retryCount,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueData(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('action: $action, ')
          ..write('data: $data, ')
          ..write('createdAt: $createdAt, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, entityType, entityId, action, data, createdAt, retryCount, lastError);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncQueueData &&
          other.id == this.id &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.action == this.action &&
          other.data == this.data &&
          other.createdAt == this.createdAt &&
          other.retryCount == this.retryCount &&
          other.lastError == this.lastError);
}

class SyncQueueCompanion extends UpdateCompanion<SyncQueueData> {
  final Value<int> id;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> action;
  final Value<String> data;
  final Value<DateTime> createdAt;
  final Value<int> retryCount;
  final Value<String?> lastError;
  const SyncQueueCompanion({
    this.id = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.action = const Value.absent(),
    this.data = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.lastError = const Value.absent(),
  });
  SyncQueueCompanion.insert({
    this.id = const Value.absent(),
    required String entityType,
    required String entityId,
    required String action,
    required String data,
    this.createdAt = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.lastError = const Value.absent(),
  })  : entityType = Value(entityType),
        entityId = Value(entityId),
        action = Value(action),
        data = Value(data);
  static Insertable<SyncQueueData> custom({
    Expression<int>? id,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? action,
    Expression<String>? data,
    Expression<DateTime>? createdAt,
    Expression<int>? retryCount,
    Expression<String>? lastError,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (action != null) 'action': action,
      if (data != null) 'data': data,
      if (createdAt != null) 'created_at': createdAt,
      if (retryCount != null) 'retry_count': retryCount,
      if (lastError != null) 'last_error': lastError,
    });
  }

  SyncQueueCompanion copyWith(
      {Value<int>? id,
      Value<String>? entityType,
      Value<String>? entityId,
      Value<String>? action,
      Value<String>? data,
      Value<DateTime>? createdAt,
      Value<int>? retryCount,
      Value<String?>? lastError}) {
    return SyncQueueCompanion(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      action: action ?? this.action,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      retryCount: retryCount ?? this.retryCount,
      lastError: lastError ?? this.lastError,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (data.present) {
      map['data'] = Variable<String>(data.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueCompanion(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('action: $action, ')
          ..write('data: $data, ')
          ..write('createdAt: $createdAt, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }
}

abstract class _$DatabaseService extends GeneratedDatabase {
  _$DatabaseService(QueryExecutor e) : super(e);
  $DatabaseServiceManager get managers => $DatabaseServiceManager(this);
  late final $PatientsTable patients = $PatientsTable(this);
  late final $EncountersTable encounters = $EncountersTable(this);
  late final $BillingTable billing = $BillingTable(this);
  late final $InventoryTable inventory = $InventoryTable(this);
  late final $SyncQueueTable syncQueue = $SyncQueueTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [patients, encounters, billing, inventory, syncQueue];
}

typedef $$PatientsTableCreateCompanionBuilder = PatientsCompanion Function({
  required String id,
  required String tenantId,
  required String patientNumber,
  required String firstName,
  required String lastName,
  Value<String?> middleName,
  required DateTime dateOfBirth,
  required String gender,
  Value<String?> phone,
  Value<String?> nationalId,
  Value<String?> county,
  Value<String?> address,
  Value<String> allergies,
  Value<String> chronicConditions,
  Value<String?> sha,
  Value<String?> insurance,
  Value<String?> emergencyContact,
  Value<bool> isActive,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> synced,
  Value<String> syncStatus,
  Value<int> rowid,
});
typedef $$PatientsTableUpdateCompanionBuilder = PatientsCompanion Function({
  Value<String> id,
  Value<String> tenantId,
  Value<String> patientNumber,
  Value<String> firstName,
  Value<String> lastName,
  Value<String?> middleName,
  Value<DateTime> dateOfBirth,
  Value<String> gender,
  Value<String?> phone,
  Value<String?> nationalId,
  Value<String?> county,
  Value<String?> address,
  Value<String> allergies,
  Value<String> chronicConditions,
  Value<String?> sha,
  Value<String?> insurance,
  Value<String?> emergencyContact,
  Value<bool> isActive,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> synced,
  Value<String> syncStatus,
  Value<int> rowid,
});

class $$PatientsTableFilterComposer
    extends Composer<_$DatabaseService, $PatientsTable> {
  $$PatientsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tenantId => $composableBuilder(
      column: $table.tenantId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get patientNumber => $composableBuilder(
      column: $table.patientNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get firstName => $composableBuilder(
      column: $table.firstName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastName => $composableBuilder(
      column: $table.lastName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get middleName => $composableBuilder(
      column: $table.middleName, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dateOfBirth => $composableBuilder(
      column: $table.dateOfBirth, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get gender => $composableBuilder(
      column: $table.gender, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nationalId => $composableBuilder(
      column: $table.nationalId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get county => $composableBuilder(
      column: $table.county, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get allergies => $composableBuilder(
      column: $table.allergies, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get chronicConditions => $composableBuilder(
      column: $table.chronicConditions,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sha => $composableBuilder(
      column: $table.sha, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get insurance => $composableBuilder(
      column: $table.insurance, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get emergencyContact => $composableBuilder(
      column: $table.emergencyContact,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));
}

class $$PatientsTableOrderingComposer
    extends Composer<_$DatabaseService, $PatientsTable> {
  $$PatientsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tenantId => $composableBuilder(
      column: $table.tenantId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get patientNumber => $composableBuilder(
      column: $table.patientNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get firstName => $composableBuilder(
      column: $table.firstName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastName => $composableBuilder(
      column: $table.lastName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get middleName => $composableBuilder(
      column: $table.middleName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dateOfBirth => $composableBuilder(
      column: $table.dateOfBirth, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get gender => $composableBuilder(
      column: $table.gender, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nationalId => $composableBuilder(
      column: $table.nationalId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get county => $composableBuilder(
      column: $table.county, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get allergies => $composableBuilder(
      column: $table.allergies, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get chronicConditions => $composableBuilder(
      column: $table.chronicConditions,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sha => $composableBuilder(
      column: $table.sha, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get insurance => $composableBuilder(
      column: $table.insurance, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get emergencyContact => $composableBuilder(
      column: $table.emergencyContact,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));
}

class $$PatientsTableAnnotationComposer
    extends Composer<_$DatabaseService, $PatientsTable> {
  $$PatientsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tenantId =>
      $composableBuilder(column: $table.tenantId, builder: (column) => column);

  GeneratedColumn<String> get patientNumber => $composableBuilder(
      column: $table.patientNumber, builder: (column) => column);

  GeneratedColumn<String> get firstName =>
      $composableBuilder(column: $table.firstName, builder: (column) => column);

  GeneratedColumn<String> get lastName =>
      $composableBuilder(column: $table.lastName, builder: (column) => column);

  GeneratedColumn<String> get middleName => $composableBuilder(
      column: $table.middleName, builder: (column) => column);

  GeneratedColumn<DateTime> get dateOfBirth => $composableBuilder(
      column: $table.dateOfBirth, builder: (column) => column);

  GeneratedColumn<String> get gender =>
      $composableBuilder(column: $table.gender, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get nationalId => $composableBuilder(
      column: $table.nationalId, builder: (column) => column);

  GeneratedColumn<String> get county =>
      $composableBuilder(column: $table.county, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get allergies =>
      $composableBuilder(column: $table.allergies, builder: (column) => column);

  GeneratedColumn<String> get chronicConditions => $composableBuilder(
      column: $table.chronicConditions, builder: (column) => column);

  GeneratedColumn<String> get sha =>
      $composableBuilder(column: $table.sha, builder: (column) => column);

  GeneratedColumn<String> get insurance =>
      $composableBuilder(column: $table.insurance, builder: (column) => column);

  GeneratedColumn<String> get emergencyContact => $composableBuilder(
      column: $table.emergencyContact, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);
}

class $$PatientsTableTableManager extends RootTableManager<
    _$DatabaseService,
    $PatientsTable,
    Patient,
    $$PatientsTableFilterComposer,
    $$PatientsTableOrderingComposer,
    $$PatientsTableAnnotationComposer,
    $$PatientsTableCreateCompanionBuilder,
    $$PatientsTableUpdateCompanionBuilder,
    (Patient, BaseReferences<_$DatabaseService, $PatientsTable, Patient>),
    Patient,
    PrefetchHooks Function()> {
  $$PatientsTableTableManager(_$DatabaseService db, $PatientsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PatientsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PatientsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PatientsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> tenantId = const Value.absent(),
            Value<String> patientNumber = const Value.absent(),
            Value<String> firstName = const Value.absent(),
            Value<String> lastName = const Value.absent(),
            Value<String?> middleName = const Value.absent(),
            Value<DateTime> dateOfBirth = const Value.absent(),
            Value<String> gender = const Value.absent(),
            Value<String?> phone = const Value.absent(),
            Value<String?> nationalId = const Value.absent(),
            Value<String?> county = const Value.absent(),
            Value<String?> address = const Value.absent(),
            Value<String> allergies = const Value.absent(),
            Value<String> chronicConditions = const Value.absent(),
            Value<String?> sha = const Value.absent(),
            Value<String?> insurance = const Value.absent(),
            Value<String?> emergencyContact = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> synced = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PatientsCompanion(
            id: id,
            tenantId: tenantId,
            patientNumber: patientNumber,
            firstName: firstName,
            lastName: lastName,
            middleName: middleName,
            dateOfBirth: dateOfBirth,
            gender: gender,
            phone: phone,
            nationalId: nationalId,
            county: county,
            address: address,
            allergies: allergies,
            chronicConditions: chronicConditions,
            sha: sha,
            insurance: insurance,
            emergencyContact: emergencyContact,
            isActive: isActive,
            createdAt: createdAt,
            updatedAt: updatedAt,
            synced: synced,
            syncStatus: syncStatus,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String tenantId,
            required String patientNumber,
            required String firstName,
            required String lastName,
            Value<String?> middleName = const Value.absent(),
            required DateTime dateOfBirth,
            required String gender,
            Value<String?> phone = const Value.absent(),
            Value<String?> nationalId = const Value.absent(),
            Value<String?> county = const Value.absent(),
            Value<String?> address = const Value.absent(),
            Value<String> allergies = const Value.absent(),
            Value<String> chronicConditions = const Value.absent(),
            Value<String?> sha = const Value.absent(),
            Value<String?> insurance = const Value.absent(),
            Value<String?> emergencyContact = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> synced = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PatientsCompanion.insert(
            id: id,
            tenantId: tenantId,
            patientNumber: patientNumber,
            firstName: firstName,
            lastName: lastName,
            middleName: middleName,
            dateOfBirth: dateOfBirth,
            gender: gender,
            phone: phone,
            nationalId: nationalId,
            county: county,
            address: address,
            allergies: allergies,
            chronicConditions: chronicConditions,
            sha: sha,
            insurance: insurance,
            emergencyContact: emergencyContact,
            isActive: isActive,
            createdAt: createdAt,
            updatedAt: updatedAt,
            synced: synced,
            syncStatus: syncStatus,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PatientsTableProcessedTableManager = ProcessedTableManager<
    _$DatabaseService,
    $PatientsTable,
    Patient,
    $$PatientsTableFilterComposer,
    $$PatientsTableOrderingComposer,
    $$PatientsTableAnnotationComposer,
    $$PatientsTableCreateCompanionBuilder,
    $$PatientsTableUpdateCompanionBuilder,
    (Patient, BaseReferences<_$DatabaseService, $PatientsTable, Patient>),
    Patient,
    PrefetchHooks Function()>;
typedef $$EncountersTableCreateCompanionBuilder = EncountersCompanion Function({
  required String id,
  required String tenantId,
  required String encounterNumber,
  required String patientId,
  required String providerId,
  Value<String> visitType,
  Value<String> status,
  Value<String?> chiefComplaint,
  Value<String?> triage,
  Value<String?> vitals,
  Value<String?> soap,
  Value<String> diagnoses,
  Value<String> prescriptions,
  Value<String> labOrders,
  Value<String?> disposition,
  Value<String?> billing,
  Value<bool> isLocked,
  Value<DateTime?> scheduledAt,
  Value<DateTime?> startedAt,
  Value<DateTime?> completedAt,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> synced,
  Value<String> syncStatus,
  Value<int> rowid,
});
typedef $$EncountersTableUpdateCompanionBuilder = EncountersCompanion Function({
  Value<String> id,
  Value<String> tenantId,
  Value<String> encounterNumber,
  Value<String> patientId,
  Value<String> providerId,
  Value<String> visitType,
  Value<String> status,
  Value<String?> chiefComplaint,
  Value<String?> triage,
  Value<String?> vitals,
  Value<String?> soap,
  Value<String> diagnoses,
  Value<String> prescriptions,
  Value<String> labOrders,
  Value<String?> disposition,
  Value<String?> billing,
  Value<bool> isLocked,
  Value<DateTime?> scheduledAt,
  Value<DateTime?> startedAt,
  Value<DateTime?> completedAt,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> synced,
  Value<String> syncStatus,
  Value<int> rowid,
});

class $$EncountersTableFilterComposer
    extends Composer<_$DatabaseService, $EncountersTable> {
  $$EncountersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tenantId => $composableBuilder(
      column: $table.tenantId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get encounterNumber => $composableBuilder(
      column: $table.encounterNumber,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get patientId => $composableBuilder(
      column: $table.patientId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get providerId => $composableBuilder(
      column: $table.providerId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get visitType => $composableBuilder(
      column: $table.visitType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get chiefComplaint => $composableBuilder(
      column: $table.chiefComplaint,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get triage => $composableBuilder(
      column: $table.triage, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get vitals => $composableBuilder(
      column: $table.vitals, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get soap => $composableBuilder(
      column: $table.soap, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get diagnoses => $composableBuilder(
      column: $table.diagnoses, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get prescriptions => $composableBuilder(
      column: $table.prescriptions, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get labOrders => $composableBuilder(
      column: $table.labOrders, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get disposition => $composableBuilder(
      column: $table.disposition, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get billing => $composableBuilder(
      column: $table.billing, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isLocked => $composableBuilder(
      column: $table.isLocked, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get scheduledAt => $composableBuilder(
      column: $table.scheduledAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
      column: $table.startedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));
}

class $$EncountersTableOrderingComposer
    extends Composer<_$DatabaseService, $EncountersTable> {
  $$EncountersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tenantId => $composableBuilder(
      column: $table.tenantId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get encounterNumber => $composableBuilder(
      column: $table.encounterNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get patientId => $composableBuilder(
      column: $table.patientId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get providerId => $composableBuilder(
      column: $table.providerId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get visitType => $composableBuilder(
      column: $table.visitType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get chiefComplaint => $composableBuilder(
      column: $table.chiefComplaint,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get triage => $composableBuilder(
      column: $table.triage, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get vitals => $composableBuilder(
      column: $table.vitals, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get soap => $composableBuilder(
      column: $table.soap, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get diagnoses => $composableBuilder(
      column: $table.diagnoses, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get prescriptions => $composableBuilder(
      column: $table.prescriptions,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get labOrders => $composableBuilder(
      column: $table.labOrders, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get disposition => $composableBuilder(
      column: $table.disposition, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get billing => $composableBuilder(
      column: $table.billing, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isLocked => $composableBuilder(
      column: $table.isLocked, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get scheduledAt => $composableBuilder(
      column: $table.scheduledAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
      column: $table.startedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));
}

class $$EncountersTableAnnotationComposer
    extends Composer<_$DatabaseService, $EncountersTable> {
  $$EncountersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tenantId =>
      $composableBuilder(column: $table.tenantId, builder: (column) => column);

  GeneratedColumn<String> get encounterNumber => $composableBuilder(
      column: $table.encounterNumber, builder: (column) => column);

  GeneratedColumn<String> get patientId =>
      $composableBuilder(column: $table.patientId, builder: (column) => column);

  GeneratedColumn<String> get providerId => $composableBuilder(
      column: $table.providerId, builder: (column) => column);

  GeneratedColumn<String> get visitType =>
      $composableBuilder(column: $table.visitType, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get chiefComplaint => $composableBuilder(
      column: $table.chiefComplaint, builder: (column) => column);

  GeneratedColumn<String> get triage =>
      $composableBuilder(column: $table.triage, builder: (column) => column);

  GeneratedColumn<String> get vitals =>
      $composableBuilder(column: $table.vitals, builder: (column) => column);

  GeneratedColumn<String> get soap =>
      $composableBuilder(column: $table.soap, builder: (column) => column);

  GeneratedColumn<String> get diagnoses =>
      $composableBuilder(column: $table.diagnoses, builder: (column) => column);

  GeneratedColumn<String> get prescriptions => $composableBuilder(
      column: $table.prescriptions, builder: (column) => column);

  GeneratedColumn<String> get labOrders =>
      $composableBuilder(column: $table.labOrders, builder: (column) => column);

  GeneratedColumn<String> get disposition => $composableBuilder(
      column: $table.disposition, builder: (column) => column);

  GeneratedColumn<String> get billing =>
      $composableBuilder(column: $table.billing, builder: (column) => column);

  GeneratedColumn<bool> get isLocked =>
      $composableBuilder(column: $table.isLocked, builder: (column) => column);

  GeneratedColumn<DateTime> get scheduledAt => $composableBuilder(
      column: $table.scheduledAt, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);
}

class $$EncountersTableTableManager extends RootTableManager<
    _$DatabaseService,
    $EncountersTable,
    Encounter,
    $$EncountersTableFilterComposer,
    $$EncountersTableOrderingComposer,
    $$EncountersTableAnnotationComposer,
    $$EncountersTableCreateCompanionBuilder,
    $$EncountersTableUpdateCompanionBuilder,
    (Encounter, BaseReferences<_$DatabaseService, $EncountersTable, Encounter>),
    Encounter,
    PrefetchHooks Function()> {
  $$EncountersTableTableManager(_$DatabaseService db, $EncountersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EncountersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EncountersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EncountersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> tenantId = const Value.absent(),
            Value<String> encounterNumber = const Value.absent(),
            Value<String> patientId = const Value.absent(),
            Value<String> providerId = const Value.absent(),
            Value<String> visitType = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> chiefComplaint = const Value.absent(),
            Value<String?> triage = const Value.absent(),
            Value<String?> vitals = const Value.absent(),
            Value<String?> soap = const Value.absent(),
            Value<String> diagnoses = const Value.absent(),
            Value<String> prescriptions = const Value.absent(),
            Value<String> labOrders = const Value.absent(),
            Value<String?> disposition = const Value.absent(),
            Value<String?> billing = const Value.absent(),
            Value<bool> isLocked = const Value.absent(),
            Value<DateTime?> scheduledAt = const Value.absent(),
            Value<DateTime?> startedAt = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> synced = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              EncountersCompanion(
            id: id,
            tenantId: tenantId,
            encounterNumber: encounterNumber,
            patientId: patientId,
            providerId: providerId,
            visitType: visitType,
            status: status,
            chiefComplaint: chiefComplaint,
            triage: triage,
            vitals: vitals,
            soap: soap,
            diagnoses: diagnoses,
            prescriptions: prescriptions,
            labOrders: labOrders,
            disposition: disposition,
            billing: billing,
            isLocked: isLocked,
            scheduledAt: scheduledAt,
            startedAt: startedAt,
            completedAt: completedAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
            synced: synced,
            syncStatus: syncStatus,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String tenantId,
            required String encounterNumber,
            required String patientId,
            required String providerId,
            Value<String> visitType = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> chiefComplaint = const Value.absent(),
            Value<String?> triage = const Value.absent(),
            Value<String?> vitals = const Value.absent(),
            Value<String?> soap = const Value.absent(),
            Value<String> diagnoses = const Value.absent(),
            Value<String> prescriptions = const Value.absent(),
            Value<String> labOrders = const Value.absent(),
            Value<String?> disposition = const Value.absent(),
            Value<String?> billing = const Value.absent(),
            Value<bool> isLocked = const Value.absent(),
            Value<DateTime?> scheduledAt = const Value.absent(),
            Value<DateTime?> startedAt = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> synced = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              EncountersCompanion.insert(
            id: id,
            tenantId: tenantId,
            encounterNumber: encounterNumber,
            patientId: patientId,
            providerId: providerId,
            visitType: visitType,
            status: status,
            chiefComplaint: chiefComplaint,
            triage: triage,
            vitals: vitals,
            soap: soap,
            diagnoses: diagnoses,
            prescriptions: prescriptions,
            labOrders: labOrders,
            disposition: disposition,
            billing: billing,
            isLocked: isLocked,
            scheduledAt: scheduledAt,
            startedAt: startedAt,
            completedAt: completedAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
            synced: synced,
            syncStatus: syncStatus,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$EncountersTableProcessedTableManager = ProcessedTableManager<
    _$DatabaseService,
    $EncountersTable,
    Encounter,
    $$EncountersTableFilterComposer,
    $$EncountersTableOrderingComposer,
    $$EncountersTableAnnotationComposer,
    $$EncountersTableCreateCompanionBuilder,
    $$EncountersTableUpdateCompanionBuilder,
    (Encounter, BaseReferences<_$DatabaseService, $EncountersTable, Encounter>),
    Encounter,
    PrefetchHooks Function()>;
typedef $$BillingTableCreateCompanionBuilder = BillingCompanion Function({
  required String id,
  required String tenantId,
  required String invoiceNumber,
  Value<String?> encounterId,
  required String patientId,
  Value<String> type,
  Value<String> status,
  Value<String> items,
  Value<double> subtotal,
  Value<double> discount,
  Value<double> total,
  Value<double> shaCover,
  Value<double> insuranceCover,
  Value<double> patientPay,
  Value<double> amountPaid,
  Value<double> balance,
  Value<String> payments,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> synced,
  Value<String> syncStatus,
  Value<int> rowid,
});
typedef $$BillingTableUpdateCompanionBuilder = BillingCompanion Function({
  Value<String> id,
  Value<String> tenantId,
  Value<String> invoiceNumber,
  Value<String?> encounterId,
  Value<String> patientId,
  Value<String> type,
  Value<String> status,
  Value<String> items,
  Value<double> subtotal,
  Value<double> discount,
  Value<double> total,
  Value<double> shaCover,
  Value<double> insuranceCover,
  Value<double> patientPay,
  Value<double> amountPaid,
  Value<double> balance,
  Value<String> payments,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> synced,
  Value<String> syncStatus,
  Value<int> rowid,
});

class $$BillingTableFilterComposer
    extends Composer<_$DatabaseService, $BillingTable> {
  $$BillingTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tenantId => $composableBuilder(
      column: $table.tenantId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get invoiceNumber => $composableBuilder(
      column: $table.invoiceNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get encounterId => $composableBuilder(
      column: $table.encounterId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get patientId => $composableBuilder(
      column: $table.patientId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get items => $composableBuilder(
      column: $table.items, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get subtotal => $composableBuilder(
      column: $table.subtotal, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get discount => $composableBuilder(
      column: $table.discount, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get total => $composableBuilder(
      column: $table.total, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get shaCover => $composableBuilder(
      column: $table.shaCover, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get insuranceCover => $composableBuilder(
      column: $table.insuranceCover,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get patientPay => $composableBuilder(
      column: $table.patientPay, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get amountPaid => $composableBuilder(
      column: $table.amountPaid, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get balance => $composableBuilder(
      column: $table.balance, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payments => $composableBuilder(
      column: $table.payments, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));
}

class $$BillingTableOrderingComposer
    extends Composer<_$DatabaseService, $BillingTable> {
  $$BillingTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tenantId => $composableBuilder(
      column: $table.tenantId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get invoiceNumber => $composableBuilder(
      column: $table.invoiceNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get encounterId => $composableBuilder(
      column: $table.encounterId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get patientId => $composableBuilder(
      column: $table.patientId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get items => $composableBuilder(
      column: $table.items, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get subtotal => $composableBuilder(
      column: $table.subtotal, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get discount => $composableBuilder(
      column: $table.discount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get total => $composableBuilder(
      column: $table.total, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get shaCover => $composableBuilder(
      column: $table.shaCover, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get insuranceCover => $composableBuilder(
      column: $table.insuranceCover,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get patientPay => $composableBuilder(
      column: $table.patientPay, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get amountPaid => $composableBuilder(
      column: $table.amountPaid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get balance => $composableBuilder(
      column: $table.balance, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payments => $composableBuilder(
      column: $table.payments, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));
}

class $$BillingTableAnnotationComposer
    extends Composer<_$DatabaseService, $BillingTable> {
  $$BillingTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tenantId =>
      $composableBuilder(column: $table.tenantId, builder: (column) => column);

  GeneratedColumn<String> get invoiceNumber => $composableBuilder(
      column: $table.invoiceNumber, builder: (column) => column);

  GeneratedColumn<String> get encounterId => $composableBuilder(
      column: $table.encounterId, builder: (column) => column);

  GeneratedColumn<String> get patientId =>
      $composableBuilder(column: $table.patientId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get items =>
      $composableBuilder(column: $table.items, builder: (column) => column);

  GeneratedColumn<double> get subtotal =>
      $composableBuilder(column: $table.subtotal, builder: (column) => column);

  GeneratedColumn<double> get discount =>
      $composableBuilder(column: $table.discount, builder: (column) => column);

  GeneratedColumn<double> get total =>
      $composableBuilder(column: $table.total, builder: (column) => column);

  GeneratedColumn<double> get shaCover =>
      $composableBuilder(column: $table.shaCover, builder: (column) => column);

  GeneratedColumn<double> get insuranceCover => $composableBuilder(
      column: $table.insuranceCover, builder: (column) => column);

  GeneratedColumn<double> get patientPay => $composableBuilder(
      column: $table.patientPay, builder: (column) => column);

  GeneratedColumn<double> get amountPaid => $composableBuilder(
      column: $table.amountPaid, builder: (column) => column);

  GeneratedColumn<double> get balance =>
      $composableBuilder(column: $table.balance, builder: (column) => column);

  GeneratedColumn<String> get payments =>
      $composableBuilder(column: $table.payments, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);
}

class $$BillingTableTableManager extends RootTableManager<
    _$DatabaseService,
    $BillingTable,
    BillingData,
    $$BillingTableFilterComposer,
    $$BillingTableOrderingComposer,
    $$BillingTableAnnotationComposer,
    $$BillingTableCreateCompanionBuilder,
    $$BillingTableUpdateCompanionBuilder,
    (
      BillingData,
      BaseReferences<_$DatabaseService, $BillingTable, BillingData>
    ),
    BillingData,
    PrefetchHooks Function()> {
  $$BillingTableTableManager(_$DatabaseService db, $BillingTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BillingTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BillingTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BillingTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> tenantId = const Value.absent(),
            Value<String> invoiceNumber = const Value.absent(),
            Value<String?> encounterId = const Value.absent(),
            Value<String> patientId = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String> items = const Value.absent(),
            Value<double> subtotal = const Value.absent(),
            Value<double> discount = const Value.absent(),
            Value<double> total = const Value.absent(),
            Value<double> shaCover = const Value.absent(),
            Value<double> insuranceCover = const Value.absent(),
            Value<double> patientPay = const Value.absent(),
            Value<double> amountPaid = const Value.absent(),
            Value<double> balance = const Value.absent(),
            Value<String> payments = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> synced = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BillingCompanion(
            id: id,
            tenantId: tenantId,
            invoiceNumber: invoiceNumber,
            encounterId: encounterId,
            patientId: patientId,
            type: type,
            status: status,
            items: items,
            subtotal: subtotal,
            discount: discount,
            total: total,
            shaCover: shaCover,
            insuranceCover: insuranceCover,
            patientPay: patientPay,
            amountPaid: amountPaid,
            balance: balance,
            payments: payments,
            createdAt: createdAt,
            updatedAt: updatedAt,
            synced: synced,
            syncStatus: syncStatus,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String tenantId,
            required String invoiceNumber,
            Value<String?> encounterId = const Value.absent(),
            required String patientId,
            Value<String> type = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String> items = const Value.absent(),
            Value<double> subtotal = const Value.absent(),
            Value<double> discount = const Value.absent(),
            Value<double> total = const Value.absent(),
            Value<double> shaCover = const Value.absent(),
            Value<double> insuranceCover = const Value.absent(),
            Value<double> patientPay = const Value.absent(),
            Value<double> amountPaid = const Value.absent(),
            Value<double> balance = const Value.absent(),
            Value<String> payments = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> synced = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BillingCompanion.insert(
            id: id,
            tenantId: tenantId,
            invoiceNumber: invoiceNumber,
            encounterId: encounterId,
            patientId: patientId,
            type: type,
            status: status,
            items: items,
            subtotal: subtotal,
            discount: discount,
            total: total,
            shaCover: shaCover,
            insuranceCover: insuranceCover,
            patientPay: patientPay,
            amountPaid: amountPaid,
            balance: balance,
            payments: payments,
            createdAt: createdAt,
            updatedAt: updatedAt,
            synced: synced,
            syncStatus: syncStatus,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$BillingTableProcessedTableManager = ProcessedTableManager<
    _$DatabaseService,
    $BillingTable,
    BillingData,
    $$BillingTableFilterComposer,
    $$BillingTableOrderingComposer,
    $$BillingTableAnnotationComposer,
    $$BillingTableCreateCompanionBuilder,
    $$BillingTableUpdateCompanionBuilder,
    (
      BillingData,
      BaseReferences<_$DatabaseService, $BillingTable, BillingData>
    ),
    BillingData,
    PrefetchHooks Function()>;
typedef $$InventoryTableCreateCompanionBuilder = InventoryCompanion Function({
  required String id,
  required String tenantId,
  required String itemCode,
  required String name,
  Value<String> category,
  Value<String> unit,
  Value<double> unitPrice,
  Value<double> costPrice,
  Value<int> quantity,
  Value<int> reorderLevel,
  Value<String> batches,
  Value<bool> expiryTracking,
  Value<bool> controlledSubstance,
  Value<String?> formulation,
  Value<String?> strength,
  Value<String> status,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> synced,
  Value<String> syncStatus,
  Value<int> rowid,
});
typedef $$InventoryTableUpdateCompanionBuilder = InventoryCompanion Function({
  Value<String> id,
  Value<String> tenantId,
  Value<String> itemCode,
  Value<String> name,
  Value<String> category,
  Value<String> unit,
  Value<double> unitPrice,
  Value<double> costPrice,
  Value<int> quantity,
  Value<int> reorderLevel,
  Value<String> batches,
  Value<bool> expiryTracking,
  Value<bool> controlledSubstance,
  Value<String?> formulation,
  Value<String?> strength,
  Value<String> status,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> synced,
  Value<String> syncStatus,
  Value<int> rowid,
});

class $$InventoryTableFilterComposer
    extends Composer<_$DatabaseService, $InventoryTable> {
  $$InventoryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tenantId => $composableBuilder(
      column: $table.tenantId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get itemCode => $composableBuilder(
      column: $table.itemCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get unit => $composableBuilder(
      column: $table.unit, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get unitPrice => $composableBuilder(
      column: $table.unitPrice, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get costPrice => $composableBuilder(
      column: $table.costPrice, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get reorderLevel => $composableBuilder(
      column: $table.reorderLevel, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get batches => $composableBuilder(
      column: $table.batches, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get expiryTracking => $composableBuilder(
      column: $table.expiryTracking,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get controlledSubstance => $composableBuilder(
      column: $table.controlledSubstance,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get formulation => $composableBuilder(
      column: $table.formulation, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get strength => $composableBuilder(
      column: $table.strength, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));
}

class $$InventoryTableOrderingComposer
    extends Composer<_$DatabaseService, $InventoryTable> {
  $$InventoryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tenantId => $composableBuilder(
      column: $table.tenantId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get itemCode => $composableBuilder(
      column: $table.itemCode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get unit => $composableBuilder(
      column: $table.unit, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get unitPrice => $composableBuilder(
      column: $table.unitPrice, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get costPrice => $composableBuilder(
      column: $table.costPrice, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get reorderLevel => $composableBuilder(
      column: $table.reorderLevel,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get batches => $composableBuilder(
      column: $table.batches, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get expiryTracking => $composableBuilder(
      column: $table.expiryTracking,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get controlledSubstance => $composableBuilder(
      column: $table.controlledSubstance,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get formulation => $composableBuilder(
      column: $table.formulation, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get strength => $composableBuilder(
      column: $table.strength, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));
}

class $$InventoryTableAnnotationComposer
    extends Composer<_$DatabaseService, $InventoryTable> {
  $$InventoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tenantId =>
      $composableBuilder(column: $table.tenantId, builder: (column) => column);

  GeneratedColumn<String> get itemCode =>
      $composableBuilder(column: $table.itemCode, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<double> get unitPrice =>
      $composableBuilder(column: $table.unitPrice, builder: (column) => column);

  GeneratedColumn<double> get costPrice =>
      $composableBuilder(column: $table.costPrice, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<int> get reorderLevel => $composableBuilder(
      column: $table.reorderLevel, builder: (column) => column);

  GeneratedColumn<String> get batches =>
      $composableBuilder(column: $table.batches, builder: (column) => column);

  GeneratedColumn<bool> get expiryTracking => $composableBuilder(
      column: $table.expiryTracking, builder: (column) => column);

  GeneratedColumn<bool> get controlledSubstance => $composableBuilder(
      column: $table.controlledSubstance, builder: (column) => column);

  GeneratedColumn<String> get formulation => $composableBuilder(
      column: $table.formulation, builder: (column) => column);

  GeneratedColumn<String> get strength =>
      $composableBuilder(column: $table.strength, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);
}

class $$InventoryTableTableManager extends RootTableManager<
    _$DatabaseService,
    $InventoryTable,
    InventoryData,
    $$InventoryTableFilterComposer,
    $$InventoryTableOrderingComposer,
    $$InventoryTableAnnotationComposer,
    $$InventoryTableCreateCompanionBuilder,
    $$InventoryTableUpdateCompanionBuilder,
    (
      InventoryData,
      BaseReferences<_$DatabaseService, $InventoryTable, InventoryData>
    ),
    InventoryData,
    PrefetchHooks Function()> {
  $$InventoryTableTableManager(_$DatabaseService db, $InventoryTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InventoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InventoryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InventoryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> tenantId = const Value.absent(),
            Value<String> itemCode = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<String> unit = const Value.absent(),
            Value<double> unitPrice = const Value.absent(),
            Value<double> costPrice = const Value.absent(),
            Value<int> quantity = const Value.absent(),
            Value<int> reorderLevel = const Value.absent(),
            Value<String> batches = const Value.absent(),
            Value<bool> expiryTracking = const Value.absent(),
            Value<bool> controlledSubstance = const Value.absent(),
            Value<String?> formulation = const Value.absent(),
            Value<String?> strength = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> synced = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              InventoryCompanion(
            id: id,
            tenantId: tenantId,
            itemCode: itemCode,
            name: name,
            category: category,
            unit: unit,
            unitPrice: unitPrice,
            costPrice: costPrice,
            quantity: quantity,
            reorderLevel: reorderLevel,
            batches: batches,
            expiryTracking: expiryTracking,
            controlledSubstance: controlledSubstance,
            formulation: formulation,
            strength: strength,
            status: status,
            createdAt: createdAt,
            updatedAt: updatedAt,
            synced: synced,
            syncStatus: syncStatus,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String tenantId,
            required String itemCode,
            required String name,
            Value<String> category = const Value.absent(),
            Value<String> unit = const Value.absent(),
            Value<double> unitPrice = const Value.absent(),
            Value<double> costPrice = const Value.absent(),
            Value<int> quantity = const Value.absent(),
            Value<int> reorderLevel = const Value.absent(),
            Value<String> batches = const Value.absent(),
            Value<bool> expiryTracking = const Value.absent(),
            Value<bool> controlledSubstance = const Value.absent(),
            Value<String?> formulation = const Value.absent(),
            Value<String?> strength = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> synced = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              InventoryCompanion.insert(
            id: id,
            tenantId: tenantId,
            itemCode: itemCode,
            name: name,
            category: category,
            unit: unit,
            unitPrice: unitPrice,
            costPrice: costPrice,
            quantity: quantity,
            reorderLevel: reorderLevel,
            batches: batches,
            expiryTracking: expiryTracking,
            controlledSubstance: controlledSubstance,
            formulation: formulation,
            strength: strength,
            status: status,
            createdAt: createdAt,
            updatedAt: updatedAt,
            synced: synced,
            syncStatus: syncStatus,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$InventoryTableProcessedTableManager = ProcessedTableManager<
    _$DatabaseService,
    $InventoryTable,
    InventoryData,
    $$InventoryTableFilterComposer,
    $$InventoryTableOrderingComposer,
    $$InventoryTableAnnotationComposer,
    $$InventoryTableCreateCompanionBuilder,
    $$InventoryTableUpdateCompanionBuilder,
    (
      InventoryData,
      BaseReferences<_$DatabaseService, $InventoryTable, InventoryData>
    ),
    InventoryData,
    PrefetchHooks Function()>;
typedef $$SyncQueueTableCreateCompanionBuilder = SyncQueueCompanion Function({
  Value<int> id,
  required String entityType,
  required String entityId,
  required String action,
  required String data,
  Value<DateTime> createdAt,
  Value<int> retryCount,
  Value<String?> lastError,
});
typedef $$SyncQueueTableUpdateCompanionBuilder = SyncQueueCompanion Function({
  Value<int> id,
  Value<String> entityType,
  Value<String> entityId,
  Value<String> action,
  Value<String> data,
  Value<DateTime> createdAt,
  Value<int> retryCount,
  Value<String?> lastError,
});

class $$SyncQueueTableFilterComposer
    extends Composer<_$DatabaseService, $SyncQueueTable> {
  $$SyncQueueTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get action => $composableBuilder(
      column: $table.action, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get data => $composableBuilder(
      column: $table.data, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastError => $composableBuilder(
      column: $table.lastError, builder: (column) => ColumnFilters(column));
}

class $$SyncQueueTableOrderingComposer
    extends Composer<_$DatabaseService, $SyncQueueTable> {
  $$SyncQueueTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get action => $composableBuilder(
      column: $table.action, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get data => $composableBuilder(
      column: $table.data, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastError => $composableBuilder(
      column: $table.lastError, builder: (column) => ColumnOrderings(column));
}

class $$SyncQueueTableAnnotationComposer
    extends Composer<_$DatabaseService, $SyncQueueTable> {
  $$SyncQueueTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => column);

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => column);

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);
}

class $$SyncQueueTableTableManager extends RootTableManager<
    _$DatabaseService,
    $SyncQueueTable,
    SyncQueueData,
    $$SyncQueueTableFilterComposer,
    $$SyncQueueTableOrderingComposer,
    $$SyncQueueTableAnnotationComposer,
    $$SyncQueueTableCreateCompanionBuilder,
    $$SyncQueueTableUpdateCompanionBuilder,
    (
      SyncQueueData,
      BaseReferences<_$DatabaseService, $SyncQueueTable, SyncQueueData>
    ),
    SyncQueueData,
    PrefetchHooks Function()> {
  $$SyncQueueTableTableManager(_$DatabaseService db, $SyncQueueTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncQueueTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncQueueTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncQueueTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> entityType = const Value.absent(),
            Value<String> entityId = const Value.absent(),
            Value<String> action = const Value.absent(),
            Value<String> data = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> retryCount = const Value.absent(),
            Value<String?> lastError = const Value.absent(),
          }) =>
              SyncQueueCompanion(
            id: id,
            entityType: entityType,
            entityId: entityId,
            action: action,
            data: data,
            createdAt: createdAt,
            retryCount: retryCount,
            lastError: lastError,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String entityType,
            required String entityId,
            required String action,
            required String data,
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> retryCount = const Value.absent(),
            Value<String?> lastError = const Value.absent(),
          }) =>
              SyncQueueCompanion.insert(
            id: id,
            entityType: entityType,
            entityId: entityId,
            action: action,
            data: data,
            createdAt: createdAt,
            retryCount: retryCount,
            lastError: lastError,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SyncQueueTableProcessedTableManager = ProcessedTableManager<
    _$DatabaseService,
    $SyncQueueTable,
    SyncQueueData,
    $$SyncQueueTableFilterComposer,
    $$SyncQueueTableOrderingComposer,
    $$SyncQueueTableAnnotationComposer,
    $$SyncQueueTableCreateCompanionBuilder,
    $$SyncQueueTableUpdateCompanionBuilder,
    (
      SyncQueueData,
      BaseReferences<_$DatabaseService, $SyncQueueTable, SyncQueueData>
    ),
    SyncQueueData,
    PrefetchHooks Function()>;

class $DatabaseServiceManager {
  final _$DatabaseService _db;
  $DatabaseServiceManager(this._db);
  $$PatientsTableTableManager get patients =>
      $$PatientsTableTableManager(_db, _db.patients);
  $$EncountersTableTableManager get encounters =>
      $$EncountersTableTableManager(_db, _db.encounters);
  $$BillingTableTableManager get billing =>
      $$BillingTableTableManager(_db, _db.billing);
  $$InventoryTableTableManager get inventory =>
      $$InventoryTableTableManager(_db, _db.inventory);
  $$SyncQueueTableTableManager get syncQueue =>
      $$SyncQueueTableTableManager(_db, _db.syncQueue);
}
