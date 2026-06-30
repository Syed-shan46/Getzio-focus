const express = require('express');
const router = express.Router();
const StickyNote = require('../models/StickyNote');

// CREATE a Sticky Note
router.post('/', async (req, res) => {
  try {
    const stickyNote = new StickyNote(req.body);
    const saved = await stickyNote.save();
    res.status(201).json(saved);
  } catch (error) {
    console.error(error);
    res.status(400).json({ message: error.message });
  }
});

// GET all Sticky Notes for a user
router.get('/', async (req, res) => {
  try {
    const { userId } = req.query;
    if (!userId) {
      return res.status(400).json({ message: 'userId query parameter is required' });
    }
    const notes = await StickyNote.find({ userId, deleted: false });
    res.json(notes);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: error.message });
  }
});

// UPDATE a Sticky Note
router.patch('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    
    // Remove protected fields from the body so they don't conflict with MongoDB operators
    const updateFields = { ...req.body };
    delete updateFields.syncVersion;
    delete updateFields._id;
    delete updateFields.id;
    
    // Bump sync version automatically on updates
    const updated = await StickyNote.findByIdAndUpdate(id, { 
      $set: updateFields, 
      $inc: { syncVersion: 1 } 
    }, { new: true });
    
    if (!updated) return res.status(404).json({ message: 'Sticky Note not found' });
    res.json(updated);
  } catch (error) {
    console.error(error);
    res.status(400).json({ message: error.message });
  }
});

// DELETE a Sticky Note (Soft Delete)
router.delete('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const updated = await StickyNote.findByIdAndUpdate(
      id, 
      { deleted: true, $inc: { syncVersion: 1 } }, 
      { new: true }
    );
    if (!updated) return res.status(404).json({ message: 'Sticky Note not found' });
    res.json(updated);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;
