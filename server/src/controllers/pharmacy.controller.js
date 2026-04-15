const { Op } = require('sequelize');
const { Inventory, Billing, Patient, Prescription, Encounter } = require('../database');
const { v4: uuidv4 } = require('uuid');

class PharmacyController {
  async listPrescriptions(req, res) {
    try {
      const { page = 1, limit = 50, status, patientId, prescriberId } = req.query;

      const where = { tenantId: req.user.tenantId };
      if (status) where.status = status;
      if (patientId) where.patientId = patientId;
      if (prescriberId) where.prescriberId = prescriberId;

      const offset = (page - 1) * limit;
      const { count, rows: prescriptions } = await Prescription.findAndCountAll({
        where,
        include: [
          { model: Patient, as: 'patient', attributes: ['id', 'patientNumber', 'firstName', 'lastName', 'phone', 'dateOfBirth'] },
          { model: Encounter, as: 'encounter', attributes: ['id', 'encounterNumber'] },
          { model: require('../database').User, as: 'prescriber', attributes: ['id', 'name', 'email'] }
        ],
        limit: parseInt(limit),
        offset,
        order: [['createdAt', 'DESC']]
      });

      const formattedPrescriptions = prescriptions.map(p => ({
        ...p.toJSON(),
        patient: p.patient ? {
          id: p.patient.id,
          name: `${p.patient.firstName} ${p.patient.lastName}`,
          patientNumber: p.patient.patientNumber,
          phone: p.patient.phone,
          age: p.patient.dateOfBirth ? Math.floor((new Date() - new Date(p.patient.dateOfBirth)) / (365.25 * 24 * 60 * 60 * 1000)) : null
        } : null
      }));

      res.json({
        prescriptions: formattedPrescriptions,
        pagination: {
          total: count,
          page: parseInt(page),
          limit: parseInt(limit),
          pages: Math.ceil(count / limit)
        }
      });
    } catch (error) {
      console.error('List prescriptions error:', error);
      res.status(500).json({ error: 'Internal server error' });
    }
  }

  async getPrescription(req, res) {
    try {
      const prescription = await Prescription.findOne({
        where: { id: req.params.id, tenantId: req.user.tenantId },
        include: [
          { model: Patient, as: 'patient' },
          { model: Encounter, as: 'encounter' },
          { model: require('../database').User, as: 'prescriber', attributes: ['id', 'name', 'email'] }
        ]
      });

      if (!prescription) {
        return res.status(404).json({ error: 'Prescription not found' });
      }

      res.json(prescription);
    } catch (error) {
      console.error('Get prescription error:', error);
      res.status(500).json({ error: 'Internal server error' });
    }
  }

  async createPrescription(req, res) {
    try {
      const tenant = await require('../database').Tenant.findByPk(req.user.tenantId);
      if (!tenant) {
        return res.status(404).json({ error: 'Tenant not found' });
      }

      const prescription = await Prescription.create({
        tenantId: req.user.tenantId,
        prescriptionNumber: Prescription.generatePrescriptionNumber(tenant.slug),
        patientId: req.body.patientId,
        encounterId: req.body.encounterId,
        prescriberId: req.user.userId,
        status: 'pending',
        items: req.body.items.map(item => ({
          ...item,
          id: uuidv4(),
          status: 'pending',
          dispensedQuantity: 0
        })),
        notes: req.body.notes,
        diagnosis: req.body.diagnosis,
        urgent: req.body.urgent || false,
        expiresAt: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000)
      });

      res.status(201).json({
        message: 'Prescription created successfully',
        prescription
      });
    } catch (error) {
      console.error('Create prescription error:', error);
      res.status(500).json({ error: 'Internal server error' });
    }
  }

  async updatePrescription(req, res) {
    try {
      const prescription = await Prescription.findOne({
        where: { id: req.params.id, tenantId: req.user.tenantId }
      });

      if (!prescription) {
        return res.status(404).json({ error: 'Prescription not found' });
      }

      if (req.body.status) prescription.status = req.body.status;
      if (req.body.notes !== undefined) prescription.notes = req.body.notes;
      if (req.body.holdReason !== undefined) prescription.holdReason = req.body.holdReason;

      await prescription.save();

      res.json({
        message: 'Prescription updated successfully',
        prescription
      });
    } catch (error) {
      console.error('Update prescription error:', error);
      res.status(500).json({ error: 'Internal server error' });
    }
  }

  async dispensePrescription(req, res) {
    try {
      const prescription = await Prescription.findOne({
        where: { id: req.params.id, tenantId: req.user.tenantId }
      });

      if (!prescription) {
        return res.status(404).json({ error: 'Prescription not found' });
      }

      if (prescription.status === 'dispensed') {
        return res.status(400).json({ error: 'Prescription already dispensed' });
      }

      if (prescription.status === 'cancelled') {
        return res.status(400).json({ error: 'Prescription was cancelled' });
      }

      if (prescription.isExpired()) {
        prescription.status = 'expired';
        await prescription.save();
        return res.status(400).json({ error: 'Prescription has expired' });
      }

      const dispenseItems = req.body.items || [];
      let totalAmount = 0;
      const dispenseRecords = [];
      let hasPartialDispense = false;

      for (const item of dispenseItems) {
        const inventoryItem = await Inventory.findOne({
          where: { id: item.drugId, tenantId: req.user.tenantId }
        });

        if (!inventoryItem) {
          return res.status(404).json({ error: `Drug not found: ${item.drugId}` });
        }

        const result = inventoryItem.deductFromBatch(item.quantity, item.batchId);
        if (!result.success) {
          return res.status(400).json({ error: `Insufficient stock for ${inventoryItem.name}` });
        }

        await inventoryItem.save();

        inventoryItem.recordMovement({
          type: 'dispense',
          quantity: item.quantity,
          batches: result.deductions,
          patientId: prescription.patientId,
          encounterId: prescription.encounterId,
          prescriptionId: prescription.id,
          performedBy: req.user.userId,
          notes: req.body.notes
        });

        const itemAmount = item.quantity * item.unitPrice;
        totalAmount += itemAmount;

        dispenseRecords.push({
          prescriptionItemId: item.prescriptionItemId,
          drugId: item.drugId,
          drugName: inventoryItem.name,
          drugCode: inventoryItem.itemCode,
          quantity: item.quantity,
          unitPrice: item.unitPrice,
          amount: itemAmount,
          batchId: item.batchId,
          isSubstituted: item.isSubstituted || false,
          substitutionNote: item.substitutionNote
        });
      }

      let billingId = null;
      if (req.body.createBilling !== false && totalAmount > 0) {
        let billing = await Billing.findOne({
          where: {
            encounterId: prescription.encounterId,
            status: { [Op.in]: ['draft', 'pending'] }
          }
        });

        if (!billing) {
          billing = await Billing.create({
            tenantId: req.user.tenantId,
            invoiceNumber: Billing.generateInvoiceNumber(req.user.tenantSlug, 'RX'),
            patientId: prescription.patientId,
            encounterId: prescription.encounterId,
            type: 'pharmacy',
            status: 'pending',
            department: 'pharmacy'
          });
        }

        for (const record of dispenseRecords) {
          const addResult = billing.addItem({
            code: record.drugCode,
            description: record.drugName,
            quantity: record.quantity,
            unitPrice: record.unitPrice,
            amount: record.amount,
            category: 'pharmacy',
            department: 'pharmacy'
          });

          if (addResult && addResult.error) {
            console.warn(`Item already exists: ${record.drugName}`);
          }
        }

        await billing.save();
        billingId = billing.id;
      }

      prescription.dispensedAt = new Date();
      prescription.dispensedBy = req.user.userId;
      prescription.dispenseRecords = dispenseRecords;

      for (const item of dispenseItems) {
        const prescriptionItem = prescription.items.find(i => i.id === item.prescriptionItemId);
        if (prescriptionItem) {
          prescriptionItem.status = 'dispensed';
          prescriptionItem.dispensedQuantity = item.quantity;
          prescriptionItem.batchId = item.batchId;
          prescriptionItem.dispensedAt = new Date();
        }
      }

      const pendingItems = prescription.items.filter(i => i.status !== 'dispensed');
      if (pendingItems.length > 0) {
        prescription.status = 'partially_dispensed';
        hasPartialDispense = true;
      } else {
        prescription.status = 'dispensed';
      }

      await prescription.save();

      res.json({
        message: hasPartialDispense ? 'Prescription partially dispensed' : 'Prescription dispensed successfully',
        dispenseId: uuidv4(),
        prescriptionId: prescription.id,
        billingId,
        totalAmount,
        items: dispenseRecords,
        dispensedAt: prescription.dispensedAt,
        partiallyDispensed: hasPartialDispense
      });
    } catch (error) {
      console.error('Dispense prescription error:', error);
      res.status(500).json({ error: 'Internal server error' });
    }
  }

  async cancelPrescription(req, res) {
    try {
      const prescription = await Prescription.findOne({
        where: { id: req.params.id, tenantId: req.user.tenantId }
      });

      if (!prescription) {
        return res.status(404).json({ error: 'Prescription not found' });
      }

      if (prescription.status === 'dispensed') {
        return res.status(400).json({ error: 'Cannot cancel dispensed prescription' });
      }

      prescription.status = 'cancelled';
      prescription.cancelledAt = new Date();
      prescription.cancelledBy = req.user.userId;
      prescription.cancellationReason = req.body.reason;

      await prescription.save();

      res.json({
        message: 'Prescription cancelled successfully',
        prescription
      });
    } catch (error) {
      console.error('Cancel prescription error:', error);
      res.status(500).json({ error: 'Internal server error' });
    }
  }
}

module.exports = new PharmacyController();
