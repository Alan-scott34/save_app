import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'auth_service.dart';
import "constants.dart";

/// ============================================
/// SPLASH SCREEN — Écran de démarrage
/// ============================================
/// C'est le PREMIER écran que l'utilisateur voit.
///
/// 🎯 Ce que fait cet écran :
/// 1. Affiche le logo et le nom de l'app
/// 2. Affiche une animation de chargement
/// 3. Vérifie si l'utilisateur est déjà connecté
/// 4. Redirige vers Login ou Dashboard
///
/// ⏱️ Durée : 3 secondes
///
/// 💡 Pourquoi un Splash Screen ?
/// → Première impression = professionnelle
/// → Temps pour initialiser les services (Firebase, etc.)
/// → Vérification de l'auth en arrière-plan
/// → Transition fluide vers l'app
///
/// 🎨 Design :
/// → Fond avec dégradé vert (couleur de l'argent)
/// → Icône PiggyBank de Lucide (symbole d'épargne)
/// → Animation de pulsation sur le logo
/// → Texte "Track. Save. Grow." en tagline
/// ============================================

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // --- Contrôleurs d'animation ---
  // 💡 Pourquoi TickerProviderStateMixin ?
  // → Nécessaire pour utiliser plusieurs AnimationController

  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _loadingController;

  // --- Animations ---
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _textOpacity;
  late Animation<double> _textSlide;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startSplashSequence();
  }

  /// Initialise toutes les animations
  void _initAnimations() {
    // --- Animation du logo : Scale + Fade In ---
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.elasticOut, // Effet rebond
      ),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    // --- Animation du texte : Fade In + Slide Up ---
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _textOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeIn));

    _textSlide = Tween<double>(
      begin: 30.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOut));

    // --- Animation du loading indicator ---
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(); // Répète en boucle
  }

  /// Séquence complète du splash
  Future<void> _startSplashSequence() async {
    // Étape 1 : Animer le logo
    _logoController.forward();

    // Étape 2 : Après 800ms, animer le texte
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) _textController.forward();

    // Étape 3 : Attendre la fin du splash
    await Future.delayed(AppConstants.splashDuration);

    // Étape 4 : Rediriger vers Login ou Dashboard
    if (mounted) {
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.loadFromStorage();

      if (authService.isLoggedIn) {
        context.go('/');
      } else {
        context.go('/login');
      }
    }
  }

  @override
  void dispose() {
    // ⚠️ TOUJOURS disposer les contrôleurs d'animation
    _logoController.dispose();
    _textController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Taille de l'écran pour le responsive
    final size = MediaQuery.of(context).size;

    return Scaffold(
      // --- Fond avec dégradé ---
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF10B981), // Vert principal
              Color(0xFF059669), // Vert foncé
              Color(0xFF047857), // Vert encore plus foncé
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // --- Éléments décoratifs en arrière-plan ---
            _buildBackgroundDecorations(size),

            // --- Contenu principal ---
            SafeArea(
              child: Column(
                children: [
                  const Spacer(flex: 3),

                  // --- Logo animé ---
                  _buildAnimatedLogo(),

                  const SizedBox(height: 24),

                  // --- Texte animé ---
                  _buildAnimatedText(),

                  const Spacer(flex: 3),

                  // --- Indicateur de chargement ---
                  _buildLoadingIndicator(),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ============================================
  /// WIDGET : Éléments décoratifs du fond
  /// ============================================
  /// 💡 Pourquoi des cercles semi-transparents ?
  /// → Ajoute de la profondeur visuelle
  /// → Design moderne (glassmorphism)
  /// → Sans ça, le fond serait trop "plat"
  /// ============================================

  Widget _buildBackgroundDecorations(Size size) {
    return Stack(
      children: [
        // Cercle en haut à droite
        Positioned(
          top: -size.height * 0.15,
          right: -size.width * 0.2,
          child: Container(
            width: size.width * 0.6,
            height: size.width * 0.6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.07),
            ),
          ),
        ),
        // Cercle en bas à gauche
        Positioned(
          bottom: -size.height * 0.1,
          left: -size.width * 0.15,
          child: Container(
            width: size.width * 0.5,
            height: size.width * 0.5,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.05),
            ),
          ),
        ),
        // Petit cercle au milieu
        Positioned(
          top: size.height * 0.35,
          left: size.width * 0.7,
          child: Container(
            width: size.width * 0.15,
            height: size.width * 0.15,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.04),
            ),
          ),
        ),
      ],
    );
  }

  /// ============================================
  /// WIDGET : Logo animé (icône + conteneur)
  /// ============================================
  /// 💡 Pourquoi AnimatedBuilder ?
  /// → Reconstruit SEULEMENT le widget du logo
  /// → Pas de rebuild de tout l'écran
  /// → Performance optimale
  /// ============================================

  Widget _buildAnimatedLogo() {
    return AnimatedBuilder(
      animation: _logoController,
      builder: (context, child) {
        return Opacity(
          opacity: _logoOpacity.value,
          child: Transform.scale(scale: _logoScale.value, child: child),
        );
      },
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: const Center(
          // Icône Lucide : PiggyBank = symbole de l'épargne
          child: Icon(
            LucideIcons.piggyBank,
            size: 56,
            color: Color(0xFF10B981),
          ),
        ),
      ),
    );
  }

  /// ============================================
  /// WIDGET : Texte animé (nom + tagline)
  /// ============================================

  Widget _buildAnimatedText() {
    return AnimatedBuilder(
      animation: _textController,
      builder: (context, child) {
        return Opacity(
          opacity: _textOpacity.value,
          child: Transform.translate(
            offset: Offset(0, _textSlide.value),
            child: child,
          ),
        );
      },
      child: Column(
        children: [
          // --- Nom de l'app ---
          const Text(
            AppConstants.appName,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 36,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),

          const SizedBox(height: 8),

          // --- Tagline ---
          Text(
            AppConstants.appTagline,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Colors.white.withValues(alpha: 0.85),
              letterSpacing: 4,
            ),
          ),
        ],
      ),
    );
  }

  /// ============================================
  /// WIDGET : Indicateur de chargement
  /// ============================================
  /// 💡 Pourquoi un indicateur custom ?
  /// → Le CircularProgressIndicator par défaut est basique
  //  → On veut un style qui matche le thème de l'app
  /// ============================================

  Widget _buildLoadingIndicator() {
    return AnimatedBuilder(
      animation: _loadingController,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            // Chaque point a un délai différent
            final delay = index * 0.3;
            final progress = (_loadingController.value - delay).clamp(0.0, 1.0);
            final scale = (progress < 0.5) ? progress * 2 : (1 - progress) * 2;

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: Transform.scale(
                scale: 0.5 + (scale * 0.5),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
