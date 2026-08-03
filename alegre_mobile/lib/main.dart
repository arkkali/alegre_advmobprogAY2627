import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  // Wrap the app with a provider so the theme state can be shared globally.
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeController(),
      child: const MyApp(),
    ),
  );
}

// Manages the app-wide theme state.
// Keeps the app-wide theme state and notifies widgets when it changes.
class ThemeController extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  void toggleTheme(bool value) {
    _isDarkMode = value;
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Read the shared theme value so the whole app can switch between light and dark UI.
    final themeController = context.watch<ThemeController>();

    return MaterialApp(
      title: 'Counter App',
      themeMode: themeController.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: const CounterPage(),
    );
  }
}

// Handles the local counter state for this page.
class CounterPage extends StatefulWidget {
  const CounterPage({super.key});

  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  // This is the local state for the counter on this page.
  int _counter = 0;

  // Increases the counter value and rebuilds the page UI.
  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Counter App')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Counter'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ThemeSettingsPage()),
                );
              },
              icon: const Icon(Icons.color_lens),
              label: const Text('Theme Settings'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        // Calls the counter function when the button is pressed.
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        backgroundColor: Colors.pink[300],
        child: const Icon(Icons.add),
      ),
    );
  }
}

class ThemeSettingsPage extends StatelessWidget {
  const ThemeSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Theme Settings')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              themeController.isDarkMode ? 'Dark Mode Enabled' : 'Light Mode Enabled',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(themeController.isDarkMode ? 'Light Mode' : 'Dark Mode'),
                const SizedBox(width: 12),
                Switch(
                  value: themeController.isDarkMode,
                  onChanged: themeController.toggleTheme,
                  activeThumbColor: Colors.pink[300],
                  activeTrackColor: Colors.pink[100],
                  inactiveThumbColor: Colors.grey[400],
                  inactiveTrackColor: Colors.grey[300],
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back'),
            ),
          ],
        ),
      ),
    );
  }
}
