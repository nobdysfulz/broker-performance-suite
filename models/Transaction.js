const mongoose = require('mongoose');

const TransactionSchema = new mongoose.Schema({
  transactionId: {
    type: String,
    unique: true,
    required: true
  },
  type: {
    type: String,
    enum: ['sale', 'purchase', 'lease', 'rental'],
    required: true
  },
  status: {
    type: String,
    enum: ['pending', 'active', 'under-contract', 'closed', 'cancelled'],
    default: 'pending'
  },
  property: {
    address: {
      street: { type: String, required: true },
      city: { type: String, required: true },
      state: { type: String, required: true },
      zipCode: { type: String, required: true }
    },
    propertyType: {
      type: String,
      enum: ['single-family', 'condo', 'townhouse', 'multi-family', 'commercial'],
      required: true
    }
  },
  pricing: {
    listPrice: { type: Number, required: true },
    salePrice: Number,
    commission: {
      rate: { type: Number, required: true },
      amount: Number
    }
  },
  parties: {
    listingAgent: {
      type: mongoose.Schema.ObjectId,
      ref: 'User'
    },
    buyingAgent: {
      type: mongoose.Schema.ObjectId,
      ref: 'User'
    }
  },
  dates: {
    listed: Date,
    closed: Date
  },
  brokerage: {
    type: mongoose.Schema.ObjectId,
    ref: 'Brokerage',
    required: true
  }
}, {
  timestamps: true
});

// Generate transaction ID
TransactionSchema.pre('save', function(next) {
  if (!this.transactionId) {
    const date = new Date();
    const year = date.getFullYear().toString().substr(-2);
    const month = (date.getMonth() + 1).toString().padStart(2, '0');
    const random = Math.floor(Math.random() * 10000).toString().padStart(4, '0');
    this.transactionId = `TXN${year}${month}${random}`;
  }
  next();
});

module.exports = mongoose.model('Transaction', TransactionSchema);
