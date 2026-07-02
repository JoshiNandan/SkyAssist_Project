// lib/main.dart
import 'package:flutter/material.dart';
import "package:provider/provider.dart";

import 'constants/app_colors.dart';
import 'constants/app_strings.dart';
import 'providers/recovery_provider.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const SkyAssistApp());
}

class SkyAssistApp extends StatelessWidget {
  const SkyAssistApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RecoveryProvider()..loadRecentSearches(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: AppStrings.appTitle,
        home: const SplashScreen(),
        // Simple background colour – no ThemeData wrapper
        builder: (context, child) =>
            Container(color: AppColors.background, child: child),
      ),
    );
  }
}
