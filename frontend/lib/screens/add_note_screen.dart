import 'package:flutter/material.dart';
import '../models/note.dart';
import '../services/api_service.dart';

class AddNoteScreen extends StatefulWidget {
  const AddNoteScreen({super.key});
  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final titleCtrl = TextEditingController();
  final contentCtrl = TextEditingController();
  String color = '#ffffff';
  bool loading = false;

  void _save() async {
    if (titleCtrl.text.trim().isEmpty && contentCtrl.text.trim().isEmpty) return;

    setState(() => loading = true);

    final note = Note(
      id: '',
      type: 'note', // Changed from 'text' to 'note'
      title: titleCtrl.text.trim(),
      content: contentCtrl.text.trim(),
      color: color,
      listItems: [], // Added empty list to satisfy model
    );

    final ok = await ApiService.createNote(note);
    setState(() => loading = false);

    if (ok && mounted) Navigator.pop(context);
    if (!ok) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Failed to save')));
    }
  }

  Color _hex(String h) {
    final hh = h.replaceFirst('#', '');
    final s = hh.length == 3 ? hh.split('').map((c) => '$c$c').join() : hh;
    return Color(int.parse('0xff$s'));
  }

  Widget _colorDot(String hex) {
    return GestureDetector(
      onTap: () => setState(() => color = hex),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: _hex(hex),
          shape: BoxShape.circle,
          border: color == hex
              ? Border.all(width: 3, color: Colors.black26)
              : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Note')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: TextField(
                controller: contentCtrl,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(
                  labelText: 'Content',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _colorDot('#fff9c4'),
                  _colorDot('#ffccbc'),
                  _colorDot('#c8e6c9'),
                  _colorDot('#bbdefb'),
                  _colorDot('#f8bbd0'),
                  _colorDot('#ffffff'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: 350,
              height: 50,
              child: ElevatedButton(
                onPressed: loading ? null : _save,
                child: loading
                    ? const CircularProgressIndicator()
                    : const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
