import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/livekit_provider.dart';
import '../providers/message_provider.dart';
import '../models/room_config.dart';
import '../services/token_service.dart';
import '../models/livekit_connection_details.dart';
import '../widgets/frequency_control.dart'; // Import the new widget

/// The main screen for the video room and radio control interface
///
/// This screen handles:
/// 1. Connection to the LiveKit room
/// 2. Sending/receiving messages via the data channel
/// 3. Radio frequency control via CAT commands
class VideoRoomScreen extends ConsumerStatefulWidget {
  const VideoRoomScreen({super.key});

  @override
  ConsumerState<VideoRoomScreen> createState() => _VideoRoomScreenState();
}

class _VideoRoomScreenState extends ConsumerState<VideoRoomScreen> {
  /// Controller for the message input text field
  final TextEditingController _messageController = TextEditingController();

  /// Controller for the message list scrolling
  final ScrollController _scrollController = ScrollController();

  /// The last received or sent frequency command
  String _lastFrequencyCommand = 'FA00014050000;';

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Sends a message via the LiveKit data channel
  ///
  /// This method:
  /// 1. Checks if the message is not empty
  /// 2. Sends it via the data channel
  /// 3. Adds it to the local messages list
  /// 4. Clears the input field
  /// 5. Scrolls the message list to the bottom
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
      _scrollToBottom();

      // Check if this is a frequency command and update the local state
      if (message.startsWith('FA') && message.endsWith(';')) {
        setState(() {
          _lastFrequencyCommand = message;
        });
      }
    }
  }

  /// Sends a frequency command via the data channel
  ///
  /// This is a specialized version of _sendMessage for frequency commands
  /// [command] The FA command to send (e.g., "FA00014050000;")
  void _sendFrequencyCommand(String command) {
    // Only process valid FA commands
    if (command.startsWith('FA') && command.endsWith(';')) {
      // Send the command via the data channel
      ref.read(liveKitProvider.notifier).sendDataToRoom(command);

      // Add the command to the local messages list with a user-friendly format
      final formattedMsg = _formatFrequencyForDisplay(command);
      ref
          .read(messagesProvider.notifier)
          .addMessage("You set frequency: $formattedMsg");

      // Update the local state
      setState(() {
        _lastFrequencyCommand = command;
      });
    }
  }

  /// Converts an FA command to a human-readable frequency string
  ///
  /// [command] An FA command (e.g., "FA00014050000;")
  /// Returns a formatted string (e.g., "14.050.000 MHz")
  String _formatFrequencyForDisplay(String command) {
    if (command.startsWith('FA') && command.endsWith(';')) {
      final numericPart = command.substring(2, command.length - 1);
      try {
        final frequency = int.parse(numericPart);
        final mhz = (frequency / 1000000).floor();
        final khz = ((frequency % 1000000) / 1000).floor();
        final hz = frequency % 1000;

        return '$mhz.${khz.toString().padLeft(3, '0')}.${hz.toString().padLeft(3, '0')} MHz';
      } catch (e) {
        return command;
      }
    }
    return command;
  }

  /// Scrolls the message list to the bottom
  void _scrollToBottom() {
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

  @override
  Widget build(BuildContext context) {
    final connectionStatus = ref.watch(connectionStatusProvider);
    final errorMessage = ref.watch(errorMessageProvider);
    final connectionDetailsAsync = ref.watch(connectionDetailsProvider);

    // Listen for changes to the messages list to scroll to bottom
    ref.listen<List<String>>(messagesProvider, (previous, current) {
      if (current.isNotEmpty &&
          (previous == null || current.length > previous.length)) {
        _scrollToBottom();
      }
    });

    // Listen for incoming messages that might contain frequency commands
    ref.listen<List<String>>(messagesProvider, (previous, next) {
      if (next.isNotEmpty &&
          previous != null &&
          next.length > previous.length) {
        // Get the latest message
        final latestMessage = next.last;

        // If it's a received message (not from us) and it's a frequency command
        if (!latestMessage.startsWith("You:") &&
            latestMessage.contains("FA") &&
            latestMessage.contains(";")) {
          // Extract the FA command - this is a simple approach that assumes the command is well-formed
          final commandStart = latestMessage.indexOf("FA");
          final commandEnd = latestMessage.indexOf(";", commandStart) + 1;

          if (commandStart >= 0 && commandEnd > commandStart) {
            final command = latestMessage.substring(commandStart, commandEnd);
            setState(() {
              _lastFrequencyCommand = command;
            });
          }
        }
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
            data: (_) => _buildMainInterface(),
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

  /// Builds the main interface with the frequency control and message input
  Widget _buildMainInterface() {
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

          // Frequency control section
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: FrequencyControl(
                initialValue: _lastFrequencyCommand,
                onFrequencyChanged: _sendFrequencyCommand,
              ),
            ),
          ),

          // Message log toggle - shows a condensed view of the message history
          ExpansionTile(
            title: const Text('Message Log'),
            children: [
              SizedBox(
                height: 150,
                child: Consumer(
                  builder: (context, ref, _) {
                    final messages = ref.watch(messagesProvider);

                    if (messages.isEmpty) {
                      return const Center(child: Text('No messages yet.'));
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
            ],
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
                      hintText: "Enter command or message",
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

  /// Builds the connection info header showing room and user details
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

  /// Builds the appropriate connection button based on current status
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
