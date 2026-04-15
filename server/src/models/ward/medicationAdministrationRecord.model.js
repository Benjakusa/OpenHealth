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
    admissionId: {
      type: DataTypes.UUID,
      allowNull: true,
      field: 'admission_id',
      references: {
        model: 'admissions',
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
    medication: {
      type: DataTypes.STRING(255),
      allowNull: false
    },
    dosage: {
      type: DataTypes.STRING(100),
      allowNull: true
    },
    route: {
      type: DataTypes.STRING(50),
      allowNull: true
    },
    frequency: {
      type: DataTypes.STRING(100),
      allowNull: true
    },
    administeredAt: {
      type: DataTypes.DATE,
      allowNull: true,
      field: 'administered_at'
    },
    administeredBy: {
      type: DataTypes.UUID,
      allowNull: true,
      field: 'administered_by',
      references: {
        model: 'users',
        key: 'id'
      }
    },
    status: {
      type: DataTypes.STRING(50),
      defaultValue: 'scheduled'
    },
    notes: {
      type: DataTypes.TEXT,
      allowNull: true
    }
  }, {
    tableName: 'medication_administration_records',
    timestamps: true,
    underscored: true,
    indexes: [
      { fields: ['admission_id'] },
      { fields: ['patient_id'] },
      { fields: ['status'] }
    ]
  });

  MedicationAdministrationRecord.associate = (models) => {
    MedicationAdministrationRecord.belongsTo(models.Admission, { foreignKey: { name: 'admissionId', field: 'admission_id' }, as: 'admission' });
    MedicationAdministrationRecord.belongsTo(models.Patient, { foreignKey: { name: 'patientId', field: 'patient_id' }, as: 'patient' });
    MedicationAdministrationRecord.belongsTo(models.User, { foreignKey: { name: 'administeredBy', field: 'administered_by' }, as: 'nurse' });
  };

  return MedicationAdministrationRecord;
};
