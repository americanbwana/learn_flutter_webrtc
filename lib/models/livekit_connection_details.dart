import 'package:freezed_annotation/freezed_annotation.dart';

// part 'livekit_connection_details.freezed.dart';
// part 'livekit_connection_details.g.dart';

/// Holds connection details returned from the LiveKit API
class LivekitConnectionDetails {
  /// The LiveKit server URL
  final String url;
  
  /// Authentication token for connecting to the room
  final String token;
  
  /// Name of the room to join
  final String roomName;
  
  /// Display name for the participant
  final String participantName;

  const LivekitConnectionDetails({
    required this.url,
    required this.token,
    required this.roomName,
    required this.participantName,
  });

  /// Creates a LivekitConnectionDetails from JSON
  factory LivekitConnectionDetails.fromJson(Map<String, dynamic> json) {
    return LivekitConnectionDetails(
      // Map API response field names to our model property names
      url: json['serverUrl'] ?? '',
      token: json['participantToken'] ?? '',
      roomName: json['roomName'] ?? '',
      participantName: json['participantName'] ?? '',
    );
  }

  /// Creates a copy of this LivekitConnectionDetails with specified fields replaced
  LivekitConnectionDetails copyWith({
    String? url,
    String? token,
    String? roomName,
    String? participantName,
  }) {
    return LivekitConnectionDetails(
      url: url ?? this.url,
      token: token ?? this.token,
      roomName: roomName ?? this.roomName,
      participantName: participantName ?? this.participantName,
    );
  }

  /// Converts this object to a map for JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'token': token,
      'roomName': roomName,
      'participantName': participantName,
    };
  }

  @override
  String toString() {
    return 'LivekitConnectionDetails(url: $url, token: *****, roomName: $roomName, participantName: $participantName)';
  }
}