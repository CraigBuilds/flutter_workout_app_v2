import 'package:flutter/material.dart';
import 'package:flutter_workout_app_v2/backend/workout_database.dart';

class HomePage extends StatelessWidget {
  final WorkoutDatabase database;

  const HomePage({super.key, required this.database});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _HomePageAppBar(),
      body: _HomePageBody(database: database),
    );
  }
}

// -- Widgets --

class _HomePageAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Workouts'),
    );
  }
}

class _HomePageBody extends StatelessWidget {
  final WorkoutDatabase database;

  const _HomePageBody({required this.database});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Number of workouts: ${database.box.length}'),
    );
  }
}