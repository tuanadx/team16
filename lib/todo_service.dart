import 'package:baitap1/todo.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Fetch ToDo List (READ)
Future<List<ToDo>> fetchToDos() async {
  final response = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/todos'));

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((data) => ToDo.fromJson(data)).toList();
  } else {
    throw Exception('Failed to load to-dos');
  }
}

Future<ToDo> createToDo(String title) async {
  final response = await http.post(
    Uri.parse('https://jsonplaceholder.typicode.com/todos'),
    headers: {'Content-Type': 'application/json; charset=UTF-8'},
    body: jsonEncode({
      'title': title,
      'completed': false,
    }),
  );

  if (response.statusCode == 201) {
    return ToDo.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to create to-do');
  }
}


Future<ToDo> updateToDo(int id, String title, bool completed) async {
  final response = await http.put(
    Uri.parse('https://jsonplaceholder.typicode.com/todos/$id'),
    headers: {'Content-Type': 'application/json; charset=UTF-8'},
    body: jsonEncode({
      'title': title,
      'completed': completed,
    }),
  );

  if (response.statusCode == 200) {
    return ToDo.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to update to-do');
  }
}


Future<void> deleteToDo(int id) async {
  final response = await http.delete(
    Uri.parse('https://jsonplaceholder.typicode.com/todos/$id'),
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to delete to-do');
  }
}
