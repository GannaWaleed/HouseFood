import 'package:flutter/material.dart';
import 'package:frontend/MyProfile.dart';
import 'HmRegistration.dart';
import 'package:http/http.dart' as http;
import 'chooser.dart';
import 'AddFood.dart';
import 'HomePage.dart';
import 'login.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(id: '66258c341f78ffdef390db00',isHomemaker: true,),
    );
  }
}