const express = require('express');
const router = express.Router();
const facilityController = require('../controllers/facility.controller');
const { authenticate, authorize } = require('../middleware/auth.middleware');

router.get('/', authenticate, facilityController.list);
router.get('/:id', authenticate, facilityController.get);
router.post('/', authenticate, authorize('SUPER_ADMIN', 'FACILITY_ADMIN'), facilityController.create);
router.put('/:id', authenticate, authorize('SUPER_ADMIN', 'FACILITY_ADMIN'), facilityController.update);

module.exports = router;
