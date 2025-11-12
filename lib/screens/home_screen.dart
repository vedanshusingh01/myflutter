import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../db/database_helper.dart';
import '../models/todo.dart';
import 'add_edit_todo_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final db = DatabaseHelper.instance;
  List<Todo> _todos = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _refreshTodos();
  }

  Future<void> _refreshTodos() async {
    setState(() => _loading = true);
    final todos = await db.getTodos();
    setState(() {
      _todos = todos;
      _loading = false;
    });
  }

  Future<void> _toggleDone(Todo todo) async {
    todo.isDone = todo.isDone == 1 ? 0 : 1;
    await db.updateTodo(todo);
    _refreshTodos();
  }

  Future<void> _deleteTodo(int id) async {
    await db.deleteTodo(id);
    _refreshTodos();
  }

  void _openAddEdit([Todo? todo]) async {
    final result = await Navigator.of(context).pushNamed(
      AddEditTodoScreen.routeName,
      arguments: todo,
    );
    if (result == true) {
      _refreshTodos();
    }
  }

  Widget _buildTile(Todo todo) {
    final due = todo.dueDate != null ? DateTime.tryParse(todo.dueDate!) : null;
    final dueText = due != null ? DateFormat.yMMMd().format(due) : null;

    return Dismissible(
      key: ValueKey(todo.id),
      background: Container(color: Colors.red, alignment: Alignment.centerLeft, padding: const EdgeInsets.only(left: 16), child: const Icon(Icons.delete, color: Colors.white)),
      secondaryBackground: Container(color: Colors.red, alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 16), child: const Icon(Icons.delete, color: Colors.white)),
      direction: DismissDirection.horizontal,
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Delete'),
            content: const Text('Are you sure you want to delete this todo?'),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('No')), 
              TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Yes')), 
            ],
          ),
        );
      },
      onDismissed: (_) {
        if (todo.id != null) _deleteTodo(todo.id!);
      },
      child: ListTile(
        leading: Checkbox(
          value: todo.isDone == 1,
          onChanged: (_) => _toggleDone(todo),
        ),
        title: Text(
          todo.title,
          style: TextStyle(decoration: todo.isDone == 1 ? TextDecoration.lineThrough : null),
        ),
        subtitle: dueText != null ? Text(dueText) : (todo.description != null ? Text(todo.description!) : null),
        onTap: () => _openAddEdit(todo),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo List'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _todos.isEmpty
              ? const Center(child: Text('No todos yet. Tap + to add one.'))
              : RefreshIndicator(
                  onRefresh: _refreshTodos,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _todos.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (ctx, i) => _buildTile(_todos[i]),
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddEdit(),
        child: const Icon(Icons.add),
      ),
    );
  }
}