from flask import Flask, request, jsonify
from flask_cors import CORS
import sqlite3

app = Flask(__name__)
CORS(app)  # Разрешить запросы с фронтенда

# Инициализация базы данных
def init_db():
    conn = sqlite3.connect('calendar.db')
    c = conn.cursor()
    c.execute('''CREATE TABLE IF NOT EXISTS users
                 (id INTEGER PRIMARY KEY AUTOINCREMENT,
                  username TEXT NOT NULL UNIQUE,
                  password TEXT NOT NULL)''')
    c.execute('''CREATE TABLE IF NOT EXISTS tasks
                 (id INTEGER PRIMARY KEY AUTOINCREMENT,
                  date TEXT NOT NULL,
                  task TEXT NOT NULL,
                  user_id INTEGER NOT NULL,
                  FOREIGN KEY(user_id) REFERENCES users(id))''')
    conn.commit()
    conn.close()

# Регистрация пользователя
@app.route('/register', methods=['POST'])
def register():
    data = request.json
    username = data['username']
    password = data['password']
    conn = sqlite3.connect('calendar.db')
    c = conn.cursor()
    try:
        c.execute("INSERT INTO users (username, password) VALUES (?, ?)", (username, password))
        conn.commit()
        return jsonify({"status": "success", "message": "User registered"}), 201
    except sqlite3.IntegrityError:
        return jsonify({"status": "error", "message": "Username already exists"}), 400
    finally:
        conn.close()

# Добавление задачи
@app.route('/tasks', methods=['POST'])
def add_task():
    data = request.json
    date = data['date']
    task = data['task']
    user_id = data['user_id']
    conn = sqlite3.connect('calendar.db')
    c = conn.cursor()
    c.execute("INSERT INTO tasks (date, task, user_id) VALUES (?, ?, ?)", (date, task, user_id))
    conn.commit()
    conn.close()
    return jsonify({"status": "success", "message": "Task added"}), 201

# Получение задач по дате и пользователю
@app.route('/tasks', methods=['GET'])
def get_tasks():
    date = request.args.get('date')
    user_id = request.args.get('user_id')
    conn = sqlite3.connect('calendar.db')
    c = conn.cursor()
    c.execute("SELECT id, task FROM tasks WHERE date=? AND user_id=?", (date, user_id))
    tasks = c.fetchall()
    conn.close()
    return jsonify([{"id": task[0], "task": task[1]} for task in tasks])

# Редактирование задачи
@app.route('/tasks/<int:task_id>', methods=['PUT'])
def edit_task(task_id):
    data = request.json
    new_task = data['task']
    conn = sqlite3.connect('calendar.db')
    c = conn.cursor()
    c.execute("UPDATE tasks SET task=? WHERE id=?", (new_task, task_id))
    conn.commit()
    conn.close()
    return jsonify({"status": "success", "message": "Task updated"}), 200

# Удаление задачи
@app.route('/tasks/<int:task_id>', methods=['DELETE'])
def delete_task(task_id):
    conn = sqlite3.connect('calendar.db')
    c = conn.cursor()
    c.execute("DELETE FROM tasks WHERE id=?", (task_id,))
    conn.commit()
    conn.close()
    return jsonify({"status": "success", "message": "Task deleted"}), 200

# Получение дней с задачами для пользователя
@app.route('/tasks/days', methods=['GET'])
def get_days_with_tasks():
    user_id = request.args.get('user_id')
    conn = sqlite3.connect('calendar.db')
    c = conn.cursor()
    c.execute("SELECT DISTINCT date FROM tasks WHERE user_id=?", (user_id,))
    days = c.fetchall()
    conn.close()
    return jsonify([day[0] for day in days])

# Получение задач для диапазона дат
@app.route('/tasks/range', methods=['GET'])
def get_tasks_for_range():
    start_date = request.args.get('start_date')
    end_date = request.args.get('end_date')
    user_id = request.args.get('user_id')
    conn = sqlite3.connect('calendar.db')
    c = conn.cursor()
    c.execute("SELECT id, date, task FROM tasks WHERE date BETWEEN ? AND ? AND user_id=?", (start_date, end_date, user_id))
    tasks = c.fetchall()
    conn.close()
    return jsonify([{"id": task[0], "date": task[1], "task": task[2]} for task in tasks])

if __name__ == '__main__':
    init_db()
    app.run(debug=True)