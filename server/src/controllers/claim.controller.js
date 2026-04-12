const { Op } = require('sequelize');
const db = require('../database');
const shaService = require('../services/integrations/sha.service');
const notificationService = require('../services/integrations/notification.service');

const Claim = db.Claim;
const ClaimLineItem = db.ClaimLineItem;
const Billing = db.Billing;
const InvoiceItem = db.InvoiceItem;
const Patient = db.Patient;
const InsurancePolicy = db.InsurancePolicy;
const Encounter = db.Encounter;
const User = db.User;

class ClaimController {
  async submitShaClaim(req, res) {
    try {
      const { invoiceId, encounterId, diagnosisCodes, procedureCodes, serviceItems, notes } = req.body;
      const tenantId = req.user?.tenantId;

      const invoice = await Billing.findOne({
        where: { id: invoiceId, tenantId },
        include: [
          { model: Patient, as: 'patient' },
          { 
            model: InvoiceItem, as: 'items',
            where: invoiceId ? {} : undefined,
            required: false
          }
        ]
      });

      if (!invoice) {
        return res.status(404).json({ error: 'Invoice not found' });
      }

      const patient = invoice.patient;
      const insurance = await InsurancePolicy.findOne({
        where: { patientId: patient.id, status: 'active' },
        order: [['createdAt', 'DESC']]
      });

      if (!insurance) {
        return res.status(400).json({ error: 'No active insurance found for patient' });
      }

      const practitioner = await User.findOne({
        where: { id: req.user.id, tenantId },
        attributes: ['id', 'firstName', 'lastName', 'licenceNumber', 'specialization']
      });

      let encounter;
      if (encounterId) {
        encounter = await Encounter.findOne({
          where: { id: encounterId, patientId: patient.id }
        });
      }

      const claimId = `CLM-${Date.now()}-${Math.random().toString(36).substr(2, 9).toUpperCase()}`;

      const claim = await Claim.create({
        tenantId,
        claimId,
        invoiceId: invoice.id,
        patientId: patient.id,
        insurancePolicyId: insurance.id,
        encounterId: encounter?.id,
        claimType: 'sha',
        status: 'draft',
        totalAmount: invoice.totalAmount,
        submittedAmount: invoice.totalAmount,
        createdBy: req.user.id
      });

      const items = serviceItems || invoice.items?.map(item => ({
        code: item.serviceCode || item.code,
        description: item.description || item.serviceName,
        quantity: item.quantity,
        unitPrice: item.unitPrice,
        total: item.total
      })) || [];

      for (const item of items) {
        await ClaimLineItem.create({
          claimId: claim.id,
          code: item.code,
          description: item.description,
          quantity: item.quantity,
          unitPrice: item.unitPrice,
          total: item.total,
          category: item.category || 'service'
        });
      }

      const claimData = {
        claimId,
        encounter: {
          id: encounter?.id,
          startTime: encounter?.startTime || invoice.createdAt,
          endTime: encounter?.endTime,
          status: encounter?.status || 'finished',
          encounterType: encounter?.visitType || 'outpatient',
          attendingPhysicianId: practitioner?.id,
          reasonCode: diagnosisCodes?.[0]?.code,
          reasonName: diagnosisCodes?.[0]?.description,
          reason: diagnosisCodes?.[0]?.description
        },
        patient: {
          id: patient.id,
          patientNumber: patient.patientNumber,
          firstName: patient.firstName,
          lastName: patient.lastName,
          middleName: patient.middleName,
          dateOfBirth: patient.dateOfBirth,
          gender: patient.gender,
          phone: patient.phone,
          email: patient.email,
          cardNumber: patient.shaCardNumber,
          address: patient.address
        },
        insurance: {
          id: insurance.id,
          patientId: patient.id,
          memberNumber: insurance.memberNumber,
          schemeType: insurance.schemeType,
          schemeName: insurance.schemeName,
          benefitPackage: insurance.benefitPackage,
          relationship: 'self'
        },
        practitioner: {
          id: practitioner?.id,
          firstName: practitioner?.firstName,
          lastName: practitioner?.lastName,
          licenceNumber: practitioner?.licenceNumber,
          specialization: practitioner?.specialization
        },
        diagnoses: diagnosisCodes || [],
        procedures: procedureCodes || [],
        medications: [],
        services: items,
        totalAmount: invoice.totalAmount
      };

      try {
        const shaResult = await shaService.submitClaim(claimData);

        claim.status = 'submitted';
        claim.externalReference = shaResult.bundleId;
        claim.submittedAt = new Date();
        await claim.save();

        invoice.claimStatus = 'submitted';
        invoice.claimReference = shaResult.bundleId;
        await invoice.save();

        notificationService.sendInsuranceClaimConfirmation(
          { ...patient.toJSON(), facilityName: req.tenant?.name },
          shaResult.bundleId
        ).catch(err => console.error('SMS notification error:', err));

        res.json({
          success: true,
          claimId: claim.id,
          claimReference: claim.claimId,
          shaReference: shaResult.bundleId,
          status: 'submitted',
          totalAmount: invoice.totalAmount
        });

      } catch (shaError) {
        console.error('SHA submission error:', shaError);

        claim.status = 'failed';
        claim.failureReason = shaError.errorMessage || shaError.message;
        await claim.save();

        res.status(400).json({
          error: 'Failed to submit to SHA',
          details: shaError.errorMessage,
          claimId: claim.id,
          claimReference: claim.claimId,
          status: 'draft'
        });
      }
    } catch (error) {
      console.error('Submit SHA claim error:', error);
      res.status(500).json({ error: 'Failed to submit claim' });
    }
  }

  async submitPreAuthorization(req, res) {
    try {
      const { invoiceId, services, notes } = req.body;
      const tenantId = req.user?.tenantId;

      const invoice = await Billing.findOne({
        where: { id: invoiceId, tenantId },
        include: [{ model: Patient, as: 'patient' }]
      });

      if (!invoice) {
        return res.status(404).json({ error: 'Invoice not found' });
      }

      const insurance = await InsurancePolicy.findOne({
        where: { patientId: invoice.patientId, status: 'active' }
      });

      if (!insurance) {
        return res.status(400).json({ error: 'No active insurance found' });
      }

      const practitioner = await User.findOne({
        where: { id: req.user.id }
      });

      const estimatedServices = services.map(s => ({
        code: s.code,
        description: s.description,
        quantity: s.quantity || 1,
        estimatedCost: s.estimatedCost || s.unitPrice
      }));

      const result = await shaService.submitPreAuthorization(
        { patientId: invoice.patientId },
        invoice.patient,
        estimatedServices,
        practitioner
      );

      const preAuthClaim = await Claim.create({
        tenantId,
        claimId: result.preAuthId,
        invoiceId: invoice.id,
        patientId: invoice.patientId,
        insurancePolicyId: insurance.id,
        claimType: 'pre_authorization',
        status: 'pending_approval',
        totalAmount: result.estimatedAmount,
        submittedAmount: result.estimatedAmount,
        externalReference: result.preAuthId,
        submittedAt: new Date(),
        createdBy: req.user.id
      });

      res.json({
        success: true,
        preAuthId: preAuthClaim.id,
        preAuthReference: result.preAuthId,
        status: 'pending',
        estimatedAmount: result.estimatedAmount
      });
    } catch (error) {
      console.error('Pre-authorization error:', error);
      res.status(500).json({ error: 'Failed to submit pre-authorization' });
    }
  }

  async checkClaimStatus(req, res) {
    try {
      const { claimReference } = req.params;
      const tenantId = req.user?.tenantId;

      const claim = await Claim.findOne({
        where: { claimId: claimReference, tenantId }
      });

      if (!claim) {
        return res.status(404).json({ error: 'Claim not found' });
      }

      if (!claim.externalReference) {
        return res.json({
          claimReference: claim.claimId,
          status: claim.status
        });
      }

      const shaStatus = await shaService.checkClaimStatus(claim.externalReference);

      claim.shaStatus = shaStatus.claim.status;
      claim.outcome = shaStatus.claim.outcome;
      claim.approvedAmount = shaStatus.claim.paidAmount;
      if (shaStatus.claim.status === 'active') {
        claim.status = 'approved';
      } else if (shaStatus.claim.status === 'cancelled') {
        claim.status = 'rejected';
      }
      await claim.save();

      res.json({
        claimReference: claim.claimId,
        shaReference: claim.externalReference,
        status: claim.status,
        shaStatus: shaStatus.claim.status,
        outcome: shaStatus.claim.outcome,
        approvedAmount: shaStatus.claim.paidAmount,
        totalAmount: claim.totalAmount
      });
    } catch (error) {
      console.error('Check claim status error:', error);
      res.status(500).json({ error: 'Failed to check claim status' });
    }
  }

  async verifyInsurance(req, res) {
    try {
      const { memberNumber, cardNumber, patientId } = req.body;

      let patient;
      if (patientId) {
        patient = await Patient.findByPk(patientId);
      }

      const result = await shaService.verifyMember(memberNumber, cardNumber);

      if (patient && result.valid) {
        notificationService.sendInsuranceVerification(patient, result).catch(err => console.error('SMS error:', err));
      }

      res.json({
        valid: result.valid,
        member: result.member,
        coverage: result.coverage,
        benefits: result.benefits
      });
    } catch (error) {
      console.error('Insurance verification error:', error);
      res.status(500).json({ error: 'Failed to verify insurance' });
    }
  }

  async getBenefits(req, res) {
    try {
      const { schemeId } = req.query;

      const result = await shaService.getBenefits(schemeId);

      res.json({
        success: true,
        benefits: result.benefits
      });
    } catch (error) {
      console.error('Get benefits error:', error);
      res.status(500).json({ error: 'Failed to fetch benefits' });
    }
  }

  async getClaims(req, res) {
    try {
      const { patientId, status, claimType, startDate, endDate, page = 1, limit = 20 } = req.query;
      const tenantId = req.user?.tenantId;

      const where = { tenantId };
      if (patientId) where.patientId = patientId;
      if (status) where.status = status;
      if (claimType) where.claimType = claimType;
      if (startDate || endDate) {
        where.createdAt = {};
        if (startDate) where.createdAt[Op.gte] = new Date(startDate);
        if (endDate) where.createdAt[Op.lte] = new Date(endDate + 'T23:59:59');
      }

      const { rows: claims, count } = await Claim.findAndCountAll({
        where,
        include: [
          { 
            model: Patient, 
            as: 'patient',
            attributes: ['id', 'patientNumber', 'firstName', 'lastName', 'phone']
          },
          { model: Billing, as: 'invoice', attributes: ['id', 'invoiceNumber', 'total'] }
        ],
        order: [['createdAt', 'DESC']],
        limit: parseInt(limit),
        offset: (parseInt(page) - 1) * parseInt(limit)
      });

      res.json({
        claims,
        pagination: {
          total: count,
          page: parseInt(page),
          limit: parseInt(limit),
          pages: Math.ceil(count / parseInt(limit))
        }
      });
    } catch (error) {
      console.error('Get claims error:', error);
      res.status(500).json({ error: 'Failed to fetch claims' });
    }
  }

  async getClaimById(req, res) {
    try {
      const { id } = req.params;
      const tenantId = req.user?.tenantId;

      const claim = await Claim.findOne({
        where: { id, tenantId },
        include: [
          { model: Patient, as: 'patient' },
          { model: Invoice, as: 'invoice' },
          { 
            model: ClaimLineItem, 
            as: 'lineItems',
            where: { claimId: id },
            required: false
          },
          { model: User, as: 'creator', attributes: ['id', 'firstName', 'lastName'] }
        ]
      });

      if (!claim) {
        return res.status(404).json({ error: 'Claim not found' });
      }

      res.json(claim);
    } catch (error) {
      console.error('Get claim error:', error);
      res.status(500).json({ error: 'Failed to fetch claim' });
    }
  }

  async updateClaimStatus(req, res) {
    try {
      const { id } = req.params;
      const { status, approvedAmount, rejectionReason } = req.body;
      const tenantId = req.user?.tenantId;

      const claim = await Claim.findOne({
        where: { id, tenantId }
      });

      if (!claim) {
        return res.status(404).json({ error: 'Claim not found' });
      }

      claim.status = status;
      if (approvedAmount !== undefined) claim.approvedAmount = approvedAmount;
      if (rejectionReason) claim.failureReason = rejectionReason;
      if (status === 'approved' || status === 'rejected') {
        claim.processedAt = new Date();
      }

      await claim.save();

      if (status === 'approved' && claim.invoiceId) {
        const invoice = await Billing.findByPk(claim.invoiceId);
        invoice.claimStatus = 'approved';
        invoice.paidAmount = (invoice.paidAmount || 0) + (approvedAmount || claim.approvedAmount);
        invoice.balance = invoice.totalAmount - invoice.paidAmount;
        if (invoice.balance <= 0) {
          invoice.status = 'paid';
        }
        await invoice.save();
      }

      res.json({
        success: true,
        claimId: claim.id,
        status: claim.status
      });
    } catch (error) {
      console.error('Update claim status error:', error);
      res.status(500).json({ error: 'Failed to update claim' });
    }
  }

  async getClaimStats(req, res) {
    try {
      const tenantId = req.user?.tenantId;
      const { startDate, endDate } = req.query;

      const where = { tenantId };
      if (startDate || endDate) {
        where.createdAt = {};
        if (startDate) where.createdAt[Op.gte] = new Date(startDate);
        if (endDate) where.createdAt[Op.lte] = new Date(endDate + 'T23:59:59');
      }

      const totalSubmitted = await Claim.count({ where });
      const totalAmount = await Claim.sum('submittedAmount', { where });
      
      const approved = await Claim.sum('approvedAmount', { 
        where: { ...where, status: 'approved' } 
      });
      
      const pending = await Claim.count({ 
        where: { ...where, status: { [Op.in]: ['submitted', 'pending_approval', 'draft'] } } 
      });

      const rejected = await Claim.count({ 
        where: { ...where, status: 'rejected' } 
      });

      const byType = await Claim.findAll({
        where,
        attributes: [
          'claimType',
          [db.sequelize.fn('COUNT', db.sequelize.col('id')), 'count'],
          [db.sequelize.fn('SUM', db.sequelize.col('submittedAmount')), 'total']
        ],
        group: ['claimType'],
        raw: true
      });

      res.json({
        totalSubmitted,
        totalAmount: totalAmount || 0,
        totalApproved: approved || 0,
        pending,
        rejected,
        approvalRate: totalSubmitted > 0 ? ((approved || 0) / totalSubmitted * 100).toFixed(2) : 0,
        byType: byType.map(t => ({
          type: t.claimType,
          count: parseInt(t.count) || 0,
          total: parseFloat(t.total) || 0
        }))
      });
    } catch (error) {
      console.error('Claim stats error:', error);
      res.status(500).json({ error: 'Failed to fetch claim stats' });
    }
  }

  async submitBulkClaims(req, res) {
    try {
      const { invoiceIds } = req.body;
      const tenantId = req.user?.tenantId;

      const results = [];

      for (const invoiceId of invoiceIds) {
        try {
          const invoice = await Billing.findOne({
            where: { id: invoiceId, tenantId },
            include: [{ model: Patient, as: 'patient' }]
          });

          if (!invoice || invoice.claimStatus === 'submitted') {
            results.push({ invoiceId, success: false, error: 'Invoice not found or already claimed' });
            continue;
          }

          const insurance = await InsurancePolicy.findOne({
            where: { patientId: invoice.patientId, status: 'active' }
          });

          if (!insurance) {
            results.push({ invoiceId, success: false, error: 'No active insurance' });
            continue;
          }

          const claimId = `CLM-${Date.now()}-${Math.random().toString(36).substr(2, 9).toUpperCase()}`;
          const claim = await Claim.create({
            tenantId,
            claimId,
            invoiceId: invoice.id,
            patientId: invoice.patientId,
            insurancePolicyId: insurance.id,
            claimType: 'sha',
            status: 'submitted',
            totalAmount: invoice.totalAmount,
            submittedAmount: invoice.totalAmount,
            submittedAt: new Date(),
            createdBy: req.user.id
          });

          invoice.claimStatus = 'submitted';
          invoice.claimReference = claimId;
          await invoice.save();

          results.push({ invoiceId, success: true, claimId, claimReference: claimId });
        } catch (err) {
          results.push({ invoiceId, success: false, error: err.message });
        }
      }

      res.json({
        success: true,
        results,
        totalSubmitted: results.filter(r => r.success).length,
        totalFailed: results.filter(r => !r.success).length
      });
    } catch (error) {
      console.error('Bulk claim submission error:', error);
      res.status(500).json({ error: 'Failed to submit bulk claims' });
    }
  }
}

module.exports = new ClaimController();
