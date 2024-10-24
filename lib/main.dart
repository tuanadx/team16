import 'package:baitap1/todo.dart';
import 'package:baitap1/todo_service.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<List<ToDo>> futureToDos;

  @override
  void initState() {
    super.initState();
    futureToDos = fetchToDos();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-Do List App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('To-Do List'),
        ),
        body: Center(
          child: FutureBuilder<List<ToDo>>(
            future: futureToDos,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List<ToDo> toDos = snapshot.data!;
                return ListView.builder(
                  itemCount: toDos.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(toDos[index].title),
                      trailing: Checkbox(
                        value: toDos[index].completed,
                        onChanged: (bool? value) async {
                          // Handle update on checkbox change
                          ToDo updatedToDo = await updateToDo(
                            toDos[index].id,
                            toDos[index].title,
                            value!,
                          );
                          setState(() {
                            toDos[index] = updatedToDo;
                          });
                        },
                      ),
                      onLongPress: () async {
                        // Handle delete on long press
                        await deleteToDo(toDos[index].id);
                        setState(() {
                          toDos.removeAt(index);
                        });
                      },
                    );
                  },
                );
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }
              return const CircularProgressIndicator();
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            // Handle create new ToDo
            ToDo newToDo = await createToDo('New Task');
            setState(() {
              futureToDos = fetchToDos();
            });
          },
          child: const Icon(Icons.add),
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
