const { Sequelize } = require('sequelize');
const config = require('../config');

const sequelize = new Sequelize(config.database.name, config.database.username, config.database.password, {
  host: config.database.host,
  port: config.database.port,
  dialect: 'postgres',
  logging: config.nodeEnv === 'development' ? console.log : false,
  pool: config.database.pool
});

const Tenant = require('../models/tenant/tenant.model')(sequelize);
const User = require('../models/user/user.model')(sequelize);
const Patient = require('../models/patient/patient.model')(sequelize);
const Encounter = require('../models/encounter/encounter.model')(sequelize);
const Billing = require('../models/billing/billing.model')(sequelize);
const Invoice = require('../models/billing/invoice.model')(sequelize);
const InvoiceItem = require('../models/billing/invoiceItem.model')(sequelize);
const Payment = require('../models/billing/payment.model')(sequelize);
const Claim = require('../models/billing/claim.model')(sequelize);
const ClaimLineItem = require('../models/billing/claimLineItem.model')(sequelize);
const InsurancePolicy = require('../models/billing/insurancePolicy.model')(sequelize);
const Inventory = require('../models/inventory/inventory.model')(sequelize);
const Ward = require('../models/ward/ward.model')(sequelize);
const Bed = require('../models/ward/bed.model')(sequelize);
const Admission = require('../models/ward/admission.model')(sequelize);
const NursingNote = require('../models/ward/nursingNote.model')(sequelize);
const MedicationAdministrationRecord = require('../models/ward/medicationAdministrationRecord.model')(sequelize);
const ReportTemplate = require('../models/report/reportTemplate.model')(sequelize);
const ReportSchedule = require('../models/report/reportSchedule.model')(sequelize);
const Report = require('../models/report/report.model')(sequelize);

Tenant.hasMany(User, { foreignKey: 'tenantId', as: 'users' });
User.belongsTo(Tenant, { foreignKey: 'tenantId', as: 'tenant' });

Tenant.hasMany(Patient, { foreignKey: 'tenantId', as: 'patients' });
Patient.belongsTo(Tenant, { foreignKey: 'tenantId', as: 'tenant' });

Tenant.hasMany(Encounter, { foreignKey: 'tenantId', as: 'encounters' });
Encounter.belongsTo(Patient, { foreignKey: 'patientId', as: 'patient' });
Encounter.belongsTo(User, { foreignKey: 'providerId', as: 'provider' });

Tenant.hasMany(Billing, { foreignKey: 'tenantId', as: 'billing' });
Billing.belongsTo(Encounter, { foreignKey: 'encounterId', as: 'encounter' });
Billing.belongsTo(Patient, { foreignKey: 'patientId', as: 'patient' });
Billing.belongsTo(Admission, { foreignKey: 'admissionId', as: 'admission' });

Tenant.hasMany(Invoice, { foreignKey: 'tenantId', as: 'invoices' });
Invoice.belongsTo(Patient, { foreignKey: 'patientId', as: 'patient' });
Invoice.belongsTo(Encounter, { foreignKey: 'encounterId', as: 'encounter' });
Invoice.belongsTo(Admission, { foreignKey: 'admissionId', as: 'admission' });
Invoice.belongsTo(User, { foreignKey: 'createdBy', as: 'creator' });
Invoice.hasMany(InvoiceItem, { foreignKey: 'invoiceId', as: 'items' });
InvoiceItem.belongsTo(Invoice, { foreignKey: 'invoiceId', as: 'invoice' });

Tenant.hasMany(Payment, { foreignKey: 'tenantId', as: 'payments' });
Payment.belongsTo(Invoice, { foreignKey: 'invoiceId', as: 'invoice' });
Payment.belongsTo(Patient, { foreignKey: 'patientId', as: 'patient' });
Payment.belongsTo(User, { foreignKey: 'createdBy', as: 'creator' });

Tenant.hasMany(Claim, { foreignKey: 'tenantId', as: 'claims' });
Claim.belongsTo(Patient, { foreignKey: 'patientId', as: 'patient' });
Claim.belongsTo(Billing, { foreignKey: 'invoiceId', as: 'invoice' });
Claim.belongsTo(Encounter, { foreignKey: 'encounterId', as: 'encounter' });
Claim.belongsTo(InsurancePolicy, { foreignKey: 'insurancePolicyId', as: 'insurancePolicy' });
Claim.belongsTo(User, { foreignKey: 'createdBy', as: 'creator' });
Claim.hasMany(ClaimLineItem, { foreignKey: 'claimId', as: 'lineItems' });
ClaimLineItem.belongsTo(Claim, { foreignKey: 'claimId', as: 'claim' });

Tenant.hasMany(InsurancePolicy, { foreignKey: 'tenantId', as: 'insurancePolicies' });
InsurancePolicy.belongsTo(Patient, { foreignKey: 'patientId', as: 'patient' });

Tenant.hasMany(Inventory, { foreignKey: 'tenantId', as: 'inventory' });

Tenant.hasMany(Ward, { foreignKey: 'tenantId', as: 'wards' });
Ward.hasMany(Bed, { foreignKey: 'wardId', as: 'beds' });
Bed.belongsTo(Ward, { foreignKey: 'wardId', as: 'ward' });
Ward.hasMany(Admission, { foreignKey: 'wardId', as: 'admissions' });
Bed.hasMany(Admission, { foreignKey: 'bedId', as: 'admissions' });
Admission.belongsTo(Patient, { foreignKey: 'patientId', as: 'patient' });
Admission.belongsTo(Encounter, { foreignKey: 'encounterId', as: 'encounter' });
Admission.belongsTo(Ward, { foreignKey: 'wardId', as: 'ward' });
Admission.belongsTo(Bed, { foreignKey: 'bedId', as: 'bed' });
Admission.hasMany(NursingNote, { foreignKey: 'admissionId', as: 'nursingNotes' });
Admission.hasMany(MedicationAdministrationRecord, { foreignKey: 'admissionId', as: 'mar' });

Tenant.hasMany(ReportTemplate, { foreignKey: 'tenantId', as: 'reportTemplates' });
ReportTemplate.hasMany(Report, { foreignKey: 'templateId', as: 'reports' });
Report.belongsTo(ReportTemplate, { foreignKey: 'templateId', as: 'template' });

module.exports = {
  sequelize,
  models: {
    Tenant,
    User,
    Patient,
    Encounter,
    Billing,
    Invoice,
    InvoiceItem,
    Payment,
    Claim,
    ClaimLineItem,
    InsurancePolicy,
    Inventory,
    Ward,
    Bed,
    Admission,
    NursingNote,
    MedicationAdministrationRecord,
    ReportTemplate,
    ReportSchedule,
    Report
  },
  Tenant,
  User,
  Patient,
  Encounter,
  Billing,
  Invoice,
  InvoiceItem,
  Payment,
  Claim,
  ClaimLineItem,
  InsurancePolicy,
  Inventory,
  Ward,
  Bed,
  Admission,
  NursingNote,
  MedicationAdministrationRecord,
  ReportTemplate,
  ReportSchedule,
  Report
};
