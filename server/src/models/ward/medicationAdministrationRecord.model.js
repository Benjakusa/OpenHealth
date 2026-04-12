'use strict';
const { DataTypes } = require('sequelize');
const { v4: uuidv4 } = require('uuid');

module.exports = (sequelize) => {
  const MedicationAdministrationRecord = sequelize.define('MedicationAdministrationRecord', {
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
    admissionId: {
      type: DataTypes.UUID,
      allowNull: false,
      references: {
        model: 'admissions',
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
    prescriptionId: {
      type: DataTypes.UUID,
      allowNull: true,
      references: {
        model: 'prescriptions',
        key: 'id'
      }
    },
    medicationName: {
      type: DataTypes.STRING(200),
      allowNull: false
    },
    dosage: {
      type: DataTypes.STRING(50),
      allowNull: false
    },
    route: {
      type: DataTypes.ENUM('oral', 'iv', 'im', 'sc', 'topical', 'inhaled', 'rectal', 'sublingual', 'transdermal'),
      allowNull: false
    },
    frequency: {
      type: DataTypes.STRING(50),
      allowNull: false,
      comment: 'OD, BD, TDS, QID, PRN, STAT'
    },
    timeOfDay: {
      type: DataTypes.JSONB,
      allowNull: true,
      comment: '["08:00", "14:00", "20:00"]'
    },
    scheduledTime: {
      type: DataTypes.DATE,
      allowNull: false
    },
    administeredTime: {
      type: DataTypes.DATE,
      allowNull: true
    },
    administeredBy: {
      type: DataTypes.UUID,
      allowNull: true,
      references: {
        model: 'users',
        key: 'id'
      }
    },
    status: {
      type: DataTypes.ENUM('scheduled', 'given', 'missed', 'refused', 'held', 'dc'),
      defaultValue: 'scheduled'
    },
    quantityGiven: {
      type: DataTypes.DECIMAL(10, 2),
      allowNull: true
    },
    batchId: {
      type: DataTypes.UUID,
      allowNull: true,
      references: {
        model: 'inventory_batches',
        key: 'id'
      }
    },
    site: {
      type: DataTypes.STRING(100),
      allowNull: true,
      comment: 'Left arm, Right glute, etc.'
    },
    response: {
      type: DataTypes.ENUM('given', 'refused', 'nauseated', 'vomited', 'reaction'),
      allowNull: true
    },
    notes: {
      type: DataTypes.TEXT,
      allowNull: true
    },
    startDate: {
      type: DataTypes.DATE,
      allowNull: false
    },
    endDate: {
      type: DataTypes.DATE,
      allowNull: true
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
    tableName: 'medication_administration_records',
    timestamps: true,
    indexes: [
      { fields: ['tenantId'] },
      { fields: ['admissionId'] },
      { fields: ['patientId'] },
      { fields: ['scheduledTime'] },
      { fields: ['status'] }
    ]
  });

  MedicationAdministrationRecord.associate = (models) => {
    MedicationAdministrationRecord.belongsTo(models.Tenant, { foreignKey: 'tenantId', as: 'tenant' });
    MedicationAdministrationRecord.belongsTo(models.Admission, { foreignKey: 'admissionId', as: 'admission' });
    MedicationAdministrationRecord.belongsTo(models.Patient, { foreignKey: 'patientId', as: 'patient' });
    MedicationAdministrationRecord.belongsTo(models.User, { foreignKey: 'administeredBy', as: 'nurse' });
    MedicationAdministrationRecord.belongsTo(models.User, { foreignKey: 'createdBy', as: 'creator' });
  };

  return MedicationAdministrationRecord;
};
