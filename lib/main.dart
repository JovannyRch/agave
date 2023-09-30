import 'package:agave/const.dart';
import 'package:agave/screens/Navigation.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bottom Navigation Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primaryColor: kMainColor),
      home: Navigation(),
    );
  }
}
