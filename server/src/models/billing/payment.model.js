const { DataTypes } = require('sequelize');

module.exports = (sequelize) => {
  const Payment = sequelize.define('Payment', {
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
    facilityId: {
      type: DataTypes.UUID,
      allowNull: false,
      references: { model: 'facilities', key: 'id' }
    },
    invoiceId: {
      type: DataTypes.UUID,
      references: { model: 'invoices', key: 'id' }
    },
    patientId: {
      type: DataTypes.UUID,
      allowNull: false,
      references: { model: 'patients', key: 'id' }
    },
    amount: {
      type: DataTypes.DECIMAL(12, 2),
      allowNull: false
    },
    paymentMethod: {
      type: DataTypes.ENUM('cash', 'mpesa', 'card', 'insurance', 'bank_transfer', 'cheque', 'other'),
      defaultValue: 'cash'
    },
    reference: {
      type: DataTypes.STRING,
      allowNull: true
    },
    externalReference: {
      type: DataTypes.STRING,
      allowNull: true
    },
    receiptNumber: {
      type: DataTypes.STRING,
      allowNull: true
    },
    status: {
      type: DataTypes.ENUM('pending', 'completed', 'failed', 'cancelled', 'refunded'),
      defaultValue: 'pending'
    },
    type: {
      type: DataTypes.ENUM('payment', 'refund', 'reversal'),
      defaultValue: 'payment'
    },
    phoneNumber: {
      type: DataTypes.STRING,
      allowNull: true
    },
    cardType: {
      type: DataTypes.STRING,
      allowNull: true
    },
    lastFourDigits: {
      type: DataTypes.STRING(4),
      allowNull: true
    },
    bankName: {
      type: DataTypes.STRING,
      allowNull: true
    },
    transactionDate: {
      type: DataTypes.DATE,
      allowNull: true
    },
    transferDate: {
      type: DataTypes.DATE,
      allowNull: true
    },
    collectedBy: {
      type: DataTypes.UUID,
      allowNull: true
    },
    description: {
      type: DataTypes.TEXT,
      allowNull: true
    },
    notes: {
      type: DataTypes.TEXT,
      allowNull: true
    },
    failureReason: {
      type: DataTypes.STRING,
      allowNull: true
    },
    completedAt: {
      type: DataTypes.DATE,
      allowNull: true
    },
    rawResponse: {
      type: DataTypes.TEXT,
      allowNull: true
    },
    createdBy: {
      type: DataTypes.UUID,
      references: { model: 'users', key: 'id' }
    }
  }, {
    tableName: 'payments',
    underscored: true,
    timestamps: true,
    indexes: [
      { fields: ['tenant_id'] },
      { fields: ['facility_id'] },
      { fields: ['invoice_id'] },
      { fields: ['patient_id'] },
      { fields: ['reference'] },
      { fields: ['status'] },
      { fields: ['created_at'] }
    ]
  });

  Payment.generateReceiptNumber = function (tenantSlug) {
    const date = new Date();
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const random = Math.floor(Math.random() * 100000).toString().padStart(5, '0');
    return `RCP-${tenantSlug.toUpperCase().substring(0, 3)}-${year}${month}-${random}`;
  };

  return Payment;
};
