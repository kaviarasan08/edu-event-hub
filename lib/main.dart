import 'package:eduevent_hub/pages/Auth%20Screens/auth_screen.dart';
import 'package:eduevent_hub/theme/theme_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://cjjituyyzsrueygtcwiu.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNqaml0dXl5enNydWV5Z3Rjd2l1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTUxMDI1OTAsImV4cCI6MjA3MDY3ODU5MH0.ifI3WIGYEX0T2MKUUDp92tcH6iTIaGpiKyIERedlCOo',
  );
  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      home: AuthScreen(),
    );
  }
}
