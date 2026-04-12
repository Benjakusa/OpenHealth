const { DataTypes } = require('sequelize');

module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.createTable('tenants', {
      id: { type: DataTypes.UUID, defaultValue: DataTypes.UUIDV4, primaryKey: true },
      name: { type: DataTypes.STRING, allowNull: false },
      slug: { type: DataTypes.STRING, allowNull: false, unique: true },
      schema: { type: DataTypes.STRING, allowNull: false, unique: true },
      package: { type: DataTypes.ENUM('DAWA', 'AFYA', 'HOSPITALI'), defaultValue: 'DAWA' },
      facility_type: { type: DataTypes.STRING, allowNull: true },
      facility_level: { type: DataTypes.INTEGER, allowNull: true },
      registration_number: { type: DataTypes.STRING, allowNull: true },
      keph_level: { type: DataTypes.INTEGER, allowNull: true },
      address: { type: DataTypes.JSONB, defaultValue: {} },
      contacts: { type: DataTypes.JSONB, defaultValue: {} },
      sha_facility_id: { type: DataTypes.STRING, allowNull: true },
      insurance_credentials: { type: DataTypes.JSONB, defaultValue: {} },
      settings: { type: DataTypes.JSONB, defaultValue: {} },
      status: { type: DataTypes.ENUM('active', 'trial', 'suspended', 'terminated'), defaultValue: 'trial' },
      subscription: { type: DataTypes.JSONB, defaultValue: {} },
      storage: { type: DataTypes.BIGINT, defaultValue: 0 },
      storage_limit: { type: DataTypes.BIGINT, defaultValue: 5368709120 },
      expires_at: { type: DataTypes.DATE, allowNull: true },
      last_sync_at: { type: DataTypes.DATE, allowNull: true },
      created_at: { type: DataTypes.DATE, defaultValue: DataTypes.NOW },
      updated_at: { type: DataTypes.DATE, defaultValue: DataTypes.NOW },
    });

    await queryInterface.createTable('users', {
      id: { type: DataTypes.UUID, defaultValue: DataTypes.UUIDV4, primaryKey: true },
      tenantId: { type: DataTypes.UUID, allowNull: false, references: { model: 'tenants', key: 'id' } },
      email: { type: DataTypes.STRING, allowNull: false, unique: 'userEmailTenant' },
      passwordHash: { type: DataTypes.STRING, allowNull: false },
      firstName: { type: DataTypes.STRING, allowNull: false },
      lastName: { type: DataTypes.STRING, allowNull: false },
      middleName: { type: DataTypes.STRING, allowNull: true },
      role: { type: DataTypes.ENUM('super_admin', 'tenant_admin', 'doctor', 'nurse', 'pharmacist', 'lab_technician', 'receptionist', 'cashier', 'ward_clerk', 'records_clerk', 'inventory_manager', 'billing_clerk', 'it_admin', 'report_viewer'), defaultValue: 'receptionist' },
      department: { type: DataTypes.STRING, allowNull: true },
      phone: { type: DataTypes.STRING, allowNull: true },
      licenseNumber: { type: DataTypes.STRING, allowNull: true },
      signature: { type: DataTypes.TEXT, allowNull: true },
      isActive: { type: DataTypes.BOOLEAN, defaultValue: true },
      lastLoginAt: { type: DataTypes.DATE, allowNull: true },
      createdAt: { type: DataTypes.DATE, defaultValue: DataTypes.NOW },
      updatedAt: { type: DataTypes.DATE, defaultValue: DataTypes.NOW },
    }, { uniqueKeys: { userEmailTenant: { fields: ['email', 'tenantId'] } } });

    await queryInterface.createTable('patients', {
      id: { type: DataTypes.UUID, defaultValue: DataTypes.UUIDV4, primaryKey: true },
      tenantId: { type: DataTypes.UUID, allowNull: false, references: { model: 'tenants', key: 'id' } },
      patientNumber: { type: DataTypes.STRING, allowNull: false, unique: true },
      firstName: { type: DataTypes.STRING, allowNull: false },
      lastName: { type: DataTypes.STRING, allowNull: false },
      middleName: { type: DataTypes.STRING, allowNull: true },
      dateOfBirth: { type: DataTypes.DATEONLY, allowNull: false },
      gender: { type: DataTypes.ENUM('male', 'female', 'other'), allowNull: false },
      phone: { type: DataTypes.STRING, allowNull: true },
      nationalId: { type: DataTypes.STRING, allowNull: true },
      email: { type: DataTypes.STRING, allowNull: true },
      county: { type: DataTypes.STRING, allowNull: true },
      address: { type: DataTypes.STRING, allowNull: true },
      allergies: { type: DataTypes.JSONB, defaultValue: [] },
      chronicConditions: { type: DataTypes.JSONB, defaultValue: [] },
      emergencyContact: { type: DataTypes.JSONB, allowNull: true },
      sha: { type: DataTypes.JSONB, allowNull: true },
      insurance: { type: DataTypes.JSONB, allowNull: true },
      isActive: { type: DataTypes.BOOLEAN, defaultValue: true },
      createdAt: { type: DataTypes.DATE, defaultValue: DataTypes.NOW },
      updatedAt: { type: DataTypes.DATE, defaultValue: DataTypes.NOW },
    });

    await queryInterface.createTable('encounters', {
      id: { type: DataTypes.UUID, defaultValue: DataTypes.UUIDV4, primaryKey: true },
      tenantId: { type: DataTypes.UUID, allowNull: false, references: { model: 'tenants', key: 'id' } },
      encounterNumber: { type: DataTypes.STRING, allowNull: false, unique: true },
      patientId: { type: DataTypes.UUID, allowNull: false, references: { model: 'patients', key: 'id' } },
      providerId: { type: DataTypes.UUID, allowNull: true, references: { model: 'users', key: 'id' } },
      visitType: { type: DataTypes.ENUM('new', 'follow_up', 'emergency', 'prenatal', 'well_child'), defaultValue: 'new' },
      status: { type: DataTypes.ENUM('pending_triage', 'pending_doctor', 'in_progress', 'completed', 'cancelled', 'referred', 'admitted'), defaultValue: 'pending_triage' },
      chiefComplaint: { type: DataTypes.TEXT, allowNull: true },
      triage: { type: DataTypes.JSONB, allowNull: true },
      vitals: { type: DataTypes.JSONB, allowNull: true },
      soap: { type: DataTypes.JSONB, allowNull: true },
      diagnoses: { type: DataTypes.JSONB, defaultValue: [] },
      prescriptions: { type: DataTypes.JSONB, defaultValue: [] },
      labOrders: { type: DataTypes.JSONB, defaultValue: [] },
      disposition: { type: DataTypes.JSONB, allowNull: true },
      billing: { type: DataTypes.JSONB, allowNull: true },
      isLocked: { type: DataTypes.BOOLEAN, defaultValue: false },
      scheduledAt: { type: DataTypes.DATE, allowNull: true },
      startedAt: { type: DataTypes.DATE, allowNull: true },
      completedAt: { type: DataTypes.DATE, allowNull: true },
      createdAt: { type: DataTypes.DATE, defaultValue: DataTypes.NOW },
      updatedAt: { type: DataTypes.DATE, defaultValue: DataTypes.NOW },
    });

    await queryInterface.createTable('invoices', {
      id: { type: DataTypes.UUID, defaultValue: DataTypes.UUIDV4, primaryKey: true },
      tenantId: { type: DataTypes.UUID, allowNull: false, references: { model: 'tenants', key: 'id' } },
      invoiceNumber: { type: DataTypes.STRING, allowNull: false, unique: true },
      encounterId: { type: DataTypes.UUID, allowNull: true, references: { model: 'encounters', key: 'id' } },
      patientId: { type: DataTypes.UUID, allowNull: false, references: { model: 'patients', key: 'id' } },
      status: { type: DataTypes.ENUM('draft', 'pending', 'partially_paid', 'paid', 'cancelled', 'refunded'), defaultValue: 'draft' },
      subtotal: { type: DataTypes.DECIMAL(12, 2), defaultValue: 0 },
      discount: { type: DataTypes.DECIMAL(12, 2), defaultValue: 0 },
      total: { type: DataTypes.DECIMAL(12, 2), defaultValue: 0 },
      shaCover: { type: DataTypes.DECIMAL(12, 2), defaultValue: 0 },
      insuranceCover: { type: DataTypes.DECIMAL(12, 2), defaultValue: 0 },
      patientPay: { type: DataTypes.DECIMAL(12, 2), defaultValue: 0 },
      amountPaid: { type: DataTypes.DECIMAL(12, 2), defaultValue: 0 },
      balance: { type: DataTypes.DECIMAL(12, 2), defaultValue: 0 },
      dueDate: { type: DataTypes.DATE, allowNull: true },
      paidAt: { type: DataTypes.DATE, allowNull: true },
      createdAt: { type: DataTypes.DATE, defaultValue: DataTypes.NOW },
      updatedAt: { type: DataTypes.DATE, defaultValue: DataTypes.NOW },
    });

    await queryInterface.createTable('invoice_items', {
      id: { type: DataTypes.UUID, defaultValue: DataTypes.UUIDV4, primaryKey: true },
      invoiceId: { type: DataTypes.UUID, allowNull: false, references: { model: 'invoices', key: 'id' }, onDelete: 'CASCADE' },
      itemCode: { type: DataTypes.STRING, allowNull: true },
      description: { type: DataTypes.STRING, allowNull: false },
      category: { type: DataTypes.STRING, allowNull: true },
      quantity: { type: DataTypes.INTEGER, defaultValue: 1 },
      unitPrice: { type: DataTypes.DECIMAL(12, 2), allowNull: false },
      total: { type: DataTypes.DECIMAL(12, 2), allowNull: false },
      department: { type: DataTypes.STRING, allowNull: true },
      referenceId: { type: DataTypes.UUID, allowNull: true },
      createdAt: { type: DataTypes.DATE, defaultValue: DataTypes.NOW },
    });

    await queryInterface.createTable('payments', {
      id: { type: DataTypes.UUID, defaultValue: DataTypes.UUIDV4, primaryKey: true },
      tenantId: { type: DataTypes.UUID, allowNull: false, references: { model: 'tenants', key: 'id' } },
      invoiceId: { type: DataTypes.UUID, allowNull: true, references: { model: 'invoices', key: 'id' } },
      patientId: { type: DataTypes.UUID, allowNull: false, references: { model: 'patients', key: 'id' } },
      paymentNumber: { type: DataTypes.STRING, allowNull: false, unique: true },
      amount: { type: DataTypes.DECIMAL(12, 2), allowNull: false },
      method: { type: DataTypes.ENUM('cash', 'mpesa', 'card', 'insurance', 'sha', 'bank'), defaultValue: 'cash' },
      reference: { type: DataTypes.STRING, allowNull: true },
      mpesaReceiptNumber: { type: DataTypes.STRING, allowNull: true },
      mpesaCheckoutRequestId: { type: DataTypes.STRING, allowNull: true },
      status: { type: DataTypes.ENUM('pending', 'completed', 'failed', 'reversed'), defaultValue: 'pending' },
      notes: { type: DataTypes.TEXT, allowNull: true },
      processedBy: { type: DataTypes.UUID, allowNull: true, references: { model: 'users', key: 'id' } },
      createdAt: { type: DataTypes.DATE, defaultValue: DataTypes.NOW },
      updatedAt: { type: DataTypes.DATE, defaultValue: DataTypes.NOW },
    });

    await queryInterface.createTable('insurance_policies', {
      id: { type: DataTypes.UUID, defaultValue: DataTypes.UUIDV4, primaryKey: true },
      tenantId: { type: DataTypes.UUID, allowNull: false, references: { model: 'tenants', key: 'id' } },
      patientId: { type: DataTypes.UUID, allowNull: false, references: { model: 'patients', key: 'id' } },
      provider: { type: DataTypes.STRING, allowNull: false },
      policyNumber: { type: DataTypes.STRING, allowNull: false },
      memberNumber: { type: DataTypes.STRING, allowNull: true },
      principalName: { type: DataTypes.STRING, allowNull: true },
      relationship: { type: DataTypes.STRING, allowNull: true },
      planType: { type: DataTypes.STRING, allowNull: true },
      coverAmount: { type: DataTypes.DECIMAL(12, 2), defaultValue: 0 },
      utilizedAmount: { type: DataTypes.DECIMAL(12, 2), defaultValue: 0 },
      startDate: { type: DataTypes.DATE, allowNull: true },
      endDate: { type: DataTypes.DATE, allowNull: true },
      isPrimary: { type: DataTypes.BOOLEAN, defaultValue: false },
      status: { type: DataTypes.ENUM('active', 'expired', 'suspended', 'cancelled'), defaultValue: 'active' },
      createdAt: { type: DataTypes.DATE, defaultValue: DataTypes.NOW },
      updatedAt: { type: DataTypes.DATE, defaultValue: DataTypes.NOW },
    });

    await queryInterface.createTable('claims', {
      id: { type: DataTypes.UUID, defaultValue: DataTypes.UUIDV4, primaryKey: true },
      tenantId: { type: DataTypes.UUID, allowNull: false, references: { model: 'tenants', key: 'id' } },
      invoiceId: { type: DataTypes.UUID, allowNull: true, references: { model: 'invoices', key: 'id' } },
      patientId: { type: DataTypes.UUID, allowNull: false, references: { model: 'patients', key: 'id' } },
      claimNumber: { type: DataTypes.STRING, allowNull: false, unique: true },
      type: { type: DataTypes.ENUM('sha', 'insurance', 'pre_auth'), defaultValue: 'sha' },
      status: { type: DataTypes.ENUM('draft', 'submitted', 'pending', 'approved', 'rejected', 'paid', 'partial'), defaultValue: 'draft' },
      amount: { type: DataTypes.DECIMAL(12, 2), defaultValue: 0 },
      approvedAmount: { type: DataTypes.DECIMAL(12, 2), defaultValue: 0 },
      paidAmount: { type: DataTypes.DECIMAL(12, 2), defaultValue: 0 },
      serviceDate: { type: DataTypes.DATE, allowNull: true },
      submittedAt: { type: DataTypes.DATE, allowNull: true },
      processedAt: { type: DataTypes.DATE, allowNull: true },
      fhirClaimId: { type: DataTypes.STRING, allowNull: true },
      externalReference: { type: DataTypes.STRING, allowNull: true },
      notes: { type: DataTypes.TEXT, allowNull: true },
      createdAt: { type: DataTypes.DATE, defaultValue: DataTypes.NOW },
      updatedAt: { type: DataTypes.DATE, defaultValue: DataTypes.NOW },
    });

    await queryInterface.createTable('claim_line_items', {
      id: { type: DataTypes.UUID, defaultValue: DataTypes.UUIDV4, primaryKey: true },
      claimId: { type: DataTypes.UUID, allowNull: false, references: { model: 'claims', key: 'id' }, onDelete: 'CASCADE' },
      serviceDate: { type: DataTypes.DATE, allowNull: true },
      serviceCode: { type: DataTypes.STRING, allowNull: true },
      description: { type: DataTypes.STRING, allowNull: false },
      quantity: { type: DataTypes.INTEGER, defaultValue: 1 },
      unitPrice: { type: DataTypes.DECIMAL(12, 2), allowNull: false },
      total: { type: DataTypes.DECIMAL(12, 2), allowNull: false },
      approvedQuantity: { type: DataTypes.INTEGER, allowNull: true },
      approvedAmount: { type: DataTypes.DECIMAL(12, 2), allowNull: true },
      denialReason: { type: DataTypes.STRING, allowNull: true },
      createdAt: { type: DataTypes.DATE, defaultValue: DataTypes.NOW },
    });

    await queryInterface.createTable('inventory', {
      id: { type: DataTypes.UUID, defaultValue: DataTypes.UUIDV4, primaryKey: true },
      tenantId: { type: DataTypes.UUID, allowNull: false, references: { model: 'tenants', key: 'id' } },
      itemCode: { type: DataTypes.STRING, allowNull: false },
      name: { type: DataTypes.STRING, allowNull: false },
      category: { type: DataTypes.ENUM('drug', 'supply', 'equipment', 'consumable'), defaultValue: 'drug' },
      unit: { type: DataTypes.STRING, defaultValue: 'unit' },
      unitPrice: { type: DataTypes.DECIMAL(12, 2), defaultValue: 0 },
      costPrice: { type: DataTypes.DECIMAL(12, 2), defaultValue: 0 },
      quantity: { type: DataTypes.INTEGER, defaultValue: 0 },
      reorderLevel: { type: DataTypes.INTEGER, defaultValue: 10 },
      batches: { type: DataTypes.JSONB, defaultValue: [] },
      expiryTracking: { type: DataTypes.BOOLEAN, defaultValue: false },
      controlledSubstance: { type: DataTypes.BOOLEAN, defaultValue: false },
      formulation: { type: DataTypes.STRING, allowNull: true },
      strength: { type: DataTypes.STRING, allowNull: true },
      status: { type: DataTypes.ENUM('active', 'inactive', 'discontinued'), defaultValue: 'active' },
      createdAt: { type: DataTypes.DATE, defaultValue: DataTypes.NOW },
      updatedAt: { type: DataTypes.DATE, defaultValue: DataTypes.NOW },
    });

    await queryInterface.createTable('wards', {
      id: { type: DataTypes.UUID, defaultValue: DataTypes.UUIDV4, primaryKey: true },
      tenantId: { type: DataTypes.UUID, allowNull: false, references: { model: 'tenants', key: 'id' } },
      name: { type: DataTypes.STRING, allowNull: false },
      code: { type: DataTypes.STRING, allowNull: false },
      type: { type: DataTypes.ENUM('general', 'icu', 'maternity', 'pediatric', 'surgical', 'private', 'semi_private', 'ward'), defaultValue: 'general' },
      gender: { type: DataTypes.ENUM('male', 'female', 'mixed', 'children'), allowNull: true },
      floor: { type: DataTypes.STRING, allowNull: true },
      building: { type: DataTypes.STRING, allowNull: true },
      totalBeds: { type: DataTypes.INTEGER, defaultValue: 0 },
      status: { type: DataTypes.ENUM('active', 'inactive', 'maintenance'), defaultValue: 'active' },
      createdAt: { type: DataTypes.DATE, defaultValue: DataTypes.NOW },
      updatedAt: { type: DataTypes.DATE, defaultValue: DataTypes.NOW },
    });

    await queryInterface.createTable('beds', {
      id: { type: DataTypes.UUID, defaultValue: DataTypes.UUIDV4, primaryKey: true },
      wardId: { type: DataTypes.UUID, allowNull: false, references: { model: 'wards', key: 'id' } },
      bedNumber: { type: DataTypes.STRING, allowNull: false },
      type: { type: DataTypes.ENUM('standard', 'electric', 'icu', 'pediatric', 'isolation', 'stretchers'), defaultValue: 'standard' },
      status: { type: DataTypes.ENUM('available', 'occupied', 'reserved', 'maintenance', 'cleaning'), defaultValue: 'available' },
      features: { type: DataTypes.JSONB, defaultValue: [] },
      createdAt: { type: DataTypes.DATE, defaultValue: DataTypes.NOW },
      updatedAt: { type: DataTypes.DATE, defaultValue: DataTypes.NOW },
    });

    await queryInterface.createTable('admissions', {
      id: { type: DataTypes.UUID, defaultValue: DataTypes.UUIDV4, primaryKey: true },
      tenantId: { type: DataTypes.UUID, allowNull: false, references: { model: 'tenants', key: 'id' } },
      admissionNumber: { type: DataTypes.STRING, allowNull: false, unique: true },
      patientId: { type: DataTypes.UUID, allowNull: false, references: { model: 'patients', key: 'id' } },
      encounterId: { type: DataTypes.UUID, allowNull: true, references: { model: 'encounters', key: 'id' } },
      wardId: { type: DataTypes.UUID, allowNull: false, references: { model: 'wards', key: 'id' } },
      bedId: { type: DataTypes.UUID, allowNull: true, references: { model: 'beds', key: 'id' } },
      admittedBy: { type: DataTypes.UUID, allowNull: true, references: { model: 'users', key: 'id' } },
      attendingDoctorId: { type: DataTypes.UUID, allowNull: true, references: { model: 'users', key: 'id' } },
      admissionDate: { type: DataTypes.DATE, allowNull: false },
      dischargeDate: { type: DataTypes.DATE, allowNull: true },
      reason: { type: DataTypes.TEXT, allowNull: true },
      diagnosis: { type: DataTypes.TEXT, allowNull: true },
      status: { type: DataTypes.ENUM('admitted', 'discharged', 'transferred', 'absconded', 'deceased'), defaultValue: 'admitted' },
      dischargeNotes: { type: DataTypes.TEXT, allowNull: true },
      createdAt: { type: DataTypes.DATE, defaultValue: DataTypes.NOW },
      updatedAt: { type: DataTypes.DATE, defaultValue: DataTypes.NOW },
    });

    await queryInterface.createTable('nursing_notes', {
      id: { type: DataTypes.UUID, defaultValue: DataTypes.UUIDV4, primaryKey: true },
      admissionId: { type: DataTypes.UUID, allowNull: false, references: { model: 'admissions', key: 'id' } },
      patientId: { type: DataTypes.UUID, allowNull: false, references: { model: 'patients', key: 'id' } },
      nurseId: { type: DataTypes.UUID, allowNull: false, references: { model: 'users', key: 'id' } },
      noteType: { type: DataTypes.ENUM('vitals', 'medication', 'observation', 'care_plan', 'general'), defaultValue: 'general' },
      content: { type: DataTypes.TEXT, allowNull: false },
      vitals: { type: DataTypes.JSONB, allowNull: true },
      createdAt: { type: DataTypes.DATE, defaultValue: DataTypes.NOW },
    });

    await queryInterface.createTable('medication_administration_records', {
      id: { type: DataTypes.UUID, defaultValue: DataTypes.UUIDV4, primaryKey: true },
      admissionId: { type: DataTypes.UUID, allowNull: false, references: { model: 'admissions', key: 'id' } },
      patientId: { type: DataTypes.UUID, allowNull: false, references: { model: 'patients', key: 'id' } },
      prescriptionItemId: { type: DataTypes.UUID, allowNull: true },
      drugName: { type: DataTypes.STRING, allowNull: false },
      dosage: { type: DataTypes.STRING, allowNull: false },
      route: { type: DataTypes.STRING, allowNull: true },
      frequency: { type: DataTypes.STRING, allowNull: true },
      administeredBy: { type: DataTypes.UUID, allowNull: false, references: { model: 'users', key: 'id' } },
      administeredAt: { type: DataTypes.DATE, allowNull: false },
      status: { type: DataTypes.ENUM('given', 'missed', 'refused', 'held'), defaultValue: 'given' },
      notes: { type: DataTypes.TEXT, allowNull: true },
      createdAt: { type: DataTypes.DATE, defaultValue: DataTypes.NOW },
    });

    await queryInterface.createTable('report_templates', {
      id: { type: DataTypes.UUID, defaultValue: DataTypes.UUIDV4, primaryKey: true },
      tenantId: { type: DataTypes.UUID, allowNull: false, references: { model: 'tenants', key: 'id' } },
      name: { type: DataTypes.STRING, allowNull: false },
      type: { type: DataTypes.ENUM('patient', 'financial', 'operational', 'clinical', 'inventory', 'custom'), defaultValue: 'custom' },
      category: { type: DataTypes.STRING, allowNull: true },
      description: { type: DataTypes.TEXT, allowNull: true },
      query: { type: DataTypes.TEXT, allowNull: true },
      columns: { type: DataTypes.JSONB, defaultValue: [] },
      filters: { type: DataTypes.JSONB, defaultValue: [] },
      sortOrder: { type: DataTypes.JSONB, defaultValue: [] },
      format: { type: DataTypes.ENUM('table', 'chart', 'pdf', 'excel'), defaultValue: 'table' },
      schedule: { type: DataTypes.JSONB, allowNull: true },
      isDefault: { type: DataTypes.BOOLEAN, defaultValue: false },
      createdAt: { type: DataTypes.DATE, defaultValue: DataTypes.NOW },
      updatedAt: { type: DataTypes.DATE, defaultValue: DataTypes.NOW },
    });

    await queryInterface.createTable('report_schedules', {
      id: { type: DataTypes.UUID, defaultValue: DataTypes.UUIDV4, primaryKey: true },
      templateId: { type: DataTypes.UUID, allowNull: false, references: { model: 'report_templates', key: 'id' } },
      tenantId: { type: DataTypes.UUID, allowNull: false, references: { model: 'tenants', key: 'id' } },
      name: { type: DataTypes.STRING, allowNull: false },
      frequency: { type: DataTypes.ENUM('daily', 'weekly', 'monthly', 'quarterly'), defaultValue: 'daily' },
      time: { type: DataTypes.TIME, allowNull: false },
      recipients: { type: DataTypes.JSONB, defaultValue: [] },
      parameters: { type: DataTypes.JSONB, defaultValue: {} },
      isActive: { type: DataTypes.BOOLEAN, defaultValue: true },
      lastRunAt: { type: DataTypes.DATE, allowNull: true },
      nextRunAt: { type: DataTypes.DATE, allowNull: true },
      createdAt: { type: DataTypes.DATE, defaultValue: DataTypes.NOW },
      updatedAt: { type: DataTypes.DATE, defaultValue: DataTypes.NOW },
    });

    await queryInterface.createTable('reports', {
      id: { type: DataTypes.UUID, defaultValue: DataTypes.UUIDV4, primaryKey: true },
      templateId: { type: DataTypes.UUID, allowNull: true, references: { model: 'report_templates', key: 'id' } },
      tenantId: { type: DataTypes.UUID, allowNull: false, references: { model: 'tenants', key: 'id' } },
      name: { type: DataTypes.STRING, allowNull: false },
      type: { type: DataTypes.ENUM('patient', 'financial', 'operational', 'clinical', 'inventory', 'custom'), defaultValue: 'custom' },
      parameters: { type: DataTypes.JSONB, defaultValue: {} },
      data: { type: DataTypes.JSONB, allowNull: true },
      fileUrl: { type: DataTypes.STRING, allowNull: true },
      generatedBy: { type: DataTypes.UUID, allowNull: true, references: { model: 'users', key: 'id' } },
      generatedAt: { type: DataTypes.DATE, defaultValue: DataTypes.NOW },
    });

    await queryInterface.createTable('lab_orders', {
      id: { type: DataTypes.UUID, defaultValue: DataTypes.UUIDV4, primaryKey: true },
      tenantId: { type: DataTypes.UUID, allowNull: false, references: { model: 'tenants', key: 'id' } },
      orderNumber: { type: DataTypes.STRING, allowNull: false, unique: true },
      patientId: { type: DataTypes.UUID, allowNull: false, references: { model: 'patients', key: 'id' } },
      encounterId: { type: DataTypes.UUID, allowNull: true, references: { model: 'encounters', key: 'id' } },
      testCode: { type: DataTypes.STRING, allowNull: false },
      testName: { type: DataTypes.STRING, allowNull: false },
      priority: { type: DataTypes.ENUM('normal', 'urgent', 'stat'), defaultValue: 'normal' },
      status: { type: DataTypes.ENUM('pending', 'collected', 'processing', 'completed', 'cancelled', 'resulted'), defaultValue: 'pending' },
      specimens: { type: DataTypes.JSONB, allowNull: true },
      results: { type: DataTypes.JSONB, allowNull: true },
      notes: { type: DataTypes.TEXT, allowNull: true },
      conclusion: { type: DataTypes.TEXT, allowNull: true },
      orderedBy: { type: DataTypes.UUID, allowNull: true, references: { model: 'users', key: 'id' } },
      collectedBy: { type: DataTypes.UUID, allowNull: true, references: { model: 'users', key: 'id' } },
      resultedBy: { type: DataTypes.UUID, allowNull: true, references: { model: 'users', key: 'id' } },
      orderedAt: { type: DataTypes.DATE, defaultValue: DataTypes.NOW },
      collectedAt: { type: DataTypes.DATE, allowNull: true },
      resultedAt: { type: DataTypes.DATE, allowNull: true },
      createdAt: { type: DataTypes.DATE, defaultValue: DataTypes.NOW },
      updatedAt: { type: DataTypes.DATE, defaultValue: DataTypes.NOW },
    });

    await queryInterface.createTable('prescriptions', {
      id: { type: DataTypes.UUID, defaultValue: DataTypes.UUIDV4, primaryKey: true },
      tenantId: { type: DataTypes.UUID, allowNull: false, references: { model: 'tenants', key: 'id' } },
      prescriptionNumber: { type: DataTypes.STRING, allowNull: false, unique: true },
      patientId: { type: DataTypes.UUID, allowNull: false, references: { model: 'patients', key: 'id' } },
      encounterId: { type: DataTypes.UUID, allowNull: true, references: { model: 'encounters', key: 'id' } },
      prescriberId: { type: DataTypes.UUID, allowNull: false, references: { model: 'users', key: 'id' } },
      status: { type: DataTypes.ENUM('pending', 'verified', 'dispensed', 'partial', 'on_hold', 'cancelled'), defaultValue: 'pending' },
      diagnosis: { type: DataTypes.TEXT, allowNull: true },
      notes: { type: DataTypes.TEXT, allowNull: true },
      urgent: { type: DataTypes.BOOLEAN, defaultValue: false },
      expiresAt: { type: DataTypes.DATE, allowNull: true },
      dispensedAt: { type: DataTypes.DATE, allowNull: true },
      dispensedBy: { type: DataTypes.UUID, allowNull: true, references: { model: 'users', key: 'id' } },
      createdAt: { type: DataTypes.DATE, defaultValue: DataTypes.NOW },
      updatedAt: { type: DataTypes.DATE, defaultValue: DataTypes.NOW },
    });

    await queryInterface.createTable('prescription_items', {
      id: { type: DataTypes.UUID, defaultValue: DataTypes.UUIDV4, primaryKey: true },
      prescriptionId: { type: DataTypes.UUID, allowNull: false, references: { model: 'prescriptions', key: 'id' }, onDelete: 'CASCADE' },
      drugId: { type: DataTypes.UUID, allowNull: true, references: { model: 'inventory', key: 'id' } },
      drugCode: { type: DataTypes.STRING, allowNull: false },
      drugName: { type: DataTypes.STRING, allowNull: false },
      genericName: { type: DataTypes.STRING, allowNull: true },
      dosage: { type: DataTypes.STRING, allowNull: false },
      frequency: { type: DataTypes.STRING, allowNull: false },
      route: { type: DataTypes.STRING, allowNull: true },
      duration: { type: DataTypes.INTEGER, allowNull: false },
      durationUnit: { type: DataTypes.STRING, defaultValue: 'days' },
      quantity: { type: DataTypes.DECIMAL(12, 2), allowNull: false },
      dispensedQuantity: { type: DataTypes.DECIMAL(12, 2), defaultValue: 0 },
      instructions: { type: DataTypes.TEXT, allowNull: true },
      isDispensed: { type: DataTypes.BOOLEAN, defaultValue: false },
      isSubstituted: { type: DataTypes.BOOLEAN, defaultValue: false },
      substitutionNote: { type: DataTypes.TEXT, allowNull: true },
      createdAt: { type: DataTypes.DATE, defaultValue: DataTypes.NOW },
    });

    await queryInterface.createTable('sync_log', {
      id: { type: DataTypes.UUID, defaultValue: DataTypes.UUIDV4, primaryKey: true },
      tenantId: { type: DataTypes.UUID, allowNull: false, references: { model: 'tenants', key: 'id' } },
      deviceId: { type: DataTypes.STRING, allowNull: true },
      entityType: { type: DataTypes.STRING, allowNull: false },
      entityId: { type: DataTypes.UUID, allowNull: false },
      action: { type: DataTypes.ENUM('create', 'update', 'delete'), allowNull: false },
      data: { type: DataTypes.JSONB, allowNull: true },
      status: { type: DataTypes.ENUM('pending', 'synced', 'failed'), defaultValue: 'pending' },
      errorMessage: { type: DataTypes.TEXT, allowNull: true },
      syncedAt: { type: DataTypes.DATE, allowNull: true },
      createdAt: { type: DataTypes.DATE, defaultValue: DataTypes.NOW },
    });
  },

  down: async (queryInterface, Sequelize) => {
    await queryInterface.dropTable('sync_log');
    await queryInterface.dropTable('prescription_items');
    await queryInterface.dropTable('prescriptions');
    await queryInterface.dropTable('lab_orders');
    await queryInterface.dropTable('reports');
    await queryInterface.dropTable('report_schedules');
    await queryInterface.dropTable('report_templates');
    await queryInterface.dropTable('medication_administration_records');
    await queryInterface.dropTable('nursing_notes');
    await queryInterface.dropTable('admissions');
    await queryInterface.dropTable('beds');
    await queryInterface.dropTable('wards');
    await queryInterface.dropTable('inventory');
    await queryInterface.dropTable('claim_line_items');
    await queryInterface.dropTable('claims');
    await queryInterface.dropTable('insurance_policies');
    await queryInterface.dropTable('payments');
    await queryInterface.dropTable('invoice_items');
    await queryInterface.dropTable('invoices');
    await queryInterface.dropTable('encounters');
    await queryInterface.dropTable('patients');
    await queryInterface.dropTable('users');
    await queryInterface.dropTable('tenants');
  }
};
