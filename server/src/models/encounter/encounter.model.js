const { DataTypes } = require('sequelize');

module.exports = (sequelize) => {
  const Encounter = sequelize.define('Encounter', {
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
    encounterNumber: {
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
    providerId: {
      type: DataTypes.UUID,
      allowNull: false,
      references: {
        model: 'users',
        key: 'id'
      }
    },
    visitType: {
      type: DataTypes.ENUM('new', 'follow_up', 'emergency', 'transfer_in', 'transfer_out', ' ANC', 'MCH', 'child_welfare', 'OPD', 'IPD'),
      defaultValue: 'new'
    },
    status: {
      type: DataTypes.ENUM('pending_triage', 'pending_doctor', 'in_progress', 'completed', 'cancelled', 'referred', 'admitted'),
      defaultValue: 'pending_triage'
    },
    triage: {
      type: DataTypes.JSONB,
      defaultValue: null
    },
    chiefComplaint: {
      type: DataTypes.TEXT,
      allowNull: true
    },
    history: {
      type: DataTypes.JSONB,
      defaultValue: {}
    },
    soap: {
      type: DataTypes.JSONB,
      defaultValue: {
        subjective: '',
        objective: {},
        assessment: {},
        plan: {}
      }
    },
    diagnoses: {
      type: DataTypes.JSONB,
      defaultValue: []
    },
    procedures: {
      type: DataTypes.JSONB,
      defaultValue: []
    },
    prescriptions: {
      type: DataTypes.JSONB,
      defaultValue: []
    },
    labOrders: {
      type: DataTypes.JSONB,
      defaultValue: []
    },
    imagingOrders: {
      type: DataTypes.JSONB,
      defaultValue: []
    },
    disposition: {
      type: DataTypes.JSONB,
      defaultValue: {}
    },
    referrals: {
      type: DataTypes.JSONB,
      defaultValue: []
    },
    vitals: {
      type: DataTypes.JSONB,
      defaultValue: {}
    },
    attachments: {
      type: DataTypes.JSONB,
      defaultValue: []
    },
    notes: {
      type: DataTypes.JSONB,
      defaultValue: []
    },
    location: {
      type: DataTypes.STRING,
      allowNull: true
    },
    department: {
      type: DataTypes.STRING,
      allowNull: true
    },
    priority: {
      type: DataTypes.ENUM('emergency', 'urgent', 'semi_urgent', 'non_urgent'),
      defaultValue: 'non_urgent'
    },
    scheduledAt: {
      type: DataTypes.DATE,
      allowNull: true
    },
    startedAt: {
      type: DataTypes.DATE,
      allowNull: true
    },
    completedAt: {
      type: DataTypes.DATE,
      allowNull: true
    },
    duration: {
      type: DataTypes.INTEGER,
      allowNull: true
    },
    billing: {
      type: DataTypes.JSONB,
      defaultValue: {}
    },
    isLocked: {
      type: DataTypes.BOOLEAN,
      defaultValue: false
    },
    lockedAt: {
      type: DataTypes.DATE,
      allowNull: true
    },
    lockedBy: {
      type: DataTypes.UUID,
      allowNull: true
    }
  }, {
    tableName: 'encounters',
    underscored: true,
    timestamps: true,
    indexes: [
      { fields: ['tenant_id'] },
      { fields: ['patient_id'] },
      { fields: ['provider_id'] },
      { fields: ['status'] },
      { fields: ['encounter_number'] },
      { fields: ['started_at'] }
    ]
  });

  Encounter.generateEncounterNumber = function(tenantSlug) {
    const date = new Date();
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    const random = Math.floor(Math.random() * 10000).toString().padStart(4, '0');
    return `${tenantSlug.toUpperCase().substring(0, 3)}-${year}${month}${day}-${random}`;
  };

  Encounter.prototype.getDuration = function() {
    if (!this.startedAt || !this.completedAt) return null;
    return Math.round((new Date(this.completedAt) - new Date(this.startedAt)) / 1000 / 60);
  };

  Encounter.prototype.addPrescription = function(prescription) {
    const prescriptions = this.prescriptions || [];
    prescriptions.push({
      ...prescription,
      prescribedAt: new Date(),
      status: 'pending'
    });
    this.prescriptions = prescriptions;
  };

  Encounter.prototype.addLabOrder = function(order) {
    const labOrders = this.labOrders || [];
    labOrders.push({
      ...order,
      orderedAt: new Date(),
      status: 'pending'
    });
    this.labOrders = labOrders;
  };

  return Encounter;
};
