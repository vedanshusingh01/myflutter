class Todo {
  int? id;
  String title;
  String? description;
  String? dueDate; // ISO string e.g. "2025-11-11"
  int isDone; // 0 or 1

  Todo({
    this.id,
    required this.title,
    this.description,
    this.dueDate,
    this.isDone = 0,
  });

  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String?,
      dueDate: map['dueDate'] as String?,
      isDone: map['isDone'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'title': title,
      'description': description,
      'dueDate': dueDate,
      'isDone': isDone,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }
}