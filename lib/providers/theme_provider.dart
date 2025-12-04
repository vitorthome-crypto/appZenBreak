import 'package:flutter/material.dart';
import '../services/prefs_service.dart';

/// ThemeController gerencia o modo de tema do app e persiste a escolha.
class ThemeController extends ChangeNotifier {
  final PrefsService _prefs;
  bool _isDark;

  ThemeController(this._prefs) : _isDark = _prefs.darkTheme;

  /// Retorna true se o tema atual for escuro.
  bool get isDark => _isDark;

  /// Retorna o ThemeMode correspondente ao estado interno.
  ThemeMode get themeMode => _isDark ? ThemeMode.dark : ThemeMode.light;

  /// Define se o tema é escuro. Persiste e notifica ouvintes.
  set isDark(bool v) {
    if (_isDark == v) return;
    _isDark = v;
    _prefs.setDarkTheme(v);
    notifyListeners();
  }

  /// Define explicitamente um ThemeMode (aceita apenas light/dark).
  void setMode(ThemeMode mode) {
    if (mode == ThemeMode.system) return; // não suportamos system aqui
    isDark = mode == ThemeMode.dark;
  }

  /// Alterna o tema entre light/dark.
  void toggle() => isDark = !_isDark;
}
