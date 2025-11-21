import 'package:flutter/material.dart';
import 'package:flutter_workout_app_v2/backend/database.dart';
import 'package:flutter_workout_app_v2/backend/models.dart';

class SettingsPage extends StatelessWidget {
  final WorkoutDatabase database;

  const SettingsPage({super.key, required this.database});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            title: Text('Clear All Data'),
            leading: Icon(Icons.delete_forever),
            onTap: () {
              database.clearAllData();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('All data cleared')),
              );
            },
          ),
          //simulated date offset
          ListTile(
            title: Text('Simulated Date Offset'),
            leading: Icon(Icons.date_range),
            onTap: () => _showSimulatedDateOffsetDialog(context),
          ),
        ],
      )
    );
  }

  void _showSimulatedDateOffsetDialog(BuildContext context) async {
    final offsetController =
        TextEditingController(text: Date.simulatedDateOffsetDays.toString());

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Set Simulated Date Offset (days)'),
          content: TextField(
            controller: offsetController,
            decoration: const InputDecoration(labelText: 'Offset in days'),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              onPressed: () {
                final offset = int.tryParse(offsetController.text);
                if (offset != null) {
                  Date.simulatedDateOffsetDays = offset;
                  database.forceRebuild();
                }
                Navigator.of(context).pop();
              },
              child: const Text('Set'),
            ),
          ],
        );
      },
    );
  }

}

