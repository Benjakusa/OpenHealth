const express = require('express');
const router = express.Router();
const authController = require('../controllers/auth.controller');
const { authenticate } = require('../middleware/auth.middleware');

router.post('/login', authController.login);
router.post('/register', authController.register);
router.post('/tenant-register', authController.tenantRegister);
router.post('/forgot-password', authController.forgotPassword);
router.post('/reset-password', authController.resetPassword);
router.post('/refresh', authController.refresh);
router.post('/logout', authenticate, authController.logout);
router.get('/me', authenticate, authController.me);
router.post('/approve-user/:userId', authenticate, authController.approveUser);
router.get('/pending-users', authenticate, authController.getPendingUsers);
router.get('/clinics', authenticate, authController.listClinics);

module.exports = router;