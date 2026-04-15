const { DataTypes } = require('sequelize');

module.exports = (sequelize) => {
    const Facility = sequelize.define('Facility', {
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
        name: {
            type: DataTypes.STRING,
            allowNull: false,
            validate: {
                notEmpty: true
            }
        },
code: {
      type: DataTypes.STRING,
      allowNull: false,
      unique: true
    },
    slug: {
      type: DataTypes.STRING,
      allowNull: true,
      unique: true
    },
        type: {
            type: DataTypes.ENUM('HOSPITAL', 'CLINIC', 'LABORATORY', 'PHARMACY', 'RADIOLOGY'),
            defaultValue: 'HOSPITAL'
        },
        kephLevel: {
            type: DataTypes.INTEGER,
            allowNull: true
        },
        registrationNumber: {
            type: DataTypes.STRING,
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
        status: {
            type: DataTypes.ENUM('active', 'inactive', 'maintenance'),
            defaultValue: 'active'
        },
        settings: {
            type: DataTypes.JSONB,
            defaultValue: {}
        }
    }, {
        tableName: 'facilities',
        underscored: true,
        timestamps: true,
        indexes: [
            { fields: ['tenant_id'] },
            { fields: ['code'] },
            { fields: ['status'] }
        ]
    });

    return Facility;
};
