import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/livekit_provider.dart';
import '../models/room_config.dart';

class VideoRoomScreen extends ConsumerStatefulWidget {
  final String livekitUrl;
  final String roomName;
  final String participantName;
  final String token;

  const VideoRoomScreen({
    super.key,
    required this.livekitUrl,
    required this.roomName,
    required this.participantName,
    required this.token,
  });

  @override
  ConsumerState<VideoRoomScreen> createState() => _VideoRoomScreenState();
}

class _VideoRoomScreenState extends ConsumerState<VideoRoomScreen> {
  @override
  Widget build(BuildContext context) {
    // Watch our connection status to rebuild when it changes
    final connectionStatus = ref.watch(connectionStatusProvider);
    // Watch for any error messages
    final errorMessage = ref.watch(errorMessageProvider);

    return Scaffold(
      appBar: AppBar(
        // Show different titles based on connection status
        title: Text(_getTitleForStatus(connectionStatus)),
        actions: [
          // Show connect/disconnect button based on status
          _buildConnectionButton(connectionStatus),
        ],
      ),
      body: Column(
        children: [
          // Show any error messages at the top
          if (errorMessage != null)
            Container(
              color: Colors.red.shade100,
              padding: const EdgeInsets.all(8),
              width: double.infinity,
              child: Text(
                'Error: $errorMessage',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          // Show different content based on connection status
          Expanded(child: _buildContentForStatus(connectionStatus)),
        ],
      ),
    );
  }

  /// Returns the appropriate title based on connection status
  String _getTitleForStatus(LiveKitConnectionStatus status) {
    switch (status) {
      case LiveKitConnectionStatus.disconnected:
        return 'Disconnected';
      case LiveKitConnectionStatus.connecting:
        return 'Connecting...';
      case LiveKitConnectionStatus.connected:
        return 'Connected';
      case LiveKitConnectionStatus.error:
        return 'Connection Error';
    }
  }

  /// Builds the connect/disconnect button based on current status
  Widget _buildConnectionButton(LiveKitConnectionStatus status) {
    // If we're connecting, show a disabled button
    if (status == LiveKitConnectionStatus.connecting) {
      return const IconButton(
        onPressed: null,
        icon: Icon(Icons.hourglass_bottom),
      );
    }

    // If we're connected, show disconnect button
    if (status == LiveKitConnectionStatus.connected) {
      return IconButton(
        onPressed: () {
          // Get our LiveKit notifier and disconnect
          ref.read(liveKitProvider.notifier).disconnect();
        },
        icon: const Icon(Icons.link_off),
      );
    }

    // Otherwise, show connect button
    return IconButton(
      onPressed: () {
        final config = RoomConfig(
          url: widget.livekitUrl,
          token: widget.token,
          roomName: widget.roomName,
          userName: widget.participantName,
        );

        ref.read(liveKitProvider.notifier).connectToRoom(config);
      },
      icon: const Icon(Icons.link),
    );
  }

  /// Builds the main content area based on connection status
  Widget _buildContentForStatus(LiveKitConnectionStatus status) {
    switch (status) {
      case LiveKitConnectionStatus.disconnected:
        return const Center(child: Text('Not connected to any room'));
      case LiveKitConnectionStatus.connecting:
        return const Center(child: CircularProgressIndicator());
      case LiveKitConnectionStatus.connected:
        return const Center(child: Text('Connected to room!'));
      case LiveKitConnectionStatus.error:
        return const Center(child: Text('An error occurred'));
    }
  }
}
