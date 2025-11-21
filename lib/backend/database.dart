import 'package:hive/hive.dart';
import 'models.dart';

///A Very simplex NoSQL (key-value) database that stores all data as a binary blob at key 0 in a Hive box.
///Hive just manages the the serialization and storage to disk (cross-platform).
class WorkoutDatabase {
  
  final Box<AllWorkouts> box;

  WorkoutDatabase(this.box);

  //for first-time initialization  
  void initializeIfDatabaseIsEmpty() {
    if (box.isEmpty) {
      box.add(AllWorkouts(workouts: {})); //adds at index 0
    }
  }

  // Helper to get and set the single AllWorkouts object stored in the box
  AllWorkouts readData() => box.values.first;
  void writeData(AllWorkouts data) => box.putAt(0, data);

  // ---- CRUD operations ---

  // -- Workout

  Workout? getWorkoutOrNull(Date date) => readData().workouts[date];

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

  void pushSetToExercise(Workout workout, Exercise exercise, int reps, double weight) {
    putSetInExercise(
      workout,
      exercise,
      ExerciseSet(indexKey: getNumberOfSetsInExercise(workout, exercise.nameKey) + 1, reps: reps, weight: weight),
    );
  }

  void deleteExerciseSetFromExercise(Workout workout, Exercise exercise, int setIndex) {
    final allWorkouts = readData(); //read the database
    exercise.sets.remove(setIndex); //modify the given exercise
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
