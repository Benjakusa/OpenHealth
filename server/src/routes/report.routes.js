'use strict';
const express = require('express');
const router = express.Router();
const reportController = require('../controllers/report.controller');
const { authenticate, authorize } = require('../middleware/auth.middleware');

router.use(authenticate);

router.get('/templates', reportController.getTemplates);
router.get('/templates/:id', reportController.getTemplate);
router.post('/templates', authorize('ADMIN', 'SUPER_ADMIN', 'REPORTS_ANALYST'), reportController.createTemplate);

router.get('/', reportController.getReports);
router.get('/dashboard', reportController.getDashboardStats);
router.get('/revenue', authorize('ADMIN', 'SUPER_ADMIN', 'BILLING_CLERK', 'REPORTS_ANALYST'), reportController.getRevenueReport);
router.get('/clinical', authorize('ADMIN', 'SUPER_ADMIN', 'DOCTOR', 'CLINICIAN', 'REPORTS_ANALYST'), reportController.getClinicalReport);
router.get('/patients', authorize('ADMIN', 'SUPER_ADMIN', 'RECEPTIONIST', 'REPORTS_ANALYST'), reportController.getPatientReport);
router.get('/inventory', authorize('ADMIN', 'SUPER_ADMIN', 'PHARMACIST', 'STORE_MANAGER', 'REPORTS_ANALYST'), reportController.getInventoryReport);
router.get('/ward', authorize('ADMIN', 'SUPER_ADMIN', 'WARD_MANAGER', 'NURSE', 'REPORTS_ANALYST'), reportController.getWardReport);

router.post('/generate', reportController.generateReport);
router.get('/:id', reportController.getReport);
router.delete('/:id', authorize('ADMIN', 'SUPER_ADMIN'), reportController.deleteReport);

module.exports = router;
