import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/app_router.dart';
import 'screens/app_theme.dart';
import 'screens/auth_service.dart';
import 'screens/transaction_service.dart';
import 'screens/goal_service.dart';
import 'screens/settings_service.dart';
import 'screens/achievement_service.dart';
import 'screens/chatbot_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()..loadFromStorage()),
        ChangeNotifierProvider(
          create: (_) => TransactionService()..initialize(),
        ),
        ChangeNotifierProvider(create: (_) => GoalService()..initialize()),
        ChangeNotifierProvider(create: (_) => SettingsService()..initialize()),
        ChangeNotifierProvider(
          create: (_) => AchievementService()..initialize(),
        ),
        ChangeNotifierProvider(create: (_) => ChatbotService()..initialize()),
      ],
      child: Consumer<SettingsService>(
        builder: (context, settingsService, child) {
          return MaterialApp.router(
            title: 'Save App',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settingsService.themeMode,
            routerConfig: appRouter,
          );
        },
      ),
    );
  }
}
