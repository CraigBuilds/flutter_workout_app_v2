// confirm_on_exit.dart
import 'package:flutter/material.dart';

class ConfirmOnExit extends StatelessWidget {
  final Widget child;

  const ConfirmOnExit({required this.child, super.key});

  Future<bool> _showConfirmationDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm'),
        content: const Text('Are you sure you want to close?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final shouldExit = await _showConfirmationDialog(context);
        if (shouldExit && context.mounted) {
          Navigator.pop(context);
        }
      },
      child: child,
    );
  }
}
