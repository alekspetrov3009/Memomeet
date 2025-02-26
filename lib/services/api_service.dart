import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:5000';

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
}