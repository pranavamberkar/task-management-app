import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../db/database_helper.dart';
import '../models/task_model.dart';
import 'add_task_page.dart';
import 'login_page.dart';

class TaskListPage extends StatefulWidget {
  const TaskListPage({super.key});

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  List<Task> _tasks = [];
  String _filterPriority = "All";
  String _filterStatus = "All";

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final tasks = await DatabaseHelper().getTasks();
    tasks.sort((a, b) =>
        DateFormat('yyyy-MM-dd').parse(a.dueDate).compareTo(
          DateFormat('yyyy-MM-dd').parse(b.dueDate),
        ));
    setState(() {
      _tasks = tasks;
    });
  }

  void _toggleComplete(Task task) async {
    await DatabaseHelper().updateTask(task.copyWith(
      isCompleted: !task.isCompleted,
    ));
    _loadTasks();
  }

  List<Task> _applyFilters(List<Task> tasks) {
    return tasks.where((task) {
      bool matchesPriority = _filterPriority == "All" ||
          task.priority.toLowerCase() == _filterPriority.toLowerCase();
      bool matchesStatus = _filterStatus == "All" ||
          (_filterStatus == "Completed" && task.isCompleted) ||
          (_filterStatus == "Pending" && !task.isCompleted);
      return matchesPriority && matchesStatus;
    }).toList();
  }

  Color _priorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case "high":
        return Colors.red;
      case "medium":
        return Colors.orange;
      case "low":
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String tempPriority = _filterPriority;
        String tempStatus = _filterStatus;

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            "Filter Tasks",
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: tempPriority,
                decoration: const InputDecoration(labelText: "Priority"),
                items: ["All", "Low", "Medium", "High"]
                    .map((p) => DropdownMenuItem(
                  value: p,
                  child: Text(p),
                ))
                    .toList(),
                onChanged: (val) {
                  tempPriority = val!;
                },
              ),
              DropdownButtonFormField<String>(
                value: tempStatus,
                decoration: const InputDecoration(labelText: "Status"),
                items: ["All", "Completed", "Pending"]
                    .map((s) => DropdownMenuItem(
                  value: s,
                  child: Text(s),
                ))
                    .toList(),
                onChanged: (val) {
                  tempStatus = val!;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                setState(() {
                  _filterPriority = tempPriority;
                  _filterStatus = tempStatus;
                });
                Navigator.pop(context);
              },
              child: const Text("Apply"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("isLoggedIn", false);

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredTasks = _applyFilters(_tasks);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          "Task Manager",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
          ),
        ],
      ),
      body: filteredTasks.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.checklist_rounded,
                size: 100, color: Colors.deepPurple.shade200),
            const SizedBox(height: 12),
            Text(
              "No tasks yet!",
              style: GoogleFonts.poppins(
                  fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              "You just installed the app.\nTap + to add your first task.",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                  fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: filteredTasks.length,
        itemBuilder: (context, index) {
          final task = filteredTasks[index];
          return Dismissible(
            key: Key(task.id.toString()),
            direction: DismissDirection.endToStart,
            confirmDismiss: (direction) async {
              return await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: Text(
                    "Delete Task?",
                    style:
                    GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  content: Text(
                    "Are you sure you want to delete \"${task.title}\"?",
                    style: GoogleFonts.poppins(),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () =>
                          Navigator.of(context).pop(false),
                      child: const Text("Cancel"),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () =>
                          Navigator.of(context).pop(true),
                      child: const Text("Delete"),
                    ),
                  ],
                ),
              );
            },
            background: Container(
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (_) async {
              await DatabaseHelper().deleteTask(task.id!);
              setState(() {
                _tasks.removeWhere((t) => t.id == task.id);
              });

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Task "${task.title}" deleted',
                    style: GoogleFonts.poppins(),
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              child: ListTile(
                leading: Checkbox(
                  activeColor: Colors.deepPurple,
                  value: task.isCompleted,
                  onChanged: (_) => _toggleComplete(task),
                ),
                title: Text(
                  task.title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    decoration: task.isCompleted
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
                subtitle: Text(
                  "Due: ${task.dueDate} • ${task.description}",
                  style: GoogleFonts.poppins(fontSize: 13),
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _priorityColor(task.priority),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    task.priority,
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddTaskPage()),
          );
          if (result == true) {
            _loadTasks();
          }
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
