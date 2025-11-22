import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';
import 'database.dart';
part 'models.g.dart';

Future<WorkoutDatabase> initHive() async {

  Platform.isWindows ? Hive.init(Directory('hive_data').path) : await Hive.initFlutter();

  Hive.registerAdapter(AllWorkoutsAdapter());
  Hive.registerAdapter(WorkoutAdapter());
  Hive.registerAdapter(ExerciseAdapter());
  Hive.registerAdapter(ExerciseSetAdapter());
  Hive.registerAdapter(DateAdapter());

  final box = await Hive.openBox<AllWorkouts>('workouts');
  final database = WorkoutDatabase(box);
  database.initializeIfDatabaseIsEmpty();

  return database;
}

@HiveType(typeId: 0)
class AllWorkouts {

  @HiveField(0)
  final Map<Date, Workout> workouts;

  @HiveField(1)
  final Map<String, Map<String, Workout>> templateWorkouts; //templateName -> (workoutName -> Workout)

  AllWorkouts({required this.workouts, required this.templateWorkouts});
}

@HiveType(typeId: 1)
class Workout {

  @HiveField(0)
  final Date dateKey;

  @HiveField(1)
  final Map<String, Exercise> exercises;

  @HiveField(2)
  final String workoutName = ""; //this is populated if this Workout was created from a template.

  Workout({required this.dateKey, required this.exercises});
}
@HiveType(typeId: 2)
class Exercise {

  @HiveField(0)
  final String nameKey;

  @HiveField(1)
  final Map<int, ExerciseSet> sets;

  @HiveField(2)
  final String superSetWithExerciseName = "";

  Exercise({required this.nameKey, required this.sets});
}

@HiveType(typeId: 3)
class ExerciseSet {

  @HiveField(0)
  final int indexKey;

  @HiveField(1)
  final int reps;

  @HiveField(2)
  final double weight;

  @HiveField(3)
  final bool completed;

  @HiveField(4)
  final int restSeconds = 0;

  @HiveField(5)
  final int rir = 0;

  @HiveField(6)
  final int partialReps;

  @HiveField(7)
  final int forcedReps = 0;

  @HiveField(8)
  final int restPauseReps = 0; //also use this for myo reps or cluster reps.

  @HiveField(9)
  final DropSet? dropSet1 = null;

  @HiveField(10)
  final DropSet? dropSet2 = null;

  @HiveField(11)
  final DropSet? dropSet3 = null;

  @HiveField(12)
  final String tempo = "";

  @HiveField(13)
  final String form = "";

  @HiveField(14)
  final int machineSetting = 0;

  @HiveField(15)
  final String notes = "";

  @HiveField(16)
  final bool isPR = false;

  ExerciseSet({required this.indexKey, required this.reps, required this.weight, required this.completed, required this.partialReps});

  //used either partial reps, forced reps, rest pause reps, or drop sets.
  bool get usedIntensityTechnique => partialReps > 0 || forcedReps > 0 || restPauseReps > 0 || dropSet1 != null;
}

@HiveType(typeId: 4)
class Date {

  @HiveField(0)
  final int year;

  @HiveField(1)
  final int month;

  @HiveField(2)
  final int day;

  static int simulatedDateOffsetDays = 0;

  const Date(this.year, this.month, this.day);

  factory Date.today() {
      final now = DateTime.now();
      return Date(now.year, now.month, now.day + simulatedDateOffsetDays);
  }

  @override
  bool operator == (Object other) {
      return (other is Date &&
      year == other.year &&
      month == other.month &&
      day == other.day);
  }

  bool operator > (Date other) {
      if (year != other.year) {
          return year > other.year;
      }
      if (month != other.month) {
          return month > other.month;
      }
      return day > other.day;
  }

  bool operator >= (Date other) {
      return this > other || this == other;
  }

  Date operator - (int days) {
      final dt = DateTime(year, month, day).subtract(Duration(days: days));
      return Date(dt.year, dt.month, dt.day);
  }
  
  @override
  int get hashCode { return year * 10000 + month * 100 + day; }

  @override
  String toString() {
    return '$year-$month-$day';
  }

  factory Date.fromString(String value) {
    final parts = value.split('-');
    return Date(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }

  DateTime toDateTime() {
    return DateTime(year, month, day);
  }

  String dayOfWeek() {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[toDateTime().weekday - 1];
  }
}

@HiveType(typeId: 5)
class DropSet {

  @HiveField(0)
  final double weight;

  @HiveField(1)
  final int reps;

  DropSet({required this.weight, required this.reps});
}