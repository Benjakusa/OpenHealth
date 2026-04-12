const bcrypt = require('bcrypt');
const { v4: uuidv4 } = require('uuid');

module.exports = {
  up: async (queryInterface, Sequelize) => {
    const tenantId = uuidv4();
    const now = new Date();

    await queryInterface.bulkInsert('tenants', [{
      id: tenantId,
      name: 'Kenyatta National Hospital',
      slug: 'knh',
      schema_name: 'tenant_knh',
      package: 'HOSPITALI',
      facility_type: 'National Referral Hospital',
      facility_level: 6,
      registration_number: 'KNH-REG-001',
      settings: JSON.stringify({
        currency: 'KES',
        timezone: 'Africa/Nairobi',
        dateFormat: 'DD/MM/YYYY'
      }),
      status: 'active',
      subscription: JSON.stringify({
        tier: 'HOSPITALI',
        startedAt: now,
        expiresAt: new Date(now.getFullYear() + 1, now.getMonth(), now.getDate())
      }),
      storage: 0,
      storage_limit: 200 * 1024 * 1024 * 1024,
      expires_at: new Date(now.getFullYear() + 1, now.getMonth(), now.getDate()),
      created_at: now,
      updated_at: now,
    }]);

    const passwordHash = await bcrypt.hash('password123', 10);

    const users = [
      {
        id: uuidv4(),
        tenant_id: tenantId,
        email: 'admin@knh.ehealth.ke',
        password_hash: passwordHash,
        first_name: 'System',
        last_name: 'Administrator',
        role: 'super_admin',
        department: 'IT',
        is_active: true,
        created_at: now,
        updated_at: now,
      },
      {
        id: uuidv4(),
        tenant_id: tenantId,
        email: 'doctor@knh.ehealth.ke',
        password_hash: passwordHash,
        first_name: 'John',
        last_name: 'Mwangi',
        role: 'doctor',
        department: 'General Medicine',
        phone: '+254712345678',
        license_number: 'KNH-MC-001',
        is_active: true,
        created_at: now,
        updated_at: now,
      },
      {
        id: uuidv4(),
        tenant_id: tenantId,
        email: 'nurse@knh.ehealth.ke',
        password_hash: passwordHash,
        first_name: 'Mary',
        last_name: 'Wanjiku',
        role: 'nurse',
        department: 'Emergency',
        phone: '+254712345679',
        is_active: true,
        created_at: now,
        updated_at: now,
      },
      {
        id: uuidv4(),
        tenant_id: tenantId,
        email: 'pharmacist@knh.ehealth.ke',
        password_hash: passwordHash,
        first_name: 'Peter',
        last_name: 'Otieno',
        role: 'pharmacist',
        department: 'Pharmacy',
        phone: '+254712345680',
        license_number: 'KNH-PH-001',
        is_active: true,
        created_at: now,
        updated_at: now,
      },
      {
        id: uuidv4(),
        tenant_id: tenantId,
        email: 'lab@knh.ehealth.ke',
        password_hash: passwordHash,
        first_name: 'Grace',
        last_name: 'Njeri',
        role: 'lab_technician',
        department: 'Laboratory',
        phone: '+254712345681',
        license_number: 'KNH-LT-001',
        is_active: true,
        created_at: now,
        updated_at: now,
      },
      {
        id: uuidv4(),
        tenant_id: tenantId,
        email: 'receptionist@knh.ehealth.ke',
        password_hash: passwordHash,
        first_name: 'Jane',
        last_name: 'Achieng',
        role: 'receptionist',
        department: 'Reception',
        phone: '+254712345682',
        is_active: true,
        created_at: now,
        updated_at: now,
      }
    ];

    await queryInterface.bulkInsert('users', users);

    const patients = [
      {
        id: uuidv4(),
        tenant_id: tenantId,
        patient_number: 'KNH-001',
        first_name: 'James',
        last_name: 'Kimani',
        date_of_birth: '1985-03-15',
        gender: 'male',
        phone: '+254722111111',
        national_id: '12345678',
        email: 'james.kimani@email.com',
        county: 'Nairobi',
        address: '123 Main Street, Nairobi',
        allergies: JSON.stringify(['Penicillin']),
        chronic_conditions: JSON.stringify(['Hypertension']),
        is_active: true,
        created_at: now,
        updated_at: now,
      },
      {
        id: uuidv4(),
        tenant_id: tenantId,
        patient_number: 'KNH-002',
        first_name: 'Sarah',
        last_name: 'Wanjiku',
        date_of_birth: '1990-07-22',
        gender: 'female',
        phone: '+254722222222',
        national_id: '23456789',
        county: 'Kiambu',
        address: '456 Oak Avenue, Kiambu',
        allergies: JSON.stringify([]),
        chronic_conditions: JSON.stringify([]),
        is_active: true,
        created_at: now,
        updated_at: now,
      },
      {
        id: uuidv4(),
        tenant_id: tenantId,
        patient_number: 'KNH-003',
        first_name: 'Michael',
        last_name: 'Ochieng',
        date_of_birth: '1978-11-08',
        gender: 'male',
        phone: '+254733333333',
        national_id: '34567890',
        county: 'Kisumu',
        address: '789 Lake View, Kisumu',
        allergies: JSON.stringify(['Sulfa']),
        chronic_conditions: JSON.stringify(['Diabetes Type 2']),
        is_active: true,
        created_at: now,
        updated_at: now,
      }
    ];

    await queryInterface.bulkInsert('patients', patients);

    await queryInterface.bulkInsert('wards', [
      {
        id: uuidv4(),
        tenant_id: tenantId,
        name: 'General Ward A',
        code: 'GWA',
        type: 'general',
        gender: 'both',
        total_beds: 20,
        available_beds: 15,
        floor: 1,
        building: 'Main',
        status: 'active',
        created_at: now,
        updated_at: now,
      },
      {
        id: uuidv4(),
        tenant_id: tenantId,
        name: 'ICU',
        code: 'ICU',
        type: 'icu',
        gender: 'both',
        total_beds: 10,
        available_beds: 8,
        floor: 2,
        building: 'Main',
        status: 'active',
        created_at: now,
        updated_at: now,
      },
      {
        id: uuidv4(),
        tenant_id: tenantId,
        name: 'Maternity Ward',
        code: 'MAT',
        type: 'maternity',
        gender: 'female',
        total_beds: 15,
        available_beds: 12,
        floor: 3,
        building: 'East Wing',
        status: 'active',
        created_at: now,
        updated_at: now,
      }
    ]);

    const labOrders = [
      {
        id: uuidv4(),
        tenant_id: tenantId,
        order_number: 'LAB-001',
        patient_id: patients[0].id,
        encounter_id: null,
        ordered_by: users[1].id,
        priority: 'normal',
        status: 'pending',
        tests: JSON.stringify([
          { code: 'CBC', name: 'Complete Blood Count' },
          { code: 'BMP', name: 'Basic Metabolic Panel' }
        ]),
        created_at: now,
        updated_at: now,
      },
      {
        id: uuidv4(),
        tenant_id: tenantId,
        order_number: 'LAB-002',
        patient_id: patients[1].id,
        encounter_id: null,
        ordered_by: users[1].id,
        priority: 'urgent',
        status: 'pending',
        tests: JSON.stringify([
          { code: 'URINE', name: 'Urinalysis' }
        ]),
        created_at: now,
        updated_at: now,
      }
    ];

    await queryInterface.bulkInsert('lab_orders', labOrders);

    await queryInterface.bulkInsert('inventory', [
      {
        id: uuidv4(),
        tenant_id: tenantId,
        item_code: 'PARA500',
        name: 'Paracetamol 500mg Tablets',
        category: 'medication',
        unit: 'tablet',
        quantity: 5000,
        min_stock: 1000,
        unit_price: 5.00,
        expiry_date: new Date('2027-12-31'),
        supplier: 'Kenya Medical Supplies',
        status: 'active',
        created_at: now,
        updated_at: now,
      },
      {
        id: uuidv4(),
        tenant_id: tenantId,
        item_code: 'AMOX250',
        name: 'Amoxicillin 250mg Capsules',
        category: 'medication',
        unit: 'capsule',
        quantity: 3000,
        min_stock: 500,
        unit_price: 8.50,
        expiry_date: new Date('2026-08-15'),
        supplier: 'Kenya Medical Supplies',
        status: 'active',
        created_at: now,
        updated_at: now,
      },
      {
        id: uuidv4(),
        tenant_id: tenantId,
        item_code: 'SYRINGE1',
        name: 'Disposable Syringe 5ml',
        category: 'supply',
        unit: 'piece',
        quantity: 10000,
        min_stock: 2000,
        unit_price: 2.00,
        expiry_date: null,
        supplier: 'Surgical Supplies Ltd',
        status: 'active',
        created_at: now,
        updated_at: now,
      }
    ]);

    await queryInterface.bulkInsert('report_templates', [
      {
        id: uuidv4(),
        tenant_id: tenantId,
        name: 'Daily Patient Summary',
        type: 'patient_summary',
        format: 'pdf',
        content: JSON.stringify({
          sections: ['patient_info', 'diagnoses', 'treatments', 'billing']
        }),
        created_by: users[0].id,
        is_default: true,
        created_at: now,
        updated_at: now,
      },
      {
        id: uuidv4(),
        tenant_id: tenantId,
        name: 'Inventory Report',
        type: 'inventory',
        format: 'excel',
        content: JSON.stringify({
          sections: ['current_stock', 'expiring_items', 'low_stock']
        }),
        created_by: users[0].id,
        is_default: false,
        created_at: now,
        updated_at: now,
      }
    ]);

    console.log('Seed data inserted successfully');
  },

  down: async (queryInterface, Sequelize) => {
    await queryInterface.bulkDelete('report_templates', null, {});
    await queryInterface.bulkDelete('inventory', null, {});
    await queryInterface.bulkDelete('lab_orders', null, {});
    await queryInterface.bulkDelete('wards', null, {});
    await queryInterface.bulkDelete('patients', null, {});
    await queryInterface.bulkDelete('users', null, {});
    await queryInterface.bulkDelete('tenants', null, {});
  }
};
