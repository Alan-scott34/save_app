import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import "splash_screen.dart";
import "login_screen.dart";
import "register_screen.dart";
import "forgot_password_screen.dart";
import "dashboard_screen.dart";
import "income_list_screen.dart";
import "income_form_screen.dart";
import "expense_list_screen.dart";
import "expense_form_screen.dart";
import "goals_list_screen.dart";
import "goal_form_screen.dart";
import "goal_detail_screen.dart";
import "savings_tracker_screen.dart";
import "reports_screen.dart";
import "profile_screen.dart";
import "settings_screen.dart";
import "voice_recording_screen.dart";
import "image_capture_screen.dart";

/// ============================================
/// APP ROUTER — Configuration de navigation
/// ============================================
/// Ce fichier définit TOUTE la navigation de l'app
/// en utilisant GoRouter.
///
/// 💡 Pourquoi GoRouter au lieu de Navigator ?
/// → Navigation déclarative (pas impérative)
/// → Support des deep links
/// → Gestion facile des routes imbriquées
/// → Meilleur support du web
/// → Transitions personnalisées
///
/// 🗺️ Structure de navigation :
///
///   /splash          → Splash Screen
///   /login           → Écran de connexion
///   /register        → Écran d'inscription
///   /forgot-password → Mot de passe oublié
///   /                → Dashboard (avec Bottom Nav)
///     ├── /income          → Liste des revenus
///     ├── /income/add      → Ajouter un revenu
///     ├── /income/edit/:id  → Modifier un revenu
///     ├── /expense         → Liste des dépenses
///     ├── /expense/add     → Ajouter une dépense
///     ├── /expense/edit/:id → Modifier une dépense
///     ├── /goals           → Liste des objectifs
///     ├── /goals/add       → Ajouter un objectif
///     ├── /goals/:id       → Détail d'un objectif
///     ├── /savings         → Suivi d'épargne
///     ├── /reports         → Rapports
///     ├── /profile         → Profil utilisateur
///     ├── /settings        → Paramètres
///     ├── /voice-recording → Enregistrement vocal
///     └── /image-capture   → Capture d'image
/// ============================================

// --- Clé de navigation globale ---
final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

// --- GoRouter instance ---
final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash',
  debugLogDiagnostics: true,

  // --- Définition de toutes les routes ---
  routes: [
    // ============ AUTH FLOW ============
    GoRoute(
      path: '/splash',
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      name: 'register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      name: 'forgotPassword',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),

    // ============ MAIN APP (Shell avec Bottom Nav) ============
    ShellRoute(
      builder: (context, state, child) {
        // Le ShellRoute garde le Bottom Nav visible
        // sur tous les écrans principaux
        return MainShell(child: child);
      },
      routes: [
        GoRoute(
          path: '/',
          name: 'dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/income',
          name: 'incomeList',
          builder: (context, state) => const IncomeListScreen(),
        ),
        GoRoute(
          path: '/expense',
          name: 'expenseList',
          builder: (context, state) => const ExpenseListScreen(),
        ),
        GoRoute(
          path: '/goals',
          name: 'goalsList',
          builder: (context, state) => const GoalsListScreen(),
        ),
        GoRoute(
          path: '/profile',
          name: 'profile',
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    ),

    // ============ ÉCRANS SANS BOTTOM NAV ============
    GoRoute(
      path: '/income/add',
      name: 'incomeAdd',
      builder: (context, state) => const IncomeFormScreen(),
    ),
    GoRoute(
      path: '/income/edit/:id',
      name: 'incomeEdit',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return IncomeFormScreen(incomeId: id);
      },
    ),
    GoRoute(
      path: '/expense/add',
      name: 'expenseAdd',
      builder: (context, state) => const ExpenseFormScreen(),
    ),
    GoRoute(
      path: '/expense/edit/:id',
      name: 'expenseEdit',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return ExpenseFormScreen(expenseId: id);
      },
    ),
    GoRoute(
      path: '/goals/add',
      name: 'goalAdd',
      builder: (context, state) => const GoalFormScreen(),
    ),
    GoRoute(
      path: '/goals/edit/:id',
      name: 'goalEdit',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return GoalFormScreen(goalId: id);
      },
    ),
    GoRoute(
      path: '/goals/:id',
      name: 'goalDetail',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return GoalDetailScreen(goalId: id);
      },
    ),
    GoRoute(
      path: '/savings',
      name: 'savingsTracker',
      builder: (context, state) => const SavingsTrackerScreen(),
    ),
    GoRoute(
      path: '/reports',
      name: 'reports',
      builder: (context, state) => const ReportsScreen(),
    ),
    GoRoute(
      path: '/settings',
      name: 'settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/voice-recording',
      name: 'voiceRecording',
      builder: (context, state) => const VoiceRecordingScreen(),
    ),
    GoRoute(
      path: '/image-capture',
      name: 'imageCapture',
      builder: (context, state) => const ImageCaptureScreen(),
    ),
  ],

  // --- Redirection si route inconnue ---
  errorBuilder: (context, state) => const NotFoundScreen(),
);

/// ============================================
/// MAIN SHELL — Conteneur avec Bottom Navigation
/// ============================================
/// Ce widget affiche :
/// - Le Bottom Navigation Bar (toujours visible)
/// - L'écran courant (child) dans le corps
///
/// 💡 Pourquoi un ShellRoute ?
/// → Le Bottom Nav reste visible sur les 5 écrans principaux
/// → Les écrans secondaires (ajout, détail, etc.) s'ouvrent
///   par-dessus SANS le Bottom Nav
/// ============================================

class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.child});

  final Widget child;

  // --- Index de l'onglet sélectionné ---
  int _getCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/income')) return 1;
    if (location.startsWith('/expense')) return 2;
    if (location.startsWith('/goals')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0; // Dashboard par défaut
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _getCurrentIndex(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.dashboard_rounded,
                  label: 'Home',
                  isSelected: currentIndex == 0,
                  onTap: () => context.go('/'),
                ),
                _NavItem(
                  icon: Icons.trending_up_rounded,
                  label: 'Income',
                  isSelected: currentIndex == 1,
                  onTap: () => context.go('/income'),
                ),
                _NavItem(
                  icon: Icons.trending_down_rounded,
                  label: 'Expenses',
                  isSelected: currentIndex == 2,
                  onTap: () => context.go('/expense'),
                ),
                _NavItem(
                  icon: Icons.track_changes_rounded,
                  label: 'Goals',
                  isSelected: currentIndex == 3,
                  onTap: () => context.go('/goals'),
                ),
                _NavItem(
                  icon: Icons.person_rounded,
                  label: 'Profile',
                  isSelected: currentIndex == 4,
                  onTap: () => context.go('/profile'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// ============================================
/// NAV ITEM — Élément de la Bottom Navigation
/// ============================================
/// Widget personnalisé pour chaque onglet.
/// Design moderne avec indicateur actif animé.
/// ============================================

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 16.0 : 12.0,
          vertical: 8.0,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? Color(0xFF10B981).withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? const Color(0xFF10B981)
                  : const Color(0xFF94A3B8),
              size: 22,
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF10B981),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// ============================================
/// 404 SCREEN — Route inconnue
/// ============================================

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off_rounded,
              size: 80,
              color: Color(0xFF94A3B8),
            ),
            const SizedBox(height: 16),
            const Text(
              '404',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Page not found',
              style: TextStyle(fontSize: 16, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    );
  }
}
