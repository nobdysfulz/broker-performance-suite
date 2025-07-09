const User = require('../models/User');
const Transaction = require('../models/Transaction');
const Brokerage = require('../models/Brokerage');
const logger = require('../utils/logger');
const moment = require('moment');

// @desc    Get broker dashboard data
// @route   GET /api/dashboard/broker
// @access  Private (Broker only)
exports.getBrokerDashboard = async (req, res) => {
  try {
    const { days = 30 } = req.query;
    const startDate = moment().subtract(days, 'days').toDate();
    const brokerage = req.user.brokerage;

    // Mock data for demonstration
    const mockData = {
      revenue: 125000,
      revenueChange: 12.5,
      activeAgents: 8,
      agentsChange: 2.1,
      transactions: 15,
      transactionsChange: 8.3,
      avgDealSize: 8333,
      dealSizeChange: -2.1,
      topPerformers: [
        { id: 1, name: 'John Smith', transactions: 5, revenue: 45000 },
        { id: 2, name: 'Sarah Johnson', transactions: 4, revenue: 38000 },
        { id: 3, name: 'Mike Davis', transactions: 3, revenue: 28000 }
      ],
      recentTransactions: [
        {
          id: 1,
          property: '123 Main St',
          address: 'Anytown, ST',
          agent: 'John Smith',
          amount: 350000,
          status: 'closed',
          date: new Date()
        },
        {
          id: 2,
          property: '456 Oak Ave',
          address: 'Somewhere, ST',
          agent: 'Sarah Johnson',
          amount: 425000,
          status: 'pending',
          date: new Date()
        }
      ]
    };

    res.status(200).json({
      success: true,
      data: mockData
    });
  } catch (error) {
    logger.error('Broker dashboard error:', error);
    res.status(500).json({
      success: false,
      error: 'Server error'
    });
  }
};

// @desc    Get agent dashboard data
// @route   GET /api/dashboard/agent
// @access  Private (Agent only)
exports.getAgentDashboard = async (req, res) => {
  try {
    const agentId = req.user.id;

    // Mock data for demonstration
    const mockData = {
      transactions: 3,
      transactionGoal: 5,
      revenue: 25000,
      revenueGoal: 50000,
      activeListings: 8,
      recentActivity: [
        {
          description: 'New listing added: 123 Main St',
          timestamp: new Date()
        },
        {
          description: 'Showing scheduled for tomorrow',
          timestamp: moment().subtract(1, 'hour').toDate()
        }
      ],
      upcomingTasks: [
        {
          title: 'Follow up with client',
          dueDate: moment().add(1, 'day').toDate(),
          priority: 'high'
        },
        {
          title: 'Prepare listing presentation',
          dueDate: moment().add(2, 'days').toDate(),
          priority: 'medium'
        }
      ]
    };

    res.status(200).json({
      success: true,
      data: mockData
    });
  } catch (error) {
    logger.error('Agent dashboard error:', error);
    res.status(500).json({
      success: false,
      error: 'Server error'
    });
  }
};

// @desc    Get admin dashboard data
// @route   GET /api/dashboard/admin
// @access  Private (Admin only)
exports.getAdminDashboard = async (req, res) => {
  try {
    // Mock data for demonstration
    const mockData = {
      brokerages: 5,
      activeUsers: 42,
      transactions: 150,
      systemLoad: Math.floor(Math.random() * 100),
      alerts: [
        {
          type: 'info',
          message: 'System backup completed successfully',
          timestamp: new Date()
        },
        {
          type: 'warning',
          message: 'High memory usage detected',
          timestamp: moment().subtract(30, 'minutes').toDate()
        }
      ],
      userActivity: [
        {
          user: 'John Doe',
          action: 'Created new transaction',
          timestamp: new Date()
        },
        {
          user: 'Jane Smith',
          action: 'Updated profile',
          timestamp: moment().subtract(15, 'minutes').toDate()
        }
      ]
    };

    res.status(200).json({
      success: true,
      data: mockData
    });
  } catch (error) {
    logger.error('Admin dashboard error:', error);
    res.status(500).json({
      success: false,
      error: 'Server error'
    });
  }
};
