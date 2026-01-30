import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myday_ai/services/ai/intent_service.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class AIAssistantState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? error;

  AIAssistantState({
    required this.messages,
    this.isLoading = false,
    this.error,
  });

  AIAssistantState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? error,
  }) {
    return AIAssistantState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AIAssistantNotifier extends StateNotifier<AIAssistantState> {
  final IntentService _intentService;

  AIAssistantNotifier(this._intentService)
      : super(AIAssistantState(messages: [
          ChatMessage(
            text: 'Hello! I\'m your MyDay AI assistant. How can I help you today?',
            isUser: false,
            timestamp: DateTime.now(),
          ),
        ]));

  Future<void> sendMessage(String message) async {
    // Add user message
    state = state.copyWith(
      messages: [
        ...state.messages,
        ChatMessage(
          text: message,
          isUser: true,
          timestamp: DateTime.now(),
        ),
      ],
      isLoading: true,
    );

    try {
      final result = await _intentService.processUserMessage(message);

      // Add AI response
      state = state.copyWith(
        messages: [
          ...state.messages,
          ChatMessage(
            text: result['confirmation'] ?? 'Action completed.',
            isUser: false,
            timestamp: DateTime.now(),
          ),
        ],
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        messages: [
          ...state.messages,
          ChatMessage(
            text: 'Sorry, I encountered an error: $e',
            isUser: false,
            timestamp: DateTime.now(),
          ),
        ],
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void clearChat() {
    state = AIAssistantState(
      messages: [
        ChatMessage(
          text: 'Chat cleared. How can I help you today?',
          isUser: false,
          timestamp: DateTime.now(),
        ),
      ],
    );
  }
}

final aiAssistantProvider =
    StateNotifierProvider<AIAssistantNotifier, AIAssistantState>((ref) {
  final intentService = ref.watch(intentServiceProvider);
  return AIAssistantNotifier(intentService);
});