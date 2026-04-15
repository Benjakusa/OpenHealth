const express = require('express');
const router = express.Router();

const authRoutes = require('./auth.routes');
const tenantRoutes = require('./tenant.routes');
const userRoutes = require('./user.routes');
const patientRoutes = require('./patient.routes');
const encounterRoutes = require('./encounter.routes');
const billingRoutes = require('./billing.routes');
const inventoryRoutes = require('./inventory.routes');
const wardRoutes = require('./ward.routes');
const reportRoutes = require('./report.routes');
const syncRoutes = require('./sync.routes');
const paymentRoutes = require('./payment.routes');
const claimRoutes = require('./claim.routes');
const pharmacyRoutes = require('./pharmacy.routes');

const facilityRoutes = require('./facility.routes');

router.use('/auth', authRoutes);
router.use('/tenants', tenantRoutes);
router.use('/facilities', facilityRoutes);
router.use('/users', userRoutes);
router.use('/patients', patientRoutes);
router.use('/encounters', encounterRoutes);
router.use('/billing', billingRoutes);
router.use('/inventory', inventoryRoutes);
router.use('/ward', wardRoutes);
router.use('/reports', reportRoutes);
router.use('/sync', syncRoutes);
router.use('/payments', paymentRoutes);
router.use('/claims', claimRoutes);
router.use('/pharmacy', pharmacyRoutes);

module.exports = router;
