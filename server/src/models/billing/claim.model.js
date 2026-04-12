const { DataTypes } = require('sequelize');

module.exports = (sequelize) => {
  const Claim = sequelize.define('Claim', {
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true
    },
    tenantId: {
      type: DataTypes.UUID,
      allowNull: false,
      references: { model: 'tenants', key: 'id' }
    },
    claimId: {
      type: DataTypes.STRING,
      allowNull: false,
      unique: true
    },
    invoiceId: {
      type: DataTypes.UUID,
      references: { model: 'billing', key: 'id' }
    },
    patientId: {
      type: DataTypes.UUID,
      allowNull: false,
      references: { model: 'patients', key: 'id' }
    },
    insurancePolicyId: {
      type: DataTypes.UUID,
      references: { model: 'insurance_policies', key: 'id' }
    },
    encounterId: {
      type: DataTypes.UUID,
      references: { model: 'encounters', key: 'id' }
    },
    claimType: {
      type: DataTypes.ENUM('sha', 'insurance', 'pre_authorization'),
      defaultValue: 'sha'
    },
    status: {
      type: DataTypes.ENUM('draft', 'submitted', 'pending_approval', 'approved', 'rejected', 'failed'),
      defaultValue: 'draft'
    },
    externalReference: {
      type: DataTypes.STRING,
      allowNull: true
    },
    totalAmount: {
      type: DataTypes.DECIMAL(12, 2),
      defaultValue: 0
    },
    submittedAmount: {
      type: DataTypes.DECIMAL(12, 2),
      defaultValue: 0
    },
    approvedAmount: {
      type: DataTypes.DECIMAL(12, 2),
      allowNull: true
    },
    shaStatus: {
      type: DataTypes.STRING,
      allowNull: true
    },
    outcome: {
      type: DataTypes.STRING,
      allowNull: true
    },
    failureReason: {
      type: DataTypes.TEXT,
      allowNull: true
    },
    diagnosisCodes: {
      type: DataTypes.JSONB,
      defaultValue: []
    },
    procedureCodes: {
      type: DataTypes.JSONB,
      defaultValue: []
    },
    submittedAt: {
      type: DataTypes.DATE,
      allowNull: true
    },
    processedAt: {
      type: DataTypes.DATE,
      allowNull: true
    },
    createdBy: {
      type: DataTypes.UUID,
      references: { model: 'users', key: 'id' }
    },
    notes: {
      type: DataTypes.TEXT,
      allowNull: true
    }
  }, {
    tableName: 'claims',
    underscored: true,
    timestamps: true,
    indexes: [
      { fields: ['tenant_id'] },
      { fields: ['claim_id'], unique: true },
      { fields: ['invoice_id'] },
      { fields: ['patient_id'] },
      { fields: ['status'] },
      { fields: ['external_reference'] }
    ]
  });

  return Claim;
};
