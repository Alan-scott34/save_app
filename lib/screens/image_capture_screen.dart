import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'app_theme.dart';

/// ============================================
/// IMAGE CAPTURE SCREEN — Capture de reçus
/// ============================================
/// 🎯 Ce que fait cet écran :
/// 1. Zone de prévisualisation caméra (placeholder)
/// 2. Bouton de capture photo
/// 3. Bouton galerie (choisir depuis la galerie)
/// 4. Grille des images récentes capturées
/// 5. Pour chaque image : vignette, tag de lieu, date,
///    bouton "Attacher à une Transaction"
/// 6. Affichage de la localisation (latitude/longitude)
///
/// 🎨 Design : Zone caméra sombre, grille de vignettes,
/// tags de localisation
///
/// 📦 Note : La capture réelle utilise le package
/// `image_picker` et `geolocator`. Ici, on stub la logique
/// — l'UI est complète et fonctionnelle.
/// ============================================

class ImageCaptureScreen extends StatefulWidget {
  const ImageCaptureScreen({super.key});

  @override
  State<ImageCaptureScreen> createState() => _ImageCaptureScreenState();
}

class _ImageCaptureScreenState extends State<ImageCaptureScreen> {
  // --- État de la localisation GPS ---
  double? _latitude;
  double? _longitude;
  bool _isLocating = false;

  // --- Images capturées (données mock) ---
  final List<CapturedImage> _capturedImages = [];

  // --- État de la caméra ---
  bool _isCameraActive = false;

  @override
  void initState() {
    super.initState();
    _loadMockImages();
    _getCurrentLocation();
  }

  /// Charge des images mock pour la démonstration
  void _loadMockImages() {
    _capturedImages.addAll([
      CapturedImage(
        id: 'img_001',
        title: 'Supermarket receipt',
        date: DateTime.now().subtract(const Duration(hours: 3)),
        latitude: 4.0511,
        longitude: 9.7677,
        locationTag: 'Douala, Cameroon',
      ),
      CapturedImage(
        id: 'img_002',
        title: 'Restaurant bill',
        date: DateTime.now().subtract(const Duration(days: 1)),
        latitude: 3.8480,
        longitude: 11.5021,
        locationTag: 'Yaoundé, Cameroon',
      ),
      CapturedImage(
        id: 'img_003',
        title: 'Pharmacy receipt',
        date: DateTime.now().subtract(const Duration(days: 2)),
        latitude: null,
        longitude: null,
        locationTag: null,
      ),
      CapturedImage(
        id: 'img_004',
        title: 'Gas station receipt',
        date: DateTime.now().subtract(const Duration(days: 5)),
        latitude: 4.0511,
        longitude: 9.7677,
        locationTag: 'Douala, Cameroon',
      ),
    ]);
  }

  /// Récupère la position GPS actuelle (stub)
  Future<void> _getCurrentLocation() async {
    setState(() => _isLocating = true);

    // Simuler un délai de géolocalisation
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _latitude = 4.0511;
      _longitude = 9.7677;
      _isLocating = false;
    });

    // TODO: Implémenter avec le package `geolocator`
    // final position = await Geolocator.getCurrentPosition();
    // setState(() {
    //   _latitude = position.latitude;
    //   _longitude = position.longitude;
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Capture Receipt'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, size: 22),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          // Bouton de rafraîchissement GPS
          IconButton(
            icon: _isLocating
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  )
                : const Icon(LucideIcons.mapPin, size: 20),
            onPressed: _getCurrentLocation,
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Zone de prévisualisation caméra ---
            _buildCameraPreview(),

            const SizedBox(height: AppSpacing.md),

            // --- Contrôles de capture ---
            _buildCaptureControls(),

            const SizedBox(height: AppSpacing.md),

            // --- Affichage de la localisation ---
            _buildLocationDisplay(),

            const SizedBox(height: AppSpacing.lg),

            // --- Grille des images récentes ---
            _buildRecentImagesGrid(),

            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  /// ============================================
  /// WIDGET : Zone de prévisualisation caméra (placeholder)
  /// ============================================
  /// Affiche un placeholder pour la prévisualisation de la
  /// caméra. En production, ceci serait un CameraPreview
  /// du package camera ou image_picker.
  Widget _buildCameraPreview() {
    return Container(
      width: double.infinity,
      height: 280,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: _isCameraActive
              ? AppColors.primary.withValues(alpha: 0.5)
              : AppColors.border,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Placeholder de la caméra
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icône caméra
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    LucideIcons.camera,
                    size: 32,
                    color: Colors.white38,
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Texte d'instruction
              Text(
                'Camera Preview',
                style: AppTypography.titleMedium.copyWith(
                  color: Colors.white38,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Position your receipt within the frame',
                style: AppTypography.bodySmall.copyWith(color: Colors.white24),
              ),
            ],
          ),

          // Cadre de scan (overlay)
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: CustomPaint(
                painter: ScanFramePainter(
                  color: _isCameraActive ? AppColors.primary : Colors.white24,
                ),
              ),
            ),
          ),

          // Indicateur d'état en haut
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _isCameraActive
                    ? AppColors.error.withValues(alpha: 0.8)
                    : Colors.black54,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: _isCameraActive ? Colors.white : Colors.white38,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _isCameraActive ? 'LIVE' : 'OFF',
                    style: AppTypography.labelSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Flash auto indicator (en haut à droite)
          Positioned(
            top: 12,
            right: 12,
            child: GestureDetector(
              onTap: () {
                // TODO: Toggle flash
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(
                  LucideIcons.zap,
                  size: 16,
                  color: Colors.white38,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ============================================
  /// WIDGET : Contrôles de capture
  /// ============================================
  /// Boutons pour capturer une photo, choisir depuis la
  /// galerie, et activer/désactiver la caméra.
  Widget _buildCaptureControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Bouton Galerie
        _buildControlButton(
          icon: LucideIcons.image,
          label: 'Gallery',
          onTap: _pickFromGallery,
        ),

        // Bouton Capture principal (grand)
        GestureDetector(
          onTap: _captureImage,
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Icon(LucideIcons.camera, size: 28, color: Colors.white),
            ),
          ),
        ),

        // Bouton Activer/Désactiver caméra
        _buildControlButton(
          icon: _isCameraActive ? LucideIcons.videoOff : LucideIcons.video,
          label: 'Camera',
          onTap: () {
            setState(() => _isCameraActive = !_isCameraActive);
          },
        ),
      ],
    );
  }

  /// Bouton de contrôle secondaire
  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Center(
              child: Icon(icon, size: 22, color: AppColors.textPrimary),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// ============================================
  /// WIDGET : Affichage de la localisation GPS
  /// ============================================
  Widget _buildLocationDisplay() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Icône de localisation
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Icon(
                _latitude != null ? LucideIcons.mapPin : LucideIcons.mapPinOff,
                size: 18,
                color: _latitude != null
                    ? AppColors.primary
                    : AppColors.textTertiary,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          // Info de localisation
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Location',
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                if (_isLocating)
                  Text(
                    'Locating...',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.warning,
                    ),
                  )
                else if (_latitude != null && _longitude != null)
                  Text(
                    'Lat: ${_latitude!.toStringAsFixed(4)}  |  Lng: ${_longitude!.toStringAsFixed(4)}',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  )
                else
                  Text(
                    'Location not available',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
              ],
            ),
          ),

          // Bouton de rafraîchissement GPS
          GestureDetector(
            onTap: _getCurrentLocation,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                LucideIcons.refreshCw,
                size: 16,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ============================================
  /// WIDGET : Grille des images récentes
  /// ============================================
  /// Affiche les images capturées dans une grille avec
  /// vignettes, tags de lieu, dates et actions.
  Widget _buildRecentImagesGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Titre de section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(
                  LucideIcons.image,
                  size: 20,
                  color: AppColors.primary,
                ),
                const SizedBox(width: AppSpacing.sm),
                const Text('Recent Captures', style: AppTypography.titleLarge),
              ],
            ),
            if (_capturedImages.isNotEmpty)
              Text(
                '${_capturedImages.length} photos',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
          ],
        ),

        const SizedBox(height: AppSpacing.md),

        // Grille ou état vide
        if (_capturedImages.isEmpty)
          _buildEmptyGridPlaceholder()
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: AppSpacing.md,
              crossAxisSpacing: AppSpacing.md,
              childAspectRatio: 0.72,
            ),
            itemCount: _capturedImages.length,
            itemBuilder: (context, index) {
              return _buildImageCard(_capturedImages[index]);
            },
          ),
      ],
    );
  }

  /// État vide quand il n'y a pas d'images
  Widget _buildEmptyGridPlaceholder() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Icon(
            LucideIcons.imageOff,
            size: 48,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No captured receipts yet',
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Capture a receipt or pick from gallery to get started',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Carte d'une image capturée
  Widget _buildImageCard(CapturedImage image) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Zone de vignette (placeholder)
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                // Placeholder de l'image
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppSpacing.radiusMd),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        LucideIcons.fileImage,
                        size: 32,
                        color: AppColors.textTertiary.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        image.title,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textTertiary,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        strutStyle: const StrutStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),

                // Tag de localisation (si disponible)
                if (image.locationTag != null)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            LucideIcons.mapPin,
                            size: 10,
                            color: Colors.white70,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            image.locationTag!,
                            style: AppTypography.labelSmall.copyWith(
                              color: Colors.white70,
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Bouton supprimer (en haut à droite)
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => _deleteImage(image.id),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        LucideIcons.x,
                        size: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Zone d'information
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date
                  Row(
                    children: [
                      const Icon(
                        LucideIcons.calendar,
                        size: 10,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        _formatDate(image.date),
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textTertiary,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),

                  // Coordonnées GPS (si disponibles)
                  if (image.latitude != null && image.longitude != null) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(
                          LucideIcons.navigation,
                          size: 10,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${image.latitude!.toStringAsFixed(2)}, ${image.longitude!.toStringAsFixed(2)}',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textTertiary,
                            fontSize: 10,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                  ],

                  const Spacer(),

                  // Bouton Attacher à une Transaction
                  GestureDetector(
                    onTap: () => _attachToTransaction(image),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusSm,
                        ),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            LucideIcons.link,
                            size: 12,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              'Attach to Transaction',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =============================================
  // ACTIONS
  // =============================================

  /// Capture une image avec la caméra (stub)
  Future<void> _captureImage() async {
    // Simuler la capture d'une image
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Capturing receipt...'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        duration: const Duration(seconds: 1),
      ),
    );

    // Simuler un délai de capture
    await Future.delayed(const Duration(seconds: 1));

    // Créer une nouvelle image capturée
    final newImage = CapturedImage(
      id: 'img_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Receipt ${_capturedImages.length + 1}',
      date: DateTime.now(),
      latitude: _latitude,
      longitude: _longitude,
      locationTag: _latitude != null ? 'Current Location' : null,
    );

    setState(() {
      _capturedImages.insert(0, newImage);
    });

    // TODO: Implémenter avec le package `image_picker`
    // final XFile? image = await ImagePicker().pickImage(
    //   source: ImageSource.camera,
    //   maxWidth: 1920,
    //   maxHeight: 1080,
    // );
  }

  /// Choisit une image depuis la galerie (stub)
  Future<void> _pickFromGallery() async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Opening gallery...'),
        backgroundColor: AppColors.info,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        duration: const Duration(seconds: 1),
      ),
    );

    // Simuler un délai de sélection
    await Future.delayed(const Duration(seconds: 1));

    final newImage = CapturedImage(
      id: 'img_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Gallery image ${_capturedImages.length + 1}',
      date: DateTime.now(),
      latitude: _latitude,
      longitude: _longitude,
      locationTag: null,
    );

    setState(() {
      _capturedImages.insert(0, newImage);
    });

    // TODO: Implémenter avec le package `image_picker`
    // final XFile? image = await ImagePicker().pickImage(
    //   source: ImageSource.gallery,
    // );
  }

  /// Attache une image à une transaction
  void _attachToTransaction(CapturedImage image) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Attaching "${image.title}" to transaction...'),
        backgroundColor: AppColors.income,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
      ),
    );

    // TODO: Navigation vers /expense/add ou /income/add
    // avec l'image attachée
  }

  /// Supprime une image capturée
  void _deleteImage(String id) {
    setState(() {
      _capturedImages.removeWhere((img) => img.id == id);
    });
  }

  // =============================================
  // HELPERS
  // =============================================

  /// Formate une date en dd/MM/yyyy HH:mm
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

// =============================================
// MODEL : CapturedImage (données locales)
// =============================================

/// Modèle de données pour une image capturée.
/// En production, ce modèle serait dans app_models.dart
/// et connecté à SQLite/Firestore.
class CapturedImage {
  final String id;
  final String title;
  final DateTime date;
  final double? latitude;
  final double? longitude;
  final String? locationTag;

  const CapturedImage({
    required this.id,
    required this.title,
    required this.date,
    this.latitude,
    this.longitude,
    this.locationTag,
  });
}

// =============================================
// CUSTOM PAINTER : Cadre de scan
// =============================================

/// Peint un cadre de scan avec des coins arrondis
/// pour guider l'utilisateur lors de la capture.
class ScanFramePainter extends CustomPainter {
  final Color color;

  ScanFramePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const cornerLength = 24.0;

    // Coin supérieur gauche
    canvas.drawLine(Offset(0, cornerLength), Offset(0, 0), paint);
    canvas.drawLine(Offset(0, 0), Offset(cornerLength, 0), paint);

    // Coin supérieur droit
    canvas.drawLine(
      Offset(size.width - cornerLength, 0),
      Offset(size.width, 0),
      paint,
    );
    canvas.drawLine(
      Offset(size.width, 0),
      Offset(size.width, cornerLength),
      paint,
    );

    // Coin inférieur gauche
    canvas.drawLine(
      Offset(0, size.height - cornerLength),
      Offset(0, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(0, size.height),
      Offset(cornerLength, size.height),
      paint,
    );

    // Coin inférieur droit
    canvas.drawLine(
      Offset(size.width - cornerLength, size.height),
      Offset(size.width, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(size.width, size.height - cornerLength),
      Offset(size.width, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(ScanFramePainter oldDelegate) {
    return color != oldDelegate.color;
  }
}
