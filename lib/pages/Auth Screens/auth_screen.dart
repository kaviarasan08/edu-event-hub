import 'package:eduevent_hub/pages/Auth%20Screens/loginorsignup.dart';
import 'package:eduevent_hub/pages/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../Provider/auth_provider.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {


@override
  Widget build(BuildContext context) {
    // final session = _supabase.auth.currentSession;
    final session = ref.watch(sessionProvider);
    if (session != null) {
      return MainScreen();
    } else {
      return LoginOrSignup();
    }
  }
}
