import 'package:flutter/material.dart';
import 'dart:async';

class RestTimer extends ChangeNotifier {
  int remaining = 0;
  Timer? _timer;

  void start(int seconds) {
    remaining = seconds;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remaining > 1) {
        remaining--;
        notifyListeners();
      } else {
        timer.cancel();
        notifyListeners();
        _vibrateAndBeep(); // Vibrate and beep when timer reaches zero
      }
    });
    notifyListeners();
  }

  void stop() {
    _timer?.cancel();
    remaining = 0;
    notifyListeners();
  }

  void _vibrateAndBeep() async {
    debugPrint('Rest timer ended: Vibrating and beeping.');
  }
}

final globalRestTimer = RestTimer();

void showCountdownSnackbar(BuildContext context, int seconds) {
  globalRestTimer.start(seconds);

  final scaffold = ScaffoldMessenger.of(context);

  SnackBar snackbar = SnackBar(
    content: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CountdownText(),
        const SizedBox(width: 16),
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            scaffold.hideCurrentSnackBar();
            globalRestTimer.stop();
          },
          child: const Text('Dismiss'),
        ),
      ],
    ),
    duration: Duration(seconds: seconds),
  );

  scaffold.showSnackBar(snackbar);
}

class CountdownText extends StatefulWidget {
  const CountdownText({super.key});

  @override
  State<CountdownText> createState() => _CountdownTextState();
}

class _CountdownTextState extends State<CountdownText> {
  @override
  void initState() {
    super.initState();
    globalRestTimer.addListener(_onTimerUpdate);
  }

  void _onTimerUpdate() {
    setState(() {});
  }

  @override
  void dispose() {
    globalRestTimer.removeListener(_onTimerUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.access_time, size: 20, color: Colors.white),
        const SizedBox(width: 8),
        Text('Rest: ${globalRestTimer.remaining} seconds left'),
      ],
    );
  }
}