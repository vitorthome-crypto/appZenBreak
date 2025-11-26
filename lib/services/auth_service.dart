import 'package:supabase_flutter/supabase_flutter.dart';

/// Exceção customizada para erros de autenticação.
class AuthException implements Exception {
  final String mensagem;
  AuthException(this.mensagem);

  @override
  String toString() => mensagem;
}

/// Serviço de autenticação usando Supabase Auth.
class AuthService {
  final SupabaseClient client;

  AuthService({required this.client});

  /// Obter usuário atualmente autenticado.
  User? get currentUser => client.auth.currentUser;

  /// Obter sesão atual.
  Session? get currentSession => client.auth.currentSession;

  /// Fazer login com email e senha.
  Future<User> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      if (response.user == null) {
        throw AuthException('Falha ao fazer login. Tente novamente.');
      }

      return response.user!;
    } on AuthException catch (e) {
      throw AuthException('Erro de autenticação: ${e.mensagem}');
    } catch (e) {
      final msg = e.toString();
      
      // Tratamento de erros comuns
      if (msg.contains('Invalid login credentials')) {
        throw AuthException('Email ou senha incorretos.');
      } else if (msg.contains('Email not confirmed')) {
        throw AuthException('Email não confirmado. Verifique seu email.');
      } else if (msg.contains('User already registered')) {
        throw AuthException('Este email já está registrado.');
      } else {
        throw AuthException('Erro ao fazer login: $msg');
      }
    }
  }

  /// Registrar novo usuário com email e senha.
  Future<User> registrar({
    required String email,
    required String password,
    required String nome,
  }) async {
    try {
      // Validações básicas
      if (email.isEmpty || password.isEmpty || nome.isEmpty) {
        throw AuthException('Preencha todos os campos.');
      }

      if (password.length < 6) {
        throw AuthException('A senha deve ter pelo menos 6 caracteres.');
      }

      final response = await client.auth.signUp(
        email: email.trim(),
        password: password,
        data: {
          'nome': nome.trim(),
        },
      );

      if (response.user == null) {
        throw AuthException('Falha ao registrar. Tente novamente.');
      }

      return response.user!;
    } on AuthException catch (e) {
      throw AuthException(e.mensagem);
    } catch (e) {
      final msg = e.toString();

      if (msg.contains('already registered')) {
        throw AuthException('Este email já está registrado.');
      } else if (msg.contains('password is too short')) {
        throw AuthException('A senha deve ter pelo menos 6 caracteres.');
      } else if (msg.contains('invalid email')) {
        throw AuthException('Email inválido.');
      } else {
        throw AuthException('Erro ao registrar: $msg');
      }
    }
  }

  /// Fazer logout.
  Future<void> logout() async {
    try {
      await client.auth.signOut();
    } catch (e) {
      throw AuthException('Erro ao fazer logout: $e');
    }
  }

  /// Resetar senha enviando email de recuperação.
  Future<void> resetarSenha(String email) async {
    try {
      await client.auth.resetPasswordForEmail(
        email.trim(),
        redirectTo: 'io.supabase.flutter://reset-callback/',
      );
    } catch (e) {
      throw AuthException('Erro ao enviar email de recuperação: $e');
    }
  }

  /// Verificar se o usuário está autenticado.
  bool get isAutenticado => currentUser != null;

  /// Obter email do usuário atual.
  String? get userEmail => currentUser?.email;

  /// Obter ID do usuário atual.
  String? get userId => currentUser?.id;

  /// Atualizar perfil do usuário.
  Future<void> atualizarPerfil({
    String? nome,
    String? avatar,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (nome != null) updates['nome'] = nome;
      if (avatar != null) updates['avatar'] = avatar;

      if (updates.isEmpty) {
        throw AuthException('Nada para atualizar.');
      }

      await client.auth.updateUser(
        UserAttributes(data: updates),
      );
    } catch (e) {
      throw AuthException('Erro ao atualizar perfil: $e');
    }
  }
}
