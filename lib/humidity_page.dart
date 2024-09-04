import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class HumidityPage extends StatefulWidget {
  const HumidityPage({Key? key}) : super(key: key);

  @override
  _HumidityPageState createState() => _HumidityPageState();
}

class _HumidityPageState extends State<HumidityPage> {
  final DatabaseReference _databaseReference1 = FirebaseDatabase.instance.ref('DHT1/humidity1');
  final DatabaseReference _databaseReference2 = FirebaseDatabase.instance.ref('DHT2/humidity2');
  final DatabaseReference _databaseReference3 = FirebaseDatabase.instance.ref('DHT3/humidity3');

  double humidity1 = 0.0;
  double humidity2 = 0.0;
  double humidity3 = 0.0;

  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();

    // Inisialisasi notifikasi lokal
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/logonotifikasi');
    const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Listen to data changes
    _databaseReference1.onValue.listen((event) {
      setState(() {
        humidity1 = double.parse(event.snapshot.value.toString());
      });
      _showAverageHumidityNotification();
    });

    _databaseReference2.onValue.listen((event) {
      setState(() {
        humidity2 = double.parse(event.snapshot.value.toString());
      });
      _showAverageHumidityNotification();
    });

    _databaseReference3.onValue.listen((event) {
      setState(() {
        humidity3 = double.parse(event.snapshot.value.toString());
      });
      _showAverageHumidityNotification();
    });

    // Show initial average humidity
    Future.delayed(Duration(seconds: 1), () {
      _showAverageHumidityNotification();
    });
  }

  double _calculateAverageHumidity() {
    return (humidity1 + humidity2 + humidity3) / 3;
  }

  Future<void> _showAverageHumidityNotification() async {
    double averageHumidity = _calculateAverageHumidity();

    // Show notification for average humidity
    _showNotification('Humidity Data', 'Average Humidity: ${averageHumidity.toStringAsFixed(2)}%');

    // Show warning if average humidity is above a certain threshold (example: 75%)
    if (averageHumidity < 35) {
      _showNotification('Warning', 'Average Humidity is above 75%');
    }
  }

  Future<void> _showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'humidity_channel',
      'Humidity Notifications',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );
    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: 'item x',
    );
  }

  @override
  void dispose() {
    _databaseReference1.onChildAdded.drain();
    _databaseReference2.onChildAdded.drain();
    _databaseReference3.onChildAdded.drain();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF6B7D5C),
        title: const Text(
          'Humidity Data',
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildHumidityCard('Humidity Conditions - Sector 1', humidity1),
            _buildHumidityCard('Humidity Conditions - Sector 2', humidity2),
            _buildHumidityCard('Humidity Conditions - Sector 3', humidity3),
            const SizedBox(height: 20),
            _buildHumidityChart(),
          ],
        ),
      ),
    );
  }

  Widget _buildHumidityCard(String title, double humidity) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6B7D5C),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '$humidity %',
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHumidityChart() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Humidity Chart',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6B7D5C),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        FlSpot(0, humidity1),
                        FlSpot(1, humidity2),
                        FlSpot(2, humidity3),
                      ],
                      isCurved: true,
                      colors: [const Color(0xFF6B7D5C)],
                      barWidth: 4,
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                  titlesData: FlTitlesData(
                    leftTitles: SideTitles(showTitles: true),
                    bottomTitles: SideTitles(
                      showTitles: true,
                      getTitles: (value) {
                        switch (value.toInt()) {
                          case 0:
                            return 'Sec-1';
                          case 1:
                            return 'Sec-2';
                          case 2:
                            return 'Sec-3';
                          default:
                            return '';
                        }
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
