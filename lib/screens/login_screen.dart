import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import "app_theme.dart";
import "auth_service.dart";

/// ============================================
/// LOGIN SCREEN — Écran de connexion
/// ============================================
/// 🎯 Ce que fait cet écran :
/// 1. Permet à l'utilisateur de se connecter avec email/mdp
/// 2. Navigation vers Register ou Forgot Password
/// 3. Validation des champs en temps réel
/// 4. Affichage des erreurs de manière élégante
///
/// 💡 Points de design :
/// → Logo en haut (cohérent avec le Splash)
/// → Champs de saisie avec icônes Lucide
/// → Bouton principal en vert (couleur de l'app)
/// → Lien secondaire vers inscription
/// → Support du mode sombre automatique
/// ============================================

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  // --- Contrôleurs de formulaire ---
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // --- État du formulaire ---
  bool _obscurePassword = true;
  bool _rememberMe = false;

  // --- Animation ---
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  /// Connexion
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authService = Provider.of<AuthService>(context, listen: false);
    await authService.login(
      _emailController.text.trim(),
      _passwordController.text,
      rememberMe: _rememberMe,
    );

    if (!mounted) return;

    if (authService.isLoggedIn) {
      context.go('/');
    } else if (authService.error != null) {
      _showErrorSnackBar(authService.error!);
    }
  }

  /// Afficher une erreur
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(LucideIcons.alertCircle, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        margin: const EdgeInsets.all(AppSpacing.md),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.xl),

                  // --- Bouton retour ---
                  _buildBackButton(),

                  const SizedBox(height: AppSpacing.xxl),

                  // --- En-tête ---
                  _buildHeader(),

                  const SizedBox(height: AppSpacing.xl),

                  // --- Champ Email ---
                  _buildEmailField(),

                  const SizedBox(height: AppSpacing.md),

                  // --- Champ Mot de passe ---
                  _buildPasswordField(),

                  const SizedBox(height: AppSpacing.md),

                  // --- Se souvenir de moi + Mot de passe oublié ---
                  _buildRememberAndForgot(),

                  const SizedBox(height: AppSpacing.xl),

                  // --- Bouton Connexion ---
                  _buildLoginButton(authService),

                  const SizedBox(height: AppSpacing.xl),

                  // --- Séparateur ---
                  _buildDivider(),

                  const SizedBox(height: AppSpacing.xl),

                  // --- Lien Inscription ---
                  _buildRegisterLink(),

                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// ============================================
  /// WIDGET : Bouton retour
  /// ============================================
  Widget _buildBackButton() {
    return GestureDetector(
      onTap: () => context.go('/splash'),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.border),
        ),
        child: const Icon(
          LucideIcons.arrowLeft,
          size: 20,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  /// ============================================
  /// WIDGET : En-tête (logo + titre)
  /// ============================================
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo compact
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Center(
            child: Icon(LucideIcons.piggyBank, size: 28, color: Colors.white),
          ),
        ),

        const SizedBox(height: AppSpacing.lg),

        // Titre
        const Text('Welcome Back!', style: AppTypography.headlineLarge),

        const SizedBox(height: AppSpacing.sm),

        // Sous-titre
        Text(
          'Sign in to continue tracking your savings',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  /// ============================================
  /// WIDGET : Champ Email
  /// ============================================
  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Email Address',
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
            hintText: 'Enter your email',
            prefixIcon: Padding(
              padding: EdgeInsets.all(14.0),
              child: Icon(
                LucideIcons.mail,
                size: 20,
                color: AppColors.textTertiary,
              ),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Email is required';
            }
            if (!value.contains('@') || !value.contains('.')) {
              return 'Enter a valid email address';
            }
            return null;
          },
        ),
      ],
    );
  }

  /// ============================================
  /// WIDGET : Champ Mot de passe
  /// ============================================
  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Password',
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _handleLogin(),
          decoration: InputDecoration(
            hintText: 'Enter your password',
            prefixIcon: const Padding(
              padding: EdgeInsets.all(14.0),
              child: Icon(
                LucideIcons.lock,
                size: 20,
                color: AppColors.textTertiary,
              ),
            ),
            suffixIcon: Padding(
              padding: const EdgeInsets.all(14.0),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
                child: Icon(
                  _obscurePassword ? LucideIcons.eyeOff : LucideIcons.eye,
                  size: 20,
                  color: AppColors.textTertiary,
                ),
              ),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Password is required';
            }
            if (value.length < 6) {
              return 'Password must be at least 6 characters';
            }
            return null;
          },
        ),
      ],
    );
  }

  /// ============================================
  /// WIDGET : Se souvenir + Mot de passe oublié
  /// ============================================
  Widget _buildRememberAndForgot() {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.sm,
      children: [
        // Se souvenir de moi
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: Checkbox(
                value: _rememberMe,
                onChanged: (value) {
                  setState(() {
                    _rememberMe = value ?? false;
                  });
                },
                activeColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Remember me',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),

        // Mot de passe oublié
        TextButton(
          onPressed: () => context.go('/forgot-password'),
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: const Size(0, 0),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'Forgot Password?',
            style: AppTypography.labelMedium.copyWith(color: AppColors.primary),
          ),
        ),
      ],
    );
  }

  /// ============================================
  /// WIDGET : Bouton Connexion
  /// ============================================
  Widget _buildLoginButton(AuthService authService) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: authService.isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          elevation: 0,
        ),
        child: authService.isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : const Text(
                'Sign In',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  /// ============================================
  /// WIDGET : Séparateur "Or"
  /// ============================================
  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: AppColors.border)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(
            'Or',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ),
        Expanded(child: Container(height: 1, color: AppColors.border)),
      ],
    );
  }

  /// ============================================
  /// WIDGET : Lien vers l'inscription
  /// ============================================
  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        TextButton(
          onPressed: () => context.go('/register'),
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: const Size(0, 0),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text(
            'Sign Up',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}
