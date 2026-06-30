const mongoose = require('mongoose');

const stickyNoteSchema = new mongoose.Schema({
  _id: { type: String, required: true },
  userId: { type: String, required: true, index: true },
  title: { type: String, required: true },
  description: { type: String, default: '' },
  progress: { 
    type: Number, 
    default: 0,
    min: 0,
    max: 100,
    validate: {
      validator: Number.isInteger,
      message: '{VALUE} is not an integer value'
    }
  },
  dueDate: { type: Date, default: null },
  priority: { 
    type: String, 
    enum: ['Low', 'Medium', 'High'], 
    default: 'Low' 
  },
  category: { type: String, default: 'Personal' },
  position: {
    x: { type: Number, default: 0 },
    y: { type: Number, default: 0 },
    zIndex: { type: Number, default: 0 }
  },
  rotation: { type: Number, default: 0 },
  scale: { type: Number, default: 1 },
  pinStyle: { type: String, default: 'default' },
  color: { type: String, default: '#FFFFFF' },
  syncVersion: { type: Number, default: 1 },
  deleted: { type: Boolean, default: false }
}, {
  timestamps: true // Automatically adds createdAt and updatedAt
});

module.exports = mongoose.model('StickyNote', stickyNoteSchema);
