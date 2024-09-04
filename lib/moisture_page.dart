import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class MoisturePage extends StatefulWidget {
  const MoisturePage({Key? key}) : super(key: key);

  @override
  _MoisturePageState createState() => _MoisturePageState();
}

class _MoisturePageState extends State<MoisturePage> {
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref('SoilMoisture');

  double moisture = 0.0;

  @override
  void initState() {
    super.initState();
    _databaseReference.onValue.listen((event) {
      setState(() {
        moisture = double.parse(event.snapshot.value.toString());
      });
      debugPrint("Dapat data dari realtime database: ${event.snapshot.value?.toString()}");
    });
  }

  @override
  void dispose() {
    _databaseReference.onChildAdded.drain();
    super.dispose();
  }

  String getMoistureDescription(double moisture) {
    if (moisture >= 900) {
      return "Media Tanam sangat kering. Butuh penyiraman segera.";
    } else if (moisture >= 700) {
      return "Media Tanam kering. Penyiraman mungkin diperlukan dalam waktu dekat.";
    } else if (moisture >= 300) {
      return "Media Tanam lembab. Kondisi ideal untuk Jamur.";
    } else {
      return "Media Tanam sangat basah. Mungkin terlalu basah untuk Jamur.";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF6B7D5C),
        title: const Text(
          'Moisture Data',
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
            _buildMoistureCard('Current Baglog Moisture', moisture),
            const SizedBox(height: 20),
            _buildMoistureDescriptionCard(moisture),
            const SizedBox(height: 20),
            _buildExplanationCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildMoistureCard(String title, double moisture) {
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
              '${moisture.toStringAsFixed(2)} %',
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

  Widget _buildMoistureDescriptionCard(double moisture) {
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
              'Moisture Description',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6B7D5C),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              getMoistureDescription(moisture),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.normal,
                color: Color(0xFF6B7D5C),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExplanationCard() {
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
          children: const [
            Text(
              'Keterangan',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6B7D5C),
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Nilai ini merupakan sampel bagi petani untuk mengetahui usia dan kesehatan dari media tanam jamur tiram.',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.normal,
                color: Color(0xFF6B7D5C),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
