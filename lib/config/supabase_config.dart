import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Hardcoded defaults (use for development/testing only).
/// In production, provide via .env (mobile/desktop) or environment variables (CI/deployment).
const String _FALLBACK_SUPABASE_URL = 'https://fedhjontnlwhfmdbbzfx.supabase.co';
const String _FALLBACK_SUPABASE_KEY = 'sb_publishable_YBcIMmIDWG79Y8G0yxVR2Q_Fq_LKV5c';

/// Supabase config getters. Load from:
/// 1. Environment variables (via dotenv on mobile/desktop)
/// 2. Fallback hardcoded values (for web/dev)
/// 3. Throw error if none available

String getSupabaseUrl({String? fallback}) {
  // Try from dotenv first (mobile/desktop)
  final fromEnv = dotenv.env['SUPABASE_URL'];
  if (fromEnv != null && fromEnv.isNotEmpty) return fromEnv;

  // Try provided fallback
  if (fallback != null && fallback.isNotEmpty) return fallback;

  // Use hardcoded default (OK for dev; consider env vars for production)
  if (_FALLBACK_SUPABASE_URL.isNotEmpty) return _FALLBACK_SUPABASE_URL;

  throw Exception('SUPABASE_URL is not configured.');
}

String getSupabaseAnonKey({String? fallback}) {
  // Try from dotenv first (mobile/desktop)
  final fromEnv = dotenv.env['SUPABASE_ANON_KEY'];
  if (fromEnv != null && fromEnv.isNotEmpty) return fromEnv;

  // Try provided fallback
  if (fallback != null && fallback.isNotEmpty) return fallback;

  // Use hardcoded default (OK for dev; consider env vars for production)
  if (_FALLBACK_SUPABASE_KEY.isNotEmpty) return _FALLBACK_SUPABASE_KEY;

  throw Exception('SUPABASE_ANON_KEY is not configured.');
}