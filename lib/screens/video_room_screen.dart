import 'package:flutter/material.dart'; // Provides UI components
import 'package:flutter_riverpod/flutter_riverpod.dart'; // State management library
import '../providers/livekit_provider.dart'; // Manages LiveKit connection and state
import '../providers/message_provider.dart'; // Manages messages sent and received in the room
import '../models/room_config.dart'; // Configuration for connecting to a LiveKit room

/// The main screen for the LiveKit video room.
/// This screen allows users to connect to a room, send/receive messages, and view the connection status.
class VideoRoomScreen extends ConsumerStatefulWidget {
  final String livekitUrl; // The URL of the LiveKit server
  final String roomName; // The name of the room to join
  final String participantName; // The name of the participant
  final String token; // The JWT token for authentication

  /// Constructor for the VideoRoomScreen.
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

/// The state for the VideoRoomScreen.
/// Manages the UI and interactions for the video room.
class _VideoRoomScreenState extends ConsumerState<VideoRoomScreen> {
  final TextEditingController _messageController =
      TextEditingController(); // Controller for the message input field
  final ScrollController _scrollController =
      ScrollController(); // Controller for the scrolling message list

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Sends a message via the LiveKit data channel.
  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      // Send the message via the data channel
      ref.read(liveKitProvider.notifier).sendDataToRoom(message);

      // Add the message to the local messages list
      ref.read(messagesProvider.notifier).addMessage("You: $message");

      // Clear the input field
      _messageController.clear();

      // Scroll to the bottom
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final connectionStatus = ref.watch(
      connectionStatusProvider,
    ); // Watches the connection status
    final errorMessage = ref.watch(
      errorMessageProvider,
    ); // Watches for error messages

    // Listen for changes to the list of messages to scroll to bottom
    ref.listen<List<String>>(messagesProvider, (previous, current) {
      if (current.isNotEmpty &&
          (previous == null || current.length > previous.length)) {
        // A new message was added, scroll to the bottom after the UI updates
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _getTitleForStatus(connectionStatus),
        ), // Displays the connection status
        actions: [
          _buildConnectionButton(
            connectionStatus,
          ), // Displays the connect/disconnect button
        ],
      ),
      body: Column(
        children: [
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
          Expanded(
            child: Consumer(
              builder: (context, ref, _) {
                final messages = ref.watch(
                  messagesProvider,
                ); // Watch the messages list

                if (messages.isEmpty) {
                  return const Center(
                    child: Text('No messages yet. Start a conversation!'),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 8,
                      ),
                      child: Text(messages[index]),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: "Enter your message",
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _sendMessage,
                  child: const Text("Send"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Returns the appropriate title based on the connection status.
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

  /// Builds the connect/disconnect button based on the connection status.
  Widget _buildConnectionButton(LiveKitConnectionStatus status) {
    if (status == LiveKitConnectionStatus.connecting) {
      return const IconButton(
        onPressed: null,
        icon: Icon(Icons.hourglass_bottom),
      );
    }

    if (status == LiveKitConnectionStatus.connected) {
      return IconButton(
        onPressed: () {
          ref.read(liveKitProvider.notifier).disconnect();
        },
        icon: const Icon(Icons.link_off),
      );
    }

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
}
