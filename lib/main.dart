import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/app_router.dart';
import 'screens/app_theme.dart';
import 'screens/auth_service.dart';
import 'screens/transaction_service.dart';
import 'screens/goal_service.dart';

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
        ChangeNotifierProvider(create: (_) => TransactionService()),
        ChangeNotifierProvider(create: (_) => GoalService()),
      ],
      child: MaterialApp.router(
        title: 'Save App',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: appRouter,
      ),
    );
  }
}
