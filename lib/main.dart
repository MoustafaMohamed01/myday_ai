import 'package:flutter/material.dart';
import 'package:myday_ai/app.dart';
import 'package:myday_ai/core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Isar database
  // Note: Isar initialization happens in App class
  
  runApp(
    ProviderScope(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const App(),
      ),
    ),
  );
}