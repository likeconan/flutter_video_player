import 'package:flutter/material.dart';
import 'package:video_player_oneplusdream_example/cache.dart';
import 'package:video_player_oneplusdream_example/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CachePage(),
    );
  }
}
