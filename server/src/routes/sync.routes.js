const express = require('express');
const router = express.Router();
const syncController = require('../controllers/sync.controller');
const { authenticate } = require('../middleware/auth.middleware');

router.use(authenticate);

router.post('/push', syncController.push);
router.get('/pull', syncController.pull);
router.get('/status', syncController.status);
router.get('/conflicts', syncController.getConflicts);
router.post('/resolve', syncController.resolveConflict);

module.exports = router;
