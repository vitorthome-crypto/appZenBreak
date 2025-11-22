import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

/// SupabaseService centraliza a inicialização e o acesso ao client Supabase.
class SupabaseService {
  /// Inicializa o Supabase. Deve ser chamado antes de usar o client.
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: SUPABASE_URL,
      anonKey: SUPABASE_ANON_KEY,
    );
  }

  /// Retorna o cliente Supabase já inicializado.
  static SupabaseClient get client => Supabase.instance.client;
}
