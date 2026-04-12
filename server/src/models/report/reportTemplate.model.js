'use strict';
const { DataTypes } = require('sequelize');
const { v4: uuidv4 } = require('uuid');

module.exports = (sequelize) => {
  const ReportTemplate = sequelize.define('ReportTemplate', {
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
      type: DataTypes.STRING(50),
      allowNull: false,
      unique: true
    },
    category: {
      type: DataTypes.ENUM('clinical', 'financial', 'operational', 'inventory', 'utilization', 'custom'),
      allowNull: false
    },
    description: {
      type: DataTypes.TEXT,
      allowNull: true
    },
    query: {
      type: DataTypes.TEXT,
      allowNull: false,
      comment: 'SQL query or report generation logic'
    },
    parameters: {
      type: DataTypes.JSONB,
      defaultValue: [],
      comment: '[{"name": "startDate", "type": "date", "required": true}]'
    },
    columns: {
      type: DataTypes.JSONB,
      defaultValue: [],
      comment: '[{"name": "total", "type": "number", "label": "Total Amount"}]'
    },
    chartType: {
      type: DataTypes.ENUM('none', 'bar', 'line', 'pie', 'table'),
      defaultValue: 'table'
    },
    isDefault: {
      type: DataTypes.BOOLEAN,
      defaultValue: false
    },
    isActive: {
      type: DataTypes.BOOLEAN,
      defaultValue: true
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
    tableName: 'report_templates',
    timestamps: true,
    indexes: [
      { fields: ['tenantId'] },
      { fields: ['category'] },
      { fields: ['tenantId', 'isDefault'] }
    ]
  });

  ReportTemplate.associate = (models) => {
    ReportTemplate.belongsTo(models.Tenant, { foreignKey: 'tenantId', as: 'tenant' });
    ReportTemplate.belongsTo(models.User, { foreignKey: 'createdBy', as: 'creator' });
    ReportTemplate.hasMany(models.ReportSchedule, { foreignKey: 'templateId', as: 'schedules' });
    ReportTemplate.hasMany(models.Report, { foreignKey: 'templateId', as: 'reports' });
  };

  return ReportTemplate;
};
