import 'package:hive/hive.dart';
import 'models.dart';

///A Very simplex NoSQL (key-value) database that stores all data as a binary blob at key 0 in a Hive box.
///Hive just manages the the serialization and storage to disk (cross-platform), and listens for changes.
///Surprisingly, this is cleaner than using json for serialization, freezed for code-gen/data-classes, and shared_preferences for storage. Also less complex than full DB like Drift.
///Any mutation to the app state must go through this class, and use the read-modify-write pattern to ensure UI updates.
class WorkoutDatabase {
  
  final Box<AllWorkouts> box;

  WorkoutDatabase(this.box);

  //for first-time initialization, add the AllWorkouts object at index 0 if the box is empty.
  //it is seeded with 7 empty workouts for the last 7 days, to show the user how the app works right away.
  void initializeIfDatabaseIsEmpty() {
    if (box.isEmpty) {
      box.add(AllWorkouts(workouts: {
        Date.today() -7 : Workout(dateKey: Date.today() -7, exercises: {}),
        Date.today() -6 : Workout(dateKey: Date.today() -6, exercises: {}),
        Date.today() -5 : Workout(dateKey: Date.today() -5, exercises: {}),
        Date.today() -4 : Workout(dateKey: Date.today() -4, exercises: {}),
        Date.today() -3 : Workout(dateKey: Date.today() -3, exercises: {}),
        Date.today() -2 : Workout(dateKey: Date.today() -2, exercises: {}),
        Date.today() -1 : Workout(dateKey: Date.today() -1, exercises: {}),
      }));
    }
  }

  // Helpers to get and set the single AllWorkouts object stored in the box
  AllWorkouts readData() => box.values.first; //there is always exactly one object stored at index 0
  void writeData(AllWorkouts data) => box.putAt(0, data); //this needs to be called to trigger a UI update

  // ---- CRUD operations ---

  // -- Workout

  Workout? getWorkoutOrNull(Date date) {
    return readData().workouts[date];
  }

  void putWorkout(Date date, Workout workout) {
    final allWorkouts = readData(); //read
    allWorkouts.workouts[date] = workout; //modify
    writeData(allWorkouts); //write
  }

  void deleteWorkout(Date date) {
    final allWorkouts = readData(); //read
    allWorkouts.workouts.remove(date); //modify
    writeData(allWorkouts); //write
  }

  // -- Exercise

  Exercise? getExerciseFromWorkoutOrNull(Workout workout, String exerciseName) {
    return workout.exercises[exerciseName];
  }

  void putExerciseInWorkout(Workout workout, Exercise exercise) {
    final allWorkouts = readData(); //read the database
    workout.exercises[exercise.nameKey] = exercise; //modify the given workout
    allWorkouts.workouts[workout.dateKey] = workout; //assign modified workout back to the database
    writeData(allWorkouts); //write back to the database
  }

  void deleteExerciseFromWorkout(Workout workout, String exerciseName) {
    final allWorkouts = readData(); //read the database
    workout.exercises.remove(exerciseName); //modify the given workout
    allWorkouts.workouts[workout.dateKey] = workout; //assign modified workout back to the database
    writeData(allWorkouts); //write back to the database
  }

  // -- ExerciseSet

  ExerciseSet? getExerciseSetFromExerciseOrNull(Exercise exercise, int setIndex) {
    return exercise.sets[setIndex];
  }

  void putSetInExercise(Workout workout, Exercise exercise, ExerciseSet exerciseSet) {
    final allWorkouts = readData(); //read the database
    exercise.sets[exerciseSet.indexKey] = exerciseSet; //modify the given exercise
    workout.exercises[exercise.nameKey] = exercise; //assign modified exercise back to the given workout
    allWorkouts.workouts[workout.dateKey] = workout; //assign modified workout back to the database
    writeData(allWorkouts); //write back to the database
  }

  void pushSetToExercise(Workout workout, Exercise exercise, int reps, double weight, int partialReps) {
    putSetInExercise(
      workout,
      exercise,
      ExerciseSet(indexKey: getNumberOfSetsInExercise(workout, exercise.nameKey) + 1, reps: reps, weight: weight, completed: false, partialReps: partialReps),
    );
  }

  void markSetAsCompleted(Workout workout, Exercise exercise, ExerciseSet set, bool completed) {
    final newSet = ExerciseSet(indexKey: set.indexKey, reps: set.reps, weight: set.weight, completed: completed, partialReps: set.partialReps);
    putSetInExercise(workout, exercise, newSet);
  }

  void deleteExerciseSetFromExercise(Workout workout, Exercise exercise, int setIndex) {
    final allWorkouts = readData(); //read the database
    exercise.sets.remove(setIndex); //modify the given exercise
    workout.exercises[exercise.nameKey] = exercise; //assign modified exercise back to the given workout
    allWorkouts.workouts[workout.dateKey] = workout; //assign modified workout back to the database    
    writeData(allWorkouts); //write back to the database
  }

  void renumberExerciseSets(Workout workout, Exercise exercise) {
    final allWorkouts = readData(); //read the database
    final setsList = exercise.sets.values.toList();
    exercise.sets.clear();
    for (int i = 0; i < setsList.length; i++) {
      final set = setsList[i];
      exercise.sets[i + 1] = ExerciseSet(indexKey: i + 1, reps: set.reps, weight: set.weight, completed: set.completed, partialReps: set.partialReps);
    }
    workout.exercises[exercise.nameKey] = exercise; //assign modified exercise back to the given workout
    allWorkouts.workouts[workout.dateKey] = workout; //assign modified workout back to the database    
    writeData(allWorkouts); //write back to the database
  }

  // ---- Additional helper methods ----

  int getTotalWorkoutCount() {
    return readData().workouts.length;
  }

  int getNumberOfSetsInExercise(Workout workout, String exerciseName) {
    final exercise = workout.exercises[exerciseName];
    if (exercise == null) {
      return 0;
    }
    return exercise.sets.length;
  }

  Workout? getWorkoutAtIndexOrNull(int index) {
    if (index < 0 || index >= readData().workouts.length) {
      return null;
    }
    return readData().workouts.values.elementAt(index);
  }

  int getIndexOfTodayWorkoutOr({int defaultIndex = 0}) {
    final today = Date.today();
    final workoutDates = readData().workouts.keys.toList();
    for (int i = 0; i < workoutDates.length; i++) {
      if (workoutDates[i] >= today) {
        return i;
      }
    }
    return defaultIndex;
  }

  List<(Date, ExerciseSet)> getHistoricalSets(Exercise exercise, {bool removeIncompleteSets = true}) {
    final allWorkouts = readData();
    final List<(Date, ExerciseSet)> historicalSets = [];
    for (final workout in allWorkouts.workouts.values) {
      final ex = workout.exercises[exercise.nameKey];
      if (ex != null) {
        for (final set in ex.sets.values) {
          historicalSets.add((workout.dateKey, set));
        }
      }
    }
    historicalSets.sort((a, b) => b.$1 > a.$1 ? 1 : -1);
    if (removeIncompleteSets) {
      historicalSets.retainWhere((element) => element.$2.completed);
    }
    return historicalSets;
  }

  ExerciseSet? getLatestSetForExerciseOrNull(Exercise exercise) {
    final historicalSets = getHistoricalSets(exercise, removeIncompleteSets: false);
    if (historicalSets.isEmpty) {
      return null;
    }
    //sort the sets by index (highest to lowest)
    historicalSets.sort((a, b) => b.$2.indexKey - a.$2.indexKey);
    //sort the sets by date (newest to oldest)
    historicalSets.sort((a, b) => b.$1 > a.$1 ? 1 : -1);
    //return the first set
    return historicalSets.first.$2;
  }

  void clearAllData() {
    final empty = AllWorkouts(workouts: {});
    writeData(empty); //replace root object
  }

  bool workoutExistsForToday() {
    final today = Date.today();
    return readData().workouts.containsKey(today);
  }

  void forceRebuild() {
    final allWorkouts = readData();
    writeData(allWorkouts);
  }

  // ---- Static Data ---- (We will eventually put this in the hive box as well, so the user can add more items)

  List<String> getAvailableExerciseNames() {
    return [
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
  }

}
