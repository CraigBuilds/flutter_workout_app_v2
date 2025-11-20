

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_workout_app_v2/main.dart';
import 'package:flutter_workout_app_v2/backend/models.dart';
import 'package:flutter_workout_app_v2/backend/workout_database.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    WidgetsFlutterBinding.ensureInitialized();
    await initHive();
    final box = await Hive.openBox<Workout>('workouts');
    final database = WorkoutDatabase(box);
    await database.seedWithExampleIfEmpty();

    await tester.pumpWidget(MyApp(database: database));

    // // Verify that our counter starts at 0.
    // expect(find.text('0'), findsOneWidget);
    // expect(find.text('1'), findsNothing);

    // // Tap the '+' icon and trigger a frame.
    // await tester.tap(find.byIcon(Icons.add));
    // await tester.pump();

    // // Verify that our counter has incremented.
    // expect(find.text('0'), findsNothing);
    // expect(find.text('1'), findsOneWidget);
  });
}
