import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Create a provider for Supabase client
final supabaseProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

// Create a StreamProvider for auth state changes
final authStateProvider = StreamProvider<AuthState>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return supabase.auth.onAuthStateChange;
});

// Optionally, create a provider to get the current session directly
final sessionProvider = Provider<Session?>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return supabase.auth.currentSession;
});
