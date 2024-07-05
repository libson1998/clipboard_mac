import 'package:flutter/material.dart';
import 'package:clipboard/clipboard_screen.dart';
import 'package:flutter/services.dart';
const MethodChannel _channel = MethodChannel('clipboard_monitor');


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.grey,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xff1E1F22),
          foregroundColor: Color(0xff1E1F22),
        ),
      ),
      themeMode: ThemeMode.system,
      // Change to ThemeMode.dark to always use dark theme
      home: const ClipboardListenerScreen(),
    );
  }
}