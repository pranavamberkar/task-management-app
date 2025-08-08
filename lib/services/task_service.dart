import '../db/database_helper.dart';
import '../models/task_model.dart';

class TaskService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<int> addTask(Task task) async {
    return await _dbHelper.createTask(task);
  }

  Future<List<Task>> getTasks() async {
    return await _dbHelper.getTasks();
  }

  Future<int> deleteTask(int id) async {
    return await _dbHelper.deleteTask(id);
  }
}
