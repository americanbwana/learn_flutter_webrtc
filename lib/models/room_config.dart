import 'package:freezed_annotation/freezed_annotation.dart';

part 'room_config.freezed.dart';
part 'room_config.g.dart';

/// Configuration for connecting to a LiveKit room
@freezed
class RoomConfig with _$RoomConfig {
  const factory RoomConfig({
    /// The LiveKit server URL (e.g., 'wss://my-livekit-server.com')
    required String url,

    /// Authentication token from LiveKit
    required String token,

    /// Name of the room to join
    required String roomName,

    /// Display name for the participant
    @Default('anonymous') String userName,
  }) = _RoomConfig;

  factory RoomConfig.fromJson(Map<String, dynamic> json) =>
      _$RoomConfigFromJson(json);
}
