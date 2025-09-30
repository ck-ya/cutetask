import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/app_themes.dart';
import 'core/constants.dart';
import 'widgets/cute_task_home.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CuteTaskApp());
}

class CuteTaskApp extends StatefulWidget {
  const CuteTaskApp({super.key});

  @override
  State<CuteTaskApp> createState() => _CuteTaskAppState();
}

class _CuteTaskAppState extends State<CuteTaskApp> {
  ThemeMode _themeMode = ThemeMode.dark;
  String _themeType = AppConstants.defaultTheme;
  String _fontFamily = AppConstants.defaultFont;
  String _colorType = AppConstants.defaultColor;
  Color _seedColor = AppConstants.colorMap[AppConstants.defaultColor]!;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _themeType = prefs.getString('theme') ?? AppConstants.defaultTheme;
      _themeMode = AppThemes.getThemeMode(_themeType);
      _fontFamily = prefs.getString('font') ?? AppConstants.defaultFont;
      _colorType = prefs.getString('color') ?? AppConstants.defaultColor;
      _seedColor =
          AppConstants.colorMap[_colorType] ?? AppConstants.defaultSeedColor;
    });
  }

  void _changeTheme(String theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme', theme);
    setState(() {
      _themeType = theme;
      _themeMode = AppThemes.getThemeMode(theme);
    });
  }

  void _changeFont(String font) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('font', font);
    setState(() {
      _fontFamily = font;
    });
  }

  void _changeColor(String color) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('color', color);
    setState(() {
      _colorType = color;
      _seedColor =
          AppConstants.colorMap[color] ?? AppConstants.defaultSeedColor;
    });
  }

  ThemeData _applyFont(ThemeData theme) {
    if (_fontFamily == 'custom') {
      return theme.copyWith(
          textTheme: GoogleFonts.poppinsTextTheme(theme.textTheme));
    }
    return theme;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: _applyFont(AppThemes.getLightTheme(_seedColor)),
      darkTheme: _applyFont(AppThemes.getDarkTheme(_themeType, _seedColor)),
      home: CuteTaskHome(
        themeType: _themeType,
        fontFamily: _fontFamily,
        colorType: _colorType,
        onThemeChanged: _changeTheme,
        onFontChanged: _changeFont,
        onColorChanged: _changeColor,
      ),
    );
  }
}
