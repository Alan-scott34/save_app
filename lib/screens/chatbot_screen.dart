import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'app_theme.dart';
import 'chatbot_service.dart';
import 'transaction_service.dart';
import 'goal_service.dart';
import 'settings_service.dart';

/// ============================================
/// CHATBOT SCREEN — Chat d'analyse financière
/// ============================================
/// 🤖 Assistant IA pour :
/// 1. Résumé des transactions
/// 2. Recommandations d'épargne
/// 3. Questions personnalisées
/// 4. Historique de conversation
/// ============================================

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _handleSendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final chatbotService = context.read<ChatbotService>();
    final transactionService = context.read<TransactionService>();
    final goalService = context.read<GoalService>();

    await chatbotService.addUserMessage(text);
    _messageController.clear();

    setState(() => _isLoading = true);

    String response = '';
    final q = text.toLowerCase();

    if (q.contains('summary') || q.contains('résumé') || q.contains('overview')) {
      response = await chatbotService.generateTransactionSummary(
        transactionService.incomes,
        transactionService.expenses,
      );
    } else if (q.contains('recommendation') ||
        q.contains('recommandation') ||
        q.contains('advice') ||
        q.contains('tip')) {
      response = await chatbotService.generateSavingsRecommendations(
        transactionService.totalIncome,
        transactionService.totalExpense,
        goalService.goals,
      );
    } else {
      response = await chatbotService.answerCustomQuestion(
        text,
        totalIncome: transactionService.totalIncome,
        totalExpense: transactionService.totalExpense,
        goalsCount: goalService.goals.length,
      );
    }

    await chatbotService.addChatbotResponse(response);

    setState(() => _isLoading = false);

    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Financial Assistant'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, size: 22),
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
        actions: [
          Consumer<SettingsService>(
            builder: (context, settings, _) => Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Tooltip(
                message: settings.hasGeminiApiKey
                    ? 'Gemini AI Connected'
                    : 'Add API Key in Settings for AI',
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: settings.hasGeminiApiKey
                        ? AppColors.success.withValues(alpha: 0.15)
                        : AppColors.warning.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: settings.hasGeminiApiKey
                          ? AppColors.success
                          : AppColors.warning,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        settings.hasGeminiApiKey
                            ? LucideIcons.zap
                            : LucideIcons.zapOff,
                        size: 12,
                        color: settings.hasGeminiApiKey
                            ? AppColors.success
                            : AppColors.warning,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        settings.hasGeminiApiKey ? 'AI On' : 'AI Off',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: settings.hasGeminiApiKey
                              ? AppColors.success
                              : AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(LucideIcons.trash2, size: 20),
            onPressed: () => _showClearHistoryDialog(),
          ),
        ],
      ),
      body: Consumer<ChatbotService>(
        builder: (context, chatbotService, child) {
          return Column(
            children: [
              // --- Messages ---
              Expanded(
                child: chatbotService.messages.isEmpty
                    ? _buildWelcomeScreen()
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(AppSpacing.md),
                        itemCount: chatbotService.messages.length,
                        itemBuilder: (context, index) {
                          final message = chatbotService.messages[index];
                          return _buildMessageBubble(message);
                        },
                      ),
              ),

              // --- Indicateur de chargement ---
              if (chatbotService.isAnalyzing)
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'Analyzing...',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

              // --- Zone de saisie ---
              _buildInputArea(),
            ],
          );
        },
      ),
    );
  }

  /// ============================================
  /// WIDGET : Écran de bienvenue
  /// ============================================
  Widget _buildWelcomeScreen() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: AppSpacing.xl),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  LucideIcons.bot,
                  size: 40,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Financial Assistant',
              style: AppTypography.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'I can help you analyze transactions, get recommendations, and answer questions about your finances.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            _buildQuickActionButton(
              'Get Summary',
              'AI-powered financial overview',
              () => _handleSendMessage('Show me a summary of my transactions'),
            ),
            const SizedBox(height: AppSpacing.md),
            _buildQuickActionButton(
              'Get Recommendations',
              'Personalised savings advice',
              () => _handleSendMessage('Give me savings recommendations'),
            ),
            const SizedBox(height: AppSpacing.md),
            Consumer<SettingsService>(
              builder: (context, settings, _) {
                if (settings.hasGeminiApiKey) return const SizedBox.shrink();
                return GestureDetector(
                  onTap: () => context.push('/settings'),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                      border: Border.all(
                        color: AppColors.warning.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          LucideIcons.key,
                          color: AppColors.warning,
                          size: 20,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Enable AI Mode',
                                style: AppTypography.titleMedium.copyWith(
                                  color: AppColors.warning,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'Add Gemini API key in Settings for real AI responses',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          LucideIcons.chevronRight,
                          color: AppColors.warning,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  /// ============================================
  /// WIDGET : Bouton d'action rapide
  /// ============================================
  Widget _buildQuickActionButton(
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: const Center(
                child: Icon(
                  LucideIcons.sparkles,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.titleMedium),
                  Text(
                    subtitle,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(LucideIcons.chevronRight, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }

  /// ============================================
  /// WIDGET : Bulle de message
  /// ============================================
  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.sender == MessageSender.user;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isUser ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: !isUser ? Border.all(color: AppColors.border) : null,
        ),
        child: SelectableText(
          message.text,
          style: AppTypography.bodyMedium.copyWith(
            color: isUser ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  /// ============================================
  /// WIDGET : Zone de saisie
  /// ============================================
  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              enabled: !_isLoading,
              maxLines: null,
              minLines: 1,
              decoration: InputDecoration(
                hintText: 'Ask me anything...',
                hintStyle: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textTertiary,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          IconButton(
            onPressed: _isLoading
                ? null
                : () => _handleSendMessage(_messageController.text),
            icon: const Icon(LucideIcons.send, size: 20),
            color: _isLoading ? AppColors.textTertiary : AppColors.primary,
          ),
        ],
      ),
    );
  }

  /// ============================================
  /// DIALOG : Confirmation de suppression d'historique
  /// ============================================
  void _showClearHistoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        title: const Text('Clear History'),
        content: const Text(
          'Are you sure? This will delete all conversation history.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final chatbotService = context.read<ChatbotService>();
              await chatbotService.clearHistory();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
