import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'share_screen.dart';
import 'package:memomeet/services/api_service.dart';

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<Map<String, dynamic>> tasks = [];
  Map<DateTime, int> tasksCount = {}; // Словарь для хранения количества задач на каждый день


  Future<void> fetchTasks(DateTime date) async {
    final response = await ApiService.getTasks(date.toIso8601String(), 1);
    setState(() {
      tasks = List<Map<String, dynamic>>.from(response);
      tasksCount[date] = tasks.length; // Сохраняем количество задач для выбранного дня
    });
}


  void _showAddTaskDialog() {
    TextEditingController taskController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Добавить задачу'),
          content: TextField(
            controller: taskController,
            decoration: InputDecoration(hintText: 'Введите задачу'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Отмена'),
            ),
            TextButton(
              onPressed: () async {
                if (taskController.text.isNotEmpty && _selectedDay != null) {
                  await ApiService.addTask(_selectedDay!.toIso8601String(), taskController.text, 1);
                  fetchTasks(_selectedDay!);
                  Navigator.pop(context);
                }
              },
              child: Text('Добавить'),
            ),
          ],
        );
      },
    );
  }

  void _showEditTaskDialog(Map<String, dynamic> task) {
    TextEditingController taskController = TextEditingController(text: task['task']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Редактировать задачу'),
          content: TextField(
            controller: taskController,
            decoration: InputDecoration(hintText: 'Введите задачу'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Отмена'),
            ),
            TextButton(
              onPressed: () async {
                if (taskController.text.isNotEmpty) {
                  await ApiService.editTask(task['id'], taskController.text);
                  fetchTasks(_selectedDay!);
                  Navigator.pop(context);
                }
              },
              child: Text('Сохранить'),
            ),
          ],
        );
      },
    );
  }

  void _deleteTask(int task_id) async {
    await ApiService.deleteTask(task_id);
    fetchTasks(_selectedDay!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Календарь'),
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ShareScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          TableCalendar(
            calendarFormat: _calendarFormat,
            focusedDay: _focusedDay,
            firstDay: DateTime(2000),
            lastDay: DateTime(2050),
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              fetchTasks(selectedDay);
            },
            eventLoader: (day) {
              return tasksCount[day] != null && tasksCount[day]! > 0 ? [1] : [];
            },
            calendarBuilders: CalendarBuilders(
            defaultBuilder: (context, day, focusedDay) {
              if (tasksCount[day] != null && tasksCount[day]! > 0) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.lightGreenAccent, // Цвет фона для дней с задачами
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Center(child: Text('${day.day}')),
                );
              }
              return null; // Возвращаем null для стандартного отображения
            },
            selectedBuilder: (context, day, focusedDay) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.blue, // Цвет фона для выбранного дня
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Center(child: Text('${day.day}', style: TextStyle(color: Colors.white))),
              );
            },
            todayBuilder: (context, day, focusedDay) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.orange, // Цвет фона для сегодняшнего дня
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Center(child: Text('${day.day}', style: TextStyle(color: Colors.white))),
              );
            },
          ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return ListTile(
                  title: Text(task['task']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          _showEditTaskDialog(task);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          _deleteTask(task['id']);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}