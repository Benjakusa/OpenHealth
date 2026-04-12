const { Op } = require('sequelize');
const { Billing, Encounter, Patient, Tenant } = require('../database');

class BillingController {
  async list(req, res) {
    try {
      const { 
        page = 1, 
        limit = 50, 
        status,
        patientId,
        type,
        startDate,
        endDate,
        sortBy = 'createdAt',
        sortOrder = 'DESC'
      } = req.query;

      const where = { tenantId: req.user.tenantId };
      
      if (status) where.status = status;
      if (patientId) where.patientId = patientId;
      if (type) where.type = type;

      if (startDate || endDate) {
        where.createdAt = {};
        if (startDate) where.createdAt[Op.gte] = new Date(startDate);
        if (endDate) where.createdAt[Op.lte] = new Date(endDate);
      }

      const offset = (page - 1) * limit;
      const { count, rows: billing } = await Billing.findAndCountAll({
        where,
        include: [
          { model: Patient, as: 'patient', attributes: ['id', 'patientNumber', 'firstName', 'lastName', 'phone'] },
          { model: Encounter, as: 'encounter', attributes: ['id', 'encounterNumber', 'status'] }
        ],
        limit: parseInt(limit),
        offset,
        order: [[sortBy, sortOrder]]
      });

      res.json({
        data: billing,
        pagination: {
          total: count,
          page: parseInt(page),
          limit: parseInt(limit),
          pages: Math.ceil(count / limit)
        }
      });
    } catch (error) {
      console.error('List billing error:', error);
      res.status(500).json({ error: 'Internal server error' });
    }
  }

  async get(req, res) {
    try {
      const invoice = await Billing.findOne({
        where: { id: req.params.id, tenantId: req.user.tenantId },
        include: [
          { model: Patient, as: 'patient' },
          { model: Encounter, as: 'encounter' }
        ]
      });

      if (!invoice) {
        return res.status(404).json({ error: 'Invoice not found' });
      }

      res.json(invoice);
    } catch (error) {
      console.error('Get billing error:', error);
      res.status(500).json({ error: 'Internal server error' });
    }
  }

  async create(req, res) {
    try {
      const tenant = await Tenant.findByPk(req.user.tenantId);
      if (!tenant) {
        return res.status(404).json({ error: 'Tenant not found' });
      }

      const invoiceData = {
        ...req.body,
        tenantId: req.user.tenantId,
        invoiceNumber: Billing.generateInvoiceNumber(tenant.slug, req.body.type || 'INV')
      };

      const invoice = await Billing.create(invoiceData);

      res.status(201).json({
        message: 'Invoice created successfully',
        invoice
      });
    } catch (error) {
      console.error('Create billing error:', error);
      res.status(500).json({ error: 'Internal server error' });
    }
  }

  async update(req, res) {
    try {
      const invoice = await Billing.findOne({
        where: { id: req.params.id, tenantId: req.user.tenantId }
      });

      if (!invoice) {
        return res.status(404).json({ error: 'Invoice not found' });
      }

      if (invoice.status === 'paid') {
        return res.status(403).json({ error: 'Cannot modify paid invoice' });
      }

      await invoice.update(req.body);

      res.json({
        message: 'Invoice updated successfully',
        invoice
      });
    } catch (error) {
      console.error('Update billing error:', error);
      res.status(500).json({ error: 'Internal server error' });
    }
  }

  async addItem(req, res) {
    try {
      const invoice = await Billing.findOne({
        where: { id: req.params.id, tenantId: req.user.tenantId }
      });

      if (!invoice) {
        return res.status(404).json({ error: 'Invoice not found' });
      }

      const result = invoice.addItem(req.body);
      if (result.error) {
        return res.status(400).json({ error: result.error, existingIndex: result.index });
      }

      await invoice.save();

      res.json({
        message: 'Item added successfully',
        items: invoice.items,
        subtotal: invoice.subtotal,
        total: invoice.total
      });
    } catch (error) {
      console.error('Add billing item error:', error);
      res.status(500).json({ error: 'Internal server error' });
    }
  }

  async removeItem(req, res) {
    try {
      const invoice = await Billing.findOne({
        where: { id: req.params.id, tenantId: req.user.tenantId }
      });

      if (!invoice) {
        return res.status(404).json({ error: 'Invoice not found' });
      }

      const removed = invoice.removeItem(req.params.itemId);
      if (!removed) {
        return res.status(404).json({ error: 'Item not found' });
      }

      await invoice.save();

      res.json({
        message: 'Item removed successfully',
        items: invoice.items,
        subtotal: invoice.subtotal,
        total: invoice.total
      });
    } catch (error) {
      console.error('Remove billing item error:', error);
      res.status(500).json({ error: 'Internal server error' });
    }
  }

  async addPayment(req, res) {
    try {
      const invoice = await Billing.findOne({
        where: { id: req.params.id, tenantId: req.user.tenantId }
      });

      if (!invoice) {
        return res.status(404).json({ error: 'Invoice not found' });
      }

      invoice.addPayment({
        ...req.body,
        receivedBy: req.user.userId
      });

      await invoice.save();

      res.json({
        message: 'Payment recorded successfully',
        invoice
      });
    } catch (error) {
      console.error('Add payment error:', error);
      res.status(500).json({ error: 'Internal server error' });
    }
  }

  async calculate(req, res) {
    try {
      const invoice = await Billing.findOne({
        where: { id: req.params.id, tenantId: req.user.tenantId }
      });

      if (!invoice) {
        return res.status(404).json({ error: 'Invoice not found' });
      }

      const patient = await Patient.findOne({
        where: { id: invoice.patientId, tenantId: req.user.tenantId }
      });

      const shaCover = req.body.shaCover || (patient?.sha?.coveragePercent || 0);
      const insuranceDetails = req.body.insurance || patient?.insurance;

      const breakdown = invoice.calculatePatientResponsibility(shaCover, insuranceDetails);

      await invoice.save();

      res.json({
        subtotal: invoice.subtotal,
        discount: invoice.discount,
        tax: invoice.tax,
        total: invoice.total,
        shaCover: breakdown.shaCover,
        insuranceCover: breakdown.insuranceCover,
        patientPay: breakdown.patientPay,
        balance: invoice.balance
      });
    } catch (error) {
      console.error('Calculate billing error:', error);
      res.status(500).json({ error: 'Internal server error' });
    }
  }

  async waive(req, res) {
    try {
      const invoice = await Billing.findOne({
        where: { id: req.params.id, tenantId: req.user.tenantId }
      });

      if (!invoice) {
        return res.status(404).json({ error: 'Invoice not found' });
      }

      if (req.user.role !== 'FACILITY_ADMIN' && req.user.role !== 'SUPER_ADMIN') {
        return res.status(403).json({ error: 'Only administrators can approve waivers' });
      }

      invoice.waiver = {
        amount: req.body.amount,
        reason: req.body.reason,
        approvedBy: req.user.userId,
        approvedAt: new Date()
      };

      invoice.discount = invoice.discount + req.body.amount;
      invoice.recalculate();

      if (invoice.balance <= 0) {
        invoice.status = 'waived';
      }

      await invoice.save();

      res.json({
        message: 'Waiver approved',
        invoice
      });
    } catch (error) {
      console.error('Waive billing error:', error);
      res.status(500).json({ error: 'Internal server error' });
    }
  }
}

module.exports = new BillingController();
