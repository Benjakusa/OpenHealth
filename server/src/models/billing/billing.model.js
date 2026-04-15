const { DataTypes } = require('sequelize');

module.exports = (sequelize) => {
  const Billing = sequelize.define('Billing', {
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
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
    facilityId: {
      type: DataTypes.UUID,
      allowNull: false,
      references: {
        model: 'facilities',
        key: 'id'
      }
    },
    invoiceNumber: {
      type: DataTypes.STRING,
      allowNull: false,
      unique: true
    },
    encounterId: {
      type: DataTypes.UUID,
      allowNull: true,
      references: {
        model: 'encounters',
        key: 'id'
      }
    },
    patientId: {
      type: DataTypes.UUID,
      allowNull: false,
      references: {
        model: 'patients',
        key: 'id'
      }
    },
    type: {
      type: DataTypes.ENUM('consultation', 'inpatient', 'pharmacy', 'laboratory', 'procedure', 'package', 'other'),
      defaultValue: 'consultation'
    },
    status: {
      type: DataTypes.ENUM('draft', 'pending', 'awaiting_payment', 'partially_paid', 'paid', 'waived', 'written_off'),
      defaultValue: 'draft'
    },
    items: {
      type: DataTypes.JSONB,
      defaultValue: []
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
    total: {
      type: DataTypes.DECIMAL(12, 2),
      defaultValue: 0
    },
    shaCover: {
      type: DataTypes.DECIMAL(12, 2),
      defaultValue: 0
    },
    insuranceCover: {
      type: DataTypes.DECIMAL(12, 2),
      defaultValue: 0
    },
    patientPay: {
      type: DataTypes.DECIMAL(12, 2),
      defaultValue: 0
    },
    payments: {
      type: DataTypes.JSONB,
      defaultValue: []
    },
    amountPaid: {
      type: DataTypes.DECIMAL(12, 2),
      defaultValue: 0
    },
    balance: {
      type: DataTypes.DECIMAL(12, 2),
      defaultValue: 0
    },
    waiver: {
      type: DataTypes.JSONB,
      defaultValue: null
    },
    claims: {
      type: DataTypes.JSONB,
      defaultValue: []
    },
    dueDate: {
      type: DataTypes.DATE,
      allowNull: true
    },
    paidAt: {
      type: DataTypes.DATE,
      allowNull: true
    },
    department: {
      type: DataTypes.STRING,
      allowNull: true
    },
    notes: {
      type: DataTypes.TEXT,
      allowNull: true
    },
    metadata: {
      type: DataTypes.JSONB,
      defaultValue: {}
    }
  }, {
    tableName: 'billing',
    underscored: true,
    timestamps: true,
    indexes: [
      { fields: ['tenant_id'] },
      { fields: ['patient_id'] },
      { fields: ['encounter_id'] },
      { fields: ['invoice_number'] },
      { fields: ['status'] }
    ]
  });

  Billing.generateInvoiceNumber = function (tenantSlug, type = 'INV') {
    const date = new Date();
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const random = Math.floor(Math.random() * 100000).toString().padStart(5, '0');
    return `${tenantSlug.toUpperCase().substring(0, 3)}-${type}-${year}${month}-${random}`;
  };

  Billing.prototype.addItem = function (item) {
    const items = this.items || [];
    const existingIndex = items.findIndex(i => i.code === item.code && !i.voided);

    if (existingIndex >= 0) {
      return { error: 'Item already added', index: existingIndex };
    }

    items.push({
      ...item,
      id: require('uuid').v4(),
      addedAt: new Date()
    });

    this.items = items;
    this.recalculate();
  };

  Billing.prototype.removeItem = function (itemId) {
    const items = this.items || [];
    const index = items.findIndex(i => i.id === itemId);
    if (index >= 0) {
      items[index].voided = true;
      items[index].voidedAt = new Date();
      this.items = items;
      this.recalculate();
      return true;
    }
    return false;
  };

  Billing.prototype.recalculate = function () {
    const validItems = (this.items || []).filter(i => !i.voided);
    this.subtotal = validItems.reduce((sum, item) => sum + (item.amount || 0), 0);
    this.total = this.subtotal - this.discount + this.tax;
    this.balance = this.total - this.amountPaid;
  };

  Billing.prototype.addPayment = function (payment) {
    const payments = this.payments || [];
    payments.push({
      ...payment,
      id: require('uuid').v4(),
      receivedAt: new Date()
    });
    this.payments = payments;
    this.amountPaid = payments.reduce((sum, p) => sum + (p.amount || 0), 0);
    this.recalculate();

    if (this.balance <= 0) {
      this.status = 'paid';
      this.paidAt = new Date();
    } else if (this.amountPaid > 0) {
      this.status = 'partially_paid';
    }
  };

  Billing.prototype.calculatePatientResponsibility = function (shaCover, insuranceCover, insuranceDetails) {
    let shaAmount = 0;
    let insuranceAmount = 0;
    let patientAmount = 0;

    const shaCoveredItems = (this.items || []).filter(i => i.shaCovered);
    shaAmount = shaCoveredItems.reduce((sum, item) => sum + (item.amount || 0), 0) * (shaCover / 100);

    if (insuranceDetails) {
      const insuranceCoveredItems = (this.items || []).filter(i =>
        i.insuranceCovered && i.insuranceProvider === insuranceDetails.provider
      );
      insuranceAmount = insuranceCoveredItems.reduce((sum, item) => sum + (item.amount || 0), 0) * (insuranceDetails.coveragePercent / 100);
    }

    patientAmount = this.total - shaAmount - insuranceAmount;

    this.shaCover = shaAmount;
    this.insuranceCover = insuranceAmount;
    this.patientPay = patientAmount;
    this.recalculate();

    return { shaCover: shaAmount, insuranceCover: insuranceAmount, patientPay: patientAmount };
  };

  return Billing;
};
