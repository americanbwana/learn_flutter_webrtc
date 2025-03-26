import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Manages the list of messages sent and received in the room
class MessagesNotifier extends StateNotifier<List<String>> {
  MessagesNotifier() : super([]);

  /// Adds a new message to the list
  void addMessage(String message) {
    print('Adding message to state: $message');
    state = [...state, message];
  }

  /// Clears all messages
  void clearMessages() {
    state = [];
  }
}

/// Provider that exposes the list of messages
final messagesProvider = StateNotifierProvider<MessagesNotifier, List<String>>(
  (ref) => MessagesNotifier(),
);
