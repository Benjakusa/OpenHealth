const { Inventory } = require('../database');

class InventoryController {
  async list(req, res) {
    try {
      const { page = 1, limit = 50, category, status, search, lowStock } = req.query;

      const where = { tenantId: req.user.tenantId };
      if (category) where.category = category;
      if (status) where.status = status;
      if (search) {
        where[require('sequelize').Op.or] = [
          { name: { [require('sequelize').Op.iLike]: `%${search}%` } },
          { itemCode: { [require('sequelize').Op.iLike]: `%${search}%` } },
          { genericName: { [require('sequelize').Op.iLike]: `%${search}%` } }
        ];
      }

      const offset = (page - 1) * limit;
      let { count, rows: inventory } = await Inventory.findAndCountAll({
        where,
        limit: parseInt(limit),
        offset,
        order: [['name', 'ASC']]
      });

      if (lowStock === 'true') {
        inventory = inventory.filter(item => item.needsReorder());
        count = inventory.length;
      }

      res.json({
        data: inventory,
        pagination: {
          total: count,
          page: parseInt(page),
          limit: parseInt(limit),
          pages: Math.ceil(count / limit)
        }
      });
    } catch (error) {
      console.error('List inventory error:', error);
      res.status(500).json({ error: 'Internal server error' });
    }
  }

  async get(req, res) {
    try {
      const item = await Inventory.findOne({
        where: { id: req.params.id, tenantId: req.user.tenantId }
      });

      if (!item) {
        return res.status(404).json({ error: 'Item not found' });
      }

      res.json(item);
    } catch (error) {
      console.error('Get inventory error:', error);
      res.status(500).json({ error: 'Internal server error' });
    }
  }

  async create(req, res) {
    try {
      const item = await Inventory.create({
        ...req.body,
        tenantId: req.user.tenantId
      });

      res.status(201).json({
        message: 'Item created successfully',
        item
      });
    } catch (error) {
      console.error('Create inventory error:', error);
      res.status(500).json({ error: 'Internal server error' });
    }
  }

  async update(req, res) {
    try {
      const item = await Inventory.findOne({
        where: { id: req.params.id, tenantId: req.user.tenantId }
      });

      if (!item) {
        return res.status(404).json({ error: 'Item not found' });
      }

      await item.update(req.body);

      res.json({
        message: 'Item updated successfully',
        item
      });
    } catch (error) {
      console.error('Update inventory error:', error);
      res.status(500).json({ error: 'Internal server error' });
    }
  }

  async addBatch(req, res) {
    try {
      const item = await Inventory.findOne({
        where: { id: req.params.id, tenantId: req.user.tenantId }
      });

      if (!item) {
        return res.status(404).json({ error: 'Item not found' });
      }

      item.addBatch({
        ...req.body,
        receivedBy: req.user.userId
      });

      item.recordMovement({
        type: 'receive',
        quantity: req.body.quantity,
        batchNumber: req.body.batchNumber,
        costPrice: req.body.costPrice,
        supplier: req.body.supplier,
        reference: req.body.grnNumber,
        performedBy: req.user.userId
      });

      await item.save();

      res.json({
        message: 'Batch added successfully',
        item
      });
    } catch (error) {
      console.error('Add batch error:', error);
      res.status(500).json({ error: 'Internal server error' });
    }
  }

  async dispense(req, res) {
    try {
      const item = await Inventory.findOne({
        where: { id: req.params.id, tenantId: req.user.tenantId }
      });

      if (!item) {
        return res.status(404).json({ error: 'Item not found' });
      }

      const result = item.deductFromBatch(req.body.quantity, req.body.batchNumber);

      if (!result.success) {
        return res.status(400).json({ error: result.message, remaining: result.remaining });
      }

      item.recordMovement({
        type: 'dispense',
        quantity: req.body.quantity,
        batches: result.deductions,
        patientId: req.body.patientId,
        encounterId: req.body.encounterId,
        prescriptionId: req.body.prescriptionId,
        performedBy: req.user.userId,
        notes: req.body.notes
      });

      if (item.needsReorder()) {
        item.status = 'active';
      }

      await item.save();

      res.json({
        message: 'Dispensed successfully',
        item,
        deductions: result.deductions
      });
    } catch (error) {
      console.error('Dispense error:', error);
      res.status(500).json({ error: 'Internal server error' });
    }
  }

  async getLowStockAlerts(req, res) {
    try {
      const items = await Inventory.findAll({
        where: { tenantId: req.user.tenantId, status: { [require('sequelize').Op.ne]: 'discontinued' } }
      });

      const lowStock = items.filter(item => item.needsReorder());

      res.json({
        alerts: lowStock.map(item => ({
          id: item.id,
          name: item.name,
          itemCode: item.itemCode,
          currentQuantity: item.quantity,
          reorderLevel: item.reorderLevel,
          reorderQuantity: item.reorderQuantity
        })),
        count: lowStock.length
      });
    } catch (error) {
      console.error('Get low stock alerts error:', error);
      res.status(500).json({ error: 'Internal server error' });
    }
  }

  async getExpiringAlerts(req, res) {
    try {
      const { days = 90 } = req.query;

      const items = await Inventory.findAll({
        where: { tenantId: req.user.tenantId, expiryTracking: true }
      });

      const expiring = items.flatMap(item => 
        item.isNearExpiry(parseInt(days)).map(batch => ({
          id: item.id,
          name: item.name,
          itemCode: item.itemCode,
          batchNumber: batch.batchNumber,
          expiryDate: batch.expiryDate,
          quantity: batch.quantity
        }))
      );

      res.json({
        alerts: expiring,
        count: expiring.length
      });
    } catch (error) {
      console.error('Get expiring alerts error:', error);
      res.status(500).json({ error: 'Internal server error' });
    }
  }
}

module.exports = new InventoryController();
