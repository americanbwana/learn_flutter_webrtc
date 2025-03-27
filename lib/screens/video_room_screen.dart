import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/livekit_provider.dart';
import '../providers/message_provider.dart';
import '../models/room_config.dart';
import '../services/token_service.dart';
import '../models/livekit_connection_details.dart';

class VideoRoomScreen extends ConsumerStatefulWidget {
  // Remove parameters since we'll get them from the token service
  const VideoRoomScreen({super.key});

  @override
  ConsumerState<VideoRoomScreen> createState() => _VideoRoomScreenState();
}

class _VideoRoomScreenState extends ConsumerState<VideoRoomScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Sends a message via the LiveKit data channel
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
    final connectionStatus = ref.watch(connectionStatusProvider);
    final errorMessage = ref.watch(errorMessageProvider);
    final connectionDetailsAsync = ref.watch(connectionDetailsProvider);

    // Listen for changes to the messages list to scroll to bottom
    ref.listen<List<String>>(messagesProvider, (previous, current) {
      if (current.isNotEmpty &&
          (previous == null || current.length > previous.length)) {
        // A new message was added, scroll to bottom after frame is rendered
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
        title: Text(_getTitleForStatus(connectionStatus)),
        actions: [
          connectionDetailsAsync.when(
            data:
                (details) => _buildConnectionButton(connectionStatus, details),
            loading: () => const CircularProgressIndicator(),
            error:
                (error, _) => Tooltip(
                  message: 'Error: $error',
                  child: const Icon(Icons.error_outline, color: Colors.red),
                ),
          ),
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
          connectionDetailsAsync.when(
            data: (_) => _buildChatInterface(),
            loading:
                () => const Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Fetching connection details...'),
                      ],
                    ),
                  ),
                ),
            error:
                (error, _) => Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Failed to get connection details: $error',
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatInterface() {
    final connectionDetailsAsync = ref.watch(connectionDetailsProvider);

    return Expanded(
      child: Column(
        children: [
          // Connection info header
          connectionDetailsAsync.when(
            data: (details) => _buildConnectionInfoHeader(details),
            loading: () => Container(),
            error: (_, __) => Container(),
          ),

          // Messages list
          Expanded(
            child: Consumer(
              builder: (context, ref, _) {
                final messages = ref.watch(messagesProvider);

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

          // Message input area
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

  Widget _buildConnectionInfoHeader(LivekitConnectionDetails details) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.blue.shade100,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Room: ${details.roomName}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text('Connected as: ${details.participantName}'),
        ],
      ),
    );
  }

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

  Widget _buildConnectionButton(
    LiveKitConnectionStatus status,
    LivekitConnectionDetails details,
  ) {
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
          url: details.url,
          token: details.token,
          roomName: details.roomName,
          userName: details.participantName,
        );

        ref.read(liveKitProvider.notifier).connectToRoom(config);
      },
      icon: const Icon(Icons.link),
    );
  }
}
