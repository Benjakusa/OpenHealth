const { DataTypes } = require('sequelize');

module.exports = (sequelize) => {
  const ClaimLineItem = sequelize.define('ClaimLineItem', {
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true
    },
    claimId: {
      type: DataTypes.UUID,
      allowNull: false,
      references: { model: 'claims', key: 'id' }
    },
    code: {
      type: DataTypes.STRING,
      allowNull: true
    },
    description: {
      type: DataTypes.STRING,
      allowNull: false
    },
    category: {
      type: DataTypes.ENUM('service', 'medication', 'procedure', 'diagnosis', 'other'),
      defaultValue: 'service'
    },
    quantity: {
      type: DataTypes.DECIMAL(10, 2),
      defaultValue: 1
    },
    unitPrice: {
      type: DataTypes.DECIMAL(12, 2),
      defaultValue: 0
    },
    total: {
      type: DataTypes.DECIMAL(12, 2),
      defaultValue: 0
    },
    approved: {
      type: DataTypes.BOOLEAN,
      defaultValue: false
    },
    approvedAmount: {
      type: DataTypes.DECIMAL(12, 2),
      allowNull: true
    },
    rejectionReason: {
      type: DataTypes.STRING,
      allowNull: true
    }
  }, {
    tableName: 'claim_line_items',
    underscored: true,
    timestamps: true,
    indexes: [
      { fields: ['claim_id'] },
      { fields: ['code'] }
    ]
  });

  ClaimLineItem.prototype.recalculate = function() {
    this.total = (parseFloat(this.quantity) || 1) * (parseFloat(this.unitPrice) || 0);
  };

  return ClaimLineItem;
};
