import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/prefs_service.dart';
import 'services/supabase_service.dart';
import 'pages/splash_page.dart';
import 'pages/demo_page.dart';
import 'pages/policy_viewer_page.dart';
import 'pages/reminder_page.dart';
import 'pages/home_page.dart';
//comentario
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Inicializa Supabase
  await SupabaseService.initialize();

  final prefs = await PrefsService.getInstance();
  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  final PrefsService? prefs;

  const MyApp({super.key, this.prefs});

  @override
  Widget build(BuildContext context) {
    // If prefs is not provided (e.g. tests using `const MyApp()`), fall back
    // to a minimal counter app to preserve the original widget_test behavior.
    if (prefs == null) return const MaterialApp(home: CounterHome());

    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF06B6D4), // Cyan 500 from PRD
    );

    return Provider<PrefsService>.value(
      value: prefs!,
      child: MaterialApp(
        title: 'ZenBreak',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: colorScheme,
          textTheme: Typography.material2021().black.apply(
                bodyColor: const Color(0xFF0F172A),
              ),
        ),
        initialRoute: '/',
        routes: {
          '/': (_) => SplashPage(),
          '/demo': (_) => const DemoPage(),
          '/policy-viewer': (_) => const PolicyViewerPage(),
          '/reminder': (_) => const ReminderPage(),
          '/home': (_) => const HomePage(),
        },
      ),
    );
  }
}

class CounterHome extends StatefulWidget {
  const CounterHome({super.key});

  @override
  State<CounterHome> createState() => _CounterHomeState();
}

class _CounterHomeState extends State<CounterHome> {
  int _counter = 0;

  void _incrementCounter() => setState(() => _counter++);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Flutter Demo Home Page')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text('You have pushed the button this many times:'),
              Text('$_counter', style: Theme.of(context).textTheme.headlineMedium),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _incrementCounter,
          tooltip: 'Increment',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

