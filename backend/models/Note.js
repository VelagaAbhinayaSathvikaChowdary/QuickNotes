import mongoose from 'mongoose';

const listItemSchema = new mongoose.Schema({
  text: { type: String, required: true },
  done: { type: Boolean, default: false },
});

const noteSchema = new mongoose.Schema({
  title: { type: String, required: true },
  content: { type: String, default: '' },
  type: { type: String, enum: ['note', 'list'], default: 'note' },
  color: { type: String, default: '#ffffff' },
  listItems: [listItemSchema],
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
}, { timestamps: true });

export default mongoose.model('Note', noteSchema);
