import 'package:flutter/material.dart';
import '../backend/models.dart';
import '../backend/database.dart';
import 'set_logging_page.dart';

class ExerciseSelectorPage extends StatelessWidget {
  final WorkoutDatabase database;
  final Workout selectedWorkout;

  const ExerciseSelectorPage({
    super.key,
    required this.database,
    required this.selectedWorkout,
  });

  static const List<String> exerciseNames = [
    'Flat Barbell Bench Press',
    'Seated Overhead Dumbbell Press',
    'Seated Cable Row',
    'Chin-Ups (Underhand Grip)',
    'Pull-Ups (Overhand Grip)',
    'Pull-Downs (Wide Grip)',
    'Leg Press',
    'Barbell Squats',
    'Conventional Deadlift',
    'Bayesian Cable Curls',
    'Barbell Curls',
    'Tricep Pushdowns (Bar)',
    'Tricep Overhead Extensions (Rope)',
    'Cable Lateral Raises',
    'Machine Chest Flys',
    'Machine Rear Delt Flys',
    'Leg Extensions',
    'Plank',
    'Hanging Leg Raises',
    'Crunches',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: ListView(
        children: [
          ...exerciseNames.map((name) => ListTile(
                title: Text(name),
                onTap: () {
                  final exercise = database.getExerciseFromWorkoutOrNull(selectedWorkout, name) ?? Exercise(nameKey: name, sets: {});
                  if (!selectedWorkout.exercises.containsKey(name)) {
                    database.putExerciseInWorkout(selectedWorkout, exercise);
                  }
                  Navigator.push(context, MaterialPageRoute(builder: (_) => SetLoggingPage(database: database, selectedExercise: exercise, selectedWorkout: selectedWorkout)),
                  );
                },
              )),
          const Divider(),
          const ListTile(title: Text("Make New Super Set")), //this adds both exercises to the workout together.
          const ListTile(title: Text("Add Custom Exercise")),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) => AppBar(
    title: Text('Select Exercise'),
    leading: IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        Navigator.of(context).pop();
      },
    ),
  );
}