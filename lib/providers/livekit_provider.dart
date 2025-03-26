import 'dart:typed_data'; // Required for Uint8List
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:livekit_client/livekit_client.dart';
import '../models/room_config.dart';
import '../providers/message_provider.dart';

/// Connection states for LiveKit
enum LiveKitConnectionStatus { disconnected, connecting, connected, error }

/// Holds the current state of the LiveKit connection
class LiveKitState {
  const LiveKitState({
    this.room,
    this.status = LiveKitConnectionStatus.disconnected,
    this.errorMessage,
  });

  final Room? room;
  final LiveKitConnectionStatus status;
  final String? errorMessage;

  /// Creates a copy of the current state with updated values
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

/// Manages the LiveKit connection and state
class LiveKitNotifier extends StateNotifier<LiveKitState> {
  final Ref ref;

  LiveKitNotifier(this.ref) : super(const LiveKitState());

  /// Connects to a LiveKit room using the provided configuration
  Future<bool> connectToRoom(RoomConfig config) async {
    try {
      state = state.copyWith(status: LiveKitConnectionStatus.connecting);

      final room = Room();

      // Set up event listeners
      EventsListener<RoomEvent> listener = room.createListener();

      // Listen for data messages
      listener.on<DataReceivedEvent>((event) => _handleDataReceived(event));

      // Listen for room events
      listener.on<RoomDisconnectedEvent>((event) => _handleDisconnect());

      // Listen for participant events
      listener.on<ParticipantConnectedEvent>(
        (event) => _handleParticipantConnected(event),
      );
      listener.on<ParticipantDisconnectedEvent>(
        (event) => _handleParticipantDisconnected(event),
      );

      await room.connect(
        config.url,
        config.token,
        connectOptions: const ConnectOptions(autoSubscribe: true),
      );

      state = state.copyWith(
        room: room,
        status: LiveKitConnectionStatus.connected,
      );

      return true;
    } catch (e) {
      print('Failed to connect to room: $e');
      state = state.copyWith(
        status: LiveKitConnectionStatus.error,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// Handles received data messages
  void _handleDataReceived(DataReceivedEvent event) {
    try {
      // Convert data to string
      final message = String.fromCharCodes(event.data);
      final sender = event.participant?.identity ?? "Unknown";

      print('Received data: $message from $sender');

      // Update the message provider with the received message
      final messageText = "$sender: $message";
      ref.read(messagesProvider.notifier).addMessage(messageText);
    } catch (e) {
      print('Error processing received data: $e');
    }
  }

  /// Handles room disconnect events
  void _handleDisconnect() {
    print('Room disconnected');
    state = const LiveKitState();
  }

  /// Handles participant connected events
  void _handleParticipantConnected(ParticipantConnectedEvent event) {
    print('Participant connected: ${event.participant.identity}');
  }

  /// Handles participant disconnected events
  void _handleParticipantDisconnected(ParticipantDisconnectedEvent event) {
    print('Participant disconnected: ${event.participant.identity}');
  }

  /// Sends data to the LiveKit room via the data channel
  Future<void> sendDataToRoom(String message) async {
    try {
      print('Sending message: $message');
      await state.room?.localParticipant?.publishData(message.codeUnits);
    } catch (e) {
      print('Failed to send data: $e');
    }
  }

  /// Disconnects from the LiveKit room
  Future<void> disconnect() async {
    try {
      final room = state.room;
      if (room != null) {
        await room.disconnect();
      }
    } catch (e) {
      print('Error during disconnect: $e');
    } finally {
      state = const LiveKitState();
    }
  }
}

/// Provides the current LiveKit state
final liveKitProvider = StateNotifierProvider<LiveKitNotifier, LiveKitState>(
  (ref) => LiveKitNotifier(ref),
);

/// Provides the current connection status
final connectionStatusProvider = Provider<LiveKitConnectionStatus>(
  (ref) => ref.watch(liveKitProvider).status,
);

/// Provides the current error message
final errorMessageProvider = Provider<String?>(
  (ref) => ref.watch(liveKitProvider).errorMessage,
);
