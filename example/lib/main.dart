import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:rms_power/rms_power.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final String _platformVersion = 'Unknown';
  final _rmsPowerPlugin = RmsPower();

  double percentage = 0;

  @override
  void dispose() {
    _rmsPowerPlugin.stopRecorder();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> _initialize() async {
    while (!(await _rmsPowerPlugin.checkPermission())) {
      _rmsPowerPlugin.requestPermission();
    }
    await _rmsPowerPlugin.startRecorder();
    debugPrint("Recorder started...");
    _rmsPowerPlugin.onRecorderStateChanged.listen((event) {
      debugPrint("frequency: $event");
      double convertedData = (event + 55) / 25;
      if (convertedData <= 0) {
        convertedData = 0;
      }
      setState(() {
        percentage = convertedData;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          children: [
            Center(
              child: Text('Running on: $_platformVersion\n'),
            ),
            LinearProgressIndicator(
              value: percentage,
            )
          ],
        ),
      ),
    );
  }
}
