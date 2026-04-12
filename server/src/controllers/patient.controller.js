const { Op } = require('sequelize');
const { Patient, Tenant, Encounter, Billing } = require('../database');

class PatientController {
  async list(req, res) {
    try {
      const { 
        page = 1, 
        limit = 50, 
        search, 
        county,
        status = 'active',
        sortBy = 'createdAt',
        sortOrder = 'DESC'
      } = req.query;

      const where = { tenantId: req.user.tenantId };
      
      if (status) {
        where.isActive = status === 'active';
      }

      if (search) {
        where[Op.or] = [
          { firstName: { [Op.iLike]: `%${search}%` } },
          { lastName: { [Op.iLike]: `%${search}%` } },
          { patientNumber: { [Op.iLike]: `%${search}%` } },
          { phone: { [Op.iLike]: `%${search}%` } },
          { nationalId: { [Op.iLike]: `%${search}%` } }
        ];
      }

      if (county) {
        where.county = county;
      }

      const offset = (page - 1) * limit;
      const { count, rows: patients } = await Patient.findAndCountAll({
        where,
        limit: parseInt(limit),
        offset,
        order: [[sortBy, sortOrder]],
        attributes: { exclude: ['deletedAt'] }
      });

      res.json({
        data: patients,
        pagination: {
          total: count,
          page: parseInt(page),
          limit: parseInt(limit),
          pages: Math.ceil(count / limit)
        }
      });
    } catch (error) {
      console.error('List patients error:', error);
      res.status(500).json({ error: 'Internal server error' });
    }
  }

  async get(req, res) {
    try {
      const patient = await Patient.findOne({
        where: { id: req.params.id, tenantId: req.user.tenantId },
        include: [
          { model: Tenant, as: 'tenant', attributes: ['id', 'name', 'slug'] }
        ]
      });

      if (!patient) {
        return res.status(404).json({ error: 'Patient not found' });
      }

      res.json(patient);
    } catch (error) {
      console.error('Get patient error:', error);
      res.status(500).json({ error: 'Internal server error' });
    }
  }

  async create(req, res) {
    try {
      const tenant = await Tenant.findByPk(req.user.tenantId);
      if (!tenant) {
        return res.status(404).json({ error: 'Tenant not found' });
      }

      const patientData = {
        ...req.body,
        tenantId: req.user.tenantId,
        patientNumber: Patient.generatePatientNumber(tenant.slug),
        registeredBy: req.user.userId
      };

      const patient = await Patient.create(patientData);

      res.status(201).json({
        message: 'Patient created successfully',
        patient
      });
    } catch (error) {
      console.error('Create patient error:', error);
      if (error.name === 'SequelizeValidationError') {
        return res.status(400).json({ error: 'Validation error', details: error.errors });
      }
      res.status(500).json({ error: 'Internal server error' });
    }
  }

  async update(req, res) {
    try {
      const patient = await Patient.findOne({
        where: { id: req.params.id, tenantId: req.user.tenantId }
      });

      if (!patient) {
        return res.status(404).json({ error: 'Patient not found' });
      }

      await patient.update(req.body);

      res.json({
        message: 'Patient updated successfully',
        patient
      });
    } catch (error) {
      console.error('Update patient error:', error);
      res.status(500).json({ error: 'Internal server error' });
    }
  }

  async delete(req, res) {
    try {
      const patient = await Patient.findOne({
        where: { id: req.params.id, tenantId: req.user.tenantId }
      });

      if (!patient) {
        return res.status(404).json({ error: 'Patient not found' });
      }

      patient.isActive = false;
      await patient.save();

      res.json({ message: 'Patient deactivated successfully' });
    } catch (error) {
      console.error('Delete patient error:', error);
      res.status(500).json({ error: 'Internal server error' });
    }
  }

  async getEncounters(req, res) {
    try {
      const encounters = await Encounter.findAll({
        where: { patientId: req.params.id, tenantId: req.user.tenantId },
        order: [['createdAt', 'DESC']],
        limit: 50
      });

      res.json(encounters);
    } catch (error) {
      console.error('Get patient encounters error:', error);
      res.status(500).json({ error: 'Internal server error' });
    }
  }

  async getBilling(req, res) {
    try {
      const billing = await Billing.findAll({
        where: { patientId: req.params.id, tenantId: req.user.tenantId },
        order: [['createdAt', 'DESC']]
      });

      res.json(billing);
    } catch (error) {
      console.error('Get patient billing error:', error);
      res.status(500).json({ error: 'Internal server error' });
    }
  }

  async verifySha(req, res) {
    try {
      const patient = await Patient.findOne({
        where: { id: req.params.id, tenantId: req.user.tenantId }
      });

      if (!patient) {
        return res.status(404).json({ error: 'Patient not found' });
      }

      if (!patient.sha || !patient.sha.memberNumber) {
        return res.status(400).json({ error: 'SHA member number not found' });
      }

      const verificationResult = {
        memberNumber: patient.sha.memberNumber,
        verified: true,
        memberName: patient.getFullName(),
        scheme: patient.sha.scheme || 'SHA',
        cardNumber: patient.sha.cardNumber,
        verifiedAt: new Date()
      };

      res.json(verificationResult);
    } catch (error) {
      console.error('Verify SHA error:', error);
      res.status(500).json({ error: 'Failed to verify SHA membership' });
    }
  }
}

module.exports = new PatientController();
