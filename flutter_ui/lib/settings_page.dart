import 'package:flutter/material.dart';
import 'dart:html' as html;

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _enableNotifications = true;
  String _apiKey = '';
  double _refreshInterval = 5.0;
  
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }
  
  void _loadSettings() {
    // Request settings from Obsidian plugin
    html.window.parent?.postMessage({
      'type': 'flutter-request-settings',
    }, '*');
    
    // Listen for settings response
    html.window.onMessage.listen((event) {
      final data = event.data;
      if (data is Map && data['type'] == 'obsidian-settings') {
        setState(() {
          _enableNotifications = data['enableNotifications'] ?? true;
          _apiKey = data['apiKey'] ?? '';
          _refreshInterval = (data['refreshInterval'] ?? 5.0).toDouble();
        });
      }
    });
  }
  
  void _saveSettings() {
    html.window.parent?.postMessage({
      'type': 'flutter-save-settings',
      'settings': {
        'enableNotifications': _enableNotifications,
        'apiKey': _apiKey,
        'refreshInterval': _refreshInterval,
      }
    }, '*');
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings saved!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          SwitchListTile(
            title: const Text('Enable Notifications'),
            subtitle: const Text('Show notifications for plugin events'),
            value: _enableNotifications,
            onChanged: (bool value) {
              setState(() {
                _enableNotifications = value;
              });
            },
          ),
          const Divider(),
          TextField(
            decoration: const InputDecoration(
              labelText: 'API Key',
              hintText: 'Enter your API key',
              border: OutlineInputBorder(),
            ),
            obscureText: true,
            value: _apiKey,
            onChanged: (value) {
              setState(() {
                _apiKey = value;
              });
            },
          ),
          const SizedBox(height: 24),
          Text('Refresh Interval: ${_refreshInterval.toInt()} seconds'),
          Slider(
            value: _refreshInterval,
            min: 1.0,
            max: 60.0,
            divisions: 59,
            label: '${_refreshInterval.toInt()}s',
            onChanged: (double value) {
              setState(() {
                _refreshInterval = value;
              });
            },
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _saveSettings,
            child: const Text('Save Settings'),
          ),
        ],
      ),
    );
  }
}
