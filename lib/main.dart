import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/add_edit_todo_screen.dart';
import 'models/todo.dart';

void main() {
  runApp(const TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo SQLite CRUD',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: const HomeScreen(),
      routes: {
        AddEditTodoScreen.routeName: (ctx) => const AddEditTodoScreen(),
      },
    );
  }
}