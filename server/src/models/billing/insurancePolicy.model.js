const { DataTypes } = require('sequelize');

module.exports = (sequelize) => {
  const InsurancePolicy = sequelize.define('InsurancePolicy', {
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
    patientId: {
      type: DataTypes.UUID,
      allowNull: false,
      references: { model: 'patients', key: 'id' }
    },
    provider: {
      type: DataTypes.ENUM('sha', 'nhif', 'private', 'other'),
      allowNull: false
    },
    schemeType: {
      type: DataTypes.STRING,
      allowNull: true
    },
    schemeName: {
      type: DataTypes.STRING,
      allowNull: true
    },
    memberNumber: {
      type: DataTypes.STRING,
      allowNull: false
    },
    cardNumber: {
      type: DataTypes.STRING,
      allowNull: true
    },
    cardExpiry: {
      type: DataTypes.DATE,
      allowNull: true
    },
    principalMemberName: {
      type: DataTypes.STRING,
      allowNull: true
    },
    relationship: {
      type: DataTypes.ENUM('self', 'spouse', 'child', 'parent', 'sibling', 'other'),
      defaultValue: 'self'
    },
    benefitPackage: {
      type: DataTypes.STRING,
      allowNull: true
    },
    coveragePercent: {
      type: DataTypes.DECIMAL(5, 2),
      defaultValue: 100
    },
    coverageLimit: {
      type: DataTypes.DECIMAL(12, 2),
      allowNull: true
    },
    preAuthorizationRequired: {
      type: DataTypes.BOOLEAN,
      defaultValue: false
    },
    preAuthorizationThreshold: {
      type: DataTypes.DECIMAL(12, 2),
      allowNull: true
    },
    status: {
      type: DataTypes.ENUM('active', 'expired', 'suspended', 'cancelled'),
      defaultValue: 'active'
    },
    startDate: {
      type: DataTypes.DATE,
      allowNull: true
    },
    endDate: {
      type: DataTypes.DATE,
      allowNull: true
    },
    verifiedAt: {
      type: DataTypes.DATE,
      allowNull: true
    },
    verifiedBy: {
      type: DataTypes.UUID,
      allowNull: true
    },
    notes: {
      type: DataTypes.TEXT,
      allowNull: true
    }
  }, {
    tableName: 'insurance_policies',
    underscored: true,
    timestamps: true,
    indexes: [
      { fields: ['tenant_id'] },
      { fields: ['patient_id'] },
      { fields: ['member_number'] },
      { fields: ['provider'] },
      { fields: ['status'] }
    ]
  });

  return InsurancePolicy;
};
