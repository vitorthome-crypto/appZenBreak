import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Supabase config getters. Prefer loading values from environment (.env).
/// If a variable is not found in environment, an optional fallback can be
/// provided (not recommended for production).

String getSupabaseUrl({String? fallback}) {
	final fromEnv = dotenv.env['SUPABASE_URL'];
	if (fromEnv != null && fromEnv.isNotEmpty) return fromEnv;
	if (fallback != null) return fallback;
	if (kDebugMode) {
		// Helpful error in debug to indicate missing env
		throw Exception('SUPABASE_URL is not set in .env');
	}
	throw Exception('SUPABASE_URL is not configured.');
}

String getSupabaseAnonKey({String? fallback}) {
	final fromEnv = dotenv.env['SUPABASE_ANON_KEY'];
	if (fromEnv != null && fromEnv.isNotEmpty) return fromEnv;
	if (fallback != null) return fallback;
	if (kDebugMode) {
		throw Exception('SUPABASE_ANON_KEY is not set in .env');
	}
	throw Exception('SUPABASE_ANON_KEY is not configured.');
}
