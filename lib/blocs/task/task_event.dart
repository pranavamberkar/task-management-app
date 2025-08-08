import '../../models/task_model.dart';

abstract class TaskEvent {}

class LoadTasksEvent extends TaskEvent {}

class AddTaskEvent extends TaskEvent {
  final Task task;
  AddTaskEvent(this.task);
}

class DeleteTaskEvent extends TaskEvent {
  final int id;
  DeleteTaskEvent(this.id);
}
