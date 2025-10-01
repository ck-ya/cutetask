import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../models/timer_model.dart';

class TimerService {
  static final TimerService _instance = TimerService._internal();
  factory TimerService() => _instance;
  TimerService._internal();

  String? activeTimerId;
  int timeLeft = 0;
  bool isRunning = false;
  Timer? timer;
  ValueNotifier<List<TimerModel>> timersNotifier = ValueNotifier([]);
  List<TimerModel> get timers => timersNotifier.value;

  Future<void> loadTimers() async {
    final prefs = await SharedPreferences.getInstance();
    final timersJson = prefs.getString('custom_timers');
    if (timersJson != null) {
      final List<dynamic> decoded = jsonDecode(timersJson);
      timersNotifier.value =
          decoded.map((e) => TimerModel.fromJson(e)).toList();
    }
    activeTimerId = prefs.getString('active_timer_id');
    timeLeft = prefs.getInt('time_left') ?? 0;
    isRunning = prefs.getBool('is_running') ?? false;
    if (isRunning) {
      // Re-start the timer only if time is left and it was running
      if (timeLeft > 0) {
        startTimer();
      } else {
        stopTimer();
      }
    }
  }

  Future<void> saveTimers() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'custom_timers',
      jsonEncode(timersNotifier.value.map((e) => e.toJson()).toList()),
    );
    await prefs.setString('active_timer_id', activeTimerId ?? '');
    await prefs.setInt('time_left', timeLeft);
    await prefs.setBool('is_running', isRunning);
  }

  void addTimer(String name, int duration) {
    final newTimers = List<TimerModel>.from(timersNotifier.value);
    newTimers.add(TimerModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      duration: duration,
    ));
    timersNotifier.value = newTimers;
    saveTimers();
  }

  void deleteTimer(String id) {
    final newTimers = List<TimerModel>.from(timersNotifier.value);
    newTimers.removeWhere((t) => t.id == id);
    timersNotifier.value = newTimers;
    if (activeTimerId == id) {
      activeTimerId = null;
      timeLeft = 0;
      stopTimer();
    }
    saveTimers();
  }

  void startTimer({String? newId, int? newDuration}) {
    if (newId != null) {
      activeTimerId = newId;
      timeLeft = newDuration ??
          timersNotifier.value
              .firstWhere((t) => t.id == newId,
                  orElse: () => TimerModel(id: '', name: '', duration: 0))
              .duration;
    }

    if (timeLeft <= 0) return; // Prevent starting a 0-second timer

    if (timer != null) stopTimer(shouldSave: false);
    isRunning = true;
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (timeLeft > 0) {
        timeLeft--;
        // timersNotifier.value assignment triggers listeners
        saveTimers();
      } else {
        stopTimer();
        SystemSound.play(SystemSoundType.alert);
      }
    });
    saveTimers();
    // timersNotifier.value assignment triggers listeners
  }

  void stopTimer({bool shouldSave = true}) {
    timer?.cancel();
    isRunning = false;
    // timersNotifier.value assignment triggers listeners
    if (shouldSave) saveTimers();
  }

  void resetTimer() {
    stopTimer();
    if (activeTimerId != null) {
      timeLeft = timersNotifier.value
          .firstWhere((t) => t.id == activeTimerId!,
              orElse: () => TimerModel(id: '', name: '', duration: 0))
          .duration;
    }
    // timersNotifier.value assignment triggers listeners
    saveTimers();
  }

  // Utility getter
  int get activeTimerDuration {
    if (activeTimerId == null || timers.isEmpty) return 0;
    return timers
        .firstWhere((t) => t.id == activeTimerId!,
            orElse: () => TimerModel(id: '', name: '', duration: 0))
        .duration;
  }
}
