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
    switch (result) {
      case 'settings': null;
      case 'createRoutine': null;
      case 'browseRoutines': null;
      case 'deleteAllData':
        database.clearAllData();
      case 'cancel': null;
    }
  }

  List<PopupMenuEntry<String>> buildAppBarMenuItems() => [
    for (var item in [
      ['settings', Icons.settings, 'Settings'],
      ['createRoutine', Icons.create, 'Create Workout Routine'],
      ['browseRoutines', Icons.search, 'Browse Workout Routines'],
      ['deleteAllData', Icons.delete_forever, 'Delete All Data'],
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
    return PageView.builder(
      scrollDirection: Axis.horizontal,
      controller: PageController(
        viewportFraction: 0.95,
        initialPage: database.getIndexOfTodayWorkoutOr(defaultIndex: database.getTotalWorkoutCount()),
      ),
      itemCount: database.getTotalWorkoutCount() + 1, // +1 for "Plan New Workout" pane
      itemBuilder: (_, i) {
        final workout = database.getWorkoutAtIndexOrNull(i);
        if (workout != null) {
          return _buildWorkoutCard(context, workout);
        } else {
          return _buildBlankWorkoutCard(context);
        }
      }
    );
  }

  Widget _buildBlankWorkoutCard(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              database.workoutExistsForToday() ? 'Plan New Workout' : 'Add Today\'s Workout',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Add Workout'),
                  onPressed: () => database.workoutExistsForToday()
                      ? _handleAddWorkout(context, date: null)
                      : _handleAddWorkout(context, date: Date.today()),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutCard(BuildContext context, Workout workout) {
    return Card(
      margin: const EdgeInsets.all(12.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              workout.dateKey.toString(),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: [
                  ...workout.exercises.values.map(
                    (exercise) => _buildExerciseTile(context, workout, exercise),
                  ),
                  _buildAddExerciseButton(context, workout),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddExerciseButton(BuildContext context, Workout workout) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ElevatedButton.icon(
        icon: const Icon(Icons.add),
        label: const Text('Add Exercise'),
        onPressed: () => _handleAddExercise(context, workout),
      ),
    );
  }

  Widget _buildExerciseTile(BuildContext context, Workout workout, Exercise exercise) {
    return ListTile(
      title: Text(exercise.nameKey),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...exercise.sets.values.map((set) => Text('${set.reps} reps @ ${set.weight} kg')),
          _buildAddSetButton(context, workout, exercise),
        ],
      ),
    );
  }

  Widget _buildAddSetButton(BuildContext context, Workout workout, Exercise exercise) {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: ElevatedButton.icon(
        icon: const Icon(Icons.add),
        label: const Text('Add Set'),
        onPressed: () => _handleAddSet(context, workout, exercise),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(80, 32),
          padding: const EdgeInsets.symmetric(horizontal: 8),
        ),
      ),
    );
  }

  // -- Handlers --

  void _handleAddWorkout(BuildContext context, {Date? date}) async {
    if (date != null) {
      database.putWorkout(date, Workout(dateKey: date, exercises: {}));
    }
    else {
      final pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      );
      if (pickedDate != null) {
        final date = Date(pickedDate.year, pickedDate.month, pickedDate.day);
        database.putWorkout(date, Workout(dateKey: date, exercises: {}));
      }
    }
  }

  void _handleAddExercise(BuildContext context, Workout workout) {
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

  void _handleAddSet(BuildContext context, Workout workout, Exercise exercise) {
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
                  database.pushSetToExercise(workout, exercise, reps, weight);
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
}