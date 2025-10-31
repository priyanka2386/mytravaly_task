import 'package:flutter/material.dart';
import 'package:mytravaly_task/pages/home_page.dart';
import 'pages/login_page.dart';

void main() {
  runApp(MyTravalyApp());
}

class MyTravalyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyTravaly Task',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
