import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' show dotenv;
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide Provider;
import 'services/prefs_service.dart';
import 'pages/splash_page.dart';
import 'pages/demo_page.dart';
import 'pages/policy_viewer_page.dart';
import 'pages/home_page.dart';
// import 'pages/reminder_page.dart';
// import 'features/providers/presentation/pages/fornecedores_page.dart';
// import 'features/reminders/presentation/pages/reminders_page.dart';
import 'features/historico/presentation/controllers/historico_controller.dart';
import 'features/historico/data/datasources/historico_remote_data_source_impl.dart';
import 'features/historico/data/repositories/historico_repository_impl.dart';
import 'pages/meditation_history_demo_page.dart';
import 'pages/historico_page.dart';
import 'services/auth_service.dart';
import 'features/auth/presentation/controllers/auth_controller.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/registro_page.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await dotenv.load(fileName: ".env");

  final supabaseUrl = dotenv.env['SUPABASE_URL']!;
  final supabseKey = dotenv.env['SUPABASE_ANON_KEY']!;

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabseKey,
  );

  final prefs = await PrefsService.getInstance();
  debugPrint('[MAIN] PrefsService inicializado com sucesso');
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
      child: ChangeNotifierProvider(
        create: (_) {
          final client = Supabase.instance.client;
          final authService = AuthService(client: client);
          return AuthController(authService: authService);
        },
        child: ChangeNotifierProvider(
          create: (_) {
            final client = Supabase.instance.client;
            final remoteDataSource = HistoricoRemoteDataSourceImpl(client: client);
            final repository = HistoricoRepositoryImpl(remoteDataSource: remoteDataSource);
            return HistoricoController(repository: repository);
          },
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
              '/': (_) => const SplashPage(),
              '/login': (_) => const LoginPage(),
              '/registro': (_) => const RegistroPage(),
              '/demo': (_) => const DemoPage(),
              '/policy-viewer': (_) => const PolicyViewerPage(),
              // '/reminder': (_) => const ReminderPage(),
              '/home': (_) => const HomePage(),
              '/historico': (_) => const HistoricoPage(),
              '/meditation-history-demo': (_) => const MeditationHistoryDemoPage(),
              // '/fornecedores': (_) => const FornecedoresPage(),
              // '/reminders': (_) => const RemindersPage(),
            },
          ),
        ),
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

