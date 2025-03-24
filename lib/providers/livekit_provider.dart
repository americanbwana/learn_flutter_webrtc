import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:livekit_client/livekit_client.dart';
import '../models/room_config.dart';

/// Connection states for LiveKit
enum LiveKitConnectionStatus { disconnected, connecting, connected, error }

/// Holds the current state of LiveKit connection
class LiveKitState {
  const LiveKitState({
    this.room,
    this.status = LiveKitConnectionStatus.disconnected,
    this.errorMessage,
  });

  final Room? room;
  final LiveKitConnectionStatus status;
  final String? errorMessage;

  LiveKitState copyWith({
    Room? room,
    LiveKitConnectionStatus? status,
    String? errorMessage,
  }) {
    return LiveKitState(
      room: room ?? this.room,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Manages LiveKit room connection and state
class LiveKitNotifier extends StateNotifier<LiveKitState> {
  LiveKitNotifier() : super(const LiveKitState());

  Future<bool> connectToRoom(RoomConfig config) async {
    try {
      state = state.copyWith(status: LiveKitConnectionStatus.connecting);

      final room = Room();

      // Verified current properties from LiveKit documentation
      await room.connect(
        config.url,
        config.token,
        connectOptions: const ConnectOptions(autoSubscribe: true),
      );

      state = state.copyWith(
        room: room,
        status: LiveKitConnectionStatus.connected,
        errorMessage: null,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        status: LiveKitConnectionStatus.error,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<void> disconnect() async {
    try {
      await state.room?.disconnect();
    } finally {
      state = const LiveKitState();
    }
  }
}

/// Provider for LiveKit state management
final liveKitProvider = StateNotifierProvider<LiveKitNotifier, LiveKitState>((
  ref,
) {
  return LiveKitNotifier();
});

/// Provider for connection status
final connectionStatusProvider = Provider<LiveKitConnectionStatus>((ref) {
  return ref.watch(liveKitProvider).status;
});

/// Provider for error messages
final errorMessageProvider = Provider<String?>((ref) {
  return ref.watch(liveKitProvider).errorMessage;
});
