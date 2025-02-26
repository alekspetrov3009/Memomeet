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
    c.execute('''CREATE TABLE IF NOT EXISTS events
                 (id INTEGER PRIMARY KEY AUTOINCREMENT,
                  date TEXT NOT NULL,
                  event TEXT NOT NULL,
                  user_id INTEGER NOT NULL,
                  FOREIGN KEY(user_id) REFERENCES users(id))''')
    c.execute('''CREATE TABLE IF NOT EXISTS shared_calendars
                 (id INTEGER PRIMARY KEY AUTOINCREMENT,
                  owner_id INTEGER NOT NULL,
                  guest_id INTEGER NOT NULL,
                  FOREIGN KEY(owner_id) REFERENCES users(id),
                  FOREIGN KEY(guest_id) REFERENCES users(id))''')
# Добавление задач
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

# Добавление события
@app.route('/events', methods=['POST'])
def add_event():
    data = request.json
    date = data['date']
    event = data['event']
    user_id = data['user_id']
    conn = sqlite3.connect('calendar.db')
    c = conn.cursor()
    c.execute("INSERT INTO events (date, event, user_id) VALUES (?, ?, ?)", (date, event, user_id))
    conn.commit()
    conn.close()
    return jsonify({"status": "success", "message": "Event added"}), 201

# Получение событий по дате и пользователю
@app.route('/events', methods=['GET'])
def get_events():
    date = request.args.get('date')
    user_id = request.args.get('user_id')
    conn = sqlite3.connect('calendar.db')
    c = conn.cursor()
    c.execute("SELECT id, event FROM events WHERE date=? AND user_id=?", (date, user_id))
    events = c.fetchall()
    conn.close()
    return jsonify([{"id": event[0], "event": event[1]} for event in events])

# Приглашение пользователя для редактирования календаря
@app.route('/share', methods=['POST'])
def share_calendar():
    data = request.json
    owner_id = data['owner_id']
    guest_username = data['guest_username']
    conn = sqlite3.connect('calendar.db')
    c = conn.cursor()
    c.execute("SELECT id FROM users WHERE username=?", (guest_username,))
    guest = c.fetchone()
    if not guest:
        return jsonify({"status": "error", "message": "User not found"}), 404
    guest_id = guest[0]
    c.execute("INSERT INTO shared_calendars (owner_id, guest_id) VALUES (?, ?)", (owner_id, guest_id))
    conn.commit()
    conn.close()
    return jsonify({"status": "success", "message": "Calendar shared"}), 201

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

if __name__ == '__main__':
    init_db()
    app.run(debug=True)