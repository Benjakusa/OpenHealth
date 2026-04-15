const express = require('express');
const router = express.Router();
const pharmacyController = require('../controllers/pharmacy.controller');
const { authenticate } = require('../middleware/auth.middleware');

router.use(authenticate);

router.get('/prescriptions', pharmacyController.listPrescriptions);
router.get('/prescriptions/:id', pharmacyController.getPrescription);
router.post('/prescriptions', pharmacyController.createPrescription);
router.put('/prescriptions/:id', pharmacyController.updatePrescription);
router.post('/prescriptions/:id/dispense', pharmacyController.dispensePrescription);
router.post('/prescriptions/:id/cancel', pharmacyController.cancelPrescription);

module.exports = router;
