// ignore_for_file: library_private_types_in_public_api, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void main() {
  tz.initializeTimeZones();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ToDoo',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        hintColor: const Color.fromARGB(255, 31, 156, 251),
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black87),
          bodyMedium: TextStyle(color: Colors.black87),
          displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.teal,
        hintColor: Colors.deepOrangeAccent,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.grey.shade900,
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.grey.shade300),
          bodyMedium: TextStyle(color: Colors.grey.shade300),
          displayLarge: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
      ),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: ToDoListScreen(
        isDarkMode: _isDarkMode,
        toggleTheme: _toggleTheme,
        flutterLocalNotificationsPlugin: _flutterLocalNotificationsPlugin,
      ),
    );
  }
}

class ToDoListScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback toggleTheme;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  const ToDoListScreen({
    required this.isDarkMode,
    required this.toggleTheme,
    required this.flutterLocalNotificationsPlugin,
    super.key,
  });

  @override
  _ToDoListScreenState createState() => _ToDoListScreenState();
}

class _ToDoListScreenState extends State<ToDoListScreen> {
  final List<String> _tasks = [];
  final List<String> _completedTasks = [];
  final List<String> _deletedTasks = [];
  final TextEditingController _controller = TextEditingController();
  TimeOfDay? _selectedTime;

  void _addTask() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _tasks.add(_controller.text);
        _controller.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Task added'),
          backgroundColor: widget.isDarkMode ? Colors.teal : const Color.fromARGB(255, 31, 156, 251),
        ),
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
      _deletedTasks.add(_tasks[index]); // Add to deleted list
      _tasks.removeAt(index);
    });
  }

  void _restoreTask(String task) {
    setState(() {
      _deletedTasks.remove(task);
      _tasks.add(task);
    });
  }

  void _deleteCompletedTask(int index) {
    setState(() {
      _completedTasks.removeAt(index);
    });
  }

  Future<void> _selectAlarmTime(BuildContext context, int index) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? const TimeOfDay(hour: 0, minute: 0),
    );
    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
        _scheduleAlarm(_tasks[index]);
      });
    }
  }

  Future<void> _scheduleAlarm(String task) async {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    final tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      channelDescription: 'your_channel_description',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
      color: Colors.teal,
      playSound: true,
      icon: '@mipmap/ic_launcher',
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await widget.flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Task Reminder',
      task,
      scheduledDate,
      platformChannelSpecifics,
      androidAllowWhileIdle: true,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  void _showTaskOptions(int index) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.check_circle, color: Colors.teal),
            title: const Text('Complete Task'),
            onTap: () {
              Navigator.pop(context);
              _completeTask(index);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Delete Task'),
            onTap: () {
              Navigator.pop(context);
              _deleteTask(index);
            },
          ),
          ListTile(
            leading: const Icon(Icons.alarm, color: Color.fromARGB(255, 31, 156, 251)),
            title: const Text('Set Alarm'),
            onTap: () {
              Navigator.pop(context);
              _selectAlarmTime(context, index);
            },
          ),
        ],
      ),
    );
  }

  void _showCompletedTaskOptions(int index) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Delete Task'),
            onTap: () {
              Navigator.pop(context);
              _deleteCompletedTask(index);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final taskColor = widget.isDarkMode ? Colors.teal.shade300 : const Color.fromARGB(255, 31, 156, 251);
    final completedTaskColor = widget.isDarkMode ? Colors.teal.shade300 : const Color.fromARGB(255, 31, 156, 251);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ToDoo'),
        actions: [
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.wb_sunny : Icons.nights_stay),
            onPressed: widget.toggleTheme,
          ),
          IconButton(
            icon: const Icon(Icons.restore_from_trash),
            onPressed: () {
              if (_deletedTasks.isNotEmpty) {
                showModalBottomSheet(
                  context: context,
                  builder: (context) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'Deleted Tasks',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      ..._deletedTasks.map((task) => ListTile(
                            title: Text(task),
                            trailing: IconButton(
                              icon: const Icon(Icons.restore),
                              onPressed: () {
                                Navigator.pop(context);
                                _restoreTask(task);
                              },
                            ),
                          )),
                      if (_deletedTasks.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text('No deleted tasks'),
                        ),
                    ],
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    maxLines: null, // Allow multiple lines
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                      hintText: 'Enter a task',
                      hintStyle: TextStyle(
                        color: widget.isDarkMode ? Colors.white : Colors.white,
                      ),
                      filled: true,
                      fillColor: widget.isDarkMode
                          ? const Color.fromARGB(255, 31, 156, 251)
                          : const Color.fromARGB(255, 31, 156, 251),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12.0),
                    ),
                    style: TextStyle(
                      color: widget.isDarkMode ? Colors.white : Colors.white,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 8.0),
                  decoration: BoxDecoration(
                    color: widget.isDarkMode ? Colors.teal : Colors.teal,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.add, color: Colors.white),
                    onPressed: _addTask,
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Hold task to reveal options',
              style: TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                color: widget.isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              'Tasks to Complete',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: taskColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _tasks.length,
                itemBuilder: (context, index) {
                  return Dismissible(
                    key: Key(_tasks[index]),
                    direction: DismissDirection.horizontal,
                    background: Container(
                      color: Colors.teal.shade200,
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: const Icon(Icons.check_circle, color: Colors.teal),
                    ),
                    secondaryBackground: Container(
                      color: Colors.red.shade300,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: const Icon(Icons.delete, color: Colors.red),
                    ),
                    confirmDismiss: (direction) async {
                      if (direction == DismissDirection.startToEnd) {
                        // Handle complete task
                        _completeTask(index);
                        return false; // Prevent dismiss
                      } else if (direction == DismissDirection.endToStart) {
                        // Handle delete task
                        return showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Confirm'),
                            content: const Text('Are you sure you want to delete this task?'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(false);
                                },
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(true);
                                  _deleteTask(index);
                                },
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                      }
                      return false;
                    },
                    child: GestureDetector(
                      onLongPress: () => _showTaskOptions(index),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        elevation: 6,
                        margin: const EdgeInsets.symmetric(vertical: 6.0),
                        color: widget.isDarkMode ? Colors.teal : Colors.teal,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                          title: Text(
                            _tasks[index],
                            style: TextStyle(
                              fontSize: 18,
                              color: widget.isDarkMode ? Colors.white : Colors.white,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Completed Tasks',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: completedTaskColor,
              ),
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _completedTasks.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onLongPress: () => _showCompletedTaskOptions(index),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      elevation: 6,
                      margin: const EdgeInsets.symmetric(vertical: 6.0),
                      color: widget.isDarkMode ? Colors.teal.shade200 : Colors.teal.shade100,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                        title: Text(
                          _completedTasks[index],
                          style: TextStyle(
                            fontSize: 18,
                            color: widget.isDarkMode ? Colors.white : Colors.white,
                          ),
                          textAlign: TextAlign.left,
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
