import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/task_model.dart';
import '../../services/timer_service.dart';
import '../../widgets/timer_display.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  final TextEditingController _taskController = TextEditingController();
  List<TaskModel> _tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
    // Register the local setState as a callback for TimerService updates
    TimerService().onUpdate = () => setState(() {});
  }

  @override
  void dispose() {
    _taskController.dispose();
    TimerService().onUpdate = null; // Clean up the callback
    super.dispose();
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = prefs.getString('tasks');
    if (tasksJson != null) {
      final List<dynamic> decoded = jsonDecode(tasksJson);
      setState(() {
        _tasks = decoded.map((e) => TaskModel.fromJson(e)).toList();
        _tasks.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      });
    } else {
      setState(() => _tasks = []);
    }
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'tasks',
      jsonEncode(_tasks.map((e) => e.toJson()).toList()),
    );
  }

  void _addTask() {
    if (_taskController.text.trim().isEmpty) return;
    setState(() {
      _tasks.insert(
        0,
        TaskModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: _taskController.text.trim(),
          done: false,
          timestamp: DateTime.now().millisecondsSinceEpoch,
        ),
      );
    });
    _taskController.clear();
    _saveTasks();
  }

  void _toggleTask(String id) {
    setState(() {
      final task = _tasks.firstWhere((t) => t.id == id);
      task.done = !task.done;
    });
    _saveTasks();
  }

  void _deleteTask(String id) {
    setState(() {
      _tasks.removeWhere((t) => t.id == id);
    });
    _saveTasks();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _taskController,
            decoration: InputDecoration(
              hintText: 'What needs to be done?',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              suffixIcon: IconButton(
                icon: Icon(Icons.add, color: colorScheme.primary),
                onPressed: _addTask,
              ),
            ),
            onSubmitted: (_) => _addTask(),
          ),
        ),
        Expanded(
          child: _tasks.isEmpty
              ? Center(
                  child: Text(
                    'No tasks yet. Add one!',
                    style: TextStyle(
                      color: colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _tasks.length,
                  itemBuilder: (context, index) {
                    final task = _tasks[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: Checkbox(
                          value: task.done,
                          onChanged: (_) => _toggleTask(task.id),
                        ),
                        title: Text(
                          task.text,
                          style: TextStyle(
                            decoration:
                                task.done ? TextDecoration.lineThrough : null,
                            color: task.done
                                ? colorScheme.onSurface.withOpacity(0.5)
                                : null,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteTask(task.id),
                        ),
                      ),
                    );
                  },
                ),
        ),
        // Timer display is now a separate reusable widget
        const TimerDisplay(),
      ],
    );
  }
}
