import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/auth/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const url = String.fromEnvironment('SUPABASE_URL');
  if (url.isEmpty) throw StateError('Missing settings: run with --dart-define-from-file=env.json (see env.example.json)');
  await Supabase.initialize(url: url, anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(debugShowCheckedModeBanner: false, title: 'Bet365', home: LoginPage());
  }
}


