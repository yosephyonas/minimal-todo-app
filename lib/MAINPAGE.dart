// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:to_do/todoTILE.dart';
import 'Dialogbox.dart';
import 'HiveDataBase.dart';

class TODO extends StatefulWidget {
  const TODO({Key? key}) : super(key: key);

  @override
  State<TODO> createState() => _TODOState();
}

class _TODOState extends State<TODO> {
  final _myBox = Hive.box('mybox');
  final _controller = TextEditingController();
  HiveDataBase db = HiveDataBase();

  @override
  void initState() {
    if (_myBox.get("todolist") == null) {
      db.createInitialData();
    } else {
      // there already exists data
      db.loadDatabase();
    }

    super.initState();
  }

  void checkBox(bool? value, int index) {
    setState(() {
      db.todolist[index][1] = value!;
    });
    db.updateDataBase();
  }

  void createNewData() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialogbox(
          controller: _controller,
          onSave: saveNewTask,
          onCancel: () => Navigator.of(context).pop(),
        );
      },
    );
  }

  void saveNewTask() {
    setState(() {
      db.todolist.add([_controller.text.trim(), false]);
      _controller.clear();
    });
    Navigator.of(context).pop();
    db.updateDataBase();
  }

  void deleteTask(int index) {
    setState(() {
      db.todolist.removeAt(index);
    });
    db.updateDataBase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Center(
          child: Text(
            "TODO",
            style: TextStyle(
              color: Colors.brown,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: createNewData,
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add),
      ),
      body: db.todolist.isEmpty
          ? Center(
              child: Text(
                "No tasks added yet",
                style: Theme.of(context).textTheme.titleMedium,
              ),
            )
          : ListView.builder(
              itemCount: db.todolist.length,
              itemBuilder: (content, index) {
                return TodoTile(
                  deleteFunction: (context) => deleteTask(index),
                  onChanged: (value) => checkBox(value, index),
                  taskCompleted: db.todolist[index][1],
                  taskName: db.todolist[index][0],
                );
              },
            ),
    );
  }
}
