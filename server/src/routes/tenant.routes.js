const express = require('express');
const router = express.Router();
const tenantController = require('../controllers/tenant.controller');
const { authenticate, authorize } = require('../middleware/auth.middleware');

router.get('/', authenticate, authorize('SUPER_ADMIN'), tenantController.list);
router.get('/:id', authenticate, tenantController.get);
router.post('/', tenantController.create);
router.put('/:id', authenticate, tenantController.update);
router.post('/:id/suspend', authenticate, authorize('SUPER_ADMIN'), tenantController.suspend);
router.post('/:id/reactivate', authenticate, authorize('SUPER_ADMIN'), tenantController.reactivate);

module.exports = router;
