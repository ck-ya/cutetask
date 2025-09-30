import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/constants.dart';
import '../pages/tasks/tasks_page.dart';
import '../pages/clock/clock_page.dart';
import '../pages/settings/settings_page.dart';
import '../services/timer_service.dart';

class CuteTaskHome extends StatefulWidget {
  final String themeType;
  final String fontFamily;
  final String colorType;
  final Function(String) onThemeChanged;
  final Function(String) onFontChanged;
  final Function(String) onColorChanged;

  const CuteTaskHome({
    super.key,
    required this.themeType,
    required this.fontFamily,
    required this.colorType,
    required this.onThemeChanged,
    required this.onFontChanged,
    required this.onColorChanged,
  });

  @override
  State<CuteTaskHome> createState() => _CuteTaskHomeState();
}

class _CuteTaskHomeState extends State<CuteTaskHome> {
  int _selectedIndex = 0;
  String _currentTime = '';
  Timer? _clockTimer;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    TimerService().loadTimers();
    _startClock();
    _pages = [
      const TasksPage(),
      const ClockPage(),
    ];
    // This periodic timer ensures the UI updates when TimerService calls onUpdate
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() {});
    });
  }

  void _startClock() {
    _updateClock();
    _clockTimer =
        Timer.periodic(const Duration(seconds: 1), (_) => _updateClock());
  }

  void _updateClock() {
    final now = DateTime.now();
    if (mounted) {
      setState(() {
        _currentTime =
            '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
      });
    }
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppConstants.appName,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color:
                      Theme.of(context).colorScheme.outline.withOpacity(0.3)),
            ),
            child: Text(
              _currentTime,
              style: TextStyle(
                fontFamily: 'monospace',
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.settings,
                color: Theme.of(context).colorScheme.primary),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsPage(
                    themeType: widget.themeType,
                    fontFamily: widget.fontFamily,
                    colorType: widget.colorType,
                    onThemeChanged: widget.onThemeChanged,
                    onFontChanged: widget.onFontChanged,
                    onColorChanged: widget.onColorChanged,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timer),
            label: 'Clock',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
