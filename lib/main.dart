import 'dart:io'; // Used to override HTTP client behavior for development
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Loads environment variables from .env file
import 'package:flutter_riverpod/flutter_riverpod.dart'; // State management library
import 'screens/video_room_screen.dart'; // The main screen for the video room

/// Overrides the default HTTP client to allow insecure connections (for development only)
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

/// The main entry point of the application
Future<void> main() async {
  // Allow insecure connections (for development only)
  HttpOverrides.global = MyHttpOverrides();

  try {
    // Load environment variables from the .env file
    await dotenv.load(fileName: ".env");
    print("Environment variables loaded successfully.");
  } catch (e) {
    print("Failed to load environment variables: $e");
  }

  // Start the app and wrap it in a ProviderScope for state management
  runApp(const ProviderScope(child: MyApp()));
}

/// The root widget of the application
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Fetch values from the .env file
    final livekitUrl = dotenv.env['LIVEKIT_URL']!;
    final roomName = dotenv.env['LIVEKIT_ROOM_NAME']!;
    final participantName = dotenv.env['LIVEKIT_PARTICIPANT_NAME']!;
    final token = dotenv.env['LIVEKIT_TOKEN']!;

    return MaterialApp(
      title: 'LiveKit Chat',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: VideoRoomScreen(
        livekitUrl: livekitUrl,
        roomName: roomName,
        participantName: participantName,
        token: token,
      ),
    );
  }
}
