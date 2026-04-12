'use strict';
const { v4: uuidv4 } = require('uuid');
const { Op, fn, col, literal } = require('sequelize');
const db = require('../database');

class ReportController {
  generateReportId() {
    return `RPT${Date.now()}${Math.random().toString(36).substr(2, 9).toUpperCase()}`;
  }

  async getTemplates(req, res) {
    try {
      const { tenantId } = req.user;
      const { category, isDefault, page = 1, limit = 50 } = req.query;

      const where = { tenantId, isActive: true };
      if (category) where.category = category;
      if (isDefault !== undefined) where.isDefault = isDefault === 'true';

      const offset = (page - 1) * limit;
      const { count, rows } = await db.models.ReportTemplate.findAndCountAll({
        where,
        include: [{ model: db.models.User, as: 'creator', attributes: ['id', 'firstName', 'lastName'] }],
        order: [['name', 'ASC']],
        limit: parseInt(limit),
        offset
      });

      res.json({
        success: true,
        data: rows,
        pagination: { total: count, page: parseInt(page), limit: parseInt(limit), pages: Math.ceil(count / limit) }
      });
    } catch (error) {
      console.error('Error fetching templates:', error);
      res.status(500).json({ success: false, message: 'Failed to fetch templates' });
    }
  }

  async getTemplate(req, res) {
    try {
      const { tenantId } = req.user;
      const { id } = req.params;

      const template = await db.models.ReportTemplate.findOne({
        where: { id, tenantId }
      });

      if (!template) {
        return res.status(404).json({ success: false, message: 'Template not found' });
      }

      res.json({ success: true, data: template });
    } catch (error) {
      console.error('Error fetching template:', error);
      res.status(500).json({ success: false, message: 'Failed to fetch template' });
    }
  }

  async createTemplate(req, res) {
    try {
      const { tenantId } = req.user;
      const { name, code, category, description, query, parameters, columns, chartType } = req.body;

      const existing = await db.models.ReportTemplate.findOne({ where: { code } });
      if (existing) {
        return res.status(400).json({ success: false, message: 'Report code already exists' });
      }

      const template = await db.models.ReportTemplate.create({
        tenantId,
        name,
        code,
        category,
        description,
        query,
        parameters: parameters || [],
        columns: columns || [],
        chartType: chartType || 'table',
        createdBy: req.user.id
      });

      res.status(201).json({ success: true, data: template });
    } catch (error) {
      console.error('Error creating template:', error);
      res.status(500).json({ success: false, message: 'Failed to create template' });
    }
  }

  async generateReport(req, res) {
    try {
      const { tenantId } = req.user;
      const { templateId, name, periodStart, periodEnd, parameters, format } = req.body;

      let template = null;
      if (templateId) {
        template = await db.models.ReportTemplate.findOne({ where: { id: templateId, tenantId } });
        if (!template) {
          return res.status(404).json({ success: false, message: 'Template not found' });
        }
      }

      const report = await db.models.Report.create({
        tenantId,
        templateId,
        name: name || (template ? template.name : 'Custom Report'),
        category: template?.category || 'custom',
        periodStart: periodStart ? new Date(periodStart) : null,
        periodEnd: periodEnd ? new Date(periodEnd) : null,
        parameters: parameters || {},
        format: format || 'pdf',
        status: 'generating',
        generatedBy: req.user.id,
        createdBy: req.user.id
      });

      try {
        const data = await this.executeReportQuery(template, tenantId, { periodStart, periodEnd, ...parameters });
        const summary = this.calculateSummary(data);

        await report.update({
          data,
          summary,
          status: 'completed'
        });
      } catch (execError) {
        await report.update({
          status: 'failed',
          errorMessage: execError.message
        });
      }

      res.status(201).json({ success: true, data: report });
    } catch (error) {
      console.error('Error generating report:', error);
      res.status(500).json({ success: false, message: 'Failed to generate report' });
    }
  }

  async executeReportQuery(template, tenantId, params) {
    if (!template || !template.query) {
      return { message: 'No query defined for this template' };
    }

    const replacements = {
      tenantId,
      startDate: params.periodStart || new Date(new Date().setDate(new Date().getDate() - 30)),
      endDate: params.periodEnd || new Date()
    };

    const query = template.query.replace(/@tenantId/g, ':tenantId')
      .replace(/@startDate/g, ':startDate')
      .replace(/@endDate/g, ':endDate');

    const results = await db.sequelize.query(query, {
      replacements,
      type: db.sequelize.QueryTypes.SELECT
    });

    return results;
  }

  calculateSummary(data) {
    if (!Array.isArray(data)) return {};

    const numericColumns = Object.keys(data[0] || {}).filter(key => {
      const val = data[0][key];
      return typeof val === 'number';
    });

    const summary = {
      totalRecords: data.length
    };

    numericColumns.forEach(col => {
      const values = data.map(r => r[col]).filter(v => typeof v === 'number');
      summary[`${col}_sum`] = values.reduce((a, b) => a + b, 0);
      summary[`${col}_avg`] = values.length ? values.reduce((a, b) => a + b, 0) / values.length : 0;
      summary[`${col}_min`] = values.length ? Math.min(...values) : 0;
      summary[`${col}_max`] = values.length ? Math.max(...values) : 0;
    });

    return summary;
  }

  async getReports(req, res) {
    try {
      const { tenantId } = req.user;
      const { category, status, startDate, endDate, page = 1, limit = 50 } = req.query;

      const where = { tenantId };
      if (category) where.category = category;
      if (status) where.status = status;
      if (startDate || endDate) {
        where.createdAt = {};
        if (startDate) where.createdAt[Op.gte] = new Date(startDate);
        if (endDate) where.createdAt[Op.lte] = new Date(endDate);
      }

      const offset = (page - 1) * limit;
      const { count, rows } = await db.models.Report.findAndCountAll({
        where,
        include: [
          { model: db.models.User, as: 'generator', attributes: ['id', 'firstName', 'lastName'] }
        ],
        order: [['createdAt', 'DESC']],
        limit: parseInt(limit),
        offset
      });

      res.json({
        success: true,
        data: rows,
        pagination: { total: count, page: parseInt(page), limit: parseInt(limit), pages: Math.ceil(count / limit) }
      });
    } catch (error) {
      console.error('Error fetching reports:', error);
      res.status(500).json({ success: false, message: 'Failed to fetch reports' });
    }
  }

  async getReport(req, res) {
    try {
      const { tenantId } = req.user;
      const { id } = req.params;

      const report = await db.models.Report.findOne({
        where: { id, tenantId },
        include: [
          { model: db.models.User, as: 'generator', attributes: ['id', 'firstName', 'lastName'] }
        ]
      });

      if (!report) {
        return res.status(404).json({ success: false, message: 'Report not found' });
      }

      res.json({ success: true, data: report });
    } catch (error) {
      console.error('Error fetching report:', error);
      res.status(500).json({ success: false, message: 'Failed to fetch report' });
    }
  }

  async getRevenueReport(req, res) {
    try {
      const { tenantId } = req.user;
      const { startDate, endDate, groupBy = 'day', department } = req.query;

      const start = startDate ? new Date(startDate) : new Date(new Date().setDate(new Date().getDate() - 30));
      const end = endDate ? new Date(endDate) : new Date();

      let groupFormat;
      switch (groupBy) {
        case 'month': groupFormat = 'YYYY-MM'; break;
        case 'week': groupFormat = 'IYYY-IW'; break;
        default: groupFormat = 'YYYY-MM-DD';
      }

      const revenueData = await db.sequelize.query(`
        SELECT 
          DATE_TRUNC('day', p."createdAt") as date,
          COUNT(DISTINCT p.id) as transaction_count,
          COUNT(DISTINCT p."patientId") as patient_count,
          SUM(p.amount) as total_amount,
          SUM(CASE WHEN p.method = 'cash' THEN p.amount ELSE 0 END) as cash_total,
          SUM(CASE WHEN p.method = 'mpesa' THEN p.amount ELSE 0 END) as mpesa_total,
          SUM(CASE WHEN p.method = 'insurance' THEN p.amount ELSE 0 END) as insurance_total,
          SUM(CASE WHEN p.method = 'sha' THEN p.amount ELSE 0 END) as sha_total
        FROM billing_payments p
        WHERE p."tenantId" = :tenantId
          AND p."createdAt" BETWEEN :startDate AND :endDate
          AND p.status = 'completed'
        GROUP BY DATE_TRUNC('day', p."createdAt")
        ORDER BY date
      `, {
        replacements: { tenantId, startDate: start, endDate: end },
        type: db.sequelize.QueryTypes.SELECT
      });

      const deptRevenue = await db.sequelize.query(`
        SELECT 
          bi.department,
          COUNT(*) as item_count,
          SUM(bi.quantity * bi.unitPrice) as total
        FROM billing_invoice_items bi
        JOIN billing_invoices i ON bi."invoiceId" = i.id
        WHERE i."tenantId" = :tenantId
          AND i."createdAt" BETWEEN :startDate AND :endDate
        GROUP BY bi.department
        ORDER BY total DESC
      `, {
        replacements: { tenantId, startDate: start, endDate: end },
        type: db.sequelize.QueryTypes.SELECT
      });

      res.json({
        success: true,
        data: {
          timeline: revenueData,
          byDepartment: deptRevenue,
          period: { start, end },
          summary: {
            totalRevenue: revenueData.reduce((sum, r) => sum + parseFloat(r.total_amount || 0), 0),
            totalTransactions: revenueData.reduce((sum, r) => sum + parseInt(r.transaction_count || 0), 0),
            uniquePatients: revenueData.reduce((sum, r) => sum + parseInt(r.patient_count || 0), 0)
          }
        }
      });
    } catch (error) {
      console.error('Error generating revenue report:', error);
      res.status(500).json({ success: false, message: 'Failed to generate revenue report' });
    }
  }

  async getClinicalReport(req, res) {
    try {
      const { tenantId } = req.user;
      const { startDate, endDate } = req.query;

      const start = startDate ? new Date(startDate) : new Date(new Date().setDate(new Date().getDate() - 30));
      const end = endDate ? new Date(endDate) : new Date();

      const encounters = await db.sequelize.query(`
        SELECT 
          DATE_TRUNC('day', e."createdAt") as date,
          COUNT(*) as total_encounters,
          COUNT(CASE WHEN e.status = 'completed' THEN 1 END) as completed,
          COUNT(CASE WHEN e.status = 'in_progress' THEN 1 END) as in_progress,
          COUNT(CASE WHEN e.type = 'emergency' THEN 1 END) as emergency,
          COUNT(CASE WHEN e.type = 'outpatient' THEN 1 END) as outpatient,
          COUNT(CASE WHEN e.type = 'inpatient' THEN 1 END) as inpatient
        FROM encounters e
        WHERE e."tenantId" = :tenantId
          AND e."createdAt" BETWEEN :startDate AND :endDate
        GROUP BY DATE_TRUNC('day', e."createdAt")
        ORDER BY date
      `, {
        replacements: { tenantId, startDate: start, endDate: end },
        type: db.sequelize.QueryTypes.SELECT
      });

      const diagnoses = await db.sequelize.query(`
        SELECT 
          d.icdCode,
          d.description,
          COUNT(*) as count
        FROM encounter_diagnoses ed
        JOIN diagnoses d ON ed."diagnosisId" = d.id
        JOIN encounters e ON ed."encounterId" = e.id
        WHERE e."tenantId" = :tenantId
          AND e."createdAt" BETWEEN :startDate AND :endDate
        GROUP BY d.icdCode, d.description
        ORDER BY count DESC
        LIMIT 20
      `, {
        replacements: { tenantId, startDate: start, endDate: end },
        type: db.sequelize.QueryTypes.SELECT
      });

      const topDiagnoses = diagnoses.map(d => ({
        code: d.icdCode,
        description: d.description,
        count: parseInt(d.count)
      }));

      res.json({
        success: true,
        data: {
          timeline: encounters,
          topDiagnoses,
          summary: {
            totalEncounters: encounters.reduce((sum, e) => sum + parseInt(e.total_encounters), 0),
            completed: encounters.reduce((sum, e) => sum + parseInt(e.completed), 0),
            emergency: encounters.reduce((sum, e) => sum + parseInt(e.emergency), 0)
          }
        }
      });
    } catch (error) {
      console.error('Error generating clinical report:', error);
      res.status(500).json({ success: false, message: 'Failed to generate clinical report' });
    }
  }

  async getPatientReport(req, res) {
    try {
      const { tenantId } = req.user;
      const { startDate, endDate, groupBy = 'day' } = req.query;

      const start = startDate ? new Date(startDate) : new Date(new Date().setDate(new Date().getDate() - 30));
      const end = endDate ? new Date(endDate) : new Date();

      const registrations = await db.sequelize.query(`
        SELECT 
          DATE_TRUNC('day', p."createdAt") as date,
          COUNT(*) as total,
          COUNT(CASE WHEN p.gender = 'male' THEN 1 END) as male,
          COUNT(CASE WHEN p.gender = 'female' THEN 1 END) as female,
          COUNT(CASE WHEN p.gender = 'other' THEN 1 END) as other,
          COUNT(CASE WHEN p."patientCategory" = 'new' THEN 1 END) as new_patients,
          COUNT(CASE WHEN p."patientCategory" = 'returning' THEN 1 END) as returning
        FROM patients p
        WHERE p."tenantId" = :tenantId
          AND p."createdAt" BETWEEN :startDate AND :endDate
        GROUP BY DATE_TRUNC('day', p."createdAt")
        ORDER BY date
      `, {
        replacements: { tenantId, startDate: start, endDate: end },
        type: db.sequelize.QueryTypes.SELECT
      });

      const ageGroups = await db.sequelize.query(`
        SELECT 
          CASE 
            WHEN EXTRACT(YEAR FROM AGE(p."dateOfBirth")) < 1 THEN 'Infant (0-1)'
            WHEN EXTRACT(YEAR FROM AGE(p."dateOfBirth")) BETWEEN 1 AND 4 THEN 'Toddler (1-4)'
            WHEN EXTRACT(YEAR FROM AGE(p."dateOfBirth")) BETWEEN 5 AND 12 THEN 'Child (5-12)'
            WHEN EXTRACT(YEAR FROM AGE(p."dateOfBirth")) BETWEEN 13 AND 17 THEN 'Adolescent (13-17)'
            WHEN EXTRACT(YEAR FROM AGE(p."dateOfBirth")) BETWEEN 18 AND 35 THEN 'Young Adult (18-35)'
            WHEN EXTRACT(YEAR FROM AGE(p."dateOfBirth")) BETWEEN 36 AND 55 THEN 'Middle Age (36-55)'
            WHEN EXTRACT(YEAR FROM AGE(p."dateOfBirth")) >= 56 THEN 'Senior (56+)'
            ELSE 'Unknown'
          END as age_group,
          COUNT(*) as count
        FROM patients p
        WHERE p."tenantId" = :tenantId
          AND p."createdAt" BETWEEN :startDate AND :endDate
        GROUP BY age_group
        ORDER BY count DESC
      `, {
        replacements: { tenantId, startDate: start, endDate: end },
        type: db.sequelize.QueryTypes.SELECT
      });

      res.json({
        success: true,
        data: {
          timeline: registrations,
          ageDistribution: ageGroups,
          summary: {
            totalRegistrations: registrations.reduce((sum, r) => sum + parseInt(r.total), 0),
            newPatients: registrations.reduce((sum, r) => sum + parseInt(r.new_patients), 0),
            maleCount: registrations.reduce((sum, r) => sum + parseInt(r.male), 0),
            femaleCount: registrations.reduce((sum, r) => sum + parseInt(r.female), 0)
          }
        }
      });
    } catch (error) {
      console.error('Error generating patient report:', error);
      res.status(500).json({ success: false, message: 'Failed to generate patient report' });
    }
  }

  async getInventoryReport(req, res) {
    try {
      const { tenantId } = req.user;
      const { startDate, endDate, category } = req.query;

      const start = startDate ? new Date(startDate) : new Date(new Date().setDate(new Date().getDate() - 30));
      const end = endDate ? new Date(endDate) : new Date();

      const stockMovement = await db.sequelize.query(`
        SELECT 
          DATE_TRUNC('day', sm."createdAt") as date,
          SUM(CASE WHEN sm.type = 'received' THEN sm.quantity ELSE 0 END) as received,
          SUM(CASE WHEN sm.type = 'dispensed' THEN sm.quantity ELSE 0 END) as dispensed,
          SUM(CASE WHEN sm.type = 'adjustment' THEN sm.quantity ELSE 0 END) as adjustment,
          SUM(CASE WHEN sm.type = 'return' THEN sm.quantity ELSE 0 END) as returns
        FROM stock_movements sm
        WHERE sm."tenantId" = :tenantId
          AND sm."createdAt" BETWEEN :startDate AND :endDate
        GROUP BY DATE_TRUNC('day', sm."createdAt")
        ORDER BY date
      `, {
        replacements: { tenantId, startDate: start, endDate: end },
        type: db.sequelize.QueryTypes.SELECT
      });

      const lowStock = await db.sequelize.query(`
        SELECT 
          i.name,
          i."reorderLevel",
          ib."currentQuantity" as quantity,
          ib.expiryDate,
          w.name as warehouse
        FROM inventory_items i
        JOIN inventory_batches ib ON i.id = ib."itemId"
        JOIN warehouses w ON ib."warehouseId" = w.id
        WHERE i."tenantId" = :tenantId
          AND ib."currentQuantity" <= i."reorderLevel"
          AND ib."currentQuantity" > 0
        ORDER BY (ib."currentQuantity"::float / NULLIF(i."reorderLevel", 0)) ASC
        LIMIT 20
      `, {
        replacements: { tenantId },
        type: db.sequelize.QueryTypes.SELECT
      });

      const expiringItems = await db.sequelize.query(`
        SELECT 
          i.name,
          ib."batchNumber",
          ib."currentQuantity" as quantity,
          ib.expiryDate,
          w.name as warehouse
        FROM inventory_items i
        JOIN inventory_batches ib ON i.id = ib."itemId"
        JOIN warehouses w ON ib."warehouseId" = w.id
        WHERE i."tenantId" = :tenantId
          AND ib.expiryDate BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '30 days'
          AND ib."currentQuantity" > 0
        ORDER BY ib.expiryDate ASC
      `, {
        replacements: { tenantId },
        type: db.sequelize.QueryTypes.SELECT
      });

      res.json({
        success: true,
        data: {
          stockMovement,
          lowStock,
          expiringItems,
          summary: {
            totalReceived: stockMovement.reduce((sum, m) => sum + parseInt(m.received || 0), 0),
            totalDispensed: stockMovement.reduce((sum, m) => sum + parseInt(m.dispensed || 0), 0),
            lowStockItems: lowStock.length,
            expiringItems: expiringItems.length
          }
        }
      });
    } catch (error) {
      console.error('Error generating inventory report:', error);
      res.status(500).json({ success: false, message: 'Failed to generate inventory report' });
    }
  }

  async getWardReport(req, res) {
    try {
      const { tenantId } = req.user;
      const { startDate, endDate, wardId } = req.query;

      const start = startDate ? new Date(startDate) : new Date(new Date().setDate(new Date().getDate() - 30));
      const end = endDate ? new Date(endDate) : new Date();

      const occupancy = await db.sequelize.query(`
        SELECT 
          w.name as ward,
          COUNT(DISTINCT b.id) as total_beds,
          COUNT(DISTINCT CASE WHEN a.status = 'admitted' OR a.status = 'in_progress' THEN a.id END) as current_admissions,
          COUNT(DISTINCT a.id) as total_admissions,
          AVG(EXTRACT(EPOCH FROM (COALESCE(a."dischargeDate", CURRENT_DATE) - a."admissionDate")) / 86400) as avg_stay_days
        FROM wards w
        LEFT JOIN beds b ON w.id = b."wardId"
        LEFT JOIN admissions a ON b.id = a."bedId" 
          AND a."createdAt" BETWEEN :startDate AND :endDate
        WHERE w."tenantId" = :tenantId
          ${wardId ? 'AND w.id = :wardId' : ''}
        GROUP BY w.id, w.name
        ORDER BY total_admissions DESC
      `, {
        replacements: { tenantId, startDate: start, endDate: end, wardId },
        type: db.sequelize.QueryTypes.SELECT
      });

      const admissionsTrend = await db.sequelize.query(`
        SELECT 
          DATE_TRUNC('day', a."createdAt") as date,
          COUNT(*) as admissions,
          COUNT(CASE WHEN a."dischargeDate" IS NOT NULL THEN 1 END) as discharges,
          COUNT(CASE WHEN a."dischargeReason" = 'died' THEN 1 END) as deaths
        FROM admissions a
        WHERE a."tenantId" = :tenantId
          AND a."createdAt" BETWEEN :startDate AND :endDate
        GROUP BY DATE_TRUNC('day', a."createdAt")
        ORDER BY date
      `, {
        replacements: { tenantId, startDate: start, endDate: end },
        type: db.sequelize.QueryTypes.SELECT
      });

      res.json({
        success: true,
        data: {
          wardOccupancy: occupancy,
          admissionsTrend,
          summary: {
            totalAdmissions: occupancy.reduce((sum, w) => sum + parseInt(w.total_admissions || 0), 0),
            avgOccupancy: occupancy.length ? 
              occupancy.reduce((sum, w) => sum + (parseFloat(w.current_admissions || 0) / parseFloat(w.total_beds || 1) * 100), 0) / occupancy.length : 0
          }
        }
      });
    } catch (error) {
      console.error('Error generating ward report:', error);
      res.status(500).json({ success: false, message: 'Failed to generate ward report' });
    }
  }

  async getDashboardStats(req, res) {
    try {
      const { tenantId } = req.user;
      const today = new Date();
      const startOfDay = new Date(today.setHours(0, 0, 0, 0));
      const endOfDay = new Date(today.setHours(23, 59, 59, 999));
      const startOfMonth = new Date(today.getFullYear(), today.getMonth(), 1);

      const [
        todayPatients,
        monthPatients,
        todayRevenue,
        monthRevenue,
        todayEncounters,
        pendingLab,
        pendingPharmacy,
        activeAdmissions
      ] = await Promise.all([
        db.models.Patient.count({
          where: { tenantId, createdAt: { [Op.between]: [startOfDay, endOfDay] } }
        }),
        db.models.Patient.count({
          where: { tenantId, createdAt: { [Op.gte]: startOfMonth } }
        }),
        db.models.BillingPayment.sum('amount', {
          where: { tenantId, status: 'completed', createdAt: { [Op.between]: [startOfDay, endOfDay] } }
        }),
        db.models.BillingPayment.sum('amount', {
          where: { tenantId, status: 'completed', createdAt: { [Op.gte]: startOfMonth } }
        }),
        db.models.Encounter.count({
          where: { tenantId, createdAt: { [Op.between]: [startOfDay, endOfDay] } }
        }),
        db.models.LabOrder.count({
          where: { tenantId, status: 'pending' }
        }),
        db.models.Dispensing.count({
          where: { tenantId, status: 'pending' }
        }),
        db.models.Admission.count({
          where: { tenantId, status: { [Op.in]: ['admitted', 'in_progress', 'stable', 'critical'] } }
        })
      ]);

      res.json({
        success: true,
        data: {
          patients: {
            today: todayPatients,
            thisMonth: monthPatients
          },
          revenue: {
            today: todayRevenue || 0,
            thisMonth: monthRevenue || 0
          },
          encounters: {
            today: todayEncounters
          },
          pending: {
            lab: pendingLab,
            pharmacy: pendingPharmacy
          },
          admissions: {
            active: activeAdmissions
          }
        }
      });
    } catch (error) {
      console.error('Error fetching dashboard stats:', error);
      res.status(500).json({ success: false, message: 'Failed to fetch dashboard stats' });
    }
  }

  async deleteReport(req, res) {
    try {
      const { tenantId } = req.user;
      const { id } = req.params;

      const report = await db.models.Report.findOne({ where: { id, tenantId } });
      if (!report) {
        return res.status(404).json({ success: false, message: 'Report not found' });
      }

      await report.destroy();
      res.json({ success: true, message: 'Report deleted successfully' });
    } catch (error) {
      console.error('Error deleting report:', error);
      res.status(500).json({ success: false, message: 'Failed to delete report' });
    }
  }
}

module.exports = new ReportController();
