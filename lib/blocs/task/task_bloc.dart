import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/task_service.dart';
import 'task_event.dart';
import 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskService taskService;

  TaskBloc(this.taskService) : super(TaskInitial()) {
    on<LoadTasksEvent>((event, emit) async {
      emit(TaskLoading());
      final tasks = await taskService.getTasks();
      emit(TaskLoaded(tasks));
    });

    on<AddTaskEvent>((event, emit) async {
      await taskService.addTask(event.task);
      add(LoadTasksEvent());
    });

    on<DeleteTaskEvent>((event, emit) async {
      await taskService.deleteTask(event.id);
      add(LoadTasksEvent());
    });
  }
}
