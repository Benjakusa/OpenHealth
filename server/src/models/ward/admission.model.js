'use strict';
const { DataTypes } = require('sequelize');
const { v4: uuidv4 } = require('uuid');

module.exports = (sequelize) => {
  const Admission = sequelize.define('Admission', {
    id: {
      type: DataTypes.UUID,
      defaultValue: () => uuidv4(),
      primaryKey: true
    },
    tenantId: {
      type: DataTypes.UUID,
      allowNull: true,
      field: 'tenant_id',
      references: {
        model: 'tenants',
        key: 'id'
      }
    },
    patientId: {
      type: DataTypes.UUID,
      allowNull: true,
      field: 'patient_id',
      references: {
        model: 'patients',
        key: 'id'
      }
    },
    encounterId: {
      type: DataTypes.UUID,
      allowNull: true,
      field: 'encounter_id',
      references: {
        model: 'encounters',
        key: 'id'
      }
    },
    wardId: {
      type: DataTypes.UUID,
      allowNull: true,
      field: 'ward_id',
      references: {
        model: 'wards',
        key: 'id'
      }
    },
    bedId: {
      type: DataTypes.UUID,
      allowNull: true,
      field: 'bed_id',
      references: {
        model: 'beds',
        key: 'id'
      }
    },
    admissionNumber: {
      type: DataTypes.STRING(255),
      allowNull: false,
      unique: true
    },
    admissionDate: {
      type: DataTypes.DATE,
      allowNull: false,
      defaultValue: DataTypes.NOW
    },
    dischargeDate: {
      type: DataTypes.DATE,
      allowNull: true
    },
    reason: {
      type: DataTypes.TEXT,
      allowNull: true
    },
    diagnosis: {
      type: DataTypes.TEXT,
      allowNull: true
    },
    treatmentPlan: {
      type: DataTypes.TEXT,
      allowNull: true,
      field: 'treatment_plan'
    },
    dischargeSummary: {
      type: DataTypes.TEXT,
      allowNull: true,
      field: 'discharge_summary'
    },
    status: {
      type: DataTypes.STRING(50),
      defaultValue: 'admitted'
    }
  }, {
    tableName: 'admissions',
    timestamps: true,
    underscored: true,
    indexes: [
      { fields: ['tenant_id'] },
      { fields: ['patient_id'] },
      { fields: ['encounter_id'] },
      { fields: ['tenant_id', 'status'] },
      { fields: ['tenant_id', 'admission_date'] }
    ]
  });

  Admission.associate = (models) => {
    Admission.belongsTo(models.Tenant, { foreignKey: { name: 'tenantId', field: 'tenant_id' }, as: 'tenant' });
    Admission.belongsTo(models.Patient, { foreignKey: { name: 'patientId', field: 'patient_id' }, as: 'patient' });
    Admission.belongsTo(models.Encounter, { foreignKey: { name: 'encounterId', field: 'encounter_id' }, as: 'encounter' });
    Admission.belongsTo(models.Ward, { foreignKey: { name: 'wardId', field: 'ward_id' }, as: 'ward' });
    Admission.belongsTo(models.Bed, { foreignKey: { name: 'bedId', field: 'bed_id' }, as: 'bed' });
    Admission.hasMany(models.NursingNote, { foreignKey: { name: 'admissionId', field: 'admission_id' }, as: 'nursingNotes' });
    Admission.hasMany(models.MedicationAdministrationRecord, { foreignKey: { name: 'admissionId', field: 'admission_id' }, as: 'mar' });
  };

  return Admission;
};
