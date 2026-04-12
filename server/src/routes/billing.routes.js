const express = require('express');
const router = express.Router();
const billingController = require('../controllers/billing.controller');
const { authenticate } = require('../middleware/auth.middleware');

router.use(authenticate);

router.get('/', billingController.list);
router.get('/:id', billingController.get);
router.post('/', billingController.create);
router.put('/:id', billingController.update);
router.post('/:id/items', billingController.addItem);
router.delete('/:id/items/:itemId', billingController.removeItem);
router.post('/:id/payments', billingController.addPayment);
router.post('/:id/calculate', billingController.calculate);
router.post('/:id/waive', billingController.waive);

module.exports = router;
