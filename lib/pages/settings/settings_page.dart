import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants.dart';

class SettingsPage extends StatelessWidget {
  final String themeType;
  final String fontFamily;
  final String colorType;
  final Function(String) onThemeChanged;
  final Function(String) onFontChanged;
  final Function(String) onColorChanged;

  const SettingsPage({
    super.key,
    required this.themeType,
    required this.fontFamily,
    required this.colorType,
    required this.onThemeChanged,
    required this.onFontChanged,
    required this.onColorChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Theme', style: TextStyle(fontWeight: FontWeight.bold)),
          ListTile(
            title: const Text('Light'),
            leading: Radio<String>(
              value: 'light',
              groupValue: themeType,
              onChanged: (value) => onThemeChanged(value!),
            ),
          ),
          ListTile(
            title: const Text('Dark'),
            leading: Radio<String>(
              value: 'dark',
              groupValue: themeType,
              onChanged: (value) => onThemeChanged(value!),
            ),
          ),
          ListTile(
            title: const Text('AMOLED'),
            leading: Radio<String>(
              value: 'amoled',
              groupValue: themeType,
              onChanged: (value) => onThemeChanged(value!),
            ),
          ),
          const Divider(),
          const Text('Colours', style: TextStyle(fontWeight: FontWeight.bold)),
          ...AppConstants.colorMap.keys.map((colorKey) => ListTile(
                title: Text(
                    '${colorKey[0].toUpperCase()}${colorKey.substring(1)}'),
                leading: Radio<String>(
                  value: colorKey,
                  groupValue: colorType,
                  onChanged: (value) => onColorChanged(value!),
                ),
              )),
          const Divider(),
          const Text('Fonts', style: TextStyle(fontWeight: FontWeight.bold)),
          ListTile(
            title: const Text('System'),
            leading: Radio<String>(
              value: 'system',
              groupValue: fontFamily,
              onChanged: (value) => onFontChanged(value!),
            ),
          ),
          ListTile(
            title: const Text('Custom (Poppins)'),
            leading: Radio<String>(
              value: 'custom',
              groupValue: fontFamily,
              onChanged: (value) => onFontChanged(value!),
            ),
          ),
          const Divider(),
          const Text('About', style: TextStyle(fontWeight: FontWeight.bold)),
          ListTile(
            title: TextButton(
              onPressed: () => launchUrl(Uri.parse(AppConstants.githubLink)),
              child: const Text(AppConstants.githubLink),
            ),
          ),
          const ListTile(
            title: Text('License: MIT'),
            subtitle: SizedBox(height: 32),
          ),
          const Center(child: Text('Made with ❤️ by CKYA')),
        ],
      ),
    );
  }
}
