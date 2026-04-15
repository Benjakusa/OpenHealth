const { DataTypes } = require('sequelize');

module.exports = (sequelize) => {
  const Inventory = sequelize.define('Inventory', {
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
    itemCode: {
      type: DataTypes.STRING,
      allowNull: false
    },
    name: {
      type: DataTypes.STRING,
      allowNull: false
    },
    genericName: {
      type: DataTypes.STRING,
      allowNull: true
    },
    brandName: {
      type: DataTypes.STRING,
      allowNull: true
    },
    category: {
      type: DataTypes.ENUM(
        'drug',
        'consumable',
        'equipment',
        'stationery',
        'food',
        'linen',
        'gas',
        'other'
      ),
      defaultValue: 'drug'
    },
    subcategory: {
      type: DataTypes.STRING,
      allowNull: true
    },
    unit: {
      type: DataTypes.STRING,
      defaultValue: 'unit'
    },
    unitPrice: {
      type: DataTypes.DECIMAL(12, 2),
      defaultValue: 0
    },
    costPrice: {
      type: DataTypes.DECIMAL(12, 2),
      defaultValue: 0
    },
    markup: {
      type: DataTypes.DECIMAL(5, 2),
      defaultValue: 0
    },
    quantity: {
      type: DataTypes.INTEGER,
      defaultValue: 0
    },
    reorderLevel: {
      type: DataTypes.INTEGER,
      defaultValue: 10
    },
    reorderQuantity: {
      type: DataTypes.INTEGER,
      defaultValue: 100
    },
    maxLevel: {
      type: DataTypes.INTEGER,
      allowNull: true
    },
    expiryTracking: {
      type: DataTypes.BOOLEAN,
      defaultValue: false
    },
    controlledSubstance: {
      type: DataTypes.BOOLEAN,
      defaultValue: false
    },
    drugSchedule: {
      type: DataTypes.STRING,
      allowNull: true
    },
    formulation: {
      type: DataTypes.STRING,
      allowNull: true
    },
    strength: {
      type: DataTypes.STRING,
      allowNull: true
    },
    manufacturer: {
      type: DataTypes.STRING,
      allowNull: true
    },
    supplier: {
      type: DataTypes.STRING,
      allowNull: true
    },
    batches: {
      type: DataTypes.JSONB,
      defaultValue: []
    },
    locations: {
      type: DataTypes.JSONB,
      defaultValue: []
    },
    alternatives: {
      type: DataTypes.JSONB,
      defaultValue: []
    },
    contraindications: {
      type: DataTypes.JSONB,
      defaultValue: []
    },
    sideEffects: {
      type: DataTypes.JSONB,
      defaultValue: []
    },
    storageConditions: {
      type: DataTypes.STRING,
      allowNull: true
    },
    image: {
      type: DataTypes.STRING,
      allowNull: true
    },
    barcode: {
      type: DataTypes.STRING,
      allowNull: true
    },
    insuranceCoverage: {
      type: DataTypes.JSONB,
      defaultValue: {}
    },
    shaCoverage: {
      type: DataTypes.BOOLEAN,
      defaultValue: false
    },
    status: {
      type: DataTypes.ENUM('active', 'inactive', 'discontinued', 'out_of_stock'),
      defaultValue: 'active'
    },
    movement: {
      type: DataTypes.JSONB,
      defaultValue: []
    }
  }, {
    tableName: 'inventory',
    underscored: true,
    timestamps: true,
    indexes: [
      { fields: ['tenant_id'] },
      { fields: ['facility_id'] },
      { fields: ['item_code'] },
      { fields: ['category'] },
      { fields: ['status'] },
      { fields: ['name'] }
    ]
  });

  Inventory.prototype.addBatch = function (batch) {
    const batches = this.batches || [];
    const existingIndex = batches.findIndex(b => b.batchNumber === batch.batchNumber);

    if (existingIndex >= 0) {
      batches[existingIndex].quantity += batch.quantity;
      batches[existingIndex].expiryDate = batch.expiryDate;
    } else {
      batches.push({
        ...batch,
        id: require('uuid').v4(),
        receivedAt: new Date()
      });
    }

    this.batches = batches;
    this.recalculateQuantity();
  };

  Inventory.prototype.deductFromBatch = function (quantity, preferredBatch = null) {
    const batches = [...this.batches].sort((a, b) =>
      new Date(a.expiryDate) - new Date(b.expiryDate)
    );

    let remaining = quantity;
    const deductions = [];

    for (const batch of batches) {
      if (remaining <= 0) break;
      if (batch.quantity <= 0) continue;

      const deducted = Math.min(batch.quantity, remaining);
      deductions.push({
        batchNumber: batch.batchNumber,
        quantity: deducted,
        expiryDate: batch.expiryDate
      });
      remaining -= deducted;
    }

    if (remaining > 0) {
      return { success: false, message: 'Insufficient stock', remaining };
    }

    this.batches = batches.map(batch => {
      const deduction = deductions.find(d => d.batchNumber === batch.batchNumber);
      if (deduction) {
        batch.quantity -= deduction.quantity;
      }
      return batch;
    }).filter(b => b.quantity > 0);

    this.recalculateQuantity();
    return { success: true, deductions };
  };

  Inventory.prototype.recalculateQuantity = function () {
    this.quantity = (this.batches || []).reduce((sum, batch) => sum + batch.quantity, 0);

    if (this.quantity <= 0) {
      this.status = 'out_of_stock';
    } else if (this.quantity <= this.reorderLevel) {
      this.status = 'active';
    }
  };

  Inventory.prototype.isNearExpiry = function (days = 90) {
    const now = new Date();
    const threshold = new Date();
    threshold.setDate(threshold.getDate() + days);

    return (this.batches || []).filter(batch => {
      const expiry = new Date(batch.expiryDate);
      return expiry <= threshold && expiry > now;
    });
  };

  Inventory.prototype.isExpired = function () {
    const now = new Date();
    return (this.batches || []).filter(batch =>
      new Date(batch.expiryDate) <= now
    );
  };

  Inventory.prototype.recordMovement = function (movement) {
    const movementRecord = {
      ...movement,
      id: require('uuid').v4(),
      timestamp: new Date()
    };
    this.movement.push(movementRecord);
  };

  Inventory.prototype.getValue = function () {
    return this.quantity * parseFloat(this.unitPrice);
  };

  Inventory.prototype.needsReorder = function () {
    return this.quantity <= this.reorderLevel;
  };

  return Inventory;
};
