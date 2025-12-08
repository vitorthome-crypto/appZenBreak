import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' show dotenv;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide Provider;
import 'services/prefs_service.dart';
import 'pages/splash_page.dart';
import 'pages/onboarding_page.dart';
import 'pages/demo_page.dart';
import 'pages/policy_viewer_page.dart';
import 'pages/home_page.dart';
import 'features/historico/presentation/controllers/historico_controller.dart';
import 'providers/theme_provider.dart';
import 'theme/color_schemes.dart';
import 'features/daily_goals/presentation/controllers/daily_goal_controller.dart';
import 'features/daily_goals/data/datasources/daily_goal_local_data_source.dart';
import 'features/daily_goals/data/repositories/daily_goal_repository_impl.dart';
import 'features/daily_goals/presentation/pages/metas_page.dart';
import 'pages/meditation_history_demo_page.dart';
import 'pages/historico_page.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint('[MAIN] Warning: Could not load .env file - $e');
  }

  final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? 'https://your-project.supabase.co';
  final supabseKey = dotenv.env['SUPABASE_ANON_KEY'] ?? 'your-anon-key-here';

  try {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabseKey,
    );
  } catch (e) {
    debugPrint('[MAIN] Warning: Could not initialize Supabase - $e');
  }

  final prefs = await PrefsService.getInstance();
  debugPrint('[MAIN] PrefsService inicializado com sucesso');

  // Inicializar SharedPreferences e DailyGoalController para prover como ChangeNotifier
  final sharedPrefs = await SharedPreferences.getInstance();
  final localDataSource = DailyGoalLocalDataSourceImpl(prefs: sharedPrefs);
  final dailyGoalRepository = DailyGoalRepositoryImpl(localDataSource: localDataSource);
  final dailyGoalController = DailyGoalController(repository: dailyGoalRepository);

  runApp(MyApp(prefs: prefs, dailyGoalController: dailyGoalController));
}

class MyApp extends StatelessWidget {
  final PrefsService? prefs;
  final DailyGoalController? dailyGoalController;

  const MyApp({super.key, this.prefs, this.dailyGoalController});

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

    // Using ColorScheme.fromSeed via `theme/color_schemes.dart`

    // Custom scroll behavior to allow mouse drag on web/desktop
    // so `RefreshIndicator` responds to mouse pull gestures.
    return MultiProvider(
      providers: [
        Provider<PrefsService>.value(value: prefs!),
        ChangeNotifierProvider<ThemeController>(
          create: (context) => ThemeController(Provider.of<PrefsService>(context, listen: false)),
        ),
        ChangeNotifierProvider<HistoricoController>(
          create: (_) => HistoricoController(),
        ),
        // Fornecer o DailyGoalController já instanciado para que as telas
        // escutem `notifyListeners()` e atualizem imediatamente.
        ChangeNotifierProvider<DailyGoalController>.value(
          value: dailyGoalController!,
        ),
      ],
      child: Consumer<ThemeController>(
        builder: (context, themeProvider, _) => MaterialApp(
          scrollBehavior: DesktopScrollBehavior(),
          title: 'ZenBreak',
          debugShowCheckedModeBanner: false,
          theme: appLightTheme,
          darkTheme: appDarkTheme,
          themeMode: themeProvider.themeMode,
          initialRoute: '/',
          routes: {
            '/': (_) => const SplashPage(),
            '/onboarding': (_) => const OnboardingPage(),
            '/demo': (_) => const DemoPage(),
            '/policy-viewer': (_) => const PolicyViewerPage(),
            '/home': (_) => const HomePage(),
                       '/metas': (_) => const MetasPage(),
            '/historico': (_) => const HistoricoPage(),
            '/meditation-history-demo': (_) => const MeditationHistoryDemoPage(),
          },
        ),
      ),
    );
  }
}

/// ScrollBehavior que habilita arrastar com mouse e touch;
/// necessário para que `RefreshIndicator` funcione com mouse no web/desktop.
class DesktopScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
        PointerDeviceKind.unknown,
      };
}

