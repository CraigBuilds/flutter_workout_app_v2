import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'backend/models.dart';
import 'backend/workout_database.dart';

Future<void> main() async {
  
  WidgetsFlutterBinding.ensureInitialized();

  await initHive();

  final box = await Hive.openBox<Workout>('workouts');
  final database = WorkoutDatabase(box);
  await database.seedWithExampleIfEmpty();

  runApp(MyApp(database: database));
}

class MyApp extends StatelessWidget {

  final WorkoutDatabase database;

  const MyApp({super.key, required this.database});

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
