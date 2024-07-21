import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'length_converter_page.dart';
import 'history_page.dart';
import 'splash_screen.dart'; // Import your splash screen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('historyBox');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Color(0xFF9172EC), // Set your theme color
      ),
      initialRoute: '/splash', // Set the initial route to splash
      routes: {
        '/splash': (context) => SplashScreen(), // SplashScreen route
        '/main': (context) => LengthConverterPage(), // Main page route
        '/history': (context) => HistoryPage(), // History page route
      },
    );
  }
}
