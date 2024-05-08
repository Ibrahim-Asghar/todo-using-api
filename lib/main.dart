import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class Todo {
  final String id;
  final String title;
  final bool completed;

  Todo({
    required this.id,
    required this.title,
    required this.completed,
  });

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      completed: json['completed'] ?? false,
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TodoListScreen(),
    );
  }
}

class TodoListScreen extends StatefulWidget {
  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  List<Todo> todos = [];
  bool isLoading = false;
  final String apiKey = '447580f1afe8444b96b451b1db74b51d';

  @override
  void initState() {
    super.initState();
    fetchTodos();
  }

  Future<void> fetchTodos() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response =
          await http.get(Uri.parse('https://crudcrud.com/api/$apiKey/todos'));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          todos = data.map((item) => Todo.fromJson(item)).toList();
        });
      } else {
        throw Exception('Failed to load todos: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> addTodo(String title) async {
    try {
      final response = await http.post(
        Uri.parse('https://crudcrud.com/api/$apiKey/todos'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'title': title,
          'completed': false,
        }),
      );
      if (response.statusCode == 201) {
        fetchTodos();
      } else {
        throw Exception('Failed to add todo: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> updateTodo(String id, String title) async {
    try {
      final response = await http.put(
        Uri.parse('https://crudcrud.com/api/$apiKey/todos/$id'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'title': title,
        }),
      );
      if (response.statusCode == 200) {
        fetchTodos();
      } else {
        throw Exception('Failed to update todo: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> deleteTodo(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('https://crudcrud.com/api/$apiKey/todos/$id'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      if (response.statusCode == 200) {
        fetchTodos();
      } else {
        throw Exception('Failed to delete todo: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _showTodoDialog({String? id, String? title}) async {
    TextEditingController _dialogController =
        TextEditingController(text: title);

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(id != null ? 'Update Todo' : 'Add Todo'),
          content: TextField(
            controller: _dialogController,
            decoration: InputDecoration(
              hintText: 'Enter a todo...',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (id != null) {
                  await updateTodo(id, _dialogController.text);
                } else {
                  await addTodo(_dialogController.text);
                }
                Navigator.of(context).pop();
              },
              child: Text(id != null ? 'Update' : 'Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        centerTitle: true,
        title: Text('Todo List'),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: <Widget>[
                Expanded(
                  child: ListView.builder(
                    itemCount: todos.length,
                    itemBuilder: (context, index) {
                      final todo = todos[index];
                      return Card(
                        color: Colors.yellow,
                        margin:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        child: Column(
                          children: <Widget>[
                            ListTile(
                              title: Text(todo.title),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.update),
                                    onPressed: () {
                                      _showTodoDialog(
                                          id: todo.id, title: todo.title);
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () {
                                      deleteTodo(todo.id);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        onPressed: () {
          _showTodoDialog();
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
