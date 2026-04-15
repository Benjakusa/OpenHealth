const { DataTypes } = require('sequelize');
const { v4: uuidv4 } = require('uuid');

module.exports = (sequelize) => {
  const Patient = sequelize.define('Patient', {
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
      allowNull: true,
      references: {
        model: 'facilities',
        key: 'id'
      }
    },
    patientNumber: {
      type: DataTypes.STRING,
      allowNull: false,
      unique: true
    },
    firstName: {
      type: DataTypes.STRING,
      allowNull: false
    },
    lastName: {
      type: DataTypes.STRING,
      allowNull: false
    },
    middleName: {
      type: DataTypes.STRING,
      allowNull: true
    },
    dateOfBirth: {
      type: DataTypes.DATEONLY,
      allowNull: false
    },
    gender: {
      type: DataTypes.ENUM('male', 'female', 'other', 'unknown'),
      allowNull: false
    },
    maritalStatus: {
      type: DataTypes.ENUM('single', 'married', 'divorced', 'widowed', 'separated'),
      allowNull: true
    },
    nationalId: {
      type: DataTypes.STRING,
      allowNull: true
    },
    passportNumber: {
      type: DataTypes.STRING,
      allowNull: true
    },
    birthCertificateNumber: {
      type: DataTypes.STRING,
      allowNull: true
    },
    phone: {
      type: DataTypes.STRING,
      allowNull: true
    },
    alternativePhone: {
      type: DataTypes.STRING,
      allowNull: true
    },
    email: {
      type: DataTypes.STRING,
      allowNull: true
    },
    address: {
      type: DataTypes.JSONB,
      defaultValue: {}
    },
    county: {
      type: DataTypes.STRING,
      allowNull: true
    },
    subCounty: {
      type: DataTypes.STRING,
      allowNull: true
    },
    ward: {
      type: DataTypes.STRING,
      allowNull: true
    },
    village: {
      type: DataTypes.STRING,
      allowNull: true
    },
    landmark: {
      type: DataTypes.STRING,
      allowNull: true
    },
    occupation: {
      type: DataTypes.STRING,
      allowNull: true
    },
    employer: {
      type: DataTypes.STRING,
      allowNull: true
    },
    religion: {
      type: DataTypes.STRING,
      allowNull: true
    },
    bloodGroup: {
      type: DataTypes.ENUM('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-', 'unknown'),
      allowNull: true
    },
    allergies: {
      type: DataTypes.JSONB,
      defaultValue: []
    },
    chronicConditions: {
      type: DataTypes.JSONB,
      defaultValue: []
    },
    familyHistory: {
      type: DataTypes.JSONB,
      defaultValue: []
    },
    emergencyContact: {
      type: DataTypes.JSONB,
      defaultValue: {}
    },
    photo: {
      type: DataTypes.STRING,
      allowNull: true
    },
    signature: {
      type: DataTypes.STRING,
      allowNull: true
    },
    sha: {
      type: DataTypes.JSONB,
      defaultValue: {}
    },
    insurance: {
      type: DataTypes.JSONB,
      defaultValue: {}
    },
    registrationSource: {
      type: DataTypes.ENUM('reception', 'emergency', 'transfer', 'self'),
      defaultValue: 'reception'
    },
    registeredBy: {
      type: DataTypes.UUID,
      allowNull: true
    },
    isActive: {
      type: DataTypes.BOOLEAN,
      defaultValue: true
    },
    isDeceased: {
      type: DataTypes.BOOLEAN,
      defaultValue: false
    },
    deceasedAt: {
      type: DataTypes.DATE,
      allowNull: true
    }
  }, {
    tableName: 'patients',
    underscored: true,
    timestamps: true,
    indexes: [
      { fields: ['tenant_id'] },
      { fields: ['facility_id'] },
      { fields: ['patient_number'] },
      { fields: ['phone'] },
      { fields: ['national_id'] },
      { fields: ['last_name'] }
    ]
  });

  Patient.prototype.getFullName = function () {
    const parts = [this.firstName];
    if (this.middleName) parts.push(this.middleName);
    parts.push(this.lastName);
    return parts.join(' ');
  };

  Patient.prototype.getAge = function () {
    const today = new Date();
    const birthDate = new Date(this.dateOfBirth);
    let age = today.getFullYear() - birthDate.getFullYear();
    const monthDiff = today.getMonth() - birthDate.getMonth();
    if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < birthDate.getDate())) {
      age--;
    }
    return age;
  };

  Patient.prototype.getAgeInMonths = function () {
    const today = new Date();
    const birthDate = new Date(this.dateOfBirth);
    return (today.getFullYear() - birthDate.getFullYear()) * 12 + (today.getMonth() - birthDate.getMonth());
  };

  Patient.generatePatientNumber = function (tenantSlug) {
    const year = new Date().getFullYear();
    const random = Math.floor(Math.random() * 100000).toString().padStart(5, '0');
    return `${tenantSlug.toUpperCase().substring(0, 3)}-${year}-${random}`;
  };

  return Patient;
};
