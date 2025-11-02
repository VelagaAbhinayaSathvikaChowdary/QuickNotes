import 'package:flutter/material.dart';
import '../models/note.dart';
import '../services/api_service.dart';

class EditNoteScreen extends StatefulWidget {
  final Note note;
  const EditNoteScreen({super.key, required this.note});
  @override
  State<EditNoteScreen> createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  late TextEditingController titleCtrl;
  late TextEditingController contentCtrl;
  List<ListItem> items = [];
  String color = '#ffffff';
  bool loading = false;

  @override
  void initState() {
    super.initState();
    titleCtrl = TextEditingController(text: widget.note.title);
    contentCtrl = TextEditingController(text: widget.note.content);
    items = widget.note.listItems.map((e) => ListItem(text: e.text, done: e.done)).toList();
    color = widget.note.color;
  }

  void _save() async {
    setState(() => loading = true);
    final updated = Note(
      id: widget.note.id,
      type: widget.note.type,
      title: titleCtrl.text,
      content: contentCtrl.text,
      color: color,
      listItems: items,
    );
    final ok = await ApiService.updateNote(widget.note.id, updated);
    setState(() => loading = false);
    if (ok && mounted) Navigator.pop(context);
    if (!ok) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to update')));
  }

  void _toggleItemDone(int idx) {
    setState(() => items[idx].done = !items[idx].done);
  }

  Widget _itemTile(int i) {
    final it = items[i];
    return Dismissible(
      key: UniqueKey(),
      onDismissed: (_) => setState(() => items.removeAt(i)),
      child: ListTile(
        leading: Checkbox(value: it.done, onChanged: (v) => _toggleItemDone(i)),
        title: Text(it.text, style: TextStyle(decoration: it.done ? TextDecoration.lineThrough : null)),
      ),
    );
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
        decoration: BoxDecoration(color: _hex(hex), shape: BoxShape.circle, border: color == hex ? Border.all(width: 3, color: Colors.black26) : null),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isList = widget.note.type == 'list';
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Note')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(children: [
          TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Title')),
          const SizedBox(height: 8),
          if (!isList)
            Expanded(child: TextField(controller: contentCtrl, maxLines: null, expands: true, decoration: const InputDecoration(labelText: 'Content', border: OutlineInputBorder()))),
          if (isList)
            Expanded(child: items.isEmpty ? const Center(child: Text('No items')) : ListView.builder(itemCount: items.length, itemBuilder: (_, i) => _itemTile(i))),
          const SizedBox(height: 8),
          SizedBox(height: 48, child: ListView(scrollDirection: Axis.horizontal, children: [
            _colorDot('#fff9c4'),
            _colorDot('#ffccbc'),
            _colorDot('#c8e6c9'),
            _colorDot('#bbdefb'),
            _colorDot('#f8bbd0'),
            _colorDot('#ffffff'),
          ])),
          const SizedBox(height: 12),
          SizedBox(
            width: 350,
              height: 50,
               child: ElevatedButton(onPressed: loading ? null : _save, child: loading ? const CircularProgressIndicator() : const Text('Update'))),
        ]),
      ),
    );
  }
}
