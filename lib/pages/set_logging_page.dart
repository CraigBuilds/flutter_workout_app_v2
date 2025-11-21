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
    title: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(selectedExercise.nameKey),
        Text(
          '${selectedWorkout.dateKey.dayOfWeek()} ${selectedWorkout.dateKey}${selectedWorkout.dateKey == Date.today() ? " (today)" : selectedWorkout.dateKey > Date.today() ? " (planned)" : " (past)"}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    ),
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
            final setsAsList = selectedExercise.sets.values.toList();
            final set = setsAsList[index];
            return _buildExerciseSetTile(context, set, null);
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
    required int initialPartialReps,
    int initialRest = 0,
    int initialRir = 0,
    required void Function(int reps, double weight, int rest, int partialReps, int rir) onSubmit,
  }) {
    final repsController = TextEditingController(text: initialReps);
    final weightController = TextEditingController(text: initialWeight);
    final restController = TextEditingController(text: initialRest.toString());
    final partialRepsController = TextEditingController(text: initialPartialReps.toString());
    final rirController = TextEditingController(text: initialRir.toString());

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
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
                TextField(
                  controller: restController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Rest (sec)'),
                ),
                TextField(
                  controller: partialRepsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Partial Reps'),
                ),
                TextField(
                  controller: rirController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'RIR'),
                ),
              ],
            ),
          ),
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
              final rest = int.tryParse(restController.text) ?? 0;
              final partialReps = int.tryParse(partialRepsController.text) ?? 0;
              final rir = int.tryParse(rirController.text) ?? 0;
              onSubmit(reps, weight, rest, partialReps, rir);
              Navigator.of(context).pop();
            },
            child: Text(title == 'Add New Set' ? 'Add' : 'Save'),
          ),
        ],
      ),
    );
  }

  Future openEditSetDialog(BuildContext context, ExerciseSet set) => openSetDialog(
    context: context,
    title: 'Edit Set',
    initialReps: set.reps.toString(),
    initialWeight: set.weight.toString(),
    initialPartialReps: set.partialReps,
    onSubmit: (reps, weight, rest, partialReps, rir) {
      database.putSetInExercise(
        selectedWorkout,
        selectedExercise,
        ExerciseSet(indexKey: set.indexKey, reps: reps, weight: weight, completed: set.completed, partialReps: partialReps),
      );
    },
  );

  Future openAddNewSetDialog(BuildContext context) => openSetDialog(
    context: context,
    title: 'Add New Set',
    initialReps: '0',
    initialWeight: '0',
    initialPartialReps: 0,
    onSubmit: (reps, weight, rest, partialReps, rir) {
      database.pushSetToExercise(
        selectedWorkout,
        selectedExercise,
        reps,
        weight,
        partialReps,
      );
    },
  );


  // ---------- Shared UI helpers ----------

  Widget _buildExerciseSetTile(BuildContext context, ExerciseSet set, Date? date) => Card(
    child: ListTile(
      leading: date == null ? Checkbox(
        value: set.completed,
        onChanged: (value) {
          database.markSetAsCompleted(
            selectedWorkout,
            selectedExercise,
            set,
            value!,
          );
        },
      ) : null,
      title: date != null ? Text('Set ${set.indexKey} on ${date.toString()}') : Text('Set ${set.indexKey}'),
      subtitle: Text('${set.reps} reps @ ${set.weight} kg ${set.partialReps > 0 ? '+ ${set.partialReps} partial reps' : ''}'),
      onTap: () =>openEditSetDialog(context, set),
      onLongPress: () => openExerciseSetLongPressContextMenu(context, set),
    ),
  );

  Future openExerciseSetLongPressContextMenu(BuildContext context, ExerciseSet set) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Set'),
        content: Text('Are you sure you want to delete set ${set.indexKey}?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              database.deleteExerciseSetFromExercise(
                selectedWorkout,
                selectedExercise,
                set.indexKey,
              );
              database.renumberExerciseSets(
                selectedWorkout,
                selectedExercise,
              );
              Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

}