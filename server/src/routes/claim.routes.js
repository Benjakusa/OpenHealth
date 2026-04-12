const express = require('express');
const router = express.Router();
const claimController = require('../controllers/claim.controller');
const { authenticate, authorize } = require('../middleware/auth.middleware');

router.post('/sha', authenticate, authorize('BILLING_CLERK', 'BILLING_MANAGER', 'CLAIMS_OFFICER', 'ADMIN'), claimController.submitShaClaim);
router.post('/pre-authorization', authenticate, authorize('DOCTOR', 'CLAIMS_OFFICER', 'BILLING_MANAGER', 'ADMIN'), claimController.submitPreAuthorization);
router.get('/verify-insurance', authenticate, authorize('BILLING_CLERK', 'BILLING_MANAGER', 'CLAIMS_OFFICER', 'REGISTRATION_CLERK', 'ADMIN'), claimController.verifyInsurance);
router.get('/benefits', authenticate, claimController.getBenefits);
router.get('/status/:claimReference', authenticate, claimController.checkClaimStatus);
router.post('/bulk', authenticate, authorize('CLAIMS_OFFICER', 'BILLING_MANAGER', 'ADMIN'), claimController.submitBulkClaims);

router.get('/', authenticate, claimController.getClaims);
router.get('/stats', authenticate, authorize('ADMIN', 'CLAIMS_OFFICER', 'BILLING_MANAGER', 'REPORTS_ANALYST'), claimController.getClaimStats);
router.get('/:id', authenticate, claimController.getClaimById);
router.patch('/:id/status', authenticate, authorize('CLAIMS_OFFICER', 'BILLING_MANAGER', 'ADMIN'), claimController.updateClaimStatus);

module.exports = router;
