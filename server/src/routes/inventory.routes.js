const express = require('express');
const router = express.Router();
const inventoryController = require('../controllers/inventory.controller');
const { authenticate } = require('../middleware/auth.middleware');

router.use(authenticate);

router.get('/', inventoryController.list);
router.get('/:id', inventoryController.get);
router.post('/', inventoryController.create);
router.put('/:id', inventoryController.update);
router.post('/:id/batches', inventoryController.addBatch);
router.post('/:id/dispense', inventoryController.dispense);
router.get('/low-stock/alerts', inventoryController.getLowStockAlerts);
router.get('/expiring/alerts', inventoryController.getExpiringAlerts);

module.exports = router;
