import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../config/supabase_config.dart';

/// SupabaseService centraliza a inicialização e o acesso ao client Supabase.
class SupabaseService {
  /// Inicializa dotenv (se necessário) e o Supabase client.
  /// Deve ser chamado antes de usar o client.
  static Future<void> initialize() async {
    // Carrega o arquivo .env se ainda não foi carregado
    if (!dotenv.isInitialized) {
      await dotenv.load();
    }

    final url = getSupabaseUrl();
    final anonKey = getSupabaseAnonKey();

    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
      // opcional: especificar debugMode em debug
    );
  }

  /// Retorna o cliente Supabase já inicializado.
  static SupabaseClient get client => Supabase.instance.client;
}
