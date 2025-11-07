import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:js' as js;

void main() {
  runApp(const ObsidianFlutterUI());
}

class ObsidianFlutterUI extends StatelessWidget {
  const ObsidianFlutterUI({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Obsidian Flutter Plugin',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
      ),
      home: const PluginHomePage(),
    );
  }
}

class PluginHomePage extends StatefulWidget {
  const PluginHomePage({super.key});

  @override
  State<PluginHomePage> createState() => _PluginHomePageState();
}

class _PluginHomePageState extends State<PluginHomePage> {
  String _message = 'Waiting for Obsidian...';
  final TextEditingController _textController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _setupMessageListener();
    _sendReadyMessage();
  }
  
  void _setupMessageListener() {
    html.window.onMessage.listen((event) {
      final data = event.data;
      if (data is Map) {
        final type = data['type'];
        if (type == 'obsidian-to-flutter') {
          setState(() {
            _message = data['message'] ?? 'No message';
          });
        }
      }
    });
  }
  
  void _sendReadyMessage() {
    html.window.parent?.postMessage({
      'type': 'flutter-ready',
      'message': 'Flutter UI loaded successfully'
    }, '*');
  }
  
  void _sendMessageToObsidian(String message) {
    html.window.parent?.postMessage({
      'type': 'flutter-to-obsidian',
      'message': message,
      'timestamp': DateTime.now().millisecondsSinceEpoch
    }, '*');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Obsidian Flutter Plugin UI'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Message from Obsidian:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _message,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _textController,
              decoration: const InputDecoration(
                labelText: 'Send message to Obsidian',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_textController.text.isNotEmpty) {
                  _sendMessageToObsidian(_textController.text);
                  _textController.clear();
                }
              },
              child: const Text('Send to Obsidian'),
            ),
          ],
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
