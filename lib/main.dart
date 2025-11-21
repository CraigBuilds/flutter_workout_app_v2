import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'backend/models.dart';
import 'backend/database.dart';
import 'pages/home_page.dart';

Future<void> main() async {
  
  WidgetsFlutterBinding.ensureInitialized();

  await initHive();

  final box = await Hive.openBox<AllWorkouts>('workouts');
  final database = WorkoutDatabase(box);
  database.initializeIfDatabaseIsEmpty();

  runApp(MyApp(database: database));
}

class MyApp extends StatelessWidget {

  final WorkoutDatabase database;

  const MyApp({super.key, required this.database});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: database.box.listenable(),
      builder: (context, box, _) {
        return MaterialApp(
          title: 'Workouts App',
          home: HomePage(database: database),
        );
      },
    );
  }
}
