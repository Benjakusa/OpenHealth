const { DataTypes } = require('sequelize');

module.exports = (sequelize) => {
  const Tenant = sequelize.define('Tenant', {
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true
    },
    name: {
      type: DataTypes.STRING,
      allowNull: false,
      validate: {
        notEmpty: true
      }
    },
    slug: {
      type: DataTypes.STRING,
      allowNull: false,
      unique: true
    },
    schema: {
      type: DataTypes.STRING,
      allowNull: false,
      unique: true
    },
    package: {
      type: DataTypes.ENUM('DAWA', 'AFYA', 'HOSPITALI'),
      defaultValue: 'DAWA'
    },
    facilityType: {
      type: DataTypes.STRING,
      allowNull: true
    },
    facilityLevel: {
      type: DataTypes.INTEGER,
      allowNull: true
    },
    registrationNumber: {
      type: DataTypes.STRING,
      allowNull: true
    },
    kephLevel: {
      type: DataTypes.INTEGER,
      allowNull: true
    },
    address: {
      type: DataTypes.JSONB,
      defaultValue: {}
    },
    contacts: {
      type: DataTypes.JSONB,
      defaultValue: {}
    },
    shaFacilityId: {
      type: DataTypes.STRING,
      allowNull: true
    },
    insuranceCredentials: {
      type: DataTypes.JSONB,
      defaultValue: {}
    },
    settings: {
      type: DataTypes.JSONB,
      defaultValue: {}
    },
    status: {
      type: DataTypes.ENUM('active', 'trial', 'suspended', 'terminated'),
      defaultValue: 'trial'
    },
    subscription: {
      type: DataTypes.JSONB,
      defaultValue: {}
    },
    storage: {
      type: DataTypes.BIGINT,
      defaultValue: 0
    },
    storageLimit: {
      type: DataTypes.BIGINT,
      defaultValue: 5 * 1024 * 1024 * 1024
    },
    expiresAt: {
      type: DataTypes.DATE,
      allowNull: true
    },
    lastSyncAt: {
      type: DataTypes.DATE,
      allowNull: true
    }
  }, {
    tableName: 'tenants',
    underscored: true,
    timestamps: true,
    indexes: [
      { fields: ['slug'] },
      { fields: ['schema'] },
      { fields: ['status'] }
    ]
  });

  Tenant.prototype.isSubscriptionActive = function() {
    return this.status === 'active' || 
           (this.status === 'trial' && new Date() < this.expiresAt);
  };

  Tenant.prototype.isWithinGracePeriod = function() {
    if (!this.expiresAt) return false;
    const gracePeriodEnd = new Date(this.expiresAt);
    gracePeriodEnd.setDate(gracePeriodEnd.getDate() + 7);
    return new Date() <= gracePeriodEnd;
  };

  return Tenant;
};
