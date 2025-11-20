import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';
part 'models.g.dart';

Future<void> initHive() async {

  Platform.isWindows ? Hive.init(Directory('hive_data').path) : await Hive.initFlutter();

  Hive.registerAdapter(WorkoutAdapter());
  Hive.registerAdapter(ExerciseAdapter());
  Hive.registerAdapter(ExerciseSetAdapter());
  Hive.registerAdapter(DateAdapter());
}

@HiveType(typeId: 0)
class Workout {

  @HiveField(0)
  final Date dateKey;

  @HiveField(1)
  final List<Exercise> exercises;

  Workout({required this.dateKey, required this.exercises});
}
@HiveType(typeId: 1)
class Exercise {

  @HiveField(0)
  final String name;

  @HiveField(1)
  final List<ExerciseSet> sets;

  Exercise({required this.name, required this.sets});
}

@HiveType(typeId: 2)
class ExerciseSet {

  @HiveField(0)
  final int reps;

  @HiveField(1)
  final double weight;

  @HiveField(2)
  final bool completed = false;

  @HiveField(3)
  final int partialReps = 0;

  @HiveField(4)
  final int restMinutes = 0;

  @HiveField(5)
  final int rir = 0;

  ExerciseSet({required this.reps, required this.weight});
}

@HiveType(typeId: 3)
class Date {

  @HiveField(0)
  final int year;

  @HiveField(1)
  final int month;

  @HiveField(2)
  final int day;

  const Date(this.year, this.month, this.day);

  factory Date.today() {
      final now = DateTime.now();
      return Date(now.year, now.month, now.day);
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
}