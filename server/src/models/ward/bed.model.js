'use strict';
const { DataTypes } = require('sequelize');
const { v4: uuidv4 } = require('uuid');

module.exports = (sequelize) => {
  const Bed = sequelize.define('Bed', {
    id: {
      type: DataTypes.UUID,
      defaultValue: () => uuidv4(),
      primaryKey: true
    },
    wardId: {
      type: DataTypes.UUID,
      allowNull: true,
      field: 'ward_id',
      references: {
        model: 'wards',
        key: 'id'
      }
    },
    bedNumber: {
      type: DataTypes.STRING(50),
      allowNull: false
    },
    type: {
      type: DataTypes.STRING(50),
      defaultValue: 'standard'
    },
    status: {
      type: DataTypes.STRING(20),
      defaultValue: 'available'
    }
  }, {
    tableName: 'beds',
    timestamps: true,
    underscored: true,
    indexes: [
      { fields: ['ward_id'] },
      { fields: ['ward_id', 'bed_number'], unique: true },
      { fields: ['status'] }
    ]
  });

  Bed.associate = (models) => {
    Bed.belongsTo(models.Ward, { foreignKey: { name: 'wardId', field: 'ward_id' }, as: 'ward' });
    Bed.hasMany(models.Admission, { foreignKey: { name: 'bedId', field: 'bed_id' }, as: 'admissions' });
  };

  return Bed;
};
