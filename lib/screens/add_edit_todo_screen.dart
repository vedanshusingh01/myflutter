import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../db/database_helper.dart';
import '../models/todo.dart';

class AddEditTodoScreen extends StatefulWidget {
  static const routeName = '/add-edit-todo';
  const AddEditTodoScreen({super.key});

  @override
  State<AddEditTodoScreen> createState() => _AddEditTodoScreenState();
}

class _AddEditTodoScreenState extends State<AddEditTodoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  DateTime? _dueDate;
  bool _isSaving = false;
  Todo? _editing;
  final db = DatabaseHelper.instance;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments;
    if (args != null && args is Todo) {
      _editing = args;
      _titleCtrl.text = _editing!.title;
      _descCtrl.text = _editing!.description ?? '';
      if (_editing!.dueDate != null) {
        _dueDate = DateTime.tryParse(_editing!.dueDate!);
      }
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 10),
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final todo = Todo(
      id: _editing?.id,
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      dueDate: _dueDate != null ? _dueDate!.toIso8601String() : null,
      isDone: _editing?.isDone ?? 0,
    );

    if (_editing == null) {
      await db.insertTodo(todo);
    } else {
      await db.updateTodo(todo);
    }

    setState(() => _isSaving = false);
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final title = _editing == null ? 'Add Todo' : 'Edit Todo';
    final dueText = _dueDate != null ? DateFormat.yMMMd().format(_dueDate!) : 'Pick due date';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          if (_editing != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Delete'),
                    content: const Text('Delete this todo?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('No')), 
                      TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Yes')), 
                    ],
                  ),
                );
                if (confirmed == true && _editing!.id != null) {
                  await db.deleteTodo(_editing!.id!);
                  Navigator.of(context).pop(true);
                }
              },
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _isSaving
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _titleCtrl,
                        decoration: const InputDecoration(labelText: 'Title'),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Please enter a title' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _descCtrl,
                        decoration: const InputDecoration(labelText: 'Description'),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: Text(dueText)),
                          TextButton(
                            onPressed: _pickDueDate,
                            child: const Text('Select Date'),
                          ),
                          if (_dueDate != null)
                            IconButton(
                              onPressed: () => setState(() => _dueDate = null),
                              icon: const Icon(Icons.clear),
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _save,
                        child: Text(_editing == null ? 'Create' : 'Update'),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}