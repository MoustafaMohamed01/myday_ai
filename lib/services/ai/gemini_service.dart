import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:myday_ai/services/local_storage/local_storage_service.dart';

class GeminiService {
  final LocalStorageService _localStorage;
  GenerativeModel? _model;
  ChatSession? _chatSession;

  GeminiService(this._localStorage);

  Future<void> _initializeModel() async {
    final apiKey = await _localStorage.getApiKey();
    if (apiKey == null) {
      throw Exception('API key not set');
    }
    
    _model = GenerativeModel(
      model: 'gemini-pro',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        maxOutputTokens: 1000,
        temperature: 0.1,
      ),
    );
    
    _chatSession = _model?.startChat(
      history: [
        Content.text(_getSystemPrompt()),
      ],
    );
  }

  String _getSystemPrompt() {
    return '''
You are MyDay AI, a personal assistant that helps manage tasks, events, and plans.
You MUST follow these rules STRICTLY:

1. You respond ONLY with valid JSON, no explanations, no markdown, no extra text.
2. You understand user intent and extract structured data.
3. All dates must be in ISO 8601 format (YYYY-MM-DDTHH:mm:ss).
4. Current date and time: ${DateTime.now().toIso8601String()}

Supported intents:
- create_task: Create a single task
- create_event: Create a single calendar event
- create_plan: Create a plan with multiple tasks/events
- list_tasks: List tasks
- list_events: List events
- update_task: Update an existing task
- delete_task: Delete a task

Response format examples:

For create_task:
{
  "intent": "create_task",
  "title": "Task title",
  "description": "Optional description",
  "dueDate": "2024-12-31T23:59:59",
  "priority": "high|medium|low"
}

For create_event:
{
  "intent": "create_event",
  "title": "Meeting title",
  "description": "Optional description",
  "startTime": "2024-12-31T10:00:00",
  "endTime": "2024-12-31T11:00:00",
  "isAllDay": false
}

For create_plan:
{
  "intent": "create_plan",
  "title": "Plan title",
  "description": "Optional description",
  "tasks": [
    {
      "title": "Task 1",
      "dueDate": "2024-12-31T08:00:00",
      "priority": "medium"
    }
  ],
  "events": [
    {
      "title": "Event 1",
      "startTime": "2024-12-31T10:00:00",
      "endTime": "2024-12-31T11:00:00"
    }
  ]
}

For list_tasks:
{
  "intent": "list_tasks",
  "filter": "today|upcoming|all"
}

For other intents, use appropriate format.

If you cannot understand the intent, respond with:
{
  "intent": "unknown",
  "message": "I didn't understand. Could you rephrase?"
}
''';
  }

  Future<Map<String, dynamic>> processMessage(String userMessage) async {
    try {
      if (_model == null) {
        await _initializeModel();
      }

      final response = await _chatSession!.sendMessage(
        Content.text(userMessage),
      );

      final text = response.text;
      if (text == null) {
        throw Exception('No response from AI');
      }

      // Clean the response
      final cleanedText = text
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      return jsonDecode(cleanedText);
    } catch (e) {
      rethrow;
    }
  }

  String generateConfirmationMessage(Map<String, dynamic> intentData) {
    final intent = intentData['intent'];
    
    switch (intent) {
      case 'create_task':
        return '✅ Task "${intentData['title']}" has been created successfully.';
      case 'create_event':
        return '📅 Event "${intentData['title']}" has been added to your calendar.';
      case 'create_plan':
        final taskCount = (intentData['tasks'] as List?)?.length ?? 0;
        final eventCount = (intentData['events'] as List?)?.length ?? 0;
        return '📋 Plan "${intentData['title']}" created with $taskCount tasks and $eventCount events.';
      case 'update_task':
        return '🔄 Task "${intentData['title']}" has been updated.';
      case 'delete_task':
        return '🗑️ Task has been deleted.';
      default:
        return '✅ Action completed successfully.';
    }
  }
}

final geminiServiceProvider = Provider<GeminiService>((ref) {
  final localStorage = ref.watch(localStorageServiceProvider);
  return GeminiService(localStorage);
});