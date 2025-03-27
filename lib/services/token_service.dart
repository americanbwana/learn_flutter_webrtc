import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/livekit_connection_details.dart';

/// Service for generating LiveKit tokens from a custom token server
class TokenService {
  // Get server URL and room name from .env file
  static String get _tokenServerUrl => dotenv.env['TOKEN_SERVER_URL'] ?? '';
  static String get _roomName => dotenv.env['LIVEKIT_ROOM_NAME'] ?? 'test-room';

  // Get optional API key from .env file
  static String get _apiKey => dotenv.env['APP_API_KEY'] ?? '';

  /// Generates a random participant name
  static String generateParticipantName() {
    final uuid = const Uuid().v4().substring(0, 8);
    return 'user-$uuid';
  }

  /// Gets connection details from the custom token server
  Future<LivekitConnectionDetails> getConnectionDetails({
    String? participantName,
  }) async {
    // Validate required environment variables
    if (_tokenServerUrl.isEmpty) {
      throw Exception('TOKEN_SERVER_URL is not defined in .env file');
    }

    final name = participantName ?? generateParticipantName();

    print('Requesting token for room: $_roomName and participant: $name');
    print('Using token server at: $_tokenServerUrl');

    try {
      // Set up headers with optional API key
      final headers = {'Content-Type': 'application/json'};

      // Add API key header if specified
      if (_apiKey.isNotEmpty) {
        headers['x-api-key'] = _apiKey;
      }

      final response = await http.post(
        Uri.parse('$_tokenServerUrl/token'),
        headers: headers,
        body: jsonEncode({'roomName': _roomName, 'participantName': name}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        print('Token server response received');

        // Check that we have all required fields
        if (data['url'] == null ||
            data['token'] == null ||
            data['roomName'] == null ||
            data['participantName'] == null) {
          throw Exception(
            'Invalid response from token server: Missing required fields\nReceived: ${data.keys.join(', ')}',
          );
        }

        return LivekitConnectionDetails(
          url: data['url'],
          token: data['token'],
          roomName: data['roomName'],
          participantName: data['participantName'],
        );
      } else {
        throw Exception(
          'Failed to get token: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Error getting token: $e');
      rethrow;
    }
  }
}

/// Provider for token service
final tokenServiceProvider = Provider<TokenService>((ref) => TokenService());

/// Provider that exposes connection details
final connectionDetailsProvider = FutureProvider<LivekitConnectionDetails>((
  ref,
) async {
  final tokenService = ref.watch(tokenServiceProvider);
  return await tokenService.getConnectionDetails();
});
