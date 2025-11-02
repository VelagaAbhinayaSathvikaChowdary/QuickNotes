import 'package:flutter/material.dart';
import '../models/note.dart';
import '../services/api_service.dart';

class AddListScreen extends StatefulWidget {
  const AddListScreen({super.key});
  @override
  State<AddListScreen> createState() => _AddListScreenState();
}

class _AddListScreenState extends State<AddListScreen> {
  final titleCtrl = TextEditingController();
  final itemCtrl = TextEditingController();
  List<ListItem> items = [];
  String color = '#ffe0b2';
  bool loading = false;

  void _addItem() {
    final t = itemCtrl.text.trim();
    if (t.isEmpty) return;
    setState(() {
      items.add(ListItem(text: t, done: false));
      itemCtrl.clear();
    });
  }

  void _save() async {
    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add at least one item')));
      return;
    }
    setState(() => loading = true);
    final note = Note(id: '', type: 'list', title: titleCtrl.text, content: '', color: color, listItems: items);
    final ok = await ApiService.createNote(note);
    setState(() => loading = false);
    if (ok && mounted) Navigator.pop(context);
    if (!ok) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to save')));
  }

  Widget _itemTile(int i) {
    final it = items[i];
    return Dismissible(
      key: UniqueKey(),
      onDismissed: (_) => setState(() => items.removeAt(i)),
      child: ListTile(
        leading: Checkbox(value: it.done, onChanged: (v) => setState(() => it.done = v ?? false)),
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
    return Scaffold(
      appBar: AppBar(title: const Text('Add List')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(children: [
          TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Title')),
          Row(children: [
            Expanded(child: TextField(controller: itemCtrl, decoration: const InputDecoration(labelText: 'New item'))),
            IconButton(onPressed: _addItem, icon: const Icon(Icons.add))
          ]),
          const SizedBox(height: 8),
          Expanded(child: items.isEmpty ? const Center(child: Text('No items yet')) : ListView.builder(itemCount: items.length, itemBuilder: (_, i) => _itemTile(i))),
          const SizedBox(height: 8),
          SizedBox(
            height: 48,
            child: ListView(scrollDirection: Axis.horizontal, children: [
              _colorDot('#ffe0b2'),
              _colorDot('#c5e1a5'),
              _colorDot('#b3e5fc'),
              _colorDot('#f8bbd0'),
              _colorDot('#fff9c4'),
              _colorDot('#ffffff'),
            ]),
          ),
          const SizedBox(height: 8),
          SizedBox(width: 350,
              height: 50,
               child: ElevatedButton(onPressed: loading ? null : _save, child: loading ? const CircularProgressIndicator() : const Text('Save List'))),
        ]),
      ),
    );
  }
}
