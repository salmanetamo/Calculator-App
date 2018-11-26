/*
Author: Salmane Tamo
Date: 18/11/2018

Description: Basic calculator application
*/

import 'package:flutter/material.dart';

import './calculator.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.grey,
        accentColor: Colors.white,
        buttonTheme: ButtonThemeData(
          minWidth: 72.0,
          height: 60.0,
          textTheme: ButtonTextTheme.accent
        )
      ),
      home: new Calculator(),
    );
  }
}


