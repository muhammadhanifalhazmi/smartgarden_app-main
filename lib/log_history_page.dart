import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LogHistoryPage extends StatelessWidget {
  const LogHistoryPage({Key? key}) : super(key: key);

  // Data dummy untuk suhu, kelembaban, dan soil moisture
  List<Map<String, dynamic>> getDummyLogs() {
    DateTime now = DateTime.now();
    List<Map<String, dynamic>> logs = [];
    for (int i = 0; i < 12; i++) {
      logs.add({
        "timestamp": now.subtract(Duration(hours: i * 2)).millisecondsSinceEpoch,
        "sector": 1,
        "suhu": 25 + i % 5,
        "kelembaban": 60 + i % 10,

      });
      logs.add({
        "timestamp": now.subtract(Duration(hours: i * 2)).millisecondsSinceEpoch,
        "sector": 2,
        "suhu": 24 + i % 5,
        "kelembaban": 65 + i % 10,

      });
      logs.add({
        "timestamp": now.subtract(Duration(hours: i * 2)).millisecondsSinceEpoch,
        "sector": 3,
        "suhu": 23 + i % 5,
        "kelembaban": 70 + i % 10,

      });

    }
    return logs;
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> logs = getDummyLogs();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF6B7D5C),
        elevation: 0,
        title: const Text(
          'Log History',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 24,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: ListView.builder(
        itemCount: logs.length,
        itemBuilder: (context, index) {
          var log = logs[index];
          var timestamp = DateTime.fromMillisecondsSinceEpoch(log['timestamp']);
          var formattedDate = DateFormat('yyyy-MM-dd – kk:mm').format(timestamp);

          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text("Sector ${log['sector']} - ${formattedDate}"),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Suhu: ${log['suhu']}°C"),
                  Text("Kelembaban: ${log['kelembaban']}%"),

                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
