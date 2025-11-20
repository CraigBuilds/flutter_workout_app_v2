import 'package:flutter/material.dart';
import 'package:flutter_workout_app_v2/backend/workout_database.dart';

class HomePage extends StatelessWidget {
  final WorkoutDatabase database;

  const HomePage({super.key, required this.database});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HomePageAppBar(),
      body: HomePageBody(database: database),
    );
  }
}

// -- Widgets --

class HomePageAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  const HomePageAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Workouts'),
    );
  }
}

class HomePageBody extends StatelessWidget {
  final WorkoutDatabase database;

  const HomePageBody({super.key, required this.database});

  //Each workout should be a card, each exercise in that workout should be a tile, and each set within that exercise should be a line of text saying "x reps @ y kg"
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: database.getTotalWorkoutCount(),
      itemBuilder: (context, index) {
        final workout = database.getWorkoutAtIndex(index)!;
        return Card(
          margin: const EdgeInsets.all(8.0),
          child: ExpansionTile(
            title: Text(workout.dateKey.toString()),
            children: workout.exercises.values.map((exercise) {
              return ListTile(
                title: Text(exercise.nameKey),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: exercise.sets.values.map((set) {
                    return Text('${set.reps} reps @ ${set.weight} kg');
                  }).toList(),
                )
              );
            }).toList(),
          ),
        );
      },
    );
  }
}