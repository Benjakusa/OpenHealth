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
    noteType: {
      type: DataTypes.ENUM('observation', 'vitals', 'care_plan', 'intervention', 'assessment', 'handover', 'incident'),
      allowNull: false
    },
    content: {
      type: DataTypes.TEXT,
      allowNull: false
    },
    vitals: {
      type: DataTypes.JSONB,
      allowNull: true,
      comment: '{"temperature": 37, "pulse": 80, "bp_systolic": 120, "bp_diastolic": 80, "respRate": 18, "spo2": 98, "pain": 0}'
    },
    painScore: {
      type: DataTypes.INTEGER,
      allowNull: true,
      validate: { min: 0, max: 10 }
    },
    consciousness: {
      type: DataTypes.ENUM('alert', 'voice', 'pain', 'unresponsive'),
      allowNull: true
    },
    mobility: {
      type: DataTypes.ENUM('ambulant', 'wheelchair', 'bedridden'),
      allowNull: true
    },
    skinCondition: {
      type: DataTypes.STRING(100),
      allowNull: true,
      comment: 'intact, pressure_ulcer, wound, rash'
    },
    ivSite: {
      type: DataTypes.STRING(100),
      allowNull: true
    },
    fluidBalance: {
      type: DataTypes.JSONB,
      allowNull: true,
      comment: '{"intake": 2000, "output": 1500, "drain": 200}'
    },
    priority: {
      type: DataTypes.ENUM('routine', 'urgent', 'critical'),
      defaultValue: 'routine'
    },
    shiftType: {
      type: DataTypes.ENUM('morning', 'evening', 'night'),
      allowNull: true
    },
    attachments: {
      type: DataTypes.JSONB,
      defaultValue: [],
      comment: '[{"type": "image", "url": "", "description": ""}]'
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
    tableName: 'nursing_notes',
    timestamps: true,
    indexes: [
      { fields: ['tenantId'] },
      { fields: ['admissionId'] },
      { fields: ['patientId'] },
      { fields: ['tenantId', 'noteType'] },
      { fields: ['createdAt'] }
    ]
  });

  NursingNote.associate = (models) => {
    NursingNote.belongsTo(models.Tenant, { foreignKey: 'tenantId', as: 'tenant' });
    NursingNote.belongsTo(models.Admission, { foreignKey: 'admissionId', as: 'admission' });
    NursingNote.belongsTo(models.Patient, { foreignKey: 'patientId', as: 'patient' });
    NursingNote.belongsTo(models.User, { foreignKey: 'createdBy', as: 'author' });
  };

  return NursingNote;
};
