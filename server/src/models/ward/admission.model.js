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
      allowNull: false,
      references: {
        model: 'tenants',
        key: 'id'
      }
    },
    patientId: {
      type: DataTypes.UUID,
      allowNull: false,
      references: {
        model: 'patients',
        key: 'id'
      }
    },
    encounterId: {
      type: DataTypes.UUID,
      allowNull: false,
      references: {
        model: 'encounters',
        key: 'id'
      }
    },
    wardId: {
      type: DataTypes.UUID,
      allowNull: false,
      references: {
        model: 'wards',
        key: 'id'
      }
    },
    bedId: {
      type: DataTypes.UUID,
      allowNull: false,
      references: {
        model: 'beds',
        key: 'id'
      }
    },
    admissionNumber: {
      type: DataTypes.STRING(50),
      allowNull: false,
      unique: true
    },
    admissionType: {
      type: DataTypes.ENUM('emergency', 'elective', 'transfer', 'daycare'),
      allowNull: false
    },
    admissionReason: {
      type: DataTypes.TEXT,
      allowNull: false
    },
    presentingComplaint: {
      type: DataTypes.TEXT,
      allowNull: true
    },
    provisionalDiagnosis: {
      type: DataTypes.TEXT,
      allowNull: true
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
    dischargeReason: {
      type: DataTypes.ENUM('discharged_home', 'transferred', 'absconded', 'died', 'referred'),
      allowNull: true
    },
    dischargeSummary: {
      type: DataTypes.TEXT,
      allowNull: true
    },
    dischargeInstructions: {
      type: DataTypes.TEXT,
      allowNull: true
    },
    attendingPhysicianId: {
      type: DataTypes.UUID,
      allowNull: true,
      references: {
        model: 'users',
        key: 'id'
      }
    },
    status: {
      type: DataTypes.ENUM('admitted', 'in_progress', 'stable', 'critical', 'discharged', 'transferred', 'deceased'),
      defaultValue: 'admitted'
    },
    bedChargeApplied: {
      type: DataTypes.BOOLEAN,
      defaultValue: true
    },
    billingCycle: {
      type: DataTypes.ENUM('hourly', 'daily'),
      defaultValue: 'daily'
    },
    specialRequirements: {
      type: DataTypes.JSONB,
      defaultValue: [],
      comment: '["isolation", "Fall_risk", "NBM", "IV_therapy"]'
    },
    allergies: {
      type: DataTypes.JSONB,
      defaultValue: []
    },
    nextOfKin: {
      type: DataTypes.JSONB,
      allowNull: true,
      comment: '{"name": "", "relationship": "", "phone": "", "address": ""}'
    },
    createdBy: {
      type: DataTypes.UUID,
      allowNull: true
    },
    updatedBy: {
      type: DataTypes.UUID,
      allowNull: true
    }
  }, {
    tableName: 'admissions',
    timestamps: true,
    indexes: [
      { fields: ['tenantId'] },
      { fields: ['patientId'] },
      { fields: ['encounterId'] },
      { fields: ['tenantId', 'status'] },
      { fields: ['tenantId', 'admissionDate'] }
    ]
  });

  Admission.associate = (models) => {
    Admission.belongsTo(models.Tenant, { foreignKey: 'tenantId', as: 'tenant' });
    Admission.belongsTo(models.Patient, { foreignKey: 'patientId', as: 'patient' });
    Admission.belongsTo(models.Encounter, { foreignKey: 'encounterId', as: 'encounter' });
    Admission.belongsTo(models.Ward, { foreignKey: 'wardId', as: 'ward' });
    Admission.belongsTo(models.Bed, { foreignKey: 'bedId', as: 'bed' });
    Admission.belongsTo(models.User, { foreignKey: 'attendingPhysicianId', as: 'attendingPhysician' });
    Admission.belongsTo(models.User, { foreignKey: 'createdBy', as: 'creator' });
    Admission.hasMany(models.NursingNote, { foreignKey: 'admissionId', as: 'nursingNotes' });
    Admission.hasMany(models.MedicationAdministrationRecord, { foreignKey: 'admissionId', as: 'mar' });
  };

  return Admission;
};
