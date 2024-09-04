// File: main.dart

import 'package:Emush/firebase_options.dart'; // Pastikan ini adalah satu-satunya import firebase_options.dart yang digunakan
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart' as gauges;
import 'package:syncfusion_flutter_charts/charts.dart';
import 'temperature_page.dart';
import 'humidity_page.dart';
import 'moisture_page.dart';
import 'water_page.dart';
import 'login_page.dart';
import 'register_page.dart';
import 'log_history_page.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:rxdart/rxdart.dart';

final _messageStreamController = BehaviorSubject<RemoteMessage>();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Tangani pesan di latar belakang jika diperlukan
  print('Handling a background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Setup Firebase Messaging
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Tangani pesan saat aplikasi berada di latar belakang atau diterminasi
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Minta izin untuk notifikasi
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  if (kDebugMode) {
    print('Permission granted: ${settings.authorizationStatus}');
  }

  // Dapatkan token perangkat
  String? token = await messaging.getToken();

  if (kDebugMode) {
    print('Registration Token=$token');
  }

  // Tangani pesan saat aplikasi sedang berjalan (foreground)
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    if (kDebugMode) {
      print('Handling a foreground message: ${message.messageId}');
      print('Message data: ${message.data}');
      print('Message notification: ${message.notification?.title}');
      print('Message notification: ${message.notification?.body}');
    }

    _messageStreamController.sink.add(message);
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // Definisikan warna utama sebagai konstanta
  static const Color primaryColor = Color(0xFF6B7D5C);

  // Buat MaterialColor kustom untuk primarySwatch
  static final MaterialColor customPrimarySwatch = MaterialColor(
    primaryColor.value,
    <int, Color>{
      50: primaryColor.withOpacity(0.1),
      100: primaryColor.withOpacity(0.2),
      200: primaryColor.withOpacity(0.3),
      300: primaryColor.withOpacity(0.4),
      400: primaryColor.withOpacity(0.5),
      500: primaryColor.withOpacity(0.6),
      600: primaryColor.withOpacity(0.7),
      700: primaryColor.withOpacity(0.8),
      800: primaryColor.withOpacity(0.9),
      900: primaryColor.withOpacity(1.0),
    },
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Garden',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: customPrimarySwatch,
        // Definisikan warna teks default jika diperlukan
        textTheme: const TextTheme(
          bodyText1: TextStyle(color: Colors.white),
          bodyText2: TextStyle(color: Colors.white),
        ),
      ),
      initialRoute: '/home',
      routes: {
        '/temperature': (context) => const TemperaturePage(),
        '/humidity': (context) => const HumidityPage(),
        '/moisture': (context) => const MoisturePage(),
        '/water': (context) => const WaterPage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/log-history': (context) => const LogHistoryPage(),
        '/home': (context) => const HomePage(title: ''),
      },
    );
  }
}

class HomePage extends StatefulWidget {
  final String title;

  const HomePage({Key? key, required this.title}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Tambahkan listener untuk autentikasi jika diperlukan
  // Misalnya menggunakan FirebaseAuth

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthenticationAndShowDialog();
    });
  }

  void _checkAuthenticationAndShowDialog() {
    // Contoh pengecekan status autentikasi
    // Jika menggunakan FirebaseAuth:
    // User? user = FirebaseAuth.instance.currentUser;
    // if (user == null) {
    //   _showLoginRegisterDialog(context);
    // }

    // Untuk saat ini, langsung tampilkan dialog
    _showLoginRegisterDialog(context);
  }

  void _showLoginRegisterDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Pengguna harus memilih opsi
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF6B7D5C),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Login Required',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
        content: const Text(
          'Would you like to register or log in before using the app? If not, just click the close button.',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Tutup dialog
              Navigator.pushNamed(context, '/login');
            },
            child: const Text(
              'Login',
              style: TextStyle(color: Colors.white),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Tutup dialog
              Navigator.pushNamed(context, '/register');
            },
            child: const Text(
              'Register',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    double width = 400,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: const Color(0xFF6B7D5C),
          borderRadius: BorderRadius.circular(26),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildNavigationButton(
          label: 'Login',
          icon: Icons.login,
          onTap: () => Navigator.pushNamed(context, '/login'),
          width: 150,
        ),
        const SizedBox(width: 16),
        _buildNavigationButton(
          label: 'Register',
          icon: Icons.app_registration,
          onTap: () => Navigator.pushNamed(context, '/register'),
          width: 150,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildNavigationButton(
                  label: 'Garden Temperature Check',
                  icon: Icons.thermostat,
                  onTap: () => Navigator.pushNamed(context, '/temperature'),
                ),
                const SizedBox(height: 16),
                _buildNavigationButton(
                  label: 'Garden Humidity Check',
                  icon: Icons.wb_sunny,
                  onTap: () => Navigator.pushNamed(context, '/humidity'),
                ),
                const SizedBox(height: 16),
                _buildNavigationButton(
                  label: 'Baglog Moisture Check',
                  icon: Icons.water,
                  onTap: () => Navigator.pushNamed(context, '/moisture'),
                ),
                const SizedBox(height: 16),
                _buildNavigationButton(
                  label: 'Control Water Pump',
                  icon: Icons.opacity,
                  onTap: () => Navigator.pushNamed(context, '/water'),
                ),
                const SizedBox(height: 16),
                _buildNavigationButton(
                  label: 'View Log History',
                  icon: Icons.history,
                  onTap: () => Navigator.pushNamed(context, '/log-history'),
                ),
                const SizedBox(height: 16),
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
