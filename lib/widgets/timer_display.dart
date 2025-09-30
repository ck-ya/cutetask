import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // <--- ADD THIS IMPORT
import '../services/timer_service.dart';
import '../pages/fullscreen/fullscreen_timer_page.dart';

class TimerDisplay extends StatefulWidget {
  const TimerDisplay({super.key});

  @override
  State<TimerDisplay> createState() => _TimerDisplayState();
}

class _TimerDisplayState extends State<TimerDisplay> {
  // Utility function to format seconds into HH:MM:SS
  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final sec = seconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  double get _timerProgress {
    final service = TimerService();
    final duration = service.activeTimerDuration;
    if (duration <= 0) return 0;
    // Calculate progress as fraction of time elapsed (from 0.0 to 1.0)
    return (duration - service.timeLeft) / duration;
  }

  Future<void> _goFullscreen() async {
    // 1. Enter Landscape Mode
    // FIX: SystemChrome is now defined due to the import.
    await SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft]);

    // 2. Navigate to Fullscreen and wait for the result (the time left)
    final service = TimerService(); // Get the single instance
    final remaining = await Navigator.push<int>(
      context,
      MaterialPageRoute(
        builder: (context) => FullscreenTimerPage(
          initialTime: service.timeLeft,
          isRunning: service.isRunning,
        ),
      ),
    );

    // 3. Exit Landscape Mode back to Portrait
    // FIX: SystemChrome is now defined due to the import.
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    // 4. Update the global TimerService with the returned value
    if (remaining != null) {
      service.timeLeft = remaining;
      // Restart the service timer if it was running before going fullscreen
      if (service.isRunning && remaining > 0) {
        service.startTimer();
      } else {
        // If it was paused or reached 0, just stop it
        service.stopTimer(shouldSave: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final service = TimerService(); // Use the singleton instance

    if (service.activeTimerId == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            _formatDuration(service.timeLeft),
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w300,
              color: colorScheme.primary,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!service.isRunning)
                ElevatedButton.icon(
                  onPressed: service.startTimer,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Start'),
                )
              else
                ElevatedButton.icon(
                  onPressed: service.stopTimer,
                  icon: const Icon(Icons.pause),
                  label: const Text('Pause'),
                ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: service.resetTimer,
                icon: const Icon(Icons.refresh),
                label: const Text('Reset'),
              ),
              const SizedBox(width: 12),
              IconButton(
                icon: const Icon(Icons.fullscreen),
                onPressed: _goFullscreen,
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: _timerProgress,
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
        ],
      ),
    );
  }
}
