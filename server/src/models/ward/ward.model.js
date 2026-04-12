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
      allowNull: false,
      references: {
        model: 'tenants',
        key: 'id'
      }
    },
    name: {
      type: DataTypes.STRING(100),
      allowNull: false
    },
    code: {
      type: DataTypes.STRING(20),
      allowNull: false
    },
    type: {
      type: DataTypes.ENUM('general', 'icu', 'maternity', 'pediatric', 'surgical', 'medical', 'private', 'isolation', 'emergency'),
      defaultValue: 'general'
    },
    floor: {
      type: DataTypes.STRING(20),
      allowNull: true
    },
    building: {
      type: DataTypes.STRING(50),
      allowNull: true
    },
    description: {
      type: DataTypes.TEXT,
      allowNull: true
    },
    genderRestriction: {
      type: DataTypes.ENUM('male', 'female', 'any'),
      defaultValue: 'any'
    },
    ageRestriction: {
      type: DataTypes.JSONB,
      allowNull: true,
      defaultValue: null,
      comment: '{"min": 0, "max": 120}'
    },
    status: {
      type: DataTypes.ENUM('active', 'inactive', 'maintenance'),
      defaultValue: 'active'
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
    tableName: 'wards',
    timestamps: true,
    indexes: [
      { fields: ['tenantId'] },
      { fields: ['tenantId', 'status'] },
      { fields: ['tenantId', 'type'] }
    ]
  });

  Ward.associate = (models) => {
    Ward.belongsTo(models.Tenant, { foreignKey: 'tenantId', as: 'tenant' });
    Ward.belongsTo(models.User, { foreignKey: 'createdBy', as: 'creator' });
    Ward.hasMany(models.Bed, { foreignKey: 'wardId', as: 'beds' });
    Ward.hasMany(models.Admission, { foreignKey: 'wardId', as: 'admissions' });
  };

  return Ward;
};
