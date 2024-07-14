import 'package:flutter/material.dart';

class TasksToCompleteScreen extends StatefulWidget {
  final List<String> tasks;
  final List<String> completedTasks;
  final Function(int) completeTask;
  final Function(int) deleteTask;
  final bool isDarkMode;

  const TasksToCompleteScreen({
    required this.tasks,
    required this.completedTasks,
    required this.completeTask,
    required this.deleteTask,
    required this.isDarkMode,
    super.key,
  });

  @override
  _TasksToCompleteScreenState createState() => _TasksToCompleteScreenState();
}

class _TasksToCompleteScreenState extends State<TasksToCompleteScreen> {
  List<String> tasks = [];
  List<String> completedTasks = [];

  @override
  void initState() {
    super.initState();
    tasks = widget.tasks;
    completedTasks = widget.completedTasks;
  }

  void _completeTask(int index) {
    setState(() {
      completedTasks.add(tasks[index]);
      tasks.removeAt(index);
    });
  }

  void _deleteTask(int index) {
    setState(() {
      tasks.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks to Complete'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Tasks to Complete',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    child: ListTile(
                      title: Text(
                        tasks[index],
                        style: TextStyle(
                          color: widget.isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.check_circle, color: Colors.green),
                            onPressed: () => _completeTask(index),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteTask(index),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Completed Tasks',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: completedTasks.length,
                itemBuilder: (context, index) {
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    child: ListTile(
                      title: Text(
                        completedTasks[index],
                        style: TextStyle(
                          color: widget.isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
