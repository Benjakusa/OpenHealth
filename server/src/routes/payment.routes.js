const express = require('express');
const router = express.Router();
const paymentController = require('../controllers/payment.controller');
const { authenticate, authorize } = require('../middleware/auth.middleware');

router.post('/mpesa/initiate', authenticate, paymentController.initiateMpesaPayment);
router.post('/mpesa/callback', paymentController.mpesaCallback);
router.get('/mpesa/status/:checkoutRequestId', authenticate, paymentController.checkMpesaStatus);

router.post('/refund', authenticate, authorize('ADMIN', 'BILLING_MANAGER', 'FINANCE_MANAGER'), paymentController.processRefund);

router.post('/cash', authenticate, authorize('BILLING_CLERK', 'BILLING_MANAGER', 'ADMIN'), paymentController.recordCashPayment);
router.post('/card', authenticate, authorize('BILLING_CLERK', 'BILLING_MANAGER', 'ADMIN'), paymentController.recordCardPayment);
router.post('/insurance', authenticate, authorize('BILLING_CLERK', 'BILLING_MANAGER', 'ADMIN'), paymentController.recordInsurancePayment);
router.post('/bank-transfer', authenticate, authorize('BILLING_CLERK', 'BILLING_MANAGER', 'ADMIN'), paymentController.recordBankTransfer);

router.get('/', authenticate, paymentController.getPayments);
router.get('/stats', authenticate, authorize('ADMIN', 'BILLING_MANAGER', 'FINANCE_MANAGER', 'REPORTS_ANALYST'), paymentController.getPaymentStats);
router.get('/:id', authenticate, paymentController.getPaymentById);
router.post('/:id/reverse', authenticate, authorize('ADMIN', 'BILLING_MANAGER', 'FINANCE_MANAGER'), paymentController.reversePayment);

module.exports = router;
