'use strict';
const express = require('express');
const router = express.Router();
const wardController = require('../controllers/ward.controller');
const { authenticate, authorize } = require('../middleware/auth.middleware');

router.use(authenticate);

router.get('/wards', wardController.getWards);
router.get('/wards/:id', wardController.getWard);
router.post('/wards', authorize('WARD_MANAGER', 'ADMIN', 'SUPER_ADMIN'), wardController.createWard);
router.put('/wards/:id', authorize('WARD_MANAGER', 'ADMIN', 'SUPER_ADMIN'), wardController.updateWard);
router.delete('/wards/:id', authorize('ADMIN', 'SUPER_ADMIN'), wardController.deleteWard);
router.get('/wards/:id/dashboard', authorize('WARD_MANAGER', 'NURSE', 'DOCTOR', 'ADMIN', 'SUPER_ADMIN'), wardController.getWardDashboard);

router.get('/beds', wardController.getBeds);
router.post('/beds', authorize('WARD_MANAGER', 'ADMIN', 'SUPER_ADMIN'), wardController.createBed);
router.put('/beds/:id', authorize('WARD_MANAGER', 'ADMIN', 'SUPER_ADMIN'), wardController.updateBed);

router.get('/admissions', wardController.getAdmissions);
router.get('/admissions/:id', wardController.getAdmission);
router.post('/admissions', authorize('DOCTOR', 'NURSE', 'ADMIN', 'SUPER_ADMIN'), wardController.createAdmission);
router.post('/admissions/:id/transfer', authorize('DOCTOR', 'NURSE', 'WARD_MANAGER', 'ADMIN', 'SUPER_ADMIN'), wardController.transferPatient);
router.post('/admissions/:id/discharge', authorize('DOCTOR', 'ADMIN', 'SUPER_ADMIN'), wardController.dischargePatient);

router.get('/nursing-notes', wardController.getNursingNotes);
router.post('/nursing-notes', authorize('NURSE', 'DOCTOR', 'WARD_MANAGER', 'ADMIN', 'SUPER_ADMIN'), wardController.createNursingNote);

router.get('/mar', wardController.getMedicationAdministrationRecords);
router.post('/mar', authorize('NURSE', 'WARD_MANAGER', 'ADMIN', 'SUPER_ADMIN'), wardController.createMarFromPrescription);
router.post('/mar/:id/administer', authorize('NURSE', 'ADMIN', 'SUPER_ADMIN'), wardController.administerMedication);

module.exports = router;
