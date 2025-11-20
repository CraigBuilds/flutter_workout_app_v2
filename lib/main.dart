import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'backend/models.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  registerHiveTypes();

  await Hive.openBox<Workout>('workouts');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Workout app bootstrap'),
        ),
      ),
    );
  }
}
