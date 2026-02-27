import 'dart:convert';

import 'package:http/http.dart' as http;

class GeminiAttachment {
  GeminiAttachment({
    required this.bytes,
    required this.mimeType,
  });

  final List<int> bytes;
  final String mimeType;
}

class GeminiChatService {
  GeminiChatService({
    String? model,
    String? apiKey,
  })  : _model = model ?? const String.fromEnvironment('GEMINI_MODEL'),
        _apiKey = apiKey ?? const String.fromEnvironment('GEMINI_API_KEY');

  static const String _systemPrompt = '''
You are the official smart advisor for Al Qasr Al Taqni Company.
In English context, display the company name as: Technical Palace Group.
You are an advanced ERPNext expert in accounting, sales, purchases, inventory, projects, HR, workflow, reporting, customization, permissions, and API integrations.
Respond in the same language used by the user unless explicitly asked otherwise.
Keep answers practical, clear, and actionable for company operations.
If asked who created you, who owns you, or who supervises you:
- In Arabic, reply exactly: "تم تطويري عن طريق شركة القصر التقني ."
- In English, reply exactly: "I was developed by Technical Palace Group under the supervision of engineer."
If a question is outside ERPNext or business operations, give a short answer then guide the user back to relevant ERPNext solutions.
''';

  final String _model;
  final String _apiKey;

  Future<String> sendMessage({
    required String prompt,
    required List<({String role, String text})> history,
    List<GeminiAttachment> attachments = const [],
  }) async {
    if (_apiKey.trim().isEmpty) {
      throw Exception(
        'Gemini API key is missing. Pass it with --dart-define=GEMINI_API_KEY=YOUR_KEY',
      );
    }

    final contents = <Map<String, dynamic>>[
      ...history.map(
        (m) => {
          'role': m.role,
          'parts': [
            {'text': m.text},
          ],
        },
      ),
      {
        'role': 'user',
        'parts': [
          if (prompt.trim().isNotEmpty) {'text': prompt.trim()},
          ...attachments.map(
            (a) => {
              'inline_data': {
                'mime_type': a.mimeType,
                'data': base64Encode(a.bytes),
              },
            },
          ),
          if (prompt.trim().isEmpty && attachments.isNotEmpty)
            {'text': 'Analyze the image and provide a practical ERPNext-focused summary.'},
        ],
      },
    ];

    final modelCandidates = <String>{
      if (_model.trim().isNotEmpty) _model.trim(),
      'gemini-2.0-flash',
      'gemini-2.0-flash-lite',
      'gemini-1.5-flash-latest',
      'gemini-1.5-flash',
    }.toList();
    const apiVersions = ['v1', 'v1beta'];
    String? lastError;

    for (final version in apiVersions) {
      for (final model in modelCandidates) {
        final uri = Uri.parse(
          'https://generativelanguage.googleapis.com/$version/models/$model:generateContent?key=$_apiKey',
        );

        final response = await http.post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'system_instruction': {
              'parts': [
                {'text': _systemPrompt},
              ],
            },
            'contents': contents,
            'generationConfig': {
              'temperature': 0.3,
              'topP': 0.9,
              'maxOutputTokens': 1024,
            },
          }),
        );

        final body = jsonDecode(response.body) as Map<String, dynamic>;

        if (response.statusCode >= 200 && response.statusCode < 300) {
          final candidates = body['candidates'];
          if (candidates is! List || candidates.isEmpty) {
            lastError = 'Gemini returned an empty response.';
            continue;
          }

          final content = candidates.first['content'];
          final parts = content is Map<String, dynamic> ? content['parts'] : null;
          if (parts is! List || parts.isEmpty) {
            lastError = 'Gemini response did not include text.';
            continue;
          }

          final texts = parts
              .map((p) => p is Map<String, dynamic> ? p['text'] : null)
              .whereType<String>()
              .where((t) => t.trim().isNotEmpty)
              .toList();
          if (texts.isEmpty) {
            lastError = 'Gemini response text is empty.';
            continue;
          }

          return texts.join('\n').trim();
        }

        final err = body['error'];
        final errMsg = err is Map<String, dynamic> ? '${err['message']}' : response.body;
        lastError = '[$version/$model] $errMsg';
      }
    }

    throw Exception('Gemini request failed: ${lastError ?? 'Unknown error'}');
  }
}
