import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:lokalny_koszyk/core/supabase/profile_bootstrap.dart';
import 'package:lokalny_koszyk/core/supabase/supabase_client.dart';
import 'package:lokalny_koszyk/screens/auth/auth_screen.dart';
import 'package:lokalny_koszyk/screens/auth/reset_password_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({
    super.key,
    required this.signedInChild,
  });

  final Widget signedInChild;

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  User? _user;
  bool _passwordRecovery = false;
  late final StreamSubscription<AuthState> _sub;

  @override
  void initState() {
    super.initState();
    _user = supabase.auth.currentUser;
    _scheduleProfileBootstrap(_user);
    _sub = supabase.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      final session = data.session;

      if (event == AuthChangeEvent.passwordRecovery) {
        setState(() {
          _user = session?.user;
          _passwordRecovery = true;
        });
        return;
      }

      if (event == AuthChangeEvent.signedIn ||
          event == AuthChangeEvent.tokenRefreshed ||
          event == AuthChangeEvent.userUpdated) {
        setState(() => _user = session?.user);
        if (event == AuthChangeEvent.signedIn ||
            event == AuthChangeEvent.userUpdated) {
          _scheduleProfileBootstrap(session?.user);
        }
      }

      if (event == AuthChangeEvent.signedOut) {
        setState(() {
          _user = null;
          _passwordRecovery = false;
        });
      }
    });
  }

  void _scheduleProfileBootstrap(User? user) {
    if (user == null) return;
    unawaited(ProfileBootstrap.ensureRowForAuthUser(user));
  }

  void _onPasswordResetCompleted() {
    setState(() => _passwordRecovery = false);
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_passwordRecovery && _user != null) {
      return ResetPasswordScreen(onCompleted: _onPasswordResetCompleted);
    }
    final user = _user;
    if (user == null) return const AuthScreen();
    return widget.signedInChild;
  }
}
