'use strict';
const { DataTypes } = require('sequelize');
const { v4: uuidv4 } = require('uuid');

module.exports = (sequelize) => {
  const NursingNote = sequelize.define('NursingNote', {
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
    nurseId: {
      type: DataTypes.UUID,
      allowNull: true,
      field: 'nurse_id',
      references: {
        model: 'users',
        key: 'id'
      }
    },
    noteType: {
      type: DataTypes.STRING(50),
      defaultValue: 'general'
    },
    notes: {
      type: DataTypes.TEXT,
      allowNull: false
    },
    vitals: {
      type: DataTypes.JSONB,
      allowNull: true
    }
  }, {
    tableName: 'nursing_notes',
    timestamps: true,
    underscored: true,
    indexes: [
      { fields: ['admission_id'] },
      { fields: ['patient_id'] },
      { fields: ['created_at'] }
    ]
  });

  NursingNote.associate = (models) => {
    NursingNote.belongsTo(models.Admission, { foreignKey: { name: 'admissionId', field: 'admission_id' }, as: 'admission' });
    NursingNote.belongsTo(models.Patient, { foreignKey: { name: 'patientId', field: 'patient_id' }, as: 'patient' });
    NursingNote.belongsTo(models.User, { foreignKey: { name: 'nurseId', field: 'nurse_id' }, as: 'nurse' });
  };

  return NursingNote;
};
