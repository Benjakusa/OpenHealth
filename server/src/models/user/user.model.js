const { DataTypes } = require('sequelize');
const bcrypt = require('bcryptjs');

module.exports = (sequelize) => {
  const User = sequelize.define('User', {
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
    email: {
      type: DataTypes.STRING,
      allowNull: false,
      validate: {
        isEmail: true
      }
    },
    passwordHash: {
      type: DataTypes.STRING,
      allowNull: false
    },
    firstName: {
      type: DataTypes.STRING,
      allowNull: false
    },
    lastName: {
      type: DataTypes.STRING,
      allowNull: false
    },
    phone: {
      type: DataTypes.STRING,
      allowNull: true
    },
    role: {
      type: DataTypes.ENUM(
        'SUPER_ADMIN',
        'FACILITY_ADMIN',
        'DOCTOR',
        'NURSE',
        'RECEPTIONIST',
        'CASHIER',
        'PHARMACIST',
        'LAB_TECHNICIAN',
        'RADIOLOGIST',
        'WARD_CLERK',
        'INVENTORY_MANAGER',
        'HR_MANAGER',
        'REPORTS_ANALYST'
      ),
      defaultValue: 'RECEPTIONIST'
    },
    specialty: {
      type: DataTypes.STRING,
      allowNull: true
    },
    qualification: {
      type: DataTypes.STRING,
      allowNull: true
    },
    licenseNumber: {
      type: DataTypes.STRING,
      allowNull: true
    },
    department: {
      type: DataTypes.STRING,
      allowNull: true
    },
    permissions: {
      type: DataTypes.JSONB,
      defaultValue: []
    },
    settings: {
      type: DataTypes.JSONB,
      defaultValue: {}
    },
    avatar: {
      type: DataTypes.STRING,
      allowNull: true
    },
    lastLoginAt: {
      type: DataTypes.DATE,
      allowNull: true
    },
    isActive: {
      type: DataTypes.BOOLEAN,
      defaultValue: true
    }
  }, {
    tableName: 'users',
    underscored: true,
    timestamps: true,
    indexes: [
      { fields: ['tenant_id'] },
      { fields: ['email'] },
      { fields: ['role'] }
    ],
    hooks: {
      beforeCreate: async (user) => {
        if (user.passwordHash) {
          user.passwordHash = await bcrypt.hash(user.passwordHash, 12);
        }
      },
      beforeUpdate: async (user) => {
        if (user.changed('passwordHash')) {
          user.passwordHash = await bcrypt.hash(user.passwordHash, 12);
        }
      }
    }
  });

  User.prototype.comparePassword = async function(password) {
    return bcrypt.compare(password, this.passwordHash);
  };

  User.prototype.getFullName = function() {
    return `${this.firstName} ${this.lastName}`;
  };

  User.ROLES = {
    SUPER_ADMIN: ['SUPER_ADMIN'],
    FACILITY_ADMIN: ['SUPER_ADMIN', 'FACILITY_ADMIN'],
    DOCTOR: ['SUPER_ADMIN', 'FACILITY_ADMIN', 'DOCTOR'],
    NURSE: ['SUPER_ADMIN', 'FACILITY_ADMIN', 'NURSE'],
    RECEPTIONIST: ['SUPER_ADMIN', 'FACILITY_ADMIN', 'RECEPTIONIST'],
    CASHIER: ['SUPER_ADMIN', 'FACILITY_ADMIN', 'CASHIER'],
    PHARMACIST: ['SUPER_ADMIN', 'FACILITY_ADMIN', 'PHARMACIST'],
    LAB_TECHNICIAN: ['SUPER_ADMIN', 'FACILITY_ADMIN', 'LAB_TECHNICIAN'],
    RADIOLOGIST: ['SUPER_ADMIN', 'FACILITY_ADMIN', 'RADIOLOGIST'],
    WARD_CLERK: ['SUPER_ADMIN', 'FACILITY_ADMIN', 'WARD_CLERK'],
    INVENTORY_MANAGER: ['SUPER_ADMIN', 'FACILITY_ADMIN', 'INVENTORY_MANAGER'],
    HR_MANAGER: ['SUPER_ADMIN', 'FACILITY_ADMIN', 'HR_MANAGER'],
    REPORTS_ANALYST: ['SUPER_ADMIN', 'FACILITY_ADMIN', 'REPORTS_ANALYST']
  };

  User.PERMISSIONS = {
    PATIENTS_READ: 'patients:read',
    PATIENTS_WRITE: 'patients:write',
    ENCOUNTERS_READ: 'encounters:read',
    ENCOUNTERS_WRITE: 'encounters:write',
    BILLING_READ: 'billing:read',
    BILLING_WRITE: 'billing:write',
    INVENTORY_READ: 'inventory:read',
    INVENTORY_WRITE: 'inventory:write',
    REPORTS_READ: 'reports:read',
    USERS_READ: 'users:read',
    USERS_WRITE: 'users:write',
    SETTINGS_READ: 'settings:read',
    SETTINGS_WRITE: 'settings:write'
  };

  return User;
};
