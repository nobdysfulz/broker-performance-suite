const mongoose = require('mongoose');

const BrokerageSchema = new mongoose.Schema({
  name: {
    type: String,
    required: [true, 'Please add a brokerage name'],
    trim: true,
    maxlength: [100, 'Name cannot be more than 100 characters']
  },
  email: {
    type: String,
    required: [true, 'Please add an email'],
    match: [
      /^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/,
      'Please add a valid email'
    ]
  },
  phone: {
    type: String,
    required: [true, 'Please add a phone number']
  },
  address: {
    street: { type: String, required: true },
    city: { type: String, required: true },
    state: { type: String, required: true },
    zipCode: { type: String, required: true }
  },
  licenseNumber: {
    type: String,
    required: [true, 'Please add a license number']
  },
  licenseState: {
    type: String,
    required: [true, 'Please add a license state']
  },
  owner: {
    type: mongoose.Schema.ObjectId,
    ref: 'User'
  },
  isActive: {
    type: Boolean,
    default: true
  }
}, {
  timestamps: true
});

module.exports = mongoose.model('Brokerage', BrokerageSchema);
