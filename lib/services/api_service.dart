import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:5000';

  // Регистрация пользователя
  static Future<void> register(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );
    if (response.statusCode != 201) {
      throw Exception('Ошибка регистрации');
    }
  }

  // Добавление задачи
  static Future<void> addTask(String date, String task, int user_id) async {
    final response = await http.post(
      Uri.parse('$baseUrl/tasks'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'date': date, 'task': task, 'user_id': user_id}),
    );
    if (response.statusCode != 201) {
      throw Exception('Ошибка добавления задачи');
    }
  }

  // Получение задач на определённую дату
  static Future<List<dynamic>> getTasks(String date, int user_id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/tasks?date=$date&user_id=$user_id'),
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

}