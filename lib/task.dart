// task.dart
import 'package:hive/hive.dart';

part 'task.g.dart';

@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  String name;

  @HiveField(2)
  bool completed;

  @HiveField(3)
  DateTime selectedDate;

  Task({
    required this.id,
    required this.name,
    required this.completed,
    required this.selectedDate,
  });
}
