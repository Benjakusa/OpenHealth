const { DataTypes } = require('sequelize');

module.exports = (sequelize) => {
  const Prescription = sequelize.define('Prescription', {
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
    prescriptionNumber: {
      type: DataTypes.STRING,
      allowNull: false,
      unique: true
    },
    patientId: {
      type: DataTypes.UUID,
      allowNull: false,
      references: {
        model: 'patients',
        key: 'id'
      }
    },
    encounterId: {
      type: DataTypes.UUID,
      allowNull: true,
      references: {
        model: 'encounters',
        key: 'id'
      }
    },
    prescriberId: {
      type: DataTypes.UUID,
      allowNull: false,
      references: {
        model: 'users',
        key: 'id'
      }
    },
    status: {
      type: DataTypes.ENUM('pending', 'dispensed', 'partially_dispensed', 'on_hold', 'cancelled', 'expired'),
      defaultValue: 'pending'
    },
    items: {
      type: DataTypes.JSONB,
      defaultValue: []
    },
    notes: {
      type: DataTypes.TEXT,
      allowNull: true
    },
    diagnosis: {
      type: DataTypes.TEXT,
      allowNull: true
    },
    urgent: {
      type: DataTypes.BOOLEAN,
      defaultValue: false
    },
    prescribedAt: {
      type: DataTypes.DATE,
      defaultValue: DataTypes.NOW
    },
    expiresAt: {
      type: DataTypes.DATE,
      allowNull: true
    },
    dispensedAt: {
      type: DataTypes.DATE,
      allowNull: true
    },
    dispensedBy: {
      type: DataTypes.UUID,
      allowNull: true,
      references: {
        model: 'users',
        key: 'id'
      }
    },
    cancelledAt: {
      type: DataTypes.DATE,
      allowNull: true
    },
    cancelledBy: {
      type: DataTypes.UUID,
      allowNull: true,
      references: {
        model: 'users',
        key: 'id'
      }
    },
    cancellationReason: {
      type: DataTypes.TEXT,
      allowNull: true
    },
    holdReason: {
      type: DataTypes.TEXT,
      allowNull: true
    },
    metadata: {
      type: DataTypes.JSONB,
      defaultValue: {}
    }
  }, {
    tableName: 'prescriptions',
    underscored: true,
    timestamps: true,
    indexes: [
      { fields: ['tenant_id'] },
      { fields: ['patient_id'] },
      { fields: ['encounter_id'] },
      { fields: ['prescriber_id'] },
      { fields: ['status'] },
      { fields: ['prescription_number'] }
    ]
  });

  Prescription.generatePrescriptionNumber = function(tenantSlug) {
    const date = new Date();
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const random = Math.floor(Math.random() * 100000).toString().padStart(5, '0');
    return `${tenantSlug.toUpperCase().substring(0, 3)}-RX-${year}${month}-${random}`;
  };

  Prescription.prototype.isExpired = function() {
    return this.expiresAt && new Date() > new Date(this.expiresAt);
  };

  Prescription.prototype.allItemsDispensed = function() {
    const items = this.items || [];
    return items.length > 0 && items.every(item => item.status === 'dispensed');
  };

  Prescription.prototype.pendingItemsCount = function() {
    const items = this.items || [];
    return items.filter(item => item.status !== 'dispensed').length;
  };

  return Prescription;
};
