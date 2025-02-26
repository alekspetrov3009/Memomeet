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
  List<String> tasks = [];

  Future<void> fetchTasks(DateTime date) async {
    // Замените user_id на реальный ID пользователя
    final response = await ApiService.getTasks(date.toIso8601String(), 1);
    setState(() {
      tasks = response.map<String>((task) => task['task']).toList();
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
          ),
          Expanded(
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                return ListTile(title: Text(tasks[index]));
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