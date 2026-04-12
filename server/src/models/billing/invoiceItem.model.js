const { DataTypes } = require('sequelize');

module.exports = (sequelize) => {
  const InvoiceItem = sequelize.define('InvoiceItem', {
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true
    },
    invoiceId: {
      type: DataTypes.UUID,
      allowNull: false,
      references: { model: 'invoices', key: 'id' }
    },
    serviceCode: {
      type: DataTypes.STRING,
      allowNull: true
    },
    serviceName: {
      type: DataTypes.STRING,
      allowNull: false
    },
    description: {
      type: DataTypes.TEXT,
      allowNull: true
    },
    category: {
      type: DataTypes.STRING,
      defaultValue: 'service'
    },
    quantity: {
      type: DataTypes.DECIMAL(10, 2),
      defaultValue: 1
    },
    unitPrice: {
      type: DataTypes.DECIMAL(12, 2),
      defaultValue: 0
    },
    total: {
      type: DataTypes.DECIMAL(12, 2),
      defaultValue: 0
    },
    discount: {
      type: DataTypes.DECIMAL(12, 2),
      defaultValue: 0
    },
    shaCovered: {
      type: DataTypes.BOOLEAN,
      defaultValue: false
    },
    insuranceCovered: {
      type: DataTypes.BOOLEAN,
      defaultValue: false
    },
    insuranceProvider: {
      type: DataTypes.STRING,
      allowNull: true
    },
    department: {
      type: DataTypes.STRING,
      allowNull: true
    },
    voided: {
      type: DataTypes.BOOLEAN,
      defaultValue: false
    },
    voidedAt: {
      type: DataTypes.DATE,
      allowNull: true
    },
    voidedBy: {
      type: DataTypes.UUID,
      allowNull: true
    }
  }, {
    tableName: 'invoice_items',
    underscored: true,
    timestamps: true,
    indexes: [
      { fields: ['invoice_id'] },
      { fields: ['service_code'] }
    ]
  });

  InvoiceItem.prototype.recalculate = function() {
    this.total = (parseFloat(this.quantity) || 1) * (parseFloat(this.unitPrice) || 0) - (parseFloat(this.discount) || 0);
  };

  return InvoiceItem;
};
