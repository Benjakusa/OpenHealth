const express = require('express');
const router = express.Router();
const userController = require('../controllers/user.controller');
const { authenticate, authorize } = require('../middleware/auth.middleware');

router.use(authenticate);

router.get('/', userController.list);
router.get('/:id', userController.get);
router.post('/', authorize('FACILITY_ADMIN', 'SUPER_ADMIN'), userController.create);
router.put('/:id', userController.update);
router.put('/:id/deactivate', authorize('FACILITY_ADMIN', 'SUPER_ADMIN'), userController.deactivate);
router.put('/:id/activate', authorize('FACILITY_ADMIN', 'SUPER_ADMIN'), userController.activate);

module.exports = router;
