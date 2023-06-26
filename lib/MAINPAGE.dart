// todo_app.dart
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import 'DialogBox.dart';
import 'HiveDataBase.dart';
import 'task.dart';
import 'todoTILE.dart';

class TODOApp extends StatelessWidget {
  const TODOApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TODO App',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: const TODO(),
    );
  }
}

class TODO extends StatefulWidget {
  const TODO({Key? key}) : super(key: key);

  @override
  State<TODO> createState() => _TODOState();
}

class _TODOState extends State<TODO> {
  final _controller = TextEditingController();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  HiveDataBase db = HiveDataBase(FlutterLocalNotificationsPlugin());
  late DateTime selectedDate;
  late TimeOfDay selectedTime;
  int currentTaskId = 0;
  final ScrollController _scrollController = ScrollController();

  _TODOState() {
    selectedDate = DateTime.now();
    selectedTime = TimeOfDay.now();
  }
  @override
  void initState() {
    super.initState();

    Hive.openBox<Task>('tasks').then((box) {
      if (db.taskList.isEmpty) {
        db.createInitialData();
      } else {
        db.loadDatabase();
      }
      setState(() {});
    });
  }

  void checkBox(bool? value, int index) {
    setState(() {
      db.taskList[index].completed = value!;
    });

    db.updateDataBase();
  }

  void createNewData() {
    showDialog(
      context: context,
      builder: (context) {
        return DialogBox(
          controller: _controller,
          onSave: saveNewTask,
          onCancel: () => Navigator.of(context).pop(),
          notificationsPlugin: flutterLocalNotificationsPlugin,
          refreshTasksCallback: refreshTasks,
          selectedDate: selectedDate,
          selectedTime: selectedTime,
          taskId: currentTaskId,
        );
      },
    );
  }

  void refreshTasks() {
    setState(() {});
  }

  void saveNewTask() async {
    final taskName = _controller.text;
    final newTaskId = db.currentId + 1;

    final newTask = Task(
      id: newTaskId,
      name: taskName,
      completed: false,
      selectedDate: selectedDate,
    );

    setState(() {
      db.addTask(newTask);
      currentTaskId = newTaskId;
    });

    Navigator.of(context).pop();
    db.updateDataBase();
    refreshTasks();

    db.currentIdBox?.put(0, newTaskId);

    setState(() {
      selectedDate = selectedDate;
      selectedTime = selectedTime;
    });

    final now = DateTime.now();

    final scheduledDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    final difference = scheduledDateTime.difference(now);
    final hours = difference.inHours;
    final minutes = difference.inMinutes % 60;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Alarm set for $hours hours and $minutes minutes from the scheduled time',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white),
        ),
        duration: const Duration(seconds: 5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        backgroundColor: Colors.grey[300],
      ),
    );
  }

  void deleteTask(int index) {
    final task = db.taskList[index];
    setState(() {
      db.removeTask(task);
    });
    db.updateDataBase();
    refreshTasks();
  }

  @override
  Widget build(BuildContext context) {
    final tasks = db.taskList;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        elevation: 0,
        title: const Text('Tasks'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: createNewData,
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add),
      ),
      body: Scrollbar(
        thickness: 8,
        controller: _scrollController,
        child: ListView.builder(
          controller: _scrollController,
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            final taskDate =
                DateFormat('EEE, MMM d, y').format(task.selectedDate);
            final taskTime = DateFormat('hh:mm a').format(task.selectedDate);

            return TodoTile(
              taskName: task.name,
              taskDate: taskDate,
              taskTime: taskTime,
              checkBoxCallback: (value) => checkBox(value, index),
              isChecked: task.completed,
              deleteCallback: (context) {
                deleteTask(index);
              },
            );
          },
        ),
      ),
    );
  }
}
