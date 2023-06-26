// hive_database.dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive/hive.dart';

import 'task.dart';

class HiveDataBase {
  Box<Task>? taskBox;
  Box<int>? currentIdBox;

  final FlutterLocalNotificationsPlugin notificationsPlugin;

  HiveDataBase(this.notificationsPlugin) {
    taskBox = Hive.box<Task>('tasks');
    currentIdBox = Hive.box<int>('currentId');
  }

  List<Task> get taskList => taskBox?.values.toList() ?? [];
  int get currentId => currentIdBox?.get(0) ?? 0;

  void createInitialData() {
    currentIdBox?.put(0, 0);
  }

  void addTask(Task task) {
    final taskId = currentId + 1;

    final newTask = Task(
      id: taskId,
      name: task.name,
      completed: task.completed,
      selectedDate: task.selectedDate,
    );

    taskBox?.put(taskId, newTask);
    currentIdBox?.put(0, taskId);
  }

  void removeTask(Task task) {
    taskBox?.delete(task.id);
    taskBox?.values.toList();
  }

  List<Task> loadDatabase() {
    return taskBox?.values.toList() ?? [];
  }

  void updateDataBase() {
    taskBox?.values.toList().forEach((task) {
      taskBox?.put(task.id, task);
    });
  }
}
