import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class TemperaturePage extends StatefulWidget {
  const TemperaturePage({Key? key}) : super(key: key);

  @override
  _TemperaturePageState createState() => _TemperaturePageState();
}

class _TemperaturePageState extends State<TemperaturePage> {
  final DatabaseReference _databaseReference1 = FirebaseDatabase.instance.ref('DHT1/temperature1');
  final DatabaseReference _databaseReference2 = FirebaseDatabase.instance.ref('DHT2/temperature2');
  final DatabaseReference _databaseReference3 = FirebaseDatabase.instance.ref('DHT3/temperature3');

  double temperature1 = 0.0;
  double temperature2 = 0.0;
  double temperature3 = 0.0;

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
        temperature1 = double.parse(event.snapshot.value.toString());
      });
      _showAverageTemperatureNotification();
    });

    _databaseReference2.onValue.listen((event) {
      setState(() {
        temperature2 = double.parse(event.snapshot.value.toString());
      });
      _showAverageTemperatureNotification();
    });

    _databaseReference3.onValue.listen((event) {
      setState(() {
        temperature3 = double.parse(event.snapshot.value.toString());
      });
      _showAverageTemperatureNotification();
    });

    // Show initial average temperature
    Future.delayed(Duration(seconds: 1), () {
      _showAverageTemperatureNotification();
    });
  }

  double _calculateAverageTemperature() {
    return (temperature1 + temperature2 + temperature3) / 3;
  }

  Future<void> _showAverageTemperatureNotification() async {
    double averageTemperature = _calculateAverageTemperature();

    // Show notification for average temperature
    _showNotification('Temperature Data', 'Average Temperature: ${averageTemperature.toStringAsFixed(2)}°C');

    // Show warning if average temperature is above 35°C
    if (averageTemperature > 35) {
      _showNotification('Warning', 'Average Temperature is above 33°C');
    }
  }

  Future<void> _showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'temperature_channel',
      'Temperature Notifications',
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
          'Temperature Data',
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
            _buildTemperatureCard('Temperature Conditions - Sector 1', temperature1),
            _buildTemperatureCard('Temperature Conditions - Sector 2', temperature2),
            _buildTemperatureCard('Temperature Conditions - Sector 3', temperature3),
            const SizedBox(height: 20),
            _buildTemperatureChart(),
          ],
        ),
      ),
    );
  }

  Widget _buildTemperatureCard(String title, double temperature) {
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
              '$temperature °C',
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

  Widget _buildTemperatureChart() {
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
              'Temperature Chart',
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
                        FlSpot(0, temperature1),
                        FlSpot(1, temperature2),
                        FlSpot(2, temperature3),
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
