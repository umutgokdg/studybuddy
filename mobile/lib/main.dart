import 'package:flutter/material.dart';
import 'package:mobile_son/home_screen.dart';
import 'package:mobile_son/login_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginScreen(),
    );
  }
}