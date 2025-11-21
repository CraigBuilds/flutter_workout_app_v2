import 'package:flutter/material.dart';
import 'package:flutter_workout_app_v2/backend/models.dart';
import 'package:flutter_workout_app_v2/backend/database.dart';
import 'package:flutter_workout_app_v2/pages/set_logging_page.dart';

//rename to WorkoutCarouselPage and add an actual home page?
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
  final WorkoutDatabase database;

  const HomePageAppBar({super.key, required this.database});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Workouts'),
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () => _showMenu(context),
        ),
      ],
    );
  }

  Future<void> _showMenu(BuildContext context) async {
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final result = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        overlay.size.width,
        kToolbarHeight,
        0,
        0,
      ),
      items: _menuItems(),
    );
    if (context.mounted) {
      _handleMenuSelection(context, result);
    }
  }

  List<PopupMenuEntry<String>> _menuItems() => [
        _menuItem('settings', Icons.settings, 'Settings'),
        _menuItem('createRoutine', Icons.create, 'Create Workout Routine'),
        _menuItem('browseRoutines', Icons.search, 'Browse Workout Routines'),
        _menuItem('simulatedDateOffset', Icons.date_range, 'Simulated Date Offset'),
        _menuItem('deleteAllData', Icons.delete_forever, 'Delete All Data'),
        _menuItem('cancel', Icons.cancel, 'Cancel'),
      ];

  PopupMenuItem<String> _menuItem(String value, IconData icon, String text) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }

  void _handleMenuSelection(BuildContext context, String? result) {
    switch (result) {
      case 'settings':
        break;
      case 'createRoutine':
        break;
      case 'browseRoutines':
        break;
      case 'simulatedDateOffset':
        _showSimulatedDateOffsetDialog(context);
        break;
      case 'deleteAllData':
        database.clearAllData();
        break;
      case 'cancel':
      default:
        break;
    }
  }

  void _showSimulatedDateOffsetDialog(BuildContext context) async {
    final offsetController =
        TextEditingController(text: Date.simulatedDateOffsetDays.toString());

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Set Simulated Date Offset (days)'),
          content: TextField(
            controller: offsetController,
            decoration: const InputDecoration(labelText: 'Offset in days'),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              onPressed: () {
                final offset = int.tryParse(offsetController.text);
                if (offset != null) {
                  Date.simulatedDateOffsetDays = offset;
                  database.forceRebuild();
                }
                Navigator.of(context).pop();
              },
              child: const Text('Set'),
            ),
          ],
        );
      },
    );
  }
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
      child: Column(
        children: [
          ListTile(title: Text(database.workoutExistsForToday() ? 'Plan New Workout' : 'Add Today\'s Workout')),
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
    );
  }

  Widget _buildWorkoutCard(BuildContext context, Workout workout) {
    return Card(
      child: Column(
        children: [
          ListTile(title: Text('${workout.dateKey}${workout.dateKey == Date.today() ? " (today)" : workout.dateKey > Date.today() ? " (planned)" : " (past)"}')),
          Expanded(
            child: ListView(
              children: [
                ...workout.exercises.values.map((exercise) => _buildExerciseCard(context, workout, exercise)),
                _buildAddExerciseButton(context, workout),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(BuildContext context, Workout workout, Exercise exercise) {
    return Card(
      color: Colors.grey[200],
      margin: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: ListTile(
        title: Text(exercise.nameKey),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...exercise.sets.values.map((set) => Text('${set.reps} reps @ ${set.weight} kg')),
          ],
        ),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SetLoggingPage(database: database, selectedExercise: exercise, selectedWorkout: workout))),
      ),
    );
  }

  Widget _buildAddExerciseButton(BuildContext context, Workout workout) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: ListTile(
        leading: Icon(Icons.add),
        title: Text('Add Exercise'),
        onTap: () => _handleAddExercise(context, workout),
      )
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

  //This will eventually be deleted, and instead the add exercise button will take you to the exercise selection page
  void _handleAddExercise(BuildContext context, Workout workout) {
    final exerciseNames = database.getAvailableExerciseNames();
    String? selectedExercise = exerciseNames.isNotEmpty ? exerciseNames.first : null;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Exercise'),
              content: DropdownButton<String>(
                value: selectedExercise,
                isExpanded: true,
                items: exerciseNames.map((name) => DropdownMenuItem(value: name, child: Text(name))).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedExercise = value;
                  });
                }
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    if (selectedExercise != null && selectedExercise!.isNotEmpty) {
                      database.putExerciseInWorkout(workout, Exercise(nameKey: selectedExercise!, sets: {}));
                    }
                    Navigator.of(context).pop();
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          }
        );
      },
    );
  }
}