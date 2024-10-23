import 'package:flutter/material.dart';
import 'todo.dart';
import 'todo_service.dart';

void main() => runApp(TodoApp());

class TodoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TodoListScreen(),
    );
  }
}

class TodoListScreen extends StatefulWidget {
  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  late Future<List<Todo>> futureTodos;
  final TodoService todoService = TodoService();

  @override
  void initState() {
    super.initState();
    futureTodos = todoService.fetchTodos();
  }

  void _addTodo() async {
    String title = await _showAddTodoDialog();
    if (title.isNotEmpty) {
      setState(() {
        futureTodos = todoService.createTodo(title).then((newTodo) {
          return [...futureTodos as List<Todo>, newTodo];
        });
      });
    }
  }

  Future<String> _showAddTodoDialog() async {
    String newTitle = '';
    return await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add a new todo'),
          content: TextField(
            onChanged: (value) {
              newTitle = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, newTitle),
              child: Text('Add'),
            ),
          ],
        );
      },
    ) ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo List'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _addTodo,
          ),
        ],
      ),
      body: FutureBuilder<List<Todo>>(
        future: futureTodos,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                Todo todo = snapshot.data![index];
                return ListTile(
                  title: Text(todo.title),
                  trailing: Checkbox(
                    value: todo.completed,
                    onChanged: (bool? value) {
                      setState(() {
                        todo.completed = value!;
                        todoService.updateTodo(todo);
                      });
                    },
                  ),
                  onLongPress: () {
                    todoService.deleteTodo(todo.id).then((_) {
                      setState(() {
                        futureTodos = todoService.fetchTodos();
                      });
                    });
                  },
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
