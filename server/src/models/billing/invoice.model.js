const { DataTypes } = require('sequelize');

module.exports = (sequelize) => {
  const Invoice = sequelize.define('Invoice', {
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
    invoiceNumber: {
      type: DataTypes.STRING,
      allowNull: false,
      unique: true
    },
    encounterId: {
      type: DataTypes.UUID,
      references: { model: 'encounters', key: 'id' }
    },
    admissionId: {
      type: DataTypes.UUID,
      references: { model: 'admissions', key: 'id' }
    },
    patientId: {
      type: DataTypes.UUID,
      allowNull: false,
      references: { model: 'patients', key: 'id' }
    },
    type: {
      type: DataTypes.ENUM('consultation', 'inpatient', 'pharmacy', 'laboratory', 'procedure', 'package', 'other'),
      defaultValue: 'consultation'
    },
    status: {
      type: DataTypes.ENUM('pending', 'partial', 'paid', 'waived', 'written_off'),
      defaultValue: 'pending'
    },
    subtotal: {
      type: DataTypes.DECIMAL(12, 2),
      defaultValue: 0
    },
    discount: {
      type: DataTypes.DECIMAL(12, 2),
      defaultValue: 0
    },
    tax: {
      type: DataTypes.DECIMAL(12, 2),
      defaultValue: 0
    },
    totalAmount: {
      type: DataTypes.DECIMAL(12, 2),
      defaultValue: 0
    },
    paidAmount: {
      type: DataTypes.DECIMAL(12, 2),
      defaultValue: 0
    },
    balance: {
      type: DataTypes.DECIMAL(12, 2),
      defaultValue: 0
    },
    claimStatus: {
      type: DataTypes.ENUM('none', 'pending', 'submitted', 'approved', 'rejected', 'partial'),
      defaultValue: 'none'
    },
    claimReference: {
      type: DataTypes.STRING,
      allowNull: true
    },
    dueDate: {
      type: DataTypes.DATE,
      allowNull: true
    },
    paidAt: {
      type: DataTypes.DATE,
      allowNull: true
    },
    notes: {
      type: DataTypes.TEXT,
      allowNull: true
    },
    createdBy: {
      type: DataTypes.UUID,
      references: { model: 'users', key: 'id' }
    }
  }, {
    tableName: 'invoices',
    underscored: true,
    timestamps: true,
    indexes: [
      { fields: ['tenant_id'] },
      { fields: ['facility_id'] },
      { fields: ['patient_id'] },
      { fields: ['invoice_number'], unique: true },
      { fields: ['status'] },
      { fields: ['claim_status'] }
    ]
  });

  Invoice.generateInvoiceNumber = function (tenantSlug) {
    const date = new Date();
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const random = Math.floor(Math.random() * 100000).toString().padStart(5, '0');
    return `INV-${tenantSlug.toUpperCase().substring(0, 3)}-${year}${month}-${random}`;
  };

  Invoice.prototype.recalculate = function () {
    this.balance = parseFloat(this.totalAmount) - parseFloat(this.paidAmount || 0) - parseFloat(this.discount || 0);
    if (this.balance <= 0) {
      this.status = 'paid';
      this.paidAt = new Date();
    } else if (parseFloat(this.paidAmount || 0) > 0) {
      this.status = 'partial';
    }
  };

  return Invoice;
};
