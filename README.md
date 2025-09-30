# cute_task

A Productivity app built with flutter.
(tip : drinking coffee makes u a hundred times more productive)

## About

The original project, TaskFlow sucked, 
so using the same backend created this with better UI.

Inspired by -> CuteMusic & CuteCalC by @sosauce

### Working with it :

this is the structure of the complete

lib/
├── main.dart                 # App Entry Point & Root Widget (CuteTaskApp)
├── core/                     # App-wide components
│   ├── app_themes.dart       # Theme data/logic
│   └── constants.dart        # Global constants
├── models/                   # Data Structures
│   ├── task_model.dart       # TaskModel class
│   └── timer_model.dart      # TimerModel class
├── services/                 # State Management
│   └── timer_service.dart    # TimerService class 
├── widgets/                  # Reusable UI components
│   ├── cute_task_home.dart   # CuteTaskHome (Scaffold, AppBar, BottomNav)
│   └── timer_display.dart    # Reusable Timer display widget (used in both pages)
└── pages/                    # Full-screen pages
    ├── tasks/
    │   └── tasks_page.dart   # TasksPage implementation
    ├── clock/
    │   └── clock_page.dart   # ClockPage implementation
    ├── settings/
    │   └── settings_page.dart# SettingsPage implementation
    └── fullscreen/
        └── fullscreen_timer_page.dart # FullscreenTimerPage implementation