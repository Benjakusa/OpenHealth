'use strict';
const { DataTypes } = require('sequelize');
const { v4: uuidv4 } = require('uuid');

module.exports = (sequelize) => {
  const Bed = sequelize.define('Bed', {
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
    wardId: {
      type: DataTypes.UUID,
      allowNull: false,
      references: {
        model: 'wards',
        key: 'id'
      }
    },
    bedNumber: {
      type: DataTypes.STRING(20),
      allowNull: false
    },
    bedType: {
      type: DataTypes.ENUM('standard', 'electric', 'pediatric', 'bariatric', 'icu', 'stretchcher', 'incubator'),
      defaultValue: 'standard'
    },
    position: {
      type: DataTypes.STRING(20),
      allowNull: true,
      comment: 'window, aisle, corner'
    },
    status: {
      type: DataTypes.ENUM('available', 'occupied', 'reserved', 'maintenance', 'cleaning'),
      defaultValue: 'available'
    },
    features: {
      type: DataTypes.JSONB,
      defaultValue: [],
      comment: '["oxygen", "suction", "monitor", "call_bell"]'
    },
    hourlyRate: {
      type: DataTypes.DECIMAL(10, 2),
      allowNull: true
    },
    dailyRate: {
      type: DataTypes.DECIMAL(10, 2),
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
    tableName: 'beds',
    timestamps: true,
    indexes: [
      { fields: ['tenantId'] },
      { fields: ['wardId'] },
      { fields: ['tenantId', 'status'] }
    ]
  });

  Bed.associate = (models) => {
    Bed.belongsTo(models.Tenant, { foreignKey: 'tenantId', as: 'tenant' });
    Bed.belongsTo(models.Ward, { foreignKey: 'wardId', as: 'ward' });
    Bed.belongsTo(models.User, { foreignKey: 'createdBy', as: 'creator' });
    Bed.hasMany(models.Admission, { foreignKey: 'bedId', as: 'admissions' });
  };

  return Bed;
};
