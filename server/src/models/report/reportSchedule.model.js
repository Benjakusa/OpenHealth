'use strict';
const { DataTypes } = require('sequelize');
const { v4: uuidv4 } = require('uuid');

module.exports = (sequelize) => {
  const ReportSchedule = sequelize.define('ReportSchedule', {
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
      allowNull: false,
      references: {
        model: 'report_templates',
        key: 'id'
      }
    },
    name: {
      type: DataTypes.STRING(100),
      allowNull: false
    },
    scheduleType: {
      type: DataTypes.ENUM('daily', 'weekly', 'monthly', 'quarterly', 'yearly', 'custom'),
      allowNull: false
    },
    scheduleTime: {
      type: DataTypes.TIME,
      allowNull: false,
      defaultValue: '08:00'
    },
    scheduleDay: {
      type: DataTypes.INTEGER,
      allowNull: true,
      comment: 'Day of week (0-6) or day of month (1-31)'
    },
    cronExpression: {
      type: DataTypes.STRING(100),
      allowNull: true,
      comment: 'For custom schedules'
    },
    recipients: {
      type: DataTypes.JSONB,
      defaultValue: [],
      comment: '["email1@example.com", "+254712345678"]'
    },
    format: {
      type: DataTypes.ENUM('pdf', 'excel', 'csv', 'email'),
      defaultValue: 'pdf'
    },
    isActive: {
      type: DataTypes.BOOLEAN,
      defaultValue: true
    },
    lastRunAt: {
      type: DataTypes.DATE,
      allowNull: true
    },
    nextRunAt: {
      type: DataTypes.DATE,
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
    tableName: 'report_schedules',
    timestamps: true,
    underscored: true,
    indexes: [
      { fields: ['tenantId'] },
      { fields: ['templateId'] },
      { fields: ['isActive', 'nextRunAt'] }
    ]
  });

  ReportSchedule.associate = (models) => {
    ReportSchedule.belongsTo(models.Tenant, { foreignKey: 'tenantId', as: 'tenant' });
    ReportSchedule.belongsTo(models.ReportTemplate, { foreignKey: 'templateId', as: 'template' });
    ReportSchedule.belongsTo(models.User, { foreignKey: 'createdBy', as: 'creator' });
  };

  return ReportSchedule;
};
