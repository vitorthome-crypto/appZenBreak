import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../config/supabase_config.dart';

/// SupabaseService centraliza a inicialização e o acesso ao client Supabase.
class SupabaseService {
  /// Inicializa dotenv (se necessário em mobile/desktop) e o Supabase client.
  /// Deve ser chamado antes de usar o client.
  static Future<void> initialize() async {
    // Em web, não tentar carregar .env (restrição de segurança)
    // Em mobile/desktop, carregar do arquivo
    if (!kIsWeb && !dotenv.isInitialized) {
      try {
        await dotenv.load();
      } catch (e) {
        if (kDebugMode) {
          print('Aviso: Não foi possível carregar .env: $e');
        }
      }
    }

    try {
      final url = getSupabaseUrl();
      final anonKey = getSupabaseAnonKey();

      await Supabase.initialize(
        url: url,
        anonKey: anonKey,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao inicializar Supabase: $e');
      }
      rethrow;
    }
  }

  /// Retorna o cliente Supabase já inicializado.
  static SupabaseClient get client => Supabase.instance.client;
}
