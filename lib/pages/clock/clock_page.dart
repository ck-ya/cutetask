import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/timer_model.dart';
import '../../services/timer_service.dart';
import '../../widgets/timer_display.dart';

class ClockPage extends StatefulWidget {
  const ClockPage({super.key});

  @override
  State<ClockPage> createState() => _ClockPageState();
}

class _ClockPageState extends State<ClockPage> {
  @override
  void initState() {
    super.initState();
    // Register the local setState as a callback for TimerService updates
    TimerService().onUpdate = () => setState(() {});
  }

  @override
  void dispose() {
    TimerService().onUpdate = null; // Clean up the callback
    super.dispose();
  }

  void _addTimer() {
    final nameController = TextEditingController();
    final hourController = TextEditingController();
    final minController = TextEditingController();

    // Clear the controllers when dialog is dismissed
    void disposeControllers() {
      nameController.dispose();
      hourController.dispose();
      minController.dispose();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Timer'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: hourController,
              decoration: const InputDecoration(labelText: 'Hours (H)'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: minController,
              decoration: const InputDecoration(labelText: 'Minutes (M)'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final hours = int.tryParse(hourController.text) ?? 0;
              final min = int.tryParse(minController.text) ?? 0;
              final duration = (hours * 3600) + (min * 60);

              if (name.isNotEmpty && duration > 0) {
                TimerService().addTimer(name, duration);
                disposeControllers();
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    ).then((_) => disposeControllers()); // Dispose after dialog closes
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final min = (seconds % 3600) ~/ 60;
    final sec = seconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            onPressed: _addTimer,
            icon: const Icon(Icons.add),
            label: const Text('Add Custom Timer'),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: TimerService().timers.length,
            itemBuilder: (context, index) {
              final timer = TimerService().timers[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  title: Text(timer.name),
                  subtitle: Text(_formatDuration(timer.duration)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          TimerService().activeTimerId == timer.id &&
                                  TimerService().isRunning
                              ? Icons.pause
                              : Icons.play_arrow,
                        ),
                        onPressed: () {
                          if (TimerService().activeTimerId == timer.id &&
                              TimerService().isRunning) {
                            TimerService().stopTimer();
                          } else {
                            TimerService().startTimer(
                                newId: timer.id, newDuration: timer.duration);
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => TimerService().deleteTimer(timer.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        // Timer display is now a separate reusable widget
        const TimerDisplay(),
      ],
    );
  }
}
