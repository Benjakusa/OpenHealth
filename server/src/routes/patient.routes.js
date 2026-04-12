const express = require('express');
const router = express.Router();
const patientController = require('../controllers/patient.controller');
const { authenticate } = require('../middleware/auth.middleware');

router.use(authenticate);

router.get('/', patientController.list);
router.get('/:id', patientController.get);
router.post('/', patientController.create);
router.put('/:id', patientController.update);
router.delete('/:id', patientController.delete);
router.get('/:id/encounters', patientController.getEncounters);
router.get('/:id/billing', patientController.getBilling);
router.post('/:id/verify-sha', patientController.verifySha);

module.exports = router;
