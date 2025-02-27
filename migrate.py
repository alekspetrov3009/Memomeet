import sqlite3

conn = sqlite3.connect('calendar.db')
c = conn.cursor()

# Добавляем calendar_id, если его нет
try:
    c.execute("ALTER TABLE tasks ADD COLUMN calendar_id INTEGER DEFAULT 1")
    print("Столбец 'calendar_id' добавлен")
except sqlite3.OperationalError:
    print("Столбец 'calendar_id' уже существует")

conn.commit()
conn.close()
