// confirm_on_exit.dart
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ConfirmOnExit extends StatelessWidget {
  final Widget child;

  const ConfirmOnExit({super.key, required this.child});

  Future<bool> _showConfirmationDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm'),
        content: const Text('Are you sure you want to close?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _exitApp(BuildContext context) {
    if (Platform.isAndroid) {
      // Properly closes the activity on Android
      SystemNavigator.pop();
    } else {
      // On iOS, apps are not supposed to exit themselves;
      // just pop the route if possible.
      Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final shouldExit = await _showConfirmationDialog(context);
        if (shouldExit && context.mounted) {
          _exitApp(context);
        }
      },
      child: child,
    );
  }
}
