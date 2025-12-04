import 'package:flutter/material.dart';

// ----------------------------
// Color schemes do app
// ----------------------------

// 1) Temas gerados automaticamente a partir de uma seed color
// (Material 3 dynamic color — recomendado para harmonia automática)
const _seedColor = Color(0xFF06B6D4); // Cyan usado como semente

final ThemeData appLightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(seedColor: _seedColor, brightness: Brightness.light),
);

final ThemeData appDarkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(seedColor: _seedColor, brightness: Brightness.dark),
);

// 2) Exemplo de ColorScheme totalmente manual
// Use isto quando você tiver uma paleta fixa do designer
// As cores abaixo são um exemplo; substitua pelos valores da sua paleta.

// Light manual
const ColorScheme _manualLightScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFF006B6B),
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFF99F0F0),
  onPrimaryContainer: Color(0xFF002020),
  secondary: Color(0xFF006B8A),
  onSecondary: Color(0xFFFFFFFF),
  secondaryContainer: Color(0xFFBEEBFF),
  onSecondaryContainer: Color(0xFF001E27),
  tertiary: Color(0xFF7B3FE4),
  onTertiary: Color(0xFFFFFFFF),
  tertiaryContainer: Color(0xFFEBDCFF),
  onTertiaryContainer: Color(0xFF23003A),
  error: Color(0xFFB00020),
  onError: Color(0xFFFFFFFF),
  errorContainer: Color(0xFFFFDAD6),
  onErrorContainer: Color(0xFF410002),
  background: Color(0xFFF7FEFF),
  onBackground: Color(0xFF001F24),
  surface: Color(0xFFFFFFFF),
  onSurface: Color(0xFF001F24),
  surfaceVariant: Color(0xFFE0F2F2),
  onSurfaceVariant: Color(0xFF244343),
  outline: Color(0xFF547272),
  shadow: Color(0xFF000000),
  inverseSurface: Color(0xFF00363A),
  onInverseSurface: Color(0xFFFFFFFF),
  inversePrimary: Color(0xFF4FD1D9),
  // scrim omitted, uses default
  surfaceTint: Color(0xFF006B6B),
);

// Dark manual
const ColorScheme _manualDarkScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xFF4FD1D9),
  onPrimary: Color(0xFF00363A),
  primaryContainer: Color(0xFF004F4F),
  onPrimaryContainer: Color(0xFF99F0F0),
  secondary: Color(0xFF5BD0FF),
  onSecondary: Color(0xFF002833),
  secondaryContainer: Color(0xFF004B57),
  onSecondaryContainer: Color(0xFFBEEBFF),
  tertiary: Color(0xFFD6B6FF),
  onTertiary: Color(0xFF3A0072),
  tertiaryContainer: Color(0xFF5C1AB2),
  onTertiaryContainer: Color(0xFFEBDCFF),
  error: Color(0xFFFFB4AB),
  onError: Color(0xFF690005),
  errorContainer: Color(0xFF93000A),
  onErrorContainer: Color(0xFFFFDAD6),
  background: Color(0xFF001F24),
  onBackground: Color(0xFFBEECEC),
  surface: Color(0xFF012024),
  onSurface: Color(0xFFBEECEC),
  surfaceVariant: Color(0xFF023233),
  onSurfaceVariant: Color(0xFF9AD3D3),
  outline: Color(0xFF4DA3A3),
  shadow: Color(0xFF000000),
  inverseSurface: Color(0xFFF7FEFF),
  onInverseSurface: Color(0xFF001F24),
  inversePrimary: Color(0xFF006B6B),
  surfaceTint: Color(0xFF4FD1D9),
);

final ThemeData appLightThemeManual = ThemeData(
  useMaterial3: true,
  colorScheme: _manualLightScheme,
);

final ThemeData appDarkThemeManual = ThemeData(
  useMaterial3: true,
  colorScheme: _manualDarkScheme,
);

// Nota: escolha entre usar appLightTheme/appDarkTheme (fromSeed)
// ou appLightThemeManual/appDarkThemeManual dependendo da necessidade.
