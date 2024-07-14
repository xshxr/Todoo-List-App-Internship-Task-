// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_application_1/todo_list_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;
  TimeOfDay _selectedTime = const TimeOfDay(hour: 0, minute: 0);

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  Future<void> _selectAlarmTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (pickedTime != null && pickedTime != _selectedTime) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-Do List',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color.fromARGB(255, 18, 18, 18),
      ),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: ToDoListScreen(
        isDarkMode: _isDarkMode,
        toggleTheme: _toggleTheme,
        selectAlarmTime: _selectAlarmTime, // Pass selectAlarmTime callback
      ),
    );
  }
}

class ToDoListScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback toggleTheme;
  final Function(BuildContext) selectAlarmTime; // Receive selectAlarmTime callback

  const ToDoListScreen({
    required this.isDarkMode,
    required this.toggleTheme,
    required this.selectAlarmTime, // Ensure to include in constructor
    super.key,
  });

  @override
  _ToDoListScreenState createState() => _ToDoListScreenState();
}

class _ToDoListScreenState extends State<ToDoListScreen> {
  final List<String> _tasks = [];
  final List<String> _completedTasks = [];
  final TextEditingController _controller = TextEditingController();

  void _addTask() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _tasks.add(_controller.text);
        _controller.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task added')),
      );
    }
  }

  void _completeTask(int index) {
    setState(() {
      _completedTasks.add(_tasks[index]);
      _tasks.removeAt(index);
    });
  }

  void _deleteTask(int index) {
    setState(() {
      _tasks.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('To-Do List'),
        actions: [
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.wb_sunny : Icons.nights_stay),
            onPressed: widget.toggleTheme,
          ),
          IconButton(
            icon: const Icon(Icons.alarm),
            onPressed: () {
              widget.selectAlarmTime(context); // Use selectAlarmTime from widget
            },
          ),
          IconButton(
            icon: const Icon(Icons.checklist),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TasksToCompleteScreen(
                    tasks: _tasks,
                    completedTasks: _completedTasks,
                    completeTask: _completeTask,
                    deleteTask: _deleteTask,
                    isDarkMode: widget.isDarkMode,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Enter a task',
                      hintStyle: TextStyle(
                        color: widget.isDarkMode ? Colors.white : Colors.black,
                      ),
                      filled: true,
                      fillColor: widget.isDarkMode
                          ? const Color.fromARGB(255, 48, 48, 48)
                          : const Color.fromARGB(255, 230, 230, 230),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: TextStyle(
                      color: widget.isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    elevation: 8, // Add shadow to button
                  ),
                  onPressed: _addTask,
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
