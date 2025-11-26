import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../services/auth_service.dart';

/// Model do usuário autenticado.
class UsuarioAutenticado {
  final String id;
  final String email;
  final String? nome;

  UsuarioAutenticado({
    required this.id,
    required this.email,
    this.nome,
  });

  factory UsuarioAutenticado.fromUser(User user) {
    return UsuarioAutenticado(
      id: user.id,
      email: user.email ?? '',
      nome: user.userMetadata?['nome'] as String?,
    );
  }
}

/// Controller que gerencia o estado de autenticação usando Provider.
class AuthController extends ChangeNotifier {
  final AuthService authService;

  UsuarioAutenticado? _usuario;
  bool _carregando = false;
  String? _erro;
  bool _obscurePassword = true;

  AuthController({required this.authService}) {
    _inicializarAutenticacao();
  }

  // Getters
  UsuarioAutenticado? get usuario => _usuario;
  bool get carregando => _carregando;
  String? get erro => _erro;
  bool get isAutenticado => _usuario != null;
  bool get obscurePassword => _obscurePassword;

  /// Inicializa a autenticação verificando se há usuário logado.
  void _inicializarAutenticacao() {
    if (authService.currentUser != null) {
      _usuario = UsuarioAutenticado.fromUser(authService.currentUser!);
      debugPrint('[AuthController] Usuário autenticado: ${_usuario?.email}');
    }
  }

  /// Fazer login com email e senha.
  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      _carregando = true;
      _erro = null;
      notifyListeners();

      final user = await authService.login(
        email: email,
        password: password,
      );

      _usuario = UsuarioAutenticado.fromUser(user);
      debugPrint('[AuthController] Login bem-sucedido: ${_usuario?.email}');
    } catch (e) {
      _erro = e.toString();
      debugPrint('[AuthController] Erro ao fazer login: $_erro');
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  /// Registrar novo usuário.
  Future<void> registrar({
    required String email,
    required String senha,
    required String nome,
  }) async {
    try {
      _carregando = true;
      _erro = null;
      notifyListeners();

      final user = await authService.registrar(
        email: email,
        password: senha,
        nome: nome,
      );

      _usuario = UsuarioAutenticado.fromUser(user);
      debugPrint('[AuthController] Registro bem-sucedido: ${_usuario?.email}');
    } catch (e) {
      _erro = e.toString();
      debugPrint('[AuthController] Erro ao registrar: $_erro');
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  /// Fazer logout.
  Future<void> logout() async {
    try {
      _carregando = true;
      await authService.logout();
      _usuario = null;
      _erro = null;
      debugPrint('[AuthController] Logout bem-sucedido');
    } catch (e) {
      _erro = e.toString();
      debugPrint('[AuthController] Erro ao fazer logout: $_erro');
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  /// Alternar visibilidade de senha.
  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  /// Limpar mensagem de erro.
  void limparErro() {
    _erro = null;
    notifyListeners();
  }

  /// Resetar senha.
  Future<void> resetarSenha(String email) async {
    try {
      _carregando = true;
      _erro = null;
      notifyListeners();

      await authService.resetarSenha(email);
      _erro = 'Email de recuperação enviado. Verifique sua caixa de entrada.';
      debugPrint('[AuthController] Email de recuperação enviado');
    } catch (e) {
      _erro = e.toString();
      debugPrint('[AuthController] Erro ao resetar senha: $_erro');
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }
}
