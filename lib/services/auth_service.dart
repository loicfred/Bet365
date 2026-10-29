import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final _supabase = Supabase.instance.client;

  Future<AuthResponse> signIn(String email, String password) async => await _supabase.auth.signInWithPassword(email: email, password: password);
  Future<AuthResponse> signUp(String email, String password) async => await _supabase.auth.signUp(email: email, password: password);
  Future signOut() async => await _supabase.auth.signOut();
  String? currentEmail() => _supabase.auth.currentSession?.user.email;
}

