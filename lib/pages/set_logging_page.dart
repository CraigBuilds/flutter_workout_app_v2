import 'package:flutter/material.dart';
import 'package:flutter_workout_app_v2/backend/models.dart';
import 'package:flutter_workout_app_v2/backend/database.dart';

class SetLoggingPage extends StatelessWidget {
  final WorkoutDatabase database; 
  final Workout selectedWorkout;
  final Exercise selectedExercise;

  const SetLoggingPage({super.key, required this.database, required this.selectedExercise, required this.selectedWorkout});
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: _buildAppBar(context),
        body: TabBarView(
          children: [
            _buildTrackTab(context),
            _buildHistoryTab(context),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) => AppBar(
    title: Text('${selectedExercise.nameKey} ${selectedWorkout.dateKey.toString()}'),
    leading: IconButton(
      icon: const Icon(Icons.home),
      onPressed: () {
        Navigator.of(context).popUntil((route) => route.isFirst);
      },
    ),
    bottom: const TabBar(
      tabs: [
        Tab(text: 'Track'),
        Tab(text: 'History'),
      ],
    ),
  );

  Widget _buildTrackTab(BuildContext context) => Column(
    children: [
      Expanded(
        child: ListView.builder(
          itemCount: selectedExercise.sets.length,
          itemBuilder: (context, index) {
            final set = selectedExercise.sets[index];
            return _buildExerciseSetTile(context, set!, null);
          },
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton.icon(
          icon: const Icon(Icons.add),
          label: const Text('Add Set'),
          onPressed: () => openAddNewSetDialog(context),
        ),
      ),
    ],
  );

  Widget _buildHistoryTab(BuildContext contexts) => ListView.builder(
    itemCount: database.getHistoricalSets(selectedExercise).length,
    itemBuilder: (context, index) {
      final (date, set) = database.getHistoricalSets(selectedExercise)[index];
      return _buildExerciseSetTile(context, set, date);
    },
  );

// ---------- Dialogs ----------

  Future openSetDialog({
    required BuildContext context,
    required String title,
    required String initialReps,
    required String initialWeight,
    required void Function(int reps, double weight) onSubmit,
  }) =>
      showDialog(
        context: context,
        builder: (context) {
          final repsController = TextEditingController(text: initialReps);
          final weightController = TextEditingController(text: initialWeight);

          return AlertDialog(
            title: Text(title),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: repsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Reps'),
                ),
                TextField(
                  controller: weightController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Weight (kg)'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final reps = int.tryParse(repsController.text) ?? 0;
                  final weight = double.tryParse(weightController.text) ?? 0.0;
                  onSubmit(reps, weight);
                  Navigator.of(context).pop();
                },
                child: Text(title == 'Add New Set' ? 'Add' : 'Save'),
              ),
            ],
          );
        },
      );

  Future openEditSetDialog(BuildContext context, ExerciseSet set) => openSetDialog(
    context: context,
    title: 'Edit Set',
    initialReps: set.reps.toString(),
    initialWeight: set.weight.toString(),
    onSubmit: (reps, weight) {
      database.putSetInExercise(
        selectedWorkout,
        selectedExercise,
        ExerciseSet(indexKey: set.indexKey, reps: reps, weight: weight),
      );
    },
  );

  Future openAddNewSetDialog(BuildContext context) => openSetDialog(
    context: context,
    title: 'Add New Set',
    initialReps: '',
    initialWeight: '',
    onSubmit: (reps, weight) {
      database.pushSetToExercise(
        selectedWorkout,
        selectedExercise,
        reps,
        weight,
      );
    },
  );


  // ---------- Shared UI helpers ----------

  Widget _buildExerciseSetTile(BuildContext context, ExerciseSet set, Date? date) => Card(
    child: ListTile(
      title: date != null ? Text('Set ${set.indexKey + 1} on ${date.toString()}') : Text('Set ${set.indexKey + 1}'),
      subtitle: Text('${set.reps} reps @ ${set.weight} kg'),
      onTap: () {
        openEditSetDialog(context, set);
      },
      onLongPress: () => openExerciseSetLongPressContextMenu(context, set),
    ),
  );

  Future openExerciseSetLongPressContextMenu(BuildContext context, ExerciseSet set) async {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final result = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        overlay.size.width / 2,
        overlay.size.height / 2,
        overlay.size.width / 2,
        overlay.size.height / 2,
      ),
      items: [
        PopupMenuItem<String>(
          value: 'delete',
          child: Text('Delete Set'),
        ),
        PopupMenuItem<String>(
          value: 'cancel',
          child: Text('Cancel'),
        ),
      ],
    );

    if (result == 'delete') {
      database.deleteExerciseSetFromExercise(
        selectedWorkout,
        selectedExercise,
        set.indexKey,
      );
    }
}

}
