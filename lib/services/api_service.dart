import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:5000';

  // Регистрация пользователя
  static Future<bool> registerUser(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      body: jsonEncode({'username': username, 'password': password}),
      headers: {'Content-Type': 'application/json'},
    );
    return response.statusCode == 201;
  }

  // Вход пользователя
  static Future<int?> loginUser(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      body: jsonEncode({'username': username, 'password': password}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['userId']; // Получаем ID пользователя
    }
    return null;
  }

  // Добавление задачи в конкретный календарь
  static Future<void> addTask(String date, String task, int user_id, int calendar_id) async {
  final response = await http.post(
    Uri.parse('$baseUrl/tasks'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'date': date,
      'task': task,
      'user_id': user_id,
      'calendar_id': calendar_id, // ✅ Передаём календарь
    }),
  );

  if (response.statusCode != 201) {
    throw Exception('Ошибка добавления задачи: ${response.body}');
  }
}


  // Получение задач для календаря
  static Future<List<dynamic>> getTasks(String date, int userId, int calendarId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/tasks?date=$date&user_id=$userId&calendar_id=$calendarId'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Ошибка получения задач');
    }
  }


  // Получение задач для диапазона дат
  static Future<List<dynamic>> getTasksForRange(String startDate, String endDate, int user_id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/tasks/range?start_date=$startDate&end_date=$endDate&user_id=$user_id'),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Ошибка получения задач для диапазона дат');
    }
  }

  // Редактирование задачи
  static Future<void> editTask(int task_id, String new_task) async {
    final response = await http.put(
      Uri.parse('$baseUrl/tasks/$task_id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'task': new_task}),
    );
    if (response.statusCode != 200) {
      throw Exception('Ошибка редактирования задачи');
    }
  }

  // Удаление задачи
  static Future<void> deleteTask(int task_id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/tasks/$task_id'),
    );
    if (response.statusCode != 200) {
      throw Exception('Ошибка удаления задачи');
    }
  }

  static Future<List<dynamic>> getDaysWithTasks(int userId) async {
  final response = await http.get(Uri.parse('$baseUrl/tasks/days?user_id=$userId'));

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Ошибка при получении дней с задачами');
  }
}

  // Создание календаря
  static Future<int?> createCalendar(String name, int userId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/calendars'),
      body: jsonEncode({'name': name, 'user_id': userId}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data['calendar_id'];
    }
    return null;
  }

// Получение календарей пользователя
  static Future<List<Map<String, dynamic>>> getCalendars(int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/calendars?user_id=$userId'),
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      throw Exception('Ошибка при получении календарей');
    }
  }


}