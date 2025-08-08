import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '/blocs/task/task_bloc.dart';
import '/blocs/task/task_event.dart';
import '/blocs/task/task_state.dart';
import '/widgets/task_tile.dart';
import 'add_task_page.dart';

class TaskListPage extends StatelessWidget {
  const TaskListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<TaskBloc>().add(LoadTasksEvent());
            },
          ),
        ],
      ),
      body: BlocBuilder<TaskBloc, TaskState>(
        builder: (context, state) {
          if (state is TaskLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is TaskLoaded) {
            if (state.tasks.isEmpty) {
              return const Center(child: Text('No tasks yet!'));
            }
            return ListView.builder(
              itemCount: state.tasks.length,
              itemBuilder: (context, index) {
                final task = state.tasks[index];
                return TaskTile(
                  task: task,
                  onDelete: () {
                    context.read<TaskBloc>().add(DeleteTaskEvent(task.id!));
                  },
                );
              },
            );
          }
          return const Center(child: Text('Press refresh to load tasks'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddTaskPage()),
          );
          context.read<TaskBloc>().add(LoadTasksEvent());
        },
      ),
    );
  }
}
