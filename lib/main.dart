import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' show dotenv;
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide Provider;
import 'services/prefs_service.dart';
import 'pages/splash_page.dart';
import 'pages/demo_page.dart';
import 'pages/policy_viewer_page.dart';
import 'pages/home_page.dart';
import 'features/historico/presentation/controllers/historico_controller.dart';
import 'features/historico/data/datasources/historico_remote_data_source_impl.dart';
import 'features/historico/data/repositories/historico_repository_impl.dart';
import 'pages/meditation_history_demo_page.dart';
import 'pages/historico_page.dart';
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
    // If prefs is not provided (e.g. tests), return a minimal home
    if (prefs == null) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(child: Text('App initialization failed')),
        ),
      );
    }

    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF06B6D4), // Cyan 500 from PRD
    );

    return MultiProvider(
      providers: [
        Provider<PrefsService>.value(value: prefs!),
        ChangeNotifierProvider<HistoricoController>(
          create: (_) {
            final client = Supabase.instance.client;
            final remoteDataSource =
                HistoricoRemoteDataSourceImpl(client: client);
            final repository =
                HistoricoRepositoryImpl(remoteDataSource: remoteDataSource);
            return HistoricoController(repository: repository);
          },
        ),
      ],
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
          '/demo': (_) => const DemoPage(),
          '/policy-viewer': (_) => const PolicyViewerPage(),
          '/home': (_) => const HomePage(),
          '/historico': (_) => const HistoricoPage(),
          '/meditation-history-demo': (_) => const MeditationHistoryDemoPage(),
        },
      ),
    );
  }
}

