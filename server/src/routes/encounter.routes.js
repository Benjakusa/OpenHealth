const express = require('express');
const router = express.Router();
const encounterController = require('../controllers/encounter.controller');
const { authenticate } = require('../middleware/auth.middleware');

router.use(authenticate);

router.get('/', encounterController.list);
router.get('/:id', encounterController.get);
router.post('/', encounterController.create);
router.put('/:id', encounterController.update);
router.post('/:id/triage', encounterController.addTriage);
router.post('/:id/soap', encounterController.addSoap);
router.post('/:id/diagnosis', encounterController.addDiagnosis);
router.post('/:id/prescription', encounterController.addPrescription);
router.post('/:id/lab-order', encounterController.addLabOrder);
router.post('/:id/complete', encounterController.complete);
router.post('/:id/refer', encounterController.refer);

module.exports = router;
