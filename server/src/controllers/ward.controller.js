'use strict';
const { v4: uuidv4 } = require('uuid');
const { Op } = require('sequelize');
const db = require('../database');

class WardController {
  async generateAdmissionNumber(tenantId) {
    const date = new Date();
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const count = await db.models.Admission.count({ where: { tenantId } });
    return `ADM${year}${month}${String(count + 1).padStart(5, '0')}`;
  }

  async getWards(req, res) {
    try {
      const { tenantId } = req.user;
      const { status, type, search, page = 1, limit = 50 } = req.query;

      const where = { tenantId };
      if (status) where.status = status;
      if (type) where.type = type;
      if (search) {
        where[Op.or] = [
          { name: { [Op.iLike]: `%${search}%` } },
          { code: { [Op.iLike]: `%${search}%` } }
        ];
      }

      const offset = (page - 1) * limit;
      const { count, rows } = await db.models.Ward.findAndCountAll({
        where,
        include: [{
          model: db.models.Bed,
          as: 'beds',
          attributes: ['id', 'status']
        }],
        order: [['name', 'ASC']],
        limit: parseInt(limit),
        offset
      });

      const wards = rows.map(ward => {
        const plain = ward.get({ plain: true });
        plain.bedCount = plain.beds.length;
        plain.availableBeds = plain.beds.filter(b => b.status === 'available').length;
        plain.occupiedBeds = plain.beds.filter(b => b.status === 'occupied').length;
        delete plain.beds;
        return plain;
      });

      res.json({
        success: true,
        data: wards,
        pagination: {
          total: count,
          page: parseInt(page),
          limit: parseInt(limit),
          pages: Math.ceil(count / limit)
        }
      });
    } catch (error) {
      console.error('Error fetching wards:', error);
      res.status(500).json({ success: false, message: 'Failed to fetch wards' });
    }
  }

  async getWard(req, res) {
    try {
      const { tenantId } = req.user;
      const { id } = req.params;

      const ward = await db.models.Ward.findOne({
        where: { id, tenantId },
        include: [{
          model: db.models.Bed,
          as: 'beds',
          order: [['bedNumber', 'ASC']]
        }]
      });

      if (!ward) {
        return res.status(404).json({ success: false, message: 'Ward not found' });
      }

      res.json({ success: true, data: ward });
    } catch (error) {
      console.error('Error fetching ward:', error);
      res.status(500).json({ success: false, message: 'Failed to fetch ward' });
    }
  }

  async createWard(req, res) {
    try {
      const { tenantId } = req.user;
      const { name, code, type, floor, building, description, genderRestriction, ageRestriction, status } = req.body;

      const existing = await db.models.Ward.findOne({ where: { tenantId, code } });
      if (existing) {
        return res.status(400).json({ success: false, message: 'Ward code already exists' });
      }

      const ward = await db.models.Ward.create({
        tenantId,
        name,
        code,
        type: type || 'general',
        floor,
        building,
        description,
        genderRestriction: genderRestriction || 'any',
        ageRestriction,
        status: status || 'active',
        createdBy: req.user.id
      });

      res.status(201).json({ success: true, data: ward });
    } catch (error) {
      console.error('Error creating ward:', error);
      res.status(500).json({ success: false, message: 'Failed to create ward' });
    }
  }

  async updateWard(req, res) {
    try {
      const { tenantId } = req.user;
      const { id } = req.params;
      const updates = req.body;

      const ward = await db.models.Ward.findOne({ where: { id, tenantId } });
      if (!ward) {
        return res.status(404).json({ success: false, message: 'Ward not found' });
      }

      if (updates.code && updates.code !== ward.code) {
        const existing = await db.models.Ward.findOne({ where: { tenantId, code: updates.code } });
        if (existing) {
          return res.status(400).json({ success: false, message: 'Ward code already exists' });
        }
      }

      await ward.update({ ...updates, updatedBy: req.user.id });
      res.json({ success: true, data: ward });
    } catch (error) {
      console.error('Error updating ward:', error);
      res.status(500).json({ success: false, message: 'Failed to update ward' });
    }
  }

  async deleteWard(req, res) {
    try {
      const { tenantId } = req.user;
      const { id } = req.params;

      const ward = await db.models.Ward.findOne({
        where: { id, tenantId },
        include: [{ model: db.models.Bed, as: 'beds' }]
      });

      if (!ward) {
        return res.status(404).json({ success: false, message: 'Ward not found' });
      }

      const occupiedBeds = ward.beds.filter(b => b.status === 'occupied').length;
      if (occupiedBeds > 0) {
        return res.status(400).json({
          success: false,
          message: `Cannot delete ward with ${occupiedBeds} occupied beds`
        });
      }

      await db.models.Bed.destroy({ where: { wardId: id } });
      await ward.destroy();

      res.json({ success: true, message: 'Ward deleted successfully' });
    } catch (error) {
      console.error('Error deleting ward:', error);
      res.status(500).json({ success: false, message: 'Failed to delete ward' });
    }
  }

  async getBeds(req, res) {
    try {
      const { tenantId } = req.user;
      const { wardId, status, search, page = 1, limit = 100 } = req.query;

      const where = { tenantId };
      if (wardId) where.wardId = wardId;
      if (status) where.status = status;

      const offset = (page - 1) * limit;
      const { count, rows } = await db.models.Bed.findAndCountAll({
        where,
        include: [
          { model: db.models.Ward, as: 'ward', attributes: ['id', 'name', 'code', 'type'] }
        ],
        order: [['wardId', 'ASC'], ['bedNumber', 'ASC']],
        limit: parseInt(limit),
        offset
      });

      res.json({
        success: true,
        data: rows,
        pagination: {
          total: count,
          page: parseInt(page),
          limit: parseInt(limit),
          pages: Math.ceil(count / limit)
        }
      });
    } catch (error) {
      console.error('Error fetching beds:', error);
      res.status(500).json({ success: false, message: 'Failed to fetch beds' });
    }
  }

  async createBed(req, res) {
    try {
      const { tenantId } = req.user;
      const { wardId, bedNumber, bedType, position, features, hourlyRate, dailyRate } = req.body;

      const ward = await db.models.Ward.findOne({ where: { id: wardId, tenantId } });
      if (!ward) {
        return res.status(404).json({ success: false, message: 'Ward not found' });
      }

      const existing = await db.models.Bed.findOne({ where: { wardId, bedNumber } });
      if (existing) {
        return res.status(400).json({ success: false, message: 'Bed number already exists in this ward' });
      }

      const bed = await db.models.Bed.create({
        tenantId,
        wardId,
        bedNumber,
        bedType: bedType || 'standard',
        position,
        features: features || [],
        hourlyRate,
        dailyRate,
        status: 'available',
        createdBy: req.user.id
      });

      res.status(201).json({ success: true, data: bed });
    } catch (error) {
      console.error('Error creating bed:', error);
      res.status(500).json({ success: false, message: 'Failed to create bed' });
    }
  }

  async updateBed(req, res) {
    try {
      const { tenantId } = req.user;
      const { id } = req.params;
      const updates = req.body;

      const bed = await db.models.Bed.findOne({ where: { id, tenantId } });
      if (!bed) {
        return res.status(404).json({ success: false, message: 'Bed not found' });
      }

      if (updates.bedNumber && updates.bedNumber !== bed.bedNumber) {
        const existing = await db.models.Bed.findOne({ where: { wardId: bed.wardId, bedNumber: updates.bedNumber } });
        if (existing) {
          return res.status(400).json({ success: false, message: 'Bed number already exists in this ward' });
        }
      }

      await bed.update({ ...updates, updatedBy: req.user.id });
      res.json({ success: true, data: bed });
    } catch (error) {
      console.error('Error updating bed:', error);
      res.status(500).json({ success: false, message: 'Failed to update bed' });
    }
  }

  async getAdmissions(req, res) {
    try {
      const { tenantId } = req.user;
      const { status, wardId, patientId, startDate, endDate, page = 1, limit = 50 } = req.query;

      const where = { tenantId };
      if (status) where.status = status;
      if (wardId) where.wardId = wardId;
      if (patientId) where.patientId = patientId;
      if (startDate || endDate) {
        where.admissionDate = {};
        if (startDate) where.admissionDate[Op.gte] = new Date(startDate);
        if (endDate) where.admissionDate[Op.lte] = new Date(endDate);
      }

      const offset = (page - 1) * limit;
      const { count, rows } = await db.models.Admission.findAndCountAll({
        where,
        include: [
          { model: db.models.Patient, as: 'patient', attributes: ['id', 'firstName', 'lastName', 'patientNumber', 'dateOfBirth', 'gender'] },
          { model: db.models.Ward, as: 'ward', attributes: ['id', 'name', 'code'] },
          { model: db.models.Bed, as: 'bed', attributes: ['id', 'bedNumber'] },
          { model: db.models.User, as: 'attendingPhysician', attributes: ['id', 'firstName', 'lastName'] }
        ],
        order: [['admissionDate', 'DESC']],
        limit: parseInt(limit),
        offset
      });

      res.json({
        success: true,
        data: rows,
        pagination: {
          total: count,
          page: parseInt(page),
          limit: parseInt(limit),
          pages: Math.ceil(count / limit)
        }
      });
    } catch (error) {
      console.error('Error fetching admissions:', error);
      res.status(500).json({ success: false, message: 'Failed to fetch admissions' });
    }
  }

  async getAdmission(req, res) {
    try {
      const { tenantId } = req.user;
      const { id } = req.params;

      const admission = await db.models.Admission.findOne({
        where: { id, tenantId },
        include: [
          { model: db.models.Patient, as: 'patient' },
          { model: db.models.Ward, as: 'ward' },
          { model: db.models.Bed, as: 'bed' },
          { model: db.models.User, as: 'attendingPhysician', attributes: ['id', 'firstName', 'lastName', 'email'] },
          { model: db.models.NursingNote, as: 'nursingNotes', include: [{ model: db.models.User, as: 'author', attributes: ['id', 'firstName', 'lastName'] }] },
          { model: db.models.MedicationAdministrationRecord, as: 'mar', include: [{ model: db.models.User, as: 'nurse', attributes: ['id', 'firstName', 'lastName'] }] }
        ]
      });

      if (!admission) {
        return res.status(404).json({ success: false, message: 'Admission not found' });
      }

      res.json({ success: true, data: admission });
    } catch (error) {
      console.error('Error fetching admission:', error);
      res.status(500).json({ success: false, message: 'Failed to fetch admission' });
    }
  }

  async createAdmission(req, res) {
    try {
      const { tenantId } = req.user;
      const {
        patientId, encounterId, wardId, bedId, admissionType, admissionReason,
        presentingComplaint, provisionalDiagnosis, attendingPhysicianId,
        specialRequirements, nextOfKin, allergies
      } = req.body;

      const patient = await db.models.Patient.findOne({ where: { id: patientId, tenantId } });
      if (!patient) {
        return res.status(404).json({ success: false, message: 'Patient not found' });
      }

      const encounter = await db.models.Encounter.findOne({ where: { id: encounterId, tenantId } });
      if (!encounter) {
        return res.status(404).json({ success: false, message: 'Encounter not found' });
      }

      const ward = await db.models.Ward.findOne({ where: { id: wardId, tenantId, status: 'active' } });
      if (!ward) {
        return res.status(404).json({ success: false, message: 'Ward not found or inactive' });
      }

      const bed = await db.models.Bed.findOne({ where: { id: bedId, wardId, tenantId } });
      if (!bed) {
        return res.status(404).json({ success: false, message: 'Bed not found in specified ward' });
      }

      if (bed.status !== 'available') {
        return res.status(400).json({ success: false, message: 'Bed is not available' });
      }

      const admissionNumber = await this.generateAdmissionNumber(tenantId);

      const admission = await db.sequelize.transaction(async (t) => {
        const newAdmission = await db.models.Admission.create({
          tenantId,
          patientId,
          encounterId,
          wardId,
          bedId,
          admissionNumber,
          admissionType,
          admissionReason,
          presentingComplaint,
          provisionalDiagnosis,
          attendingPhysicianId,
          specialRequirements: specialRequirements || [],
          nextOfKin,
          allergies: allergies || patient.allergies || [],
          status: 'admitted',
          createdBy: req.user.id
        }, { transaction: t });

        await db.models.Bed.update(
          { status: 'occupied', updatedBy: req.user.id },
          { where: { id: bedId }, transaction: t }
        );

        if (ward.dailyRate) {
          await db.models.BillingInvoice.create({
            tenantId,
            patientId,
            encounterId,
            admissionId: newAdmission.id,
            invoiceNumber: `INV${Date.now()}`,
            type: 'ward_charge',
            description: `Ward stay - ${ward.name}`,
            amount: ward.dailyRate,
            status: 'pending',
            createdBy: req.user.id
          }, { transaction: t });
        }

        return newAdmission;
      });

      const fullAdmission = await db.models.Admission.findByPk(admission.id, {
        include: [
          { model: db.models.Patient, as: 'patient' },
          { model: db.models.Ward, as: 'ward' },
          { model: db.models.Bed, as: 'bed' }
        ]
      });

      res.status(201).json({ success: true, data: fullAdmission });
    } catch (error) {
      console.error('Error creating admission:', error);
      res.status(500).json({ success: false, message: 'Failed to create admission' });
    }
  }

  async transferPatient(req, res) {
    try {
      const { tenantId } = req.user;
      const { id } = req.params;
      const { newWardId, newBedId, reason } = req.body;

      const admission = await db.models.Admission.findOne({
        where: { id, tenantId },
        include: [{ model: db.models.Bed, as: 'bed' }]
      });

      if (!admission) {
        return res.status(404).json({ success: false, message: 'Admission not found' });
      }

      const newBed = await db.models.Bed.findOne({ where: { id: newBedId, wardId: newWardId, tenantId } });
      if (!newBed || newBed.status !== 'available') {
        return res.status(400).json({ success: false, message: 'Target bed is not available' });
      }

      await db.sequelize.transaction(async (t) => {
        await db.models.Bed.update(
          { status: 'available', updatedBy: req.user.id },
          { where: { id: admission.bedId }, transaction: t }
        );

        await db.models.Bed.update(
          { status: 'occupied', updatedBy: req.user.id },
          { where: { id: newBedId }, transaction: t }
        );

        await db.models.NursingNote.create({
          tenantId,
          admissionId: id,
          patientId: admission.patientId,
          noteType: 'transfer',
          content: `Patient transferred from ${admission.wardId} to ${newWardId}. Reason: ${reason}`,
          priority: 'urgent',
          createdBy: req.user.id
        }, { transaction: t });

        await admission.update({
          wardId: newWardId,
          bedId: newBedId,
          updatedBy: req.user.id
        }, { transaction: t });
      });

      const updated = await db.models.Admission.findByPk(id, {
        include: [
          { model: db.models.Patient, as: 'patient' },
          { model: db.models.Ward, as: 'ward' },
          { model: db.models.Bed, as: 'bed' }
        ]
      });

      res.json({ success: true, data: updated });
    } catch (error) {
      console.error('Error transferring patient:', error);
      res.status(500).json({ success: false, message: 'Failed to transfer patient' });
    }
  }

  async dischargePatient(req, res) {
    try {
      const { tenantId } = req.user;
      const { id } = req.params;
      const { dischargeReason, dischargeSummary, dischargeInstructions } = req.body;

      const admission = await db.models.Admission.findOne({
        where: { id, tenantId },
        include: [{ model: db.models.Bed, as: 'bed' }]
      });

      if (!admission) {
        return res.status(404).json({ success: false, message: 'Admission not found' });
      }

      if (admission.status === 'discharged') {
        return res.status(400).json({ success: false, message: 'Patient already discharged' });
      }

      await db.sequelize.transaction(async (t) => {
        await db.models.Bed.update(
          { status: 'cleaning', updatedBy: req.user.id },
          { where: { id: admission.bedId }, transaction: t }
        );

        await db.models.MedicationAdministrationRecord.update(
          { status: 'dc', endDate: new Date(), updatedBy: req.user.id },
          { where: { admissionId: id, status: 'scheduled' }, transaction: t }
        );

        await admission.update({
          status: 'discharged',
          dischargeDate: new Date(),
          dischargeReason,
          dischargeSummary,
          dischargeInstructions,
          updatedBy: req.user.id
        }, { transaction: t });
      });

      const updated = await db.models.Admission.findByPk(id, {
        include: [
          { model: db.models.Patient, as: 'patient' },
          { model: db.models.Ward, as: 'ward' },
          { model: db.models.Bed, as: 'bed' }
        ]
      });

      res.json({ success: true, data: updated });
    } catch (error) {
      console.error('Error discharging patient:', error);
      res.status(500).json({ success: false, message: 'Failed to discharge patient' });
    }
  }

  async getNursingNotes(req, res) {
    try {
      const { tenantId } = req.user;
      const { admissionId, patientId, noteType, priority, page = 1, limit = 50 } = req.query;

      const where = { tenantId };
      if (admissionId) where.admissionId = admissionId;
      if (patientId) where.patientId = patientId;
      if (noteType) where.noteType = noteType;
      if (priority) where.priority = priority;

      const offset = (page - 1) * limit;
      const { count, rows } = await db.models.NursingNote.findAndCountAll({
        where,
        include: [
          { model: db.models.User, as: 'author', attributes: ['id', 'firstName', 'lastName', 'role'] }
        ],
        order: [['createdAt', 'DESC']],
        limit: parseInt(limit),
        offset
      });

      res.json({
        success: true,
        data: rows,
        pagination: {
          total: count,
          page: parseInt(page),
          limit: parseInt(limit),
          pages: Math.ceil(count / limit)
        }
      });
    } catch (error) {
      console.error('Error fetching nursing notes:', error);
      res.status(500).json({ success: false, message: 'Failed to fetch nursing notes' });
    }
  }

  async createNursingNote(req, res) {
    try {
      const { tenantId } = req.user;
      const {
        admissionId, patientId, noteType, content, vitals, painScore,
        consciousness, mobility, skinCondition, ivSite, fluidBalance,
        priority, shiftType, attachments
      } = req.body;

      const admission = await db.models.Admission.findOne({ where: { id: admissionId, tenantId } });
      if (!admission) {
        return res.status(404).json({ success: false, message: 'Admission not found' });
      }

      const note = await db.models.NursingNote.create({
        tenantId,
        admissionId,
        patientId: patientId || admission.patientId,
        noteType,
        content,
        vitals,
        painScore,
        consciousness,
        mobility,
        skinCondition,
        ivSite,
        fluidBalance,
        priority: priority || 'routine',
        shiftType,
        attachments: attachments || [],
        createdBy: req.user.id
      });

      const fullNote = await db.models.NursingNote.findByPk(note.id, {
        include: [{ model: db.models.User, as: 'author', attributes: ['id', 'firstName', 'lastName'] }]
      });

      res.status(201).json({ success: true, data: fullNote });
    } catch (error) {
      console.error('Error creating nursing note:', error);
      res.status(500).json({ success: false, message: 'Failed to create nursing note' });
    }
  }

  async getMedicationAdministrationRecords(req, res) {
    try {
      const { tenantId } = req.user;
      const { admissionId, patientId, status, date, page = 1, limit = 100 } = req.query;

      const where = { tenantId };
      if (admissionId) where.admissionId = admissionId;
      if (patientId) where.patientId = patientId;
      if (status) where.status = status;
      if (date) {
        const startOfDay = new Date(date);
        startOfDay.setHours(0, 0, 0, 0);
        const endOfDay = new Date(date);
        endOfDay.setHours(23, 59, 59, 999);
        where.scheduledTime = { [Op.between]: [startOfDay, endOfDay] };
      }

      const offset = (page - 1) * limit;
      const { count, rows } = await db.models.MedicationAdministrationRecord.findAndCountAll({
        where,
        include: [
          { model: db.models.User, as: 'nurse', attributes: ['id', 'firstName', 'lastName'] },
          { model: db.models.Admission, as: 'admission', include: [{ model: db.models.Ward, as: 'ward' }] }
        ],
        order: [['scheduledTime', 'ASC']],
        limit: parseInt(limit),
        offset
      });

      res.json({
        success: true,
        data: rows,
        pagination: {
          total: count,
          page: parseInt(page),
          limit: parseInt(limit),
          pages: Math.ceil(count / limit)
        }
      });
    } catch (error) {
      console.error('Error fetching MAR:', error);
      res.status(500).json({ success: false, message: 'Failed to fetch medication records' });
    }
  }

  async administerMedication(req, res) {
    try {
      const { tenantId } = req.user;
      const { id } = req.params;
      const { response, quantityGiven, batchId, site, notes } = req.body;

      const record = await db.models.MedicationAdministrationRecord.findOne({
        where: { id, tenantId },
        include: [{ model: db.models.Admission, as: 'admission' }]
      });

      if (!record) {
        return res.status(404).json({ success: false, message: 'Medication record not found' });
      }

      if (record.status !== 'scheduled') {
        return res.status(400).json({ success: false, message: 'Medication already administered or cancelled' });
      }

      await record.update({
        status: response === 'refused' ? 'refused' : 'given',
        administeredTime: new Date(),
        administeredBy: req.user.id,
        quantityGiven,
        batchId,
        site,
        response,
        notes,
        updatedBy: req.user.id
      });

      if (response !== 'refused' && batchId) {
        await db.models.InventoryBatch.decrement(
          'currentQuantity',
          { by: quantityGiven, where: { id: batchId, tenantId } }
        );
      }

      const updated = await db.models.MedicationAdministrationRecord.findByPk(id, {
        include: [
          { model: db.models.User, as: 'nurse' },
          { model: db.models.Admission, as: 'admission', include: [{ model: db.models.Ward, as: 'ward' }] }
        ]
      });

      res.json({ success: true, data: updated });
    } catch (error) {
      console.error('Error administering medication:', error);
      res.status(500).json({ success: false, message: 'Failed to administer medication' });
    }
  }

  async createMarFromPrescription(req, res) {
    try {
      const { tenantId } = req.user;
      const { prescriptionId, admissionId } = req.body;

      const prescription = await db.models.Prescription.findOne({
        where: { id: prescriptionId, tenantId }
      });

      if (!prescription) {
        return res.status(404).json({ success: false, message: 'Prescription not found' });
      }

      const admission = await db.models.Admission.findOne({
        where: { id: admissionId, tenantId }
      });

      if (!admission) {
        return res.status(404).json({ success: false, message: 'Admission not found' });
      }

      const frequencyMap = {
        'OD': 1, 'BD': 2, 'TDS': 3, 'QID': 4, 'Q4H': 6, 'Q6H': 4, 'Q8H': 3, 'Q12H': 2,
        'STAT': 1, 'PRN': 0
      };

      const timesPerDay = frequencyMap[prescription.frequency] || 1;
      const startDate = new Date();
      const endDate = prescription.duration ? new Date(startDate.getTime() + prescription.duration * 24 * 60 * 60 * 1000) : null;

      const records = [];
      for (let day = 0; day < 7; day++) {
        const currentDate = new Date(startDate);
        currentDate.setDate(currentDate.getDate() + day);
        currentDate.setHours(8, 0, 0, 0);

        const times = timesPerDay > 0 ? timesPerDay : 1;
        const interval = 24 / times;

        for (let t = 0; t < times; t++) {
          const scheduledTime = new Date(currentDate);
          scheduledTime.setHours(8 + (t * interval));

          const record = await db.models.MedicationAdministrationRecord.create({
            tenantId,
            admissionId,
            patientId: prescription.patientId,
            prescriptionId: prescription.id,
            medicationName: prescription.medicationName,
            dosage: prescription.dosage,
            route: prescription.route,
            frequency: prescription.frequency,
            scheduledTime,
            startDate,
            endDate,
            status: 'scheduled',
            createdBy: req.user.id
          });

          records.push(record);
        }
      }

      res.status(201).json({ success: true, data: records, count: records.length });
    } catch (error) {
      console.error('Error creating MAR from prescription:', error);
      res.status(500).json({ success: false, message: 'Failed to create medication records' });
    }
  }

  async getWardDashboard(req, res) {
    try {
      const { tenantId } = req.user;
      const { wardId } = req.params;

      const ward = await db.models.Ward.findOne({ where: { id: wardId, tenantId } });
      if (!ward) {
        return res.status(404).json({ success: false, message: 'Ward not found' });
      }

      const beds = await db.models.Bed.findAll({
        where: { wardId, tenantId },
        include: [{
          model: db.models.Admission,
          as: 'admissions',
          where: { status: { [Op.ne]: 'discharged' } },
          required: false,
          include: [{
            model: db.models.Patient,
            as: 'patient',
            attributes: ['id', 'firstName', 'lastName', 'patientNumber', 'dateOfBirth']
          }]
        }]
      });

      const pendingMeds = await db.models.MedicationAdministrationRecord.count({
        where: {
          tenantId,
          status: 'scheduled',
          scheduledTime: { [Op.lte]: new Date() }
        },
        include: [{
          model: db.models.Admission,
          as: 'admission',
          where: { wardId },
          required: true
        }]
      });

      const nursingNotes = await db.models.NursingNote.findAll({
        where: { tenantId },
        include: [{
          model: db.models.Admission,
          as: 'admission',
          where: { wardId },
          required: true
        }],
        order: [['createdAt', 'DESC']],
        limit: 10
      });

      res.json({
        success: true,
        data: {
          ward,
          beds,
          stats: {
            totalBeds: beds.length,
            available: beds.filter(b => b.status === 'available').length,
            occupied: beds.filter(b => b.status === 'occupied').length,
            maintenance: beds.filter(b => b.status === 'maintenance').length,
            pendingMedications: pendingMeds
          },
          recentNotes: nursingNotes
        }
      });
    } catch (error) {
      console.error('Error fetching ward dashboard:', error);
      res.status(500).json({ success: false, message: 'Failed to fetch ward dashboard' });
    }
  }
}

module.exports = new WardController();
