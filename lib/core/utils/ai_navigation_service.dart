// lib/core/utils/ai_navigation_service.dart
//
// This is the heart of EasyRoute's intelligence:
// it takes raw Google Maps instruction data and transforms it
// into warm, landmark-based, conversational guidance.

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import '../../domain/entities/route_entity.dart';

class AiNavigationService {
  // ── Prompt Engineering ─────────────────────────────────────────────────
  // We send structured route data to Claude and ask for human-friendly
  // instructions that anyone — regardless of map literacy — can follow.

  static const _systemPrompt = '''
You are EasyRoute's navigation assistant. Your job is to convert technical 
navigation instructions into simple, warm, conversational guidance that 
anyone can follow — especially people who struggle with maps, compass 
directions, or left/right orientation.

Rules:
1. Use landmarks instead of compass directions when possible
   - BAD: "Head northwest on MG Road"
   - GOOD: "Walk straight along the main road with the mall on your left"

2. Use simple distance descriptions
   - BAD: "In 420 meters"
   - GOOD: "Walk for about 5 minutes" or "Walk about 4 blocks"

3. For turns, add helpful context
   - BAD: "Turn right"
   - GOOD: "Turn right at the traffic light — you'll see a pharmacy on the corner"

4. For public transport, be very specific and reassuring
   - BAD: "Board Bus 42"
   - GOOD: "Wait at the bus stop ahead for Bus 42. It's a blue bus. Board from the front door and tell the conductor you're going to City Center."

5. For alighting: count stops and give landmarks
   - GOOD: "Stay on the bus for 3 stops — about 10 minutes. Get off when you see the large park on your right."

6. Keep a calm, encouraging tone. Users may be anxious.

Respond ONLY with a JSON object with this shape:
{
  "steps": [
    {
      "original": "original instruction text",
      "friendly": "your friendly version",
      "type": "walk|transit_board|transit_ride|transit_alight|arrive",
      "emoji": "relevant emoji"
    }
  ],
  "summary": "one-sentence friendly summary of the whole journey"
}
''';

  /// Transforms a list of raw step instructions into friendly ones.
  static Future<AiNavigationResult> transformRoute({
    required String originName,
    required String destinationName,
    required List<Map<String, dynamic>> rawSteps,
    required int totalMinutes,
  }) async {
    // Build a compact payload for the AI
    final stepsText = rawSteps
        .map((s) => '- ${s['instruction']} (${s['distance']}, ${s['duration']})')
        .join('\n');

    final userMessage = '''
Transform these navigation steps into friendly instructions.

Journey: From "$originName" to "$destinationName"
Total time: $totalMinutes minutes

Raw steps:
$stepsText

Remember to use landmarks, simple language, and a reassuring tone.
''';

    const geminiKey = String.fromEnvironment('GEMINI_API_KEY');

    try {
      final response = await http.post(
        Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/gemma-3-27b-it:generateContent?key=$geminiKey',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': '$_systemPrompt\n\n$userMessage'}
              ]
            }
          ],
          'generationConfig': {
            'maxOutputTokens': 2000,
            'temperature': 0.3,
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates'][0]['content']['parts'][0]['text'] as String;
        final json = jsonDecode(text) as Map<String, dynamic>;

        return AiNavigationResult.fromJson(json);
      } else {
        // Fallback to rule-based transformation if AI fails
        return _fallbackTransform(rawSteps, originName, destinationName);
      }
    } catch (e) {
      return _fallbackTransform(rawSteps, originName, destinationName);
    }
  }

  /// Rule-based fallback when AI is unavailable (offline, etc.)
  static AiNavigationResult _fallbackTransform(
    List<Map<String, dynamic>> rawSteps,
    String origin,
    String destination,
  ) {
    final steps = rawSteps.map((step) {
      final instruction = step['instruction'] as String;
      final distance = step['distance'] as String? ?? '';
      final type = _detectStepType(instruction);

      return AiStep(
        original: instruction,
        friendly: _humanizeInstruction(instruction, distance),
        type: type,
        emoji: _emojiForType(type),
      );
    }).toList();

    return AiNavigationResult(
      steps: steps,
      summary: 'Head from $origin to $destination.',
    );
  }

  static String _humanizeInstruction(String raw, String distance) {
    var result = raw
        .replaceAll('Head ', 'Walk ')
        .replaceAll('northwest', 'forward')
        .replaceAll('northeast', 'forward')
        .replaceAll('southwest', 'forward')
        .replaceAll('southeast', 'forward')
        .replaceAll('north', 'forward')
        .replaceAll('south', 'forward')
        .replaceAll('east', 'forward')
        .replaceAll('west', 'forward');

    // Convert distance to time
    if (distance.isNotEmpty) {
      result = '$result — about $distance';
    }

    return result;
  }

  static String _detectStepType(String instruction) {
    final lower = instruction.toLowerCase();
    if (lower.contains('board') || lower.contains('take the')) return 'transit_board';
    if (lower.contains('get off') || lower.contains('exit')) return 'transit_alight';
    if (lower.contains('arrive') || lower.contains('destination')) return 'arrive';
    if (lower.contains('bus') || lower.contains('metro') || lower.contains('train')) {
      return 'transit_ride';
    }
    return 'walk';
  }

  static String _emojiForType(String type) {
    switch (type) {
      case 'transit_board': return '🚌';
      case 'transit_ride': return '🪑';
      case 'transit_alight': return '🚶';
      case 'arrive': return '📍';
      default: return '👣';
    }
  }

  /// Generate a voice-friendly version of a single step
  /// (shorter, suited for text-to-speech)
  static Future<String> generateVoiceStep(String friendlyInstruction) async {
    // Strip emojis for TTS
    final cleaned = friendlyInstruction
        .replaceAll(RegExp(r'[^\x00-\x7F]'), '')
        .trim();
    return cleaned;
  }
}

class AiNavigationResult {
  final List<AiStep> steps;
  final String summary;

  AiNavigationResult({required this.steps, required this.summary});

  factory AiNavigationResult.fromJson(Map<String, dynamic> json) {
    final stepsList = (json['steps'] as List)
        .map((s) => AiStep.fromJson(s as Map<String, dynamic>))
        .toList();
    return AiNavigationResult(
      steps: stepsList,
      summary: json['summary'] as String? ?? '',
    );
  }
}

class AiStep {
  final String original;
  final String friendly;
  final String type;
  final String emoji;

  AiStep({
    required this.original,
    required this.friendly,
    required this.type,
    required this.emoji,
  });

  factory AiStep.fromJson(Map<String, dynamic> json) => AiStep(
        original: json['original'] as String? ?? '',
        friendly: json['friendly'] as String? ?? '',
        type: json['type'] as String? ?? 'walk',
        emoji: json['emoji'] as String? ?? '👣',
      );
}
