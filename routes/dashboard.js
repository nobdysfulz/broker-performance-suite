const express = require('express');
const {
  getBrokerDashboard,
  getAgentDashboard,
  getAdminDashboard
} = require('../controllers/dashboard');
const { protect, authorize } = require('../middlewares/auth');

const router = express.Router();

router.get('/broker', protect, authorize('broker', 'admin'), getBrokerDashboard);
router.get('/agent', protect, authorize('agent', 'broker', 'admin'), getAgentDashboard);
router.get('/admin', protect, authorize('admin'), getAdminDashboard);

module.exports = router;
