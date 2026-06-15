import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'app_theme.dart';

/// ============================================
/// SPEED DIAL ACTION — Modèle pour une action
/// ============================================
class SpeedDialAction {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const SpeedDialAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}

/// ============================================
/// SPEED DIAL FAB WIDGET — Bouton flottant avec menu
/// ============================================
class SpeedDialFAB extends StatefulWidget {
  final List<SpeedDialAction> actions;
  final IconData mainIcon;
  final bool isExpanded;

  const SpeedDialFAB({
    super.key,
    required this.actions,
    this.mainIcon = LucideIcons.plus,
    this.isExpanded = false,
  });

  @override
  State<SpeedDialFAB> createState() => _SpeedDialFABState();
}

class _SpeedDialFABState extends State<SpeedDialFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.isExpanded;

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });

    if (_isExpanded) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _handleAction(VoidCallback action) {
    _toggleExpanded();
    Future.delayed(const Duration(milliseconds: 150), () {
      action();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        if (_isExpanded)
          GestureDetector(
            onTap: _toggleExpanded,
            child: AnimatedOpacity(
              opacity: _isExpanded ? 0.3 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.black,
              ),
            ),
          ),
        
        ..._buildActions(),

        ScaleTransition(
          scale: _scaleAnimation,
          child: FloatingActionButton(
            heroTag: 'main_fab',
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 8,
            onPressed: _toggleExpanded,
            child: RotationTransition(
              turns: _rotationAnimation,
              child: Icon(widget.mainIcon, size: 28),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildActions() {
    final List<Widget> widgets = [];
    
    // Reverse the actions so the first action is closest to the FAB
    for (int i = 0; i < widget.actions.length; i++) {
      final action = widget.actions[i];
      // Offset calculates from the FAB upwards. Each step goes up 1.3 times the height.
      final offsetAnimation = Tween<Offset>(
        begin: Offset.zero,
        end: Offset(0, -1.3 * (i + 1)),
      ).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Curves.easeInOut,
        ),
      );

      final scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            (i * 0.1).clamp(0.0, 1.0), 
            1.0, 
            curve: Curves.elasticOut
          ),
        ),
      );

      if (_isExpanded) {
        widgets.add(
          SlideTransition(
            position: offsetAnimation,
            child: ScaleTransition(
              scale: scaleAnimation,
              child: Padding(
                padding: const EdgeInsets.only(right: 4.0),
                child: _buildFABButton(action),
              ),
            ),
          ),
        );
      }
    }
    
    return widgets;
  }

  Widget _buildFABButton(SpeedDialAction action) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label
        Container(
          margin: const EdgeInsets.only(right: 16),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            action.label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
        // Button
        GestureDetector(
          onTap: () => _handleAction(action.onTap),
          child: Container(
            decoration: BoxDecoration(
              color: action.color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: action.color.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _handleAction(action.onTap),
                customBorder: const CircleBorder(),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Icon(action.icon, color: Colors.white, size: 24),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
