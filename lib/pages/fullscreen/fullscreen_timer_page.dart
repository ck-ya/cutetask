import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FullscreenTimerPage extends StatefulWidget {
  final int initialTime;
  final bool isRunning;

  const FullscreenTimerPage({
    super.key,
    required this.initialTime,
    required this.isRunning,
  });

  @override
  State<FullscreenTimerPage> createState() => _FullscreenTimerPageState();
}

class _FullscreenTimerPageState extends State<FullscreenTimerPage> {
  late int _timeLeft;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timeLeft = widget.initialTime;
    if (widget.isRunning) _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel(); // Ensure no duplicate timers
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        _timer?.cancel();
        return;
      }
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
        } else {
          _timer?.cancel();
          SystemSound.play(SystemSoundType.alert);
        }
      });
    });
  }

  String get _timerDisplay {
    final hours = _timeLeft ~/ 3600;
    final minutes = (_timeLeft % 3600) ~/ 60;
    final seconds = _timeLeft % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // New function to handle exiting
  void _exitFullscreen() {
    // Navigator.pop returns the current time left
    Navigator.pop(context, _timeLeft);
  }

  @override
  Widget build(BuildContext context) {
    // The PopScope is for handling the device back button (Android/Web/Desktop)
    return PopScope(
      canPop:
          false, // Prevent pop until we explicitly call it to return _timeLeft
      onPopInvoked: (didPop) {
        if (didPop) return;
        _exitFullscreen();
      },
      child: Scaffold(
        body: GestureDetector(
          // FIX: The onTap now calls _exitFullscreen()
          // HitTestBehavior.opaque ensures that taps anywhere on the screen
          // (within the GestureDetector's bounds) are detected, solving the issue.
          behavior: HitTestBehavior.opaque,
          onTap: _exitFullscreen,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Theme.of(context).colorScheme.background,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _timerDisplay,
                    style: const TextStyle(
                      fontSize: 100,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Tap anywhere to exit full screen',
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
