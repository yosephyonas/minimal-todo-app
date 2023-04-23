// ignore: file_names
import 'package:hive_flutter/hive_flutter.dart';

class HiveDataBase {
  List todolist = [];

  final _mybox = Hive.box('mybox');

  void createInitialData() {
    todolist = [];
  }

  void loadDatabase() {
    todolist = _mybox.get("todolist");
  }

  void updateDataBase() {
    _mybox.put("todolist", todolist);
  }
}
