'use strict';
const { DataTypes } = require('sequelize');
const { v4: uuidv4 } = require('uuid');

module.exports = (sequelize) => {
  const Report = sequelize.define('Report', {
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
    templateId: {
      type: DataTypes.UUID,
      allowNull: true,
      references: {
        model: 'report_templates',
        key: 'id'
      }
    },
    name: {
      type: DataTypes.STRING(200),
      allowNull: false
    },
    category: {
      type: DataTypes.ENUM('clinical', 'financial', 'operational', 'inventory', 'utilization', 'custom'),
      allowNull: false
    },
    periodStart: {
      type: DataTypes.DATE,
      allowNull: true
    },
    periodEnd: {
      type: DataTypes.DATE,
      allowNull: true
    },
    parameters: {
      type: DataTypes.JSONB,
      defaultValue: {}
    },
    data: {
      type: DataTypes.JSONB,
      allowNull: true,
      comment: 'Report data/results'
    },
    summary: {
      type: DataTypes.JSONB,
      defaultValue: {},
      comment: 'Summary statistics'
    },
    format: {
      type: DataTypes.ENUM('pdf', 'excel', 'csv'),
      defaultValue: 'pdf'
    },
    fileUrl: {
      type: DataTypes.STRING(500),
      allowNull: true
    },
    fileSize: {
      type: DataTypes.INTEGER,
      allowNull: true,
      comment: 'Size in bytes'
    },
    status: {
      type: DataTypes.ENUM('generating', 'completed', 'failed'),
      defaultValue: 'generating'
    },
    errorMessage: {
      type: DataTypes.TEXT,
      allowNull: true
    },
    generatedBy: {
      type: DataTypes.UUID,
      allowNull: true,
      references: {
        model: 'users',
        key: 'id'
      }
    },
    createdBy: {
      type: DataTypes.UUID,
      allowNull: true
    }
  }, {
    tableName: 'reports',
    timestamps: true,
    underscored: true,
    indexes: [
      { fields: ['tenantId'] },
      { fields: ['category'] },
      { fields: ['templateId'] },
      { fields: ['tenantId', 'createdAt'] }
    ]
  });

  Report.associate = (models) => {
    Report.belongsTo(models.Tenant, { foreignKey: 'tenantId', as: 'tenant' });
    Report.belongsTo(models.ReportTemplate, { foreignKey: 'templateId', as: 'template' });
    Report.belongsTo(models.User, { foreignKey: 'generatedBy', as: 'generator' });
    Report.belongsTo(models.User, { foreignKey: 'createdBy', as: 'creator' });
  };

  return Report;
};
