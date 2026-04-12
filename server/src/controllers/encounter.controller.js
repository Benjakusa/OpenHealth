const { Op } = require('sequelize');
const { Encounter, Patient, User, Tenant, Billing } = require('../database');

class EncounterController {
  async list(req, res) {
    try {
      const { 
        page = 1, 
        limit = 50, 
        status,
        patientId,
        providerId,
        department,
        startDate,
        endDate,
        priority,
        sortBy = 'createdAt',
        sortOrder = 'DESC'
      } = req.query;

      const where = { tenantId: req.user.tenantId };
      
      if (status) where.status = status;
      if (patientId) where.patientId = patientId;
      if (providerId) where.providerId = providerId;
      if (department) where.department = department;
      if (priority) where.priority = priority;

      if (startDate || endDate) {
        where.startedAt = {};
        if (startDate) where.startedAt[Op.gte] = new Date(startDate);
        if (endDate) where.startedAt[Op.lte] = new Date(endDate);
      }

      const offset = (page - 1) * limit;
      const { count, rows: encounters } = await Encounter.findAndCountAll({
        where,
        include: [
          { model: Patient, as: 'patient', attributes: ['id', 'patientNumber', 'firstName', 'lastName', 'phone', 'dateOfBirth', 'gender'] },
          { model: User, as: 'provider', attributes: ['id', 'firstName', 'lastName', 'specialty'] }
        ],
        limit: parseInt(limit),
        offset,
        order: [[sortBy, sortOrder]]
      });

      res.json({
        data: encounters,
        pagination: {
          total: count,
          page: parseInt(page),
          limit: parseInt(limit),
          pages: Math.ceil(count / limit)
        }
      });
    } catch (error) {
      console.error('List encounters error:', error);
      res.status(500).json({ error: 'Internal server error' });
    }
  }

  async get(req, res) {
    try {
      const encounter = await Encounter.findOne({
        where: { id: req.params.id, tenantId: req.user.tenantId },
        include: [
          { model: Patient, as: 'patient' },
          { model: User, as: 'provider', attributes: ['id', 'firstName', 'lastName', 'specialty', 'role'] }
        ]
      });

      if (!encounter) {
        return res.status(404).json({ error: 'Encounter not found' });
      }

      res.json(encounter);
    } catch (error) {
      console.error('Get encounter error:', error);
      res.status(500).json({ error: 'Internal server error' });
    }
  }

  async create(req, res) {
    try {
      const tenant = await Tenant.findByPk(req.user.tenantId);
      if (!tenant) {
        return res.status(404).json({ error: 'Tenant not found' });
      }

      const patient = await Patient.findOne({
        where: { id: req.body.patientId, tenantId: req.user.tenantId }
      });

      if (!patient) {
        return res.status(404).json({ error: 'Patient not found' });
      }

      const encounterData = {
        ...req.body,
        tenantId: req.user.tenantId,
        encounterNumber: Encounter.generateEncounterNumber(tenant.slug),
        providerId: req.body.providerId || req.user.userId,
        status: 'pending_triage',
        startedAt: new Date()
      };

      const encounter = await Encounter.create(encounterData);

      const billing = await Billing.create({
        tenantId: req.user.tenantId,
        invoiceNumber: Billing.generateInvoiceNumber(tenant.slug, 'ENC'),
        encounterId: encounter.id,
        patientId: encounter.patientId,
        type: 'consultation',
        status: 'draft'
      });

      await billing.addItem({
        code: 'REG-FEE',
        description: 'Registration Fee',
        amount: req.body.registrationFee || 0,
        category: 'registration'
      });

      res.status(201).json({
        message: 'Encounter created successfully',
        encounter,
        billing: billing.id
      });
    } catch (error) {
      console.error('Create encounter error:', error);
      res.status(500).json({ error: 'Internal server error' });
    }
  }

  async update(req, res) {
    try {
      const encounter = await Encounter.findOne({
        where: { id: req.params.id, tenantId: req.user.tenantId }
      });

      if (!encounter) {
        return res.status(404).json({ error: 'Encounter not found' });
      }

      if (encounter.isLocked && !req.body.unlock) {
        return res.status(403).json({ error: 'Encounter is locked' });
      }

      await encounter.update(req.body);

      res.json({
        message: 'Encounter updated successfully',
        encounter
      });
    } catch (error) {
      console.error('Update encounter error:', error);
      res.status(500).json({ error: 'Internal server error' });
    }
  }

  async addTriage(req, res) {
    try {
      const encounter = await Encounter.findOne({
        where: { id: req.params.id, tenantId: req.user.tenantId }
      });

      if (!encounter) {
        return res.status(404).json({ error: 'Encounter not found' });
      }

      const triage = {
        ...req.body,
        recordedBy: req.user.userId,
        recordedAt: new Date()
      };

      encounter.triage = triage;
      encounter.vitals = req.body.vitals || encounter.vitals;
      encounter.status = 'pending_doctor';

      if (triage.category === 'emergency') {
        encounter.priority = 'emergency';
      }

      await encounter.save();

      const billing = await Billing.findOne({
        where: { encounterId: encounter.id, tenantId: req.user.tenantId }
      });

      if (billing && req.body.triageFee > 0) {
        await billing.addItem({
          code: 'TRIAGE',
          description: 'Triage/Nursing Assessment',
          amount: req.body.triageFee,
          category: 'triage'
        });
      }

      res.json({
        message: 'Triage added successfully',
        encounter
      });
    } catch (error) {
      console.error('Add triage error:', error);
      res.status(500).json({ error: 'Internal server error' });
    }
  }

  async addSoap(req, res) {
    try {
      const encounter = await Encounter.findOne({
        where: { id: req.params.id, tenantId: req.user.tenantId }
      });

      if (!encounter) {
        return res.status(404).json({ error: 'Encounter not found' });
      }

      const soap = {
        ...req.body,
        enteredBy: req.user.userId,
        enteredAt: new Date()
      };

      encounter.soap = {
        ...encounter.soap,
        ...soap
      };
      encounter.status = 'in_progress';
      encounter.chiefComplaint = soap.chiefComplaint || encounter.chiefComplaint;

      await encounter.save();

      res.json({
        message: 'SOAP notes added successfully',
        encounter
      });
    } catch (error) {
      console.error('Add SOAP error:', error);
      res.status(500).json({ error: 'Internal server error' });
    }
  }

  async addDiagnosis(req, res) {
    try {
      const encounter = await Encounter.findOne({
        where: { id: req.params.id, tenantId: req.user.tenantId }
      });

      if (!encounter) {
        return res.status(404).json({ error: 'Encounter not found' });
      }

      const diagnoses = encounter.diagnoses || [];
      diagnoses.push({
        ...req.body,
        diagnosedBy: req.user.userId,
        diagnosedAt: new Date()
      });

      encounter.diagnoses = diagnoses;
      await encounter.save();

      res.json({
        message: 'Diagnosis added successfully',
        diagnoses: encounter.diagnoses
      });
    } catch (error) {
      console.error('Add diagnosis error:', error);
      res.status(500).json({ error: 'Internal server error' });
    }
  }

  async addPrescription(req, res) {
    try {
      const encounter = await Encounter.findOne({
        where: { id: req.params.id, tenantId: req.user.tenantId }
      });

      if (!encounter) {
        return res.status(404).json({ error: 'Encounter not found' });
      }

      const prescriptions = encounter.prescriptions || [];
      prescriptions.push({
        ...req.body,
        prescribedBy: req.user.userId,
        prescribedAt: new Date(),
        status: 'pending'
      });

      encounter.prescriptions = prescriptions;
      await encounter.save();

      const billing = await Billing.findOne({
        where: { encounterId: encounter.id, tenantId: req.user.tenantId }
      });

      if (billing && req.body.unitPrice && req.body.quantity) {
        await billing.addItem({
          code: req.body.drugCode || 'DRUG',
          description: `${req.body.drugName} ${req.body.formulation || ''} ${req.body.strength || ''}`,
          amount: req.body.unitPrice * req.body.quantity,
          category: 'pharmacy',
          drugId: req.body.drugId
        });
      }

      res.json({
        message: 'Prescription added successfully',
        prescriptions: encounter.prescriptions
      });
    } catch (error) {
      console.error('Add prescription error:', error);
      res.status(500).json({ error: 'Internal server error' });
    }
  }

  async addLabOrder(req, res) {
    try {
      const encounter = await Encounter.findOne({
        where: { id: req.params.id, tenantId: req.user.tenantId }
      });

      if (!encounter) {
        return res.status(404).json({ error: 'Encounter not found' });
      }

      const labOrders = encounter.labOrders || [];
      labOrders.push({
        ...req.body,
        orderedBy: req.user.userId,
        orderedAt: new Date(),
        status: 'pending'
      });

      encounter.labOrders = labOrders;
      await encounter.save();

      const billing = await Billing.findOne({
        where: { encounterId: encounter.id, tenantId: req.user.tenantId }
      });

      if (billing && req.body.price) {
        await billing.addItem({
          code: req.body.testCode || 'LAB',
          description: req.body.testName,
          amount: req.body.price,
          category: 'laboratory'
        });
      }

      res.json({
        message: 'Lab order added successfully',
        labOrders: encounter.labOrders
      });
    } catch (error) {
      console.error('Add lab order error:', error);
      res.status(500).json({ error: 'Internal server error' });
    }
  }

  async complete(req, res) {
    try {
      const encounter = await Encounter.findOne({
        where: { id: req.params.id, tenantId: req.user.tenantId }
      });

      if (!encounter) {
        return res.status(404).json({ error: 'Encounter not found' });
      }

      encounter.status = 'completed';
      encounter.completedAt = new Date();
      encounter.isLocked = true;
      encounter.lockedAt = new Date();
      encounter.lockedBy = req.user.userId;
      encounter.duration = encounter.getDuration();

      if (req.body.disposition) {
        encounter.disposition = req.body.disposition;
        if (req.body.disposition.action === 'admit') {
          encounter.status = 'admitted';
        } else if (req.body.disposition.action === 'refer') {
          encounter.status = 'referred';
        }
      }

      await encounter.save();

      const billing = await Billing.findOne({
        where: { encounterId: encounter.id, tenantId: req.user.tenantId }
      });

      if (billing) {
        billing.status = 'awaiting_payment';
        await billing.save();
      }

      res.json({
        message: 'Encounter completed successfully',
        encounter
      });
    } catch (error) {
      console.error('Complete encounter error:', error);
      res.status(500).json({ error: 'Internal server error' });
    }
  }

  async refer(req, res) {
    try {
      const encounter = await Encounter.findOne({
        where: { id: req.params.id, tenantId: req.user.tenantId }
      });

      if (!encounter) {
        return res.status(404).json({ error: 'Encounter not found' });
      }

      const referrals = encounter.referrals || [];
      referrals.push({
        ...req.body,
        referredBy: req.user.userId,
        referredAt: new Date(),
        status: 'pending'
      });

      encounter.referrals = referrals;
      encounter.status = 'referred';
      encounter.disposition = {
        action: 'refer',
        ...req.body
      };

      await encounter.save();

      res.json({
        message: 'Referral created successfully',
        referrals: encounter.referrals
      });
    } catch (error) {
      console.error('Create referral error:', error);
      res.status(500).json({ error: 'Internal server error' });
    }
  }
}

module.exports = new EncounterController();
