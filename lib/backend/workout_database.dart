import 'package:hive/hive.dart';
import 'models.dart';

class WorkoutDatabase {
  final Box<Workout> _box;

  WorkoutDatabase(this._box);

  // Exposed so composition root (main.dart) can wire listeners.
  Box<Workout> get box => _box;

  bool get isEmpty => _box.isEmpty;

  List<Workout> getAll() => _box.values.toList(growable: false);

  Future<void> addWorkout(Workout workout) => _box.add(workout);

  Future<void> seedWithExampleIfEmpty() async {
    if (isEmpty) {
      await addWorkout(
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
  }
}
