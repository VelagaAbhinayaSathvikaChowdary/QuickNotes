import express from 'express';
import Note from '../models/Note.js';
import auth from '../middleware/auth.js';

const router = express.Router();

// CREATE NOTE / LIST
router.post('/create', auth, async (req, res) => {
  try {
    const { title, content, type, color, listItems } = req.body;
    const note = new Note({
      title: title || '',
      content: content || '',
      type: type || 'note',
      color: color || '#ffffff',
      listItems: listItems || [],
      userId: req.user.id,
    });
    await note.save();
    res.status(201).json(note);
  } catch (err) {
    console.error('Error creating note:', err);
    res.status(500).json({ error: 'Failed to create note' });
  }
});

// GET ALL NOTES FOR USER
router.get('/all', auth, async (req, res) => {
  try {
    const notes = await Note.find({ userId: req.user.id }).sort({ updatedAt: -1 });
    res.status(200).json(notes);
  } catch (err) {
    console.error('Error fetching notes:', err);
    res.status(500).json({ error: 'Failed to fetch notes' });
  }
});

// UPDATE NOTE / LIST
router.put('/update/:id', auth, async (req, res) => {
  try {
    const { id } = req.params;
    const { title, content, type, color, listItems } = req.body;

    const updated = await Note.findOneAndUpdate(
      { _id: id, userId: req.user.id },
      { title, content, type, color, listItems },
      { new: true }
    );

    if (!updated) return res.status(404).json({ error: 'Note not found' });
    res.status(200).json(updated);
  } catch (err) {
    console.error('Error updating note:', err);
    res.status(500).json({ error: 'Failed to update note' });
  }
});

// DELETE NOTE
router.delete('/delete/:id', auth, async (req, res) => {
  try {
    const { id } = req.params;
    const deleted = await Note.findOneAndDelete({ _id: id, userId: req.user.id });
    if (!deleted) return res.status(404).json({ error: 'Note not found' });
    res.status(200).json({ msg: 'Deleted successfully' });
  } catch (err) {
    console.error('Error deleting note:', err);
    res.status(500).json({ error: 'Failed to delete note' });
  }
});

// TOGGLE LIST ITEM DONE
router.put('/toggle-item/:noteId/:itemIndex', auth, async (req, res) => {
  try {
    const { noteId, itemIndex } = req.params;
    const note = await Note.findOne({ _id: noteId, userId: req.user.id });
    if (!note) return res.status(404).json({ error: 'Note not found' });

    note.listItems[itemIndex].done = !note.listItems[itemIndex].done;
    await note.save();

    res.status(200).json(note);
  } catch (err) {
    console.error('Error toggling list item:', err);
    res.status(500).json({ error: 'Failed to toggle list item' });
  }
});

export default router;
