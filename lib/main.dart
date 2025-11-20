import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'backend/models.dart';

Future<void> main() async {
  
  WidgetsFlutterBinding.ensureInitialized();

  await initHive();

  final box = await Hive.openBox<Workout>('workouts');

  if (box.isEmpty) {
    await box.add(
      Workout(
        dateKey: Date.today(),
        exercises: [
          Exercise(
            name: 'Bench Press',
            sets: [
              ExerciseSet(reps: 8, weight: 60),
              ExerciseSet(reps: 6, weight: 70),
              ExerciseSet(reps: 4, weight: 80),
            ],
          ),
          Exercise(
            name: 'Overhead Press',
            sets: [
              ExerciseSet(reps: 10, weight: 30),
              ExerciseSet(reps: 8, weight: 35),
            ],
          ),
        ],
      ),
    );
  }

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
