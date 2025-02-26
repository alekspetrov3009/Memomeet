import 'package:flutter/material.dart';

class ShareScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Пригласить')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(decoration: InputDecoration(labelText: 'Имя пользователя')),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Логика приглашения
              },
              child: Text('Пригласить'),
            ),
          ],
        ),
      ),
    );
  }
}