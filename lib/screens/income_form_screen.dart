import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import "app_theme.dart";
import "transaction_service.dart";
import "app_models.dart";
import "constants.dart";

/// ============================================
/// INCOME FORM SCREEN — Formulaire d'ajout/modification de revenu
/// ============================================
/// 🎯 Permet d'ajouter ou modifier un revenu avec :
/// - Montant
/// - Catégorie (IncomeCategory)
/// - Date
/// - Note optionnelle
/// - Pièce jointe (image ou note vocale)
/// ============================================

class IncomeFormScreen extends StatefulWidget {
  final String? incomeId;

  const IncomeFormScreen({super.key, this.incomeId});

  @override
  State<IncomeFormScreen> createState() => _IncomeFormScreenState();
}

class _IncomeFormScreenState extends State<IncomeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  IncomeCategory _selectedCategory = IncomeCategory.salary;
  DateTime _selectedDate = DateTime.now();
  bool get _isEditing => widget.incomeId != null;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.surface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _saveIncome() async {
    if (!_formKey.currentState!.validate()) return;

    final service = Provider.of<TransactionService>(context, listen: false);

    final income = IncomeModel(
      id: widget.incomeId ?? 'inc_${DateTime.now().millisecondsSinceEpoch}',
      amount: double.parse(_amountController.text.replaceAll(',', '')),
      category: _selectedCategory,
      date: _selectedDate,
      note: _noteController.text.isEmpty ? null : _noteController.text,
      createdAt: DateTime.now(),
    );

    if (_isEditing) {
      await service.updateIncome(income);
    } else {
      await service.addIncome(income);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? 'Income updated successfully'
                : 'Income added successfully',
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Income' : 'Add Income'),
        actions: [
          TextButton(
            onPressed: _saveIncome,
            child: const Text(
              'Save',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Montant ---
              _buildAmountField(),

              const SizedBox(height: AppSpacing.xl),

              // --- Catégorie ---
              _buildCategorySelector(),

              const SizedBox(height: AppSpacing.xl),

              // --- Date ---
              _buildDateSelector(),

              const SizedBox(height: AppSpacing.xl),

              // --- Note ---
              _buildNoteField(),

              const SizedBox(height: AppSpacing.xl),

              // --- Options supplémentaires ---
              _buildExtraOptions(),

              const SizedBox(height: AppSpacing.xxl),

              // --- Bouton Sauvegarder ---
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAmountField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Amount',
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: AppColors.income,
          ),
          decoration: InputDecoration(
            hintText: '0',
            prefixText: '${Currency.xaf.symbol} ',
            prefixStyle: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textTertiary,
            ),
            filled: true,
            fillColor: AppColors.income.withValues(alpha: 0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              borderSide: BorderSide.none,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) return 'Amount is required';
            if (double.tryParse(value.replaceAll(',', '')) == null) {
              return 'Enter a valid amount';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: IncomeCategory.values.map((category) {
            final isSelected = _selectedCategory == category;
            return GestureDetector(
              onTap: () => setState(() => _selectedCategory = category),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Color(category.color).withValues(alpha: 0.15)
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(
                    color: isSelected
                        ? Color(category.color)
                        : AppColors.border,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getCategoryIcon(category.icon),
                      size: 16,
                      color: isSelected
                          ? Color(category.color)
                          : AppColors.textTertiary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      category.label,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: isSelected
                            ? Color(category.color)
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date',
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        GestureDetector(
          onTap: _selectDate,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Row(
              children: [
                const Icon(
                  LucideIcons.calendar,
                  size: 20,
                  color: AppColors.primary,
                ),
                const SizedBox(width: AppSpacing.md),
                Text(
                  _formatDate(_selectedDate),
                  style: AppTypography.bodyMedium,
                ),
                const Spacer(),
                const Icon(
                  LucideIcons.chevronDown,
                  size: 16,
                  color: AppColors.textTertiary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNoteField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Note (Optional)',
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: _noteController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Add a note about this income...',
          ),
        ),
      ],
    );
  }

  Widget _buildExtraOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Attachments',
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            _buildOptionChip(
              icon: LucideIcons.camera,
              label: 'Photo',
              onTap: () => context.push('/image-capture'),
            ),
            const SizedBox(width: AppSpacing.sm),
            _buildOptionChip(
              icon: LucideIcons.mic,
              label: 'Voice Note',
              onTap: () => context.push('/voice-recording'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOptionChip({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _saveIncome,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.income,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
        ),
        child: Text(
          _isEditing ? 'Update Income' : 'Save Income',
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String iconName) {
    final iconMap = {
      'briefcase': LucideIcons.briefcase,
      'laptop': LucideIcons.laptop,
      'building-2': LucideIcons.building2,
      'trending-up': LucideIcons.trendingUp,
      'home': LucideIcons.home,
      'gift': LucideIcons.gift,
      'rotate-ccw': LucideIcons.rotateCcw,
      'more-horizontal': LucideIcons.moreHorizontal,
    };
    return iconMap[iconName] ?? LucideIcons.circle;
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
