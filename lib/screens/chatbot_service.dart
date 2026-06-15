import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'app_models.dart';

/// ============================================
/// CHATBOT MESSAGE MODEL — Modèle de message
/// ============================================

enum MessageSender { user, chatbot }

class ChatMessage {
  final String? id;
  final String text;
  final MessageSender sender;
  final DateTime timestamp;
  final bool isAIGenerated;
  final Map<String, dynamic>? metadata;

  const ChatMessage({
    this.id,
    required this.text,
    required this.sender,
    required this.timestamp,
    this.isAIGenerated = false,
    this.metadata,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'sender': sender.name,
      'timestamp': timestamp.toIso8601String(),
      'isAIGenerated': isAIGenerated ? 1 : 0,
      'metadata': metadata != null ? jsonEncode(metadata) : null,
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id']?.toString(),
      text: map['text'] ?? '',
      sender:
          MessageSender.values.firstWhere(
            (s) => s.name == map['sender'],
            orElse: () => MessageSender.user,
          ),
      timestamp: map['timestamp'] != null
          ? DateTime.parse(map['timestamp'])
          : DateTime.now(),
      isAIGenerated: (map['isAIGenerated'] ?? 0) == 1,
      metadata: map['metadata'] != null ? jsonDecode(map['metadata']) : null,
    );
  }
}

/// ============================================
/// CHATBOT SERVICE — Service IA avec Gemini API
/// ============================================
/// Supports:
/// - Real AI via Google Gemini API (when API key is configured)
/// - Local rule-based analysis as fallback (no API key needed)
/// ============================================

class ChatbotService extends ChangeNotifier {
  static const String _messagesKey = 'app_chat_messages';
  static const String _geminiBaseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

  late SharedPreferences _prefs;
  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isAnalyzing = false;
  String _apiKey = '';

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;
  bool get isAnalyzing => _isAnalyzing;
  bool get hasApiKey => _apiKey.isNotEmpty;

  /// Initialiser avec SharedPreferences
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _apiKey = _prefs.getString('app_gemini_api_key') ?? '';
    await loadMessages();
  }

  /// Mettre à jour la clé API (appelé depuis SettingsService)
  void updateApiKey(String key) {
    _apiKey = key.trim();
    notifyListeners();
  }

  /// Charger les messages depuis SharedPreferences
  Future<void> loadMessages() async {
    try {
      _isLoading = true;
      notifyListeners();

      final messagesJson = _prefs.getStringList(_messagesKey) ?? [];

      _messages = messagesJson
          .map((json) => ChatMessage.fromMap(jsonDecode(json)))
          .toList();

      _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading chatbot messages: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sauvegarder les messages
  Future<void> _saveMessages() async {
    try {
      final messagesJson = _messages.map((m) => jsonEncode(m.toMap())).toList();
      await _prefs.setStringList(_messagesKey, messagesJson);
    } catch (e) {
      debugPrint('Error saving chatbot messages: $e');
    }
  }

  /// Ajouter un message utilisateur
  Future<void> addUserMessage(String text) async {
    final message = ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      text: text,
      sender: MessageSender.user,
      timestamp: DateTime.now(),
    );
    _messages.add(message);
    await _saveMessages();
    notifyListeners();
  }

  /// Ajouter une réponse du chatbot
  Future<void> addChatbotResponse(
    String text, {
    Map<String, dynamic>? metadata,
  }) async {
    final message = ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      text: text,
      sender: MessageSender.chatbot,
      timestamp: DateTime.now(),
      isAIGenerated: true,
      metadata: metadata,
    );
    _messages.add(message);
    await _saveMessages();
    notifyListeners();
  }

  /// ============================================
  /// GEMINI AI — Appel à l'API Gemini
  /// ============================================
  Future<String> callGeminiAI({
    required String userQuestion,
    required String financialContext,
  }) async {
    // Refresh API key from prefs in case it was updated
    _apiKey = _prefs.getString('app_gemini_api_key') ?? _apiKey;

    if (_apiKey.isEmpty) {
      // Fallback: local rule-based response
      return _localFallbackResponse(userQuestion, financialContext);
    }

    _isAnalyzing = true;
    notifyListeners();

    try {
      final systemPrompt = '''You are a helpful personal finance assistant for the SaveApp. 
You have access to the user's financial data and can provide insights, analysis, and advice.
Always be concise, friendly, and actionable. Format amounts in FCFA (West African CFA franc).
Use emojis sparingly but effectively.

FINANCIAL CONTEXT:
$financialContext

Answer the user's question based on their actual financial data above. If asked for general advice, 
tailor it specifically to their financial situation.''';

      final response = await http
          .post(
            Uri.parse('$_geminiBaseUrl?key=$_apiKey'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'contents': [
                {
                  'parts': [
                    {'text': '$systemPrompt\n\nUser: $userQuestion'},
                  ],
                },
              ],
              'generationConfig': {
                'temperature': 0.7,
                'maxOutputTokens': 512,
                'topP': 0.9,
              },
              'safetySettings': [
                {
                  'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
                  'threshold': 'BLOCK_ONLY_HIGH',
                },
              ],
            }),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final candidates = data['candidates'] as List?;
        if (candidates != null && candidates.isNotEmpty) {
          final content = candidates[0]['content'];
          final parts = content['parts'] as List?;
          if (parts != null && parts.isNotEmpty) {
            _isAnalyzing = false;
            notifyListeners();
            return parts[0]['text']?.toString() ?? 'No response generated.';
          }
        }
        _isAnalyzing = false;
        notifyListeners();
        return 'I could not generate a response. Please try again.';
      } else if (response.statusCode == 400) {
        _isAnalyzing = false;
        notifyListeners();
        return '⚠️ Invalid API key. Please check your Gemini API key in Settings.';
      } else if (response.statusCode == 429) {
        _isAnalyzing = false;
        notifyListeners();
        return '⏳ Rate limit reached. Please wait a moment and try again.';
      } else {
        debugPrint('Gemini API error: ${response.statusCode} — ${response.body}');
        // Fallback to local on API error
        _isAnalyzing = false;
        notifyListeners();
        return _localFallbackResponse(userQuestion, financialContext);
      }
    } catch (e) {
      debugPrint('Gemini API exception: $e');
      _isAnalyzing = false;
      notifyListeners();
      // Network error: fall back gracefully
      return _localFallbackResponse(userQuestion, financialContext);
    }
  }

  /// ============================================
  /// LOCAL FALLBACK — Réponses basées sur des règles
  /// ============================================
  String _localFallbackResponse(String question, String context) {
    _isAnalyzing = false;
    notifyListeners();

    final q = question.toLowerCase();

    if (q.contains('summary') || q.contains('résumé') || q.contains('overview')) {
      return _extractSummaryFromContext(context);
    } else if (q.contains('recommendation') ||
        q.contains('advice') ||
        q.contains('tip') ||
        q.contains('conseil')) {
      return _extractRecommendationsFromContext(context);
    } else if (q.contains('save') || q.contains('saving')) {
      return '💰 To save more:\n• Track every expense\n• Set monthly saving goals\n• Automate savings transfers\n• Review subscriptions regularly\n\n💡 Tip: Set up your Gemini API key in Settings for personalized AI advice!';
    } else if (q.contains('budget')) {
      return '📊 The 50/30/20 rule works well:\n• 50% → Needs (rent, food, transport)\n• 30% → Wants (entertainment, dining)\n• 20% → Savings & investments\n\n💡 Add your Gemini API key in Settings for AI-powered budget analysis!';
    } else if (q.contains('goal')) {
      return '🎯 Great goal-setting tips:\n• Be specific with amounts and dates\n• Break large goals into milestones\n• Review progress weekly\n• Celebrate small wins!';
    } else if (q.contains('invest')) {
      return '📈 Investment basics:\n• Build 3-6 months emergency fund first\n• Start with low-risk options\n• Diversify your portfolio\n• Think long-term (5+ years)';
    } else {
      return '💬 I\'m your financial assistant! I can help with:\n• **Summary** - overview of your finances\n• **Recommendations** - savings advice\n• **Budget** - budgeting strategies\n• **Goals** - goal-setting tips\n\n🤖 For AI-powered answers, add your Gemini API key in **Settings → AI Assistant**.';
    }
  }

  String _extractSummaryFromContext(String context) {
    return '📊 **Financial Summary**\n\n$context\n\n💡 Add your Gemini API key in Settings for deeper AI-powered analysis!';
  }

  String _extractRecommendationsFromContext(String context) {
    return '💡 **Savings Recommendations**\n\nBased on your data:\n• Keep tracking your expenses consistently\n• Set aside at least 20% of income\n• Review your goals regularly\n• Build an emergency fund (3-6 months of expenses)\n\n🤖 For personalized AI recommendations, add your Gemini API key in **Settings → AI Assistant**.';
  }

  /// ============================================
  /// BUILT-IN ANALYSIS — Génération de résumé local
  /// ============================================
  Future<String> generateTransactionSummary(
    List<IncomeModel> incomes,
    List<ExpenseModel> expenses,
  ) async {
    _isAnalyzing = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 300));

    final totalIncome = incomes.fold<double>(0, (sum, i) => sum + i.amount);
    final totalExpense = expenses.fold<double>(0, (sum, e) => sum + e.amount);
    final netSavings = totalIncome - totalExpense;
    final savingsRate = totalIncome > 0
        ? ((netSavings / totalIncome) * 100).toStringAsFixed(1)
        : '0.0';

    final expensesByCategory = <String, double>{};
    for (final expense in expenses) {
      final categoryName = expense.category.label;
      expensesByCategory[categoryName] =
          (expensesByCategory[categoryName] ?? 0) + expense.amount;
    }

    String topCategory = 'None';
    double topAmount = 0;
    for (final entry in expensesByCategory.entries) {
      if (entry.value > topAmount) {
        topAmount = entry.value;
        topCategory = entry.key;
      }
    }

    final financialContext = '''
Total Income: ${totalIncome.toStringAsFixed(0)} FCFA
Total Expenses: ${totalExpense.toStringAsFixed(0)} FCFA
Net Savings: ${netSavings.toStringAsFixed(0)} FCFA
Savings Rate: $savingsRate%
Income Entries: ${incomes.length}
Expense Entries: ${expenses.length}
Top Expense Category: $topCategory (${topAmount.toStringAsFixed(0)} FCFA)
''';

    _isAnalyzing = false;
    notifyListeners();

    return callGeminiAI(
      userQuestion: 'Give me a concise summary of my financial situation and 2-3 key insights.',
      financialContext: financialContext,
    );
  }

  /// Générer des recommandations d'épargne
  Future<String> generateSavingsRecommendations(
    double totalIncome,
    double totalExpense,
    List<dynamic> goals,
  ) async {
    _isAnalyzing = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 300));

    final netSavings = totalIncome - totalExpense;
    final savingsRate = totalIncome > 0
        ? ((netSavings / totalIncome) * 100).toStringAsFixed(1)
        : '0.0';

    final financialContext = '''
Monthly Income: ${totalIncome.toStringAsFixed(0)} FCFA
Monthly Expenses: ${totalExpense.toStringAsFixed(0)} FCFA
Net Savings: ${netSavings.toStringAsFixed(0)} FCFA
Savings Rate: $savingsRate%
Active Goals: ${goals.length}
''';

    _isAnalyzing = false;
    notifyListeners();

    return callGeminiAI(
      userQuestion: 'Based on my financial data, give me 3-4 specific, actionable savings recommendations.',
      financialContext: financialContext,
    );
  }

  /// Répondre à une question personnalisée avec contexte financier
  Future<String> answerCustomQuestion(
    String question, {
    double? totalIncome,
    double? totalExpense,
    int? goalsCount,
  }) async {
    _isAnalyzing = true;
    notifyListeners();

    final financialContext = '''
Income: ${totalIncome?.toStringAsFixed(0) ?? 'Not provided'} FCFA
Expenses: ${totalExpense?.toStringAsFixed(0) ?? 'Not provided'} FCFA
Savings Rate: ${totalIncome != null && totalIncome > 0 ? (((totalIncome - (totalExpense ?? 0)) / totalIncome) * 100).toStringAsFixed(1) : 'N/A'}%
Active Goals: ${goalsCount ?? 'Unknown'}
''';

    _isAnalyzing = false;
    notifyListeners();

    return callGeminiAI(
      userQuestion: question,
      financialContext: financialContext,
    );
  }

  /// Effacer tout l'historique
  Future<void> clearHistory() async {
    _messages.clear();
    await _prefs.remove(_messagesKey);
    notifyListeners();
  }
}
