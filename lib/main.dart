import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'backend/models.dart';
import 'backend/workout_database.dart';
import 'backend/hive_box_material_app.dart';
import 'pages/home_page.dart';

Future<void> main() async {
  
  WidgetsFlutterBinding.ensureInitialized();

  await initHive();

  final box = await Hive.openBox<AllWorkouts>('workouts');
  final database = WorkoutDatabase(box);

  runApp(MyApp(database: database));
}

class MyApp extends StatelessWidget {

  final WorkoutDatabase database;

  const MyApp({super.key, required this.database});

  @override
  Widget build(BuildContext context) {
    return HiveBoxMaterialApp<AllWorkouts>(
      box: database.box,
      title: 'Workouts App',
      homeBuilder: (context, box) {
        return MaterialApp(
          title: 'Workouts',
          home: HomePage(database: database),
        );
      },
    );
  }
}
