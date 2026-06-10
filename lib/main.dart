import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart'; // Import Hive
import 'login_page.dart';
import 'home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inisialisasi Hive
  await Hive.initFlutter();
  // Membuka box bernama 'mahasiswaBox'
  await Hive.openBox('mahasiswaBox'); 

  SharedPreferences prefs = await SharedPreferences.getInstance();
  
  // Cek apakah session login tersimpan
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  
  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Latihan Login',
      // Jika sudah login arahkan ke HomePage, jika belum ke LoginPage
      home: isLoggedIn ? const HomePage() : const LoginPage(),
    );
  }
}