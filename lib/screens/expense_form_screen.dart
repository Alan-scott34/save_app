import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import "app_theme.dart";
import "transaction_service.dart";
import "app_models.dart";
import "constants.dart";
import "speed_dial_fab.dart";

/// ============================================
/// EXPENSE FORM SCREEN — Formulaire d'ajout/modification de dépense
/// ============================================

class ExpenseFormScreen extends StatefulWidget {
  final String? expenseId;

  const ExpenseFormScreen({super.key, this.expenseId});

  @override
  State<ExpenseFormScreen> createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends State<ExpenseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  ExpenseCategory _selectedCategory = ExpenseCategory.food;
  DateTime _selectedDate = DateTime.now();
  bool get _isEditing => widget.expenseId != null;

  // Existing record when editing
  ExpenseModel? _existingExpense;
  String? _pendingAttachmentPath;
  String? _pendingVoiceNotePath;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadExistingData());
    }
  }

  Future<void> _loadExistingData() async {
    final service = Provider.of<TransactionService>(context, listen: false);
    if (service.expenses.isEmpty) await service.loadTransactions();
    if (!mounted) return;
    final idx = service.expenses.indexWhere((e) => e.id == widget.expenseId);
    if (idx != -1) {
      final expense = service.expenses[idx];
      setState(() {
        _existingExpense = expense;
        _amountController.text = expense.amount.toStringAsFixed(0);
        _noteController.text = expense.note ?? '';
        _selectedCategory = expense.category;
        _selectedDate = expense.date;
        _pendingAttachmentPath = expense.attachmentUrl;
        _pendingVoiceNotePath = expense.voiceNoteUrl;
      });
    }
  }

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
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) return;

    final service = Provider.of<TransactionService>(context, listen: false);

    final expense = ExpenseModel(
      id: widget.expenseId ?? 'exp_${DateTime.now().millisecondsSinceEpoch}',
      amount: double.parse(_amountController.text.replaceAll(',', '')),
      category: _selectedCategory,
      date: _selectedDate,
      note: _noteController.text.isEmpty ? null : _noteController.text,
      attachmentUrl: _pendingAttachmentPath,
      voiceNoteUrl: _pendingVoiceNotePath,
      // Preserve original createdAt when editing
      createdAt: _existingExpense?.createdAt ?? DateTime.now(),
      updatedAt: _isEditing ? DateTime.now() : null,
    );

    if (_isEditing) {
      await service.updateExpense(expense);
    } else {
      await service.addExpense(expense);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing ? 'Expense updated' : 'Expense added'),
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
      floatingActionButton: SpeedDialFAB(
        mainIcon: LucideIcons.paperclip,
        actions: [
          SpeedDialAction(
            icon: LucideIcons.camera,
            label: _pendingAttachmentPath != null ? 'Photo Attached ✓' : 'Attach Photo',
            color: _pendingAttachmentPath != null ? AppColors.income : AppColors.success,
            onTap: () async {
              final path = await context.push<String>('/image-capture');
              if (path != null && mounted) {
                setState(() => _pendingAttachmentPath = path);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Photo attached to expense'),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
          ),
          SpeedDialAction(
            icon: LucideIcons.mic,
            label: _pendingVoiceNotePath != null ? 'Voice Attached ✓' : 'Attach Voice',
            color: _pendingVoiceNotePath != null ? AppColors.income : AppColors.primary,
            onTap: () async {
              final path = await context.push<String>('/voice-recording');
              if (path != null && mounted) {
                setState(() => _pendingVoiceNotePath = path);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Voice note attached to expense'),
                    backgroundColor: AppColors.primary,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
          ),
        ],
      ),
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Expense' : 'Add Expense'),
        actions: [
          TextButton(
            onPressed: _saveExpense,
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
              _buildAmountField(),
              const SizedBox(height: AppSpacing.xl),
              _buildCategorySelector(),
              const SizedBox(height: AppSpacing.xl),
              _buildDateSelector(),
              const SizedBox(height: AppSpacing.xl),
              _buildNoteField(),
              const SizedBox(height: AppSpacing.xxl),
              _buildSaveButton(),
              const SizedBox(height: 100), // Espace pour le FAB
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
            color: AppColors.expense,
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
            fillColor: AppColors.expense.withValues(alpha: 0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              borderSide: BorderSide.none,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Amount is required';
            }
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
          children: ExpenseCategory.values.map((category) {
            final isSelected = _selectedCategory == category;
            return GestureDetector(
              onTap: () => setState(() => _selectedCategory = category),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
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
                child: Text(
                  category.label,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected
                        ? Color(category.color)
                        : AppColors.textSecondary,
                  ),
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
                  '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}',
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
            hintText: 'Add a note about this expense...',
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
            GestureDetector(
              onTap: () => context.push('/image-capture'),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      LucideIcons.camera,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Photo Receipt',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            GestureDetector(
              onTap: () => context.push('/voice-recording'),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.mic, size: 16, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text(
                      'Voice Note',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _saveExpense,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.expense,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
        ),
        child: Text(
          _isEditing ? 'Update Expense' : 'Save Expense',
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
}
