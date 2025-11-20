import 'package:flutter/material.dart';
import 'package:flutter_workout_app_v2/backend/models.dart';
import 'package:flutter_workout_app_v2/backend/workout_database.dart';

class HomePage extends StatelessWidget {
  final WorkoutDatabase database;

  const HomePage({super.key, required this.database});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HomePageAppBar(database: database),
      body: HomePageBody(database: database),
    );
  }
}

// ---- Widgets ----

// -- AppBar

class HomePageAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  final WorkoutDatabase database;

  const HomePageAppBar({super.key, required this.database});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Workouts'),
      actions: [
        IconButton(
          icon: Icon(Icons.more_vert),
          onPressed: () => handleAppBarMenuButtonPressed(context),
        )
      ]
    );
  }

  Future<void> handleAppBarMenuButtonPressed(BuildContext context) async {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final result = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        overlay.size.width,
        kToolbarHeight,
        0,
        0,
      ),
      items: buildAppBarMenuItems(),
    );
    if (result == 'settings') {
      // Navigator.of(context).push(MaterialPageRoute(builder: (_) => buildSettingsPage(context, appState)),);
    }
  }

  List<PopupMenuEntry<String>> buildAppBarMenuItems() => [
    for (var item in [
      ['settings', Icons.settings, 'Settings'],
      ['createRoutine', Icons.create, 'Create Workout Routine'],
      ['browseRoutines', Icons.search, 'Browse Workout Routines'],
      ['cancel', Icons.cancel, 'Cancel'],
    ])
      PopupMenuItem<String>(
        value: item[0] as String,
        child: Row(
          children: [
            Icon(item[1] as IconData, size: 20),
            SizedBox(width: 8),
            Text(item[2] as String),
          ],
        ),
      ),
  ];
}

// -- Body

class HomePageBody extends StatelessWidget {
  final WorkoutDatabase database;

  const HomePageBody({super.key, required this.database});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // AddWorkout button
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Add Workout'),
            onPressed: () => handleAddWorkout(context, database),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: database.getTotalWorkoutCount(),
            itemBuilder: (context, index) {
              final workout = database.getWorkoutAtIndex(index)!;
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ExpansionTile(
                  title: Text(workout.dateKey.toString()),
                  children: [
                    // AddExercise button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Add Exercise'),
                        onPressed: () => handleAddExercise(context, database, workout),
                      ),
                    ),
                    ...workout.exercises.values.map((exercise) {
                      return ListTile(
                        title: Text(exercise.nameKey),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ...exercise.sets.values.map((set) {
                              return Text('${set.reps} reps @ ${set.weight} kg');
                            }),
                            // AddSet button
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.add),
                                label: const Text('Add Set'),
                                onPressed: () => handleAddSet(context, database, workout, exercise),
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(80, 32),
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// -- Handlers --

void handleAddWorkout(BuildContext context, WorkoutDatabase database) {
  final now = Date.today();
  database.putWorkout(now, Workout(dateKey: now, exercises: {}));
}

void handleAddExercise(BuildContext context, WorkoutDatabase database, Workout workout) {
  final exerciseNameController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Add Exercise'),
        content: TextField(
          controller: exerciseNameController,
          decoration: const InputDecoration(labelText: 'Exercise Name'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              final exerciseName = exerciseNameController.text;
              if (exerciseName.isNotEmpty) {
                database.putExerciseInWorkout(workout, Exercise(nameKey: exerciseName, sets: {}));
              }
              Navigator.of(context).pop();
            },
            child: const Text('Add'),
          ),
        ],
      );
    },
  );
}

void handleAddSet(BuildContext context, WorkoutDatabase database, Workout workout, Exercise exercise) {
  final repsController = TextEditingController();
  final weightController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Add Set'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: repsController,
              decoration: const InputDecoration(labelText: 'Reps'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: weightController,
              decoration: const InputDecoration(labelText: 'Weight (kg)'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              final reps = int.tryParse(repsController.text);
              final weight = double.tryParse(weightController.text);
              if (reps != null && weight != null) {
                database.pushSetToExercise(workout,exercise,reps,weight);
              }
              Navigator.of(context).pop();
            },
            child: const Text('Add'),
          ),
        ],
      );
    },
  );
}