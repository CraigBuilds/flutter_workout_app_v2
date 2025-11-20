import 'package:hive/hive.dart';
import 'models.dart';

class WorkoutDatabase {
  
  final Box<AllWorkouts> _box;

  WorkoutDatabase(this._box);

  // Exposed so composition root (main.dart) can wire listeners.
  Box<AllWorkouts> get box => _box;

  //for first-time initialization  
  void initializeIfDatabaseIsEmpty() {
    if (_box.isEmpty) {
      _box.add(AllWorkouts(workouts: {}));
    }
  }

  // Helper to get the single AllWorkouts object stored in the box
  AllWorkouts get boxData => _box.values.first;

  // ---- CRUD operations ---

  // -- Workout

  Workout? getWorkoutOrNull(Date date) => boxData.workouts[date];

  void putWorkout(Date date, Workout workout) {
    final allWorkouts = boxData; //read
    allWorkouts.workouts[date] = workout; //modify
    _box.putAt(0, allWorkouts); //write
  }

  void deleteWorkout(Date date) {
    final allWorkouts = boxData; //read
    allWorkouts.workouts.remove(date); //modify
    _box.putAt(0, allWorkouts); //write
  }

  // -- Exercise

  Exercise? getExerciseFromWorkoutOrNull(Workout workout, String exerciseName) {
    return workout.exercises[exerciseName];
  }

  void putExerciseInWorkout(Workout workout, Exercise exercise) {
    final allWorkouts = boxData; //read the database
    workout.exercises[exercise.nameKey] = exercise; //modify the given workout
    allWorkouts.workouts[workout.dateKey] = workout; //assign modified workout back to the database
    _box.putAt(0, allWorkouts); //write back to the database
  }

  void deleteExerciseFromWorkout(Workout workout, String exerciseName) {
    final allWorkouts = boxData; //read the database
    workout.exercises.remove(exerciseName); //modify the given workout
    allWorkouts.workouts[workout.dateKey] = workout; //assign modified workout back to the database
    _box.putAt(0, allWorkouts); //write back to the database
  }

  // -- ExerciseSet

  ExerciseSet? getExerciseSetFromExerciseOrNull(Exercise exercise, int setIndex) {
    return exercise.sets[setIndex];
  }

  void putSetInExercise(Workout workout, Exercise exercise, ExerciseSet exerciseSet) {
    final allWorkouts = boxData; //read the database
    exercise.sets[exerciseSet.indexKey] = exerciseSet; //modify the given exercise
    workout.exercises[exercise.nameKey] = exercise; //assign modified exercise back to the given workout
    allWorkouts.workouts[workout.dateKey] = workout; //assign modified workout back to the database
    _box.putAt(0, allWorkouts); //write back to the database
  }

  void pushSetToExercise(Workout workout, Exercise exercise, int reps, double weight) {
    putSetInExercise(
      workout,
      exercise,
      ExerciseSet(indexKey: getNumberOfSetsInExercise(workout, exercise.nameKey) + 1, reps: reps, weight: weight),
    );
  }

  void deleteExerciseSetFromExercise(Workout workout, Exercise exercise, int setIndex) {
    final allWorkouts = boxData; //read the database
    exercise.sets.remove(setIndex); //modify the given exercise
    workout.exercises[exercise.nameKey] = exercise; //assign modified exercise back to the given workout
    allWorkouts.workouts[workout.dateKey] = workout; //assign modified workout back to the database
    _box.putAt(0, allWorkouts); //write back to the database
  }

  // ---- Additional helper methods ----

  int getTotalWorkoutCount() {
    return boxData.workouts.length;
  }

  int getNumberOfSetsInExercise(Workout workout, String exerciseName) {
    final exercise = workout.exercises[exerciseName];
    if (exercise == null) {
      return 0;
    }
    return exercise.sets.length;
  }

  Workout? getWorkoutAtIndexOrNull(int index) {
    if (index < 0 || index >= boxData.workouts.length) {
      return null;
    }
    return boxData.workouts.values.elementAt(index);
  }

  int getIndexOfTodayWorkoutOr({int defaultIndex = 0}) {
    final today = Date.today();
    final workoutDates = boxData.workouts.keys.toList();
    for (int i = 0; i < workoutDates.length; i++) {
      if (workoutDates[i] >= today) {
        return i;
      }
    }
    return defaultIndex;
  }

  void clearAllData() {
    final empty = AllWorkouts(workouts: {});
    _box.putAt(0, empty); //replace root object
  }

  bool workoutExistsForToday() {
    final today = Date.today();
    return boxData.workouts.containsKey(today);
  }

  void seedInitialDataForTesting() {

    final workout1 = Workout(
      dateKey: Date(2024, 6, 1),
      exercises: {
        'Squat': Exercise(
          nameKey: 'Squat',
          sets: {
            1: ExerciseSet(indexKey: 1, reps: 5, weight: 100.0),
            2: ExerciseSet(indexKey: 2, reps: 5, weight: 105.0),
          },
        ),
        'Bench Press': Exercise(
          nameKey: 'Bench Press',
          sets: {
            1: ExerciseSet(indexKey: 1, reps: 5, weight: 80.0),
            2: ExerciseSet(indexKey: 2, reps: 5, weight: 85.0),
          },
        ),
      },
    );

    final workout2 = Workout(
      dateKey: Date(2024, 6, 3),
      exercises: {
        'Deadlift': Exercise(
          nameKey: 'Deadlift',
          sets: {
            1: ExerciseSet(indexKey: 1, reps: 5, weight: 120.0),
            2: ExerciseSet(indexKey: 2, reps: 5, weight: 125.0),
          },
        ),
      },
    );

    putWorkout(workout1.dateKey, workout1);
    putWorkout(workout2.dateKey, workout2);
  }

}
