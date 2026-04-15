'use strict';
const { DataTypes } = require('sequelize');
const { v4: uuidv4 } = require('uuid');

module.exports = (sequelize) => {
  const Ward = sequelize.define('Ward', {
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
    name: {
      type: DataTypes.STRING(255),
      allowNull: false
    },
    code: {
      type: DataTypes.STRING(50),
      allowNull: false,
      unique: true
    },
    type: {
      type: DataTypes.STRING(50),
      defaultValue: 'general'
    },
    gender: {
      type: DataTypes.STRING(20),
      defaultValue: 'both'
    },
    totalBeds: {
      type: DataTypes.INTEGER,
      defaultValue: 0,
      field: 'total_beds'
    },
    availableBeds: {
      type: DataTypes.INTEGER,
      defaultValue: 0,
      field: 'available_beds'
    },
    floor: {
      type: DataTypes.INTEGER,
      allowNull: true
    },
    building: {
      type: DataTypes.STRING(255),
      allowNull: true
    },
    status: {
      type: DataTypes.STRING(20),
      defaultValue: 'active'
    }
  }, {
    tableName: 'wards',
    timestamps: true,
    underscored: true,
    indexes: [
      { fields: ['tenant_id'] },
      { fields: ['tenant_id', 'status'] },
      { fields: ['tenant_id', 'type'] }
    ]
  });

  Ward.associate = (models) => {
    Ward.belongsTo(models.Tenant, { foreignKey: 'tenantId', as: 'tenant' });
    Ward.hasMany(models.Bed, { foreignKey: { name: 'wardId', field: 'ward_id' }, as: 'beds' });
    Ward.hasMany(models.Admission, { foreignKey: { name: 'wardId', field: 'ward_id' }, as: 'admissions' });
  };

  return Ward;
};
